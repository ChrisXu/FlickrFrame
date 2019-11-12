import XCTest
@testable import Flickr

class PhotoListViewControllerTestCase: XCTestCase {

    private var viewModel: MockViewModel!
    private var viewController: PhotoListViewController!
    
    override func setUp() {
        super.setUp()
        viewModel = MockViewModel()
        viewController = PhotoListViewController(viewModel: viewModel)
        
        viewController.viewDidLoad()
    }
    
    func testIfItReloadsPhotos() {
        // Given
        let existingPhoto = Photo(identifier: "123", secret: "456", farm: 7, server: "8")
        let expectedNewPhoto = Photo.mock
        viewModel._photos = [existingPhoto]
        
        // When
        viewController.reload()
        
        // Then
        XCTAssertFalse(viewModel._photos.contains(existingPhoto))
        XCTAssertTrue(viewModel._photos.contains(expectedNewPhoto))
    }
    
    func testIfItLoadsMore() {
        // Given
        let existingPhoto = Photo(identifier: "123", secret: "456", farm: 7, server: "8")
        let expectedNewPhoto = Photo.mock
        viewModel._photos = [existingPhoto]
        
        // When
        viewController.loadMore()
        
        // Then
        XCTAssertTrue(viewModel._photos.contains(existingPhoto))
        XCTAssertTrue(viewModel._photos.contains(expectedNewPhoto))
    }
    
    func testIfItHandlesDidReceiveMemoryWarning() {
        // Given
        viewModel._didhandleDidReceiveMemoryWarning = false
        
        // When
        viewController.didReceiveMemoryWarning()
        
        // Then
        XCTAssertTrue(viewModel._didhandleDidReceiveMemoryWarning)
    }
    
    func testIfItLoadsPhotoWhenCellWillDisplay() {
        // Given
        let collectionView = viewController.collectionView
        let cell = PhotoCollectionViewCell()
        let expectedIndexPath = IndexPath(item: 0, section: 0)
        
        // When
        viewController.collectionView(collectionView, willDisplay: cell, forItemAt: expectedIndexPath)
        
        // Then
        XCTAssertTrue(viewModel._loadingIndexPathes.contains(expectedIndexPath))
    }
    
    func testIfItCancelsLoadingPhotoWhenCellDidEndDisplaying() {
        // Given
        let collectionView = viewController.collectionView
        let cell = PhotoCollectionViewCell()
        let indexPathes = [IndexPath(item: 0, section: 0), IndexPath(item: 1, section: 0)]
        
        // When
        indexPathes.forEach { 
            viewController.collectionView(collectionView, willDisplay: cell, forItemAt: $0)
        }
        viewController.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPathes.first!)
        
        // Then
        XCTAssertFalse(viewModel._loadingIndexPathes.contains(indexPathes.first!))
        XCTAssertTrue(viewModel._loadingIndexPathes.contains(indexPathes.last!))
    }
}

private class MockViewModel: PhotoListViewPresentable {
    
    var _photos = [Photo]()
    var _didhandleDidReceiveMemoryWarning = false
    var _loadingIndexPathes = [IndexPath]()
    
    // MARK: - PhotoListViewPresentable
    
    var keywords: [String] = []
    
    var isFetching: Bool = false
    
    var hasMore: Bool = true
    
    func numberOfPhotos() -> Int {
        return _photos.count
    }
    
    func setKeywords(_ keywords: [String]) {
        self.keywords = keywords
    }
    
    func loadMore(completion: @escaping (Error?) -> Void) {
        _photos.append(Photo.mock)
        completion(nil)
    }
    
    func loadPhoto(at indexPath: IndexPath, completion: @escaping (UIImage?, Error?) -> Void) {
        _loadingIndexPathes.append(indexPath)
        completion(nil, nil)
    }
    
    func cancelLoadingPhoto(at indexPath: IndexPath) {
        _loadingIndexPathes.removeAll(where: { $0 == indexPath })
    }
    
    func removeAllPhotos() {
        _photos.removeAll()
    }
    
    func handleDidReceiveMemoryWarning() {
        _didhandleDidReceiveMemoryWarning = true    
    }
}

private extension Photo {
    
    static let mock = Photo(identifier: "1a2b3c4d5e6", secret: "secret", farm: 123, server: "aws")
}
