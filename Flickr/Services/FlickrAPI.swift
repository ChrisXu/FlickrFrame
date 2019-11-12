import Foundation

struct FlickrAPI {
    
    enum Method: String {
        case search = "flickr.photos.search"
        case getRecent = "flickr.photos.getRecent"
    }
    
    enum SizeType: String {
        case smallSquare = "q" // 150x150
        case thumbnail = "t"
        case medium = "z"
        case large = "h"
    }
    
    static let apiKey = "fca898bf757f5b5857c93712acbc3ba7"
    static let baseURL = "https://www.flickr.com"
    static let restAPI = "/services/rest"
    
    private static let requiredQueryItems: [URLQueryItem] = {
        var items = [URLQueryItem]()
        items.append(URLQueryItem(name: "api_key", value: apiKey))
        items.append(URLQueryItem(name: "format", value: "json"))
        items.append(URLQueryItem(name: "nojsoncallback", value: "1"))
        return items
    }()
    
    static func urlForSearch(_ keywords: [String], perPage: Int = 20, page: Int = 1) throws -> URL {
        
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw FlickrPhotoService.Error.invalid("Invalid baseURL \(baseURL)")
        }
        
        urlComponents.path = restAPI
        
        var items = requiredQueryItems
        let method = keywords.isEmpty ? Method.getRecent : Method.search
        items.append(URLQueryItem(name: "method", value: method.rawValue))
        items.append(URLQueryItem(name: "per_page", value: "\(perPage)"))
        items.append(URLQueryItem(name: "page", value: "\(page)"))
        
        let tags = keywords.joined(separator: ",")
        if !tags.isEmpty {
            items.append(URLQueryItem(name: "tags", value: tags))
        }
        urlComponents.queryItems = items
        
        guard let url = urlComponents.url else {
            throw FlickrPhotoService.Error.invalid("Cannot construct valid url")
        }
        
        return url
    }
    
    static func urlForPhoto(with identifier: String, farm: Int, server: String, secret: String, sizeType: SizeType) -> URL? {
        
        let fileName = [identifier, secret, sizeType.rawValue].joined(separator: "_") + ".jpg"
        let path = "/" + server + "/" + fileName
        let urlString = "https://farm\(farm).staticflickr.com" + path
        
        return URL(string: urlString)
    }
}
