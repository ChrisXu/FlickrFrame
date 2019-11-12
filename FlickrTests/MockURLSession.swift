import Foundation
@testable import Flickr

class MockURLSession: URLSessionProtocol {
    
    var requestInterceptor: ((URLRequest) -> Data?)?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTaskProtocol {
        
        let data = requestInterceptor?(request)
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        return MockURLSessionTask(data: data, response: response, completionHandler: completionHandler)
    }
}

private class MockURLSessionTask: URLSessionTaskProtocol {
    
    var completionHandler: (Data?, URLResponse?, Error?) -> Void
    
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    init(data: Data?, response: URLResponse? = nil, error: Error? = nil, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void ) {
        self.data = data
        self.response = response
        self.error = error
        self.completionHandler = completionHandler
    }
    
    func resume() { completionHandler(data, response, error) }
    
    func cancel() {
        let error = NSError(domain: "URLSessionTask has been cancelled", code: NSURLErrorCancelled, userInfo: nil)
        completionHandler(nil, nil, error)
    }
}
