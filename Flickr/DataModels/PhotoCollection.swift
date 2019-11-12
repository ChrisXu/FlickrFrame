import Foundation

struct PhotoCollection {
    
    enum CodingKeys: String, CodingKey {
        case photos
    }
    
    enum CollectionKeys: String, CodingKey {
        case page
        case numberOfPhotosPerPage = "perpage"
        case totalPages = "pages"
        case photos = "photo"
    }
    
    let page: Int
    
    let numberOfPhotosPerPage: Int
    
    let totalPages: Int
    
    let photos: [Photo]
}

extension PhotoCollection: Codable {
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let collection = try values.nestedContainer(keyedBy: CollectionKeys.self, forKey: .photos)
        self.page = try collection.decode(Int.self, forKey: .page)
        self.numberOfPhotosPerPage = try collection.decode(Int.self, forKey: .numberOfPhotosPerPage)
        
        self.totalPages = try collection.decode(Int.self, forKey: .totalPages)
        
        self.photos = try collection.decode([Photo].self, forKey: .photos)
    }
}

extension PhotoCollection: Equatable { }
