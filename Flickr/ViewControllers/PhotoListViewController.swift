import UIKit

class PhotoListViewController: UIViewController {

    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        return collectionView
    }()
    
    private var collectionViewLayout = UICollectionViewLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let service = FlickrPhotoService(session: URLSession.shared)
        service.fetchPhotos(with: ["amsterdam"]) { result in
            
        }
    }

    // MARK: - Private methods
    
    private func addCollectionView() {
        
    }
}

