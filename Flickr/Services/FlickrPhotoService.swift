import Foundation

class FlickrPhotoService {
    
    enum Error: Swift.Error {
        case invalid(String)
        case notFound(String)
        case unauthorized(String)
    }
    
    let session: URLSessionProtocol
    
    private let timeoutInterval: TimeInterval = 15
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    func fetchPhotos(with keywords: [String] = [], at page: Int = 1, complection: @escaping (Result<PhotoCollection, Swift.Error>) -> Void) {
        
        do {
            let url = try FlickrAPI.urlForSearch(keywords, page: page)
            
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeoutInterval)
            let task = session.dataTask(with: request) { (data, response, error) in
                
                do {
                    guard error == nil else {
                        throw error!
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw FlickrPhotoService.Error.invalid("Invalid API response \(String(describing: response))")
                    }
                    
                    try httpResponse.validated()
                    
                    guard let data = data else {
                        throw FlickrPhotoService.Error.notFound("data is missing")
                    }
                    
                    let collection = try JSONDecoder().decode(PhotoCollection.self, from: data)
                    complection(Result.success(collection))
                } catch {
                    complection(Result.failure(error))
                }        
            }
            task.resume()
            
        } catch {
            complection(Result.failure(error))
        }
    }
    
    typealias ImageData = Data
    
    @discardableResult
    func loadPhoto(at url: URL, completion: ((Result<ImageData, Swift.Error>) -> Void)?) -> URLSessionTaskProtocol? {
        
        let request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        
        let task = session.dataTask(with: request) { (data
            , response, error) in
            
            do {
                guard error == nil else {
                    throw error!
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw FlickrPhotoService.Error.invalid("Invalid API response \(String(describing: response))")
                }
                
                try httpResponse.validated()
                
                guard let data = data else {
                    throw FlickrPhotoService.Error.notFound("data is missing")
                }
                completion?(Result.success(data))
            } catch {
                completion?(Result.failure(error))
            }
        }
        task.resume()
        
        return task
    }
}

private extension HTTPURLResponse {
    
    func validated() throws {
        
        let statusCode = self.statusCode
        
        switch statusCode {
        case 200 ... 299:
            // 2xx (Successful): The request was successfully received, understood, and accepted
            return
        case 400:
            throw FlickrPhotoService.Error.invalid("\(statusCode) - Bad Request")
        case 401:
            throw FlickrPhotoService.Error.unauthorized("\(statusCode) - Unauthorized")
        case 402 ... 499:
            // The request contains bad syntax or cannot be fulfilled
            throw FlickrPhotoService.Error.invalid("\(statusCode) - General client error")
        case 500 ... 599:
            // 5xx (Server Error): The server failed to fulfill an apparently valid request
            throw FlickrPhotoService.Error.invalid("\(statusCode) - General server error")
        default:
            // 1xx (Informational): The request was received, continuing process
            // 3xx (Redirection): Further action needs to be taken in order to complete the request
            throw FlickrPhotoService.Error.invalid("\(statusCode) - Undefined statusCode") 
        }
    }
}
