import XCTest
@testable import Flickr

class FlickrPhotoServiceTestCase: XCTestCase {

    private var service: FlickrPhotoService!
    private var session: MockURLSession!
    
    override func setUp() {
        super.setUp()
        session = MockURLSession()
        service = FlickrPhotoService(session: session)
    }
    
    func testIfItFetchesPhotos() {
        let expect = expectation(description: #function)
        
        do {
            // Given
            let keywords = ["cute", "cat"]
            let page = 3
            let mockJSONString = PhotoCollection.mockJSONString
            let expectedCollection: PhotoCollection = try mockJSONString.decodedObject()
            let expectedURL = try FlickrAPI.urlForSearch(keywords, page: page)
            
            session.requestInterceptor = { request in
                XCTAssertEqual(request.url, expectedURL)
                XCTAssertEqual(request.cachePolicy, .reloadIgnoringCacheData)
                
                return mockJSONString.data(using: .utf8)
            }
            
            // When
            service.fetchPhotos(with: keywords, at: page) { result in
                switch result {
                // Then
                case .success(let collection):
                    XCTAssertEqual(collection, expectedCollection)
                case .failure(let error):
                    XCTFail("\(error)")
                }
                expect.fulfill()
            }
        } catch {
            XCTFail("\(error)")
        }
        
        waitForExpectations(timeout: 0.5)
    }
}

private extension PhotoCollection {
    
    static let mockJSONString = """
    {
        "photos": {
            "page":1,
            "pages":15450,
            "perpage":20,
            "total":"308998",
            "photo":[]
        },
        "stat":"ok"
    }
    """
}
