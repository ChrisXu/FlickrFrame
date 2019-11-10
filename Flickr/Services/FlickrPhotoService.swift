import Foundation

class FlickrPhotoService {
    
    enum Error: Swift.Error {
        case invalid(String)
        case notFound(String)
        case unauthorized(String)
    }
    
    private struct FlickrAPI {
        static let baseURL = "https://www.flickr.com"
        static let feeds = "/services/feeds/photos_public.gne"
    }
    
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func fetchPhotos(with keywords: [String] = [], complection: @escaping (Result<[Photo], Swift.Error>) -> Void) {
        
        do {
            guard var urlComponents = URLComponents(string: FlickrAPI.baseURL) else {
                throw FlickrPhotoService.Error.invalid("BaseURL is invalid")
            }
            
            urlComponents.path = FlickrAPI.feeds
            
            var items = [URLQueryItem]()
            let tags = keywords.joined(separator: ",")
            if !tags.isEmpty {
                items.append(URLQueryItem(name: "tags", value: tags))
            }
            items.append(URLQueryItem(name: "format", value: "json"))
            items.append(URLQueryItem(name: "nojsoncallback", value: "1"))
            urlComponents.queryItems = items
            
            guard let url = urlComponents.url else {
                throw FlickrPhotoService.Error.invalid("Cannot construct valid url")
            }
            
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 15)
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
                    
                    let object = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    
                    guard let json = object as? [String: Any] else {
                        throw FlickrPhotoService.Error.invalid("Invalid json")
                    }
                    
                    guard let items = json["items"] as? [[String: Any]] else {
                        throw FlickrPhotoService.Error.notFound("Cannot decode data - missing media")
                    }
                    
                    let photos = try items.map { try Photo(json: $0) }
                    complection(Result.success(photos))
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
    
    func loadPhoto(at url: URL, usingCache: Bool = true, completion: ((Result<ImageData, Swift.Error>) -> Void)?) -> URLSessionDataTask? {
        
        let cachePolicy: NSURLRequest.CachePolicy = usingCache ? .returnCacheDataElseLoad : .reloadIgnoringLocalCacheData
        let request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: 15)
        
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

private extension Photo {
    
    convenience init(json: [String: Any]) throws {
        
        guard let media = json["media"] as? [String: String] else {
            throw FlickrPhotoService.Error.notFound("Cannot decode data - missing media")
        }
        
        guard let firstURL = media.first?.value else {
            throw FlickrPhotoService.Error.notFound("Cannot decode data - missing photo URL")
        }
        
        guard let url = URL(string: firstURL) else {
            throw FlickrPhotoService.Error.invalid("Cannot decode data - \(firstURL) is invalid url")
        }
        
        self.init(url: url)
    }
}
