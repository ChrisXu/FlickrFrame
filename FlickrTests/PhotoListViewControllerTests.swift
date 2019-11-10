//
//  PhotoListViewControllerTests.swift
//  FlickrTests
//
//  Created by Chris Xu on 11/10/19.
//

import XCTest
@testable import Flickr

class PhotoListViewControllerTestCase: XCTestCase {

    private var viewModel: MockViewModel!
    private var viewController: PhotoListViewController!
    
    override func setUp() {
        super.setUp()
        viewModel = MockViewModel()
        viewController = PhotoListViewController(viewModel: viewModel)
    }
    
    func testIfItReloadsPhotos() {
        XCTFail()
    }
}

private class MockViewModel: PhotoListViewPresentable {
    
    func numberOfPhotos() -> Int {
        return 0
    }
    
    func photo(at indexPath: IndexPath) -> Photo? {
        return nil
    }
}
