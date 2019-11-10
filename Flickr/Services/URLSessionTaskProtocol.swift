import Foundation

public protocol URLSessionTaskProtocol {
    func resume()
    func cancel()
}

extension URLSessionTask: URLSessionTaskProtocol { }
