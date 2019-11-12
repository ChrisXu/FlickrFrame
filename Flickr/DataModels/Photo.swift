import UIKit

struct Photo {
    
    enum CodingKeys: String, CodingKey {
        case secret, farm, server
        case identifier = "id"
    }
    
    let identifier: String
    
    let secret: String
    
    let farm: Int
    
    let server: String
}

extension Photo: Codable { }

extension Photo: Equatable { }
