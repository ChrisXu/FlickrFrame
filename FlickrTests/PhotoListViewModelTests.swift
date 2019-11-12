import XCTest
@testable import Flickr

class PhotoListViewModelTestCase: XCTestCase {

    private var session: MockURLSession!
    private var viewModel: PhotoListViewModel!
    
    override func setUp() {
        super.setUp()
        session = MockURLSession()
        viewModel = PhotoListViewModel(urlSession: session)
    }
    
    func testIfItFetchesPhotos() {
        let expect = expectation(description: #function)
        
        do {
            // Given
            let mockJSONString = PhotoCollection.mockJSONString
            let expectedCollection: PhotoCollection = try mockJSONString.decodedObject()
            
            session.requestInterceptor = { _ in
                return mockJSONString.data(using: .utf8)
            }
            
            // When
            viewModel.loadMore { error in
                // Then
                XCTAssertNil(error)
                XCTAssertEqual(self.viewModel.numberOfPhotos(), expectedCollection.photos.count)
                XCTAssertFalse(self.viewModel.hasMore)
                XCTAssertFalse(self.viewModel.isFetching)
                expect.fulfill()
            }
        } catch {
            XCTFail("\(error)")
        }
        
        waitForExpectations(timeout: 0.5)
    }
    
    func testIfItFetchesPhotosWithKeyowrds() {
        let expect = expectation(description: #function)
        
        do {
            // Given
            let keywords = ["barking", "DOG"]
            let mockJSONString = PhotoCollection.mockJSONString
            let expectedCollection: PhotoCollection = try mockJSONString.decodedObject()
            let expectedURL = try FlickrAPI.urlForSearch(keywords)
            
            session.requestInterceptor = { request in
                XCTAssertEqual(request.url, expectedURL)
                return mockJSONString.data(using: .utf8)
            }
            
            // When
            viewModel.setKeywords(keywords)
            viewModel.loadMore { error in
                // Then
                XCTAssertNil(error)
                XCTAssertEqual(self.viewModel.numberOfPhotos(), expectedCollection.photos.count)
                XCTAssertFalse(self.viewModel.hasMore)
                XCTAssertFalse(self.viewModel.isFetching)
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
            "pages":1,
            "perpage":20,
            "total":"2",
            "photo":[
            {"id":"49049991141","owner":"64588547@N00","secret":"279bba90d5","server":"65535","farm":66,"title":"untitled-8","ispublic":1,"isfriend":0,"isfamily":0},
                {"id":"49049991142","owner":"64588547@N00","secret":"279bba90d5","server":"65535","farm":66,"title":"untitled-8","ispublic":1,"isfriend":0,"isfamily":0}
            ]
        },
        "stat":"ok"
    }
    """
}
