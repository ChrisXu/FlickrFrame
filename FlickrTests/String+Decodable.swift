import Foundation

extension String {
    
    func decodedObject<T: Decodable>() throws -> T {
        let data = self.data(using: .utf8)!
        let object = try JSONDecoder().decode(T.self, from: data)
        return object
    }
}
