import UIKit // because of UIImage

protocol PhotoListViewPresentable {
    
    var keywords: [String] { get }
    
    var isFetching: Bool { get }
    
    var hasMore: Bool { get }
    
    func numberOfPhotos() -> Int
    
    func setKeywords(_ keywords: [String])
    
    func loadMore(completion: @escaping (Swift.Error?) -> Void)
    
    func loadPhoto(at indexPath: IndexPath, completion: @escaping (UIImage?, Swift.Error?) -> Void)
    
    func cancelLoadingPhoto(at indexPath: IndexPath)
    
    func removeAllPhotos()
    
    func handleDidReceiveMemoryWarning()
}

class PhotoListViewModel: PhotoListViewPresentable {
    
    enum Error: Swift.Error {
        case invalid(String)
        case notFound(String)
        case noMoreData
    }
    
    /// A Boolean value that determines whether there are more photos
    var hasMore: Bool {
        return currentPage < totalPages
    }
    
    /// A Boolean value that determines whether if it's fetching the photos
    private(set) var isFetching: Bool = false
    
    /// A array of string for searching photos
    private(set) var keywords = [String]()
    
    private let servie: FlickrPhotoService
    private var photos = [Photo]()
    private var currentPage: Int = 1 // page starts from 1
    private var totalPages: Int = Int.max
    private var cache = NSCache<NSString, UIImage>()
    private var taskMapTable = [String: URLSessionTaskProtocol]()
    private var taskMapTableUpdatingQueue = DispatchQueue(label: "chrisxu.flickr.taskMapTableUpdatingQueue")
    
    init(urlSession: URLSessionProtocol) {
        servie = FlickrPhotoService(session: urlSession)
        cache.countLimit = 100
        cache.totalCostLimit = 500 * 1024 * 1024
    }
    
    func numberOfPhotos() -> Int {
        return photos.count
    }
    
    /// It sets new keywords for the photos
    /// It will clean out the fetched photos and rest the current page
    ///
    /// - Parameter keywords: [String]
    func setKeywords(_ keywords: [String]) {
        removeAllPhotos() // It needs to call first since it also resets keywords
        self.keywords = keywords.filter { !$0.isEmpty }
        currentPage = 1
        totalPages = Int.max
    }
    
    /// It loads more photos with the given keywords
    /// It will increase the nimber of current page by the times of 
    /// this function being called
    ///
    /// - Parameter completion: A callback when the operation is finished
    func loadMore(completion: @escaping (Swift.Error?) -> Void) {
        
        do {
            guard hasMore else {
                throw PhotoListViewModel.Error.noMoreData
            }
            
            isFetching = true
            servie.fetchPhotos(with: keywords, at: currentPage) { [weak self] result in
                guard let self = self else { return }
                
                self.isFetching = false
                switch result {
                case .success(let collection):
                    self.photos.append(contentsOf: collection.photos)
                    self.totalPages = collection.totalPages
                    self.currentPage = collection.page + 1
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        } catch {
            completion(error)
        }
    }
    
    /// It loads the image for the given indexPath
    ///
    /// - Parameters:
    ///   - indexPath: the indexPath to load the image
    ///   - completion: A callback when the operation is finished
    func loadPhoto(at indexPath: IndexPath, completion: @escaping (UIImage?, Swift.Error?) -> Void) {
        
        do {
            guard let photo = photo(at: indexPath) else {
                throw PhotoListViewModel.Error.notFound("Photo does not exist at \(indexPath)")
            }
            
            guard let url = photo.squareImageURL() else {
                throw PhotoListViewModel.Error.invalid("Photo URL is invalid") 
            }
            
            if let image = cache.object(forKey: url.absoluteString as NSString) {
                completion(image, nil)
                return
            }
            
            let task = servie.loadPhoto(at: url) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else {
                        completion(nil, PhotoListViewModel.Error.invalid("Invalid data as Image"))
                        return
                    }
                    self.cache.setObject(image, forKey: url.absoluteString as NSString, cost: data.count)
                    completion(image, nil)
                case .failure(let error):
                    completion(nil, error)
                }
                
                self.taskMapTableUpdatingQueue.sync {
                    self.taskMapTable[url.absoluteString] = nil
                }
            }
            
            if let task = task {
                taskMapTableUpdatingQueue.sync {
                    taskMapTable[url.absoluteString] = task
                }
            }
            
        } catch {
            completion(nil, error)
        }
    }
    
    /// It cancels the loading for the given indexPath
    ///
    /// - Parameter indexPath: the indexPath to be cancelled
    func cancelLoadingPhoto(at indexPath: IndexPath) {
        guard let photo = photo(at: indexPath) else {
            return
        }
        
        guard let url = photo.squareImageURL() else {
            return 
        }
        
        taskMapTableUpdatingQueue.sync {
            guard let task = taskMapTable[url.absoluteString] else {
                return
            }
            task.cancel()
            taskMapTable[url.absoluteString] = nil
        }
    }
    
    /// Calling this function will remove all fetched images and cache in the memory
    func removeAllPhotos() {
        photos.removeAll()
        cache.removeAllObjects()
    }
    
    /// It removes all cache in the memory when receiving memory warning
    func handleDidReceiveMemoryWarning() {
        cache.removeAllObjects()
    }
    
    // MARK: - Private method
    
    private func photo(at indexPath: IndexPath) -> Photo? {
        guard indexPath.row < photos.count else {
            return nil
        }
        return photos[indexPath.row]
    }
}

private extension Photo {
    
    func squareImageURL() -> URL? {
        return FlickrAPI.urlForPhoto(with: identifier, farm: farm, server: server, secret: secret, sizeType: .smallSquare)
    }
}
