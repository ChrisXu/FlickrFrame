import Foundation

protocol PhotoListViewPresentable {
    
    func numberOfPhotos() -> Int
    
    func photo(at indexPath: IndexPath) -> Photo?
}

class PhotoListViewModel: PhotoListViewPresentable {
    
    private var photos = [Photo]()
    
    func numberOfPhotos() -> Int {
        return 20
    }
    
    func photo(at indexPath: IndexPath) -> Photo? {
        guard indexPath.row < photos.count else {
            return nil
        }
        return photos[indexPath.row]
    }
}
