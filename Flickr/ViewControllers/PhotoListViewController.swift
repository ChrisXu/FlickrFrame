import UIKit

class PhotoListViewController: UIViewController {

    var viewModel: PhotoListViewPresentable {
        didSet {
            reload()
        }
    }
    
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .white
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.accessibilityIdentifier = "PhotoListViewController.collectionView"
        return collectionView
    }()
    private(set) lazy var collectionViewLayout: UICollectionViewFlowLayout = { 
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return layout
    }()
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Looking for something special?", comment: "")
        searchController.searchBar.accessibilityIdentifier = "PhotoListViewController.searchBar"
        return searchController
    }()
    
    private var searchTimer: Timer?
    
    init(viewModel: PhotoListViewPresentable) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureCollectionView()
        configureSearchbar()
        
        reload()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        viewModel.handleDidReceiveMemoryWarning()
    }
    
    // MARK: Public methods
    
    /// It reloads the screen with a clean slate.
    func reload() {
        viewModel.removeAllPhotos()
        collectionView.reloadData()
        loadMore()
    }
    
    /// It loads more photos and updates screen if there is more.
    func loadMore() {
        guard viewModel.hasMore else {
            return
        }
        
        viewModel.loadMore { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.handle(error)
                } else {
                    let numberOfItems = self.collectionView.numberOfItems(inSection: 0)
                    let diff = self.viewModel.numberOfPhotos() - numberOfItems
                    let indexPathes = Array(0..<diff).map { IndexPath(item: numberOfItems + $0, section: 0) }
                    self.collectionView.insertItems(at: indexPathes)
                }
            }
        }
    }
    
    /// It handles the error and present the corresponding UI
    ///
    /// - Parameter error: Error
    func handle(_ error: Error) {
        // [TODO]
    }

    // MARK: - Private methods
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            collectionView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0).isActive = true
            collectionView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0).isActive = true
        } else {
            collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func configureSearchbar() {
        searchController.searchResultsUpdater = self
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            navigationItem.titleView = searchController.searchBar
            searchController.hidesNavigationBarDuringPresentation = false
        }
        
        definesPresentationContext = true
    }
    
    @objc private func updateSearchResultIfNeeded() {
        let text = searchController.searchBar.text ?? ""
        let keywords = text.components(separatedBy: " ").filter { !$0.isEmpty }
        if viewModel.keywords != keywords {
            viewModel.setKeywords(keywords)
            reload()
        }
    }
}

extension PhotoListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier, for: indexPath)
        return cell
    }
}

extension PhotoListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? PhotoCollectionViewCell {
            viewModel.loadPhoto(at: indexPath) { (image, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        cell.imageView.image = image
                    }
                }
            }
        }
        
        // load more if needed
        if viewModel.hasMore && !viewModel.isFetching && indexPath.row == viewModel.numberOfPhotos() - 1 {
            loadMore()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        viewModel.cancelLoadingPhoto(at: indexPath)
    }
}

extension PhotoListViewController: UICollectionViewDelegateFlowLayout {
    
    var numberOfColumns: CGFloat { return 3 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        
        let sectionInset = layout.sectionInset
        
        let reservedWidthForSpacing = (numberOfColumns - 1) * layout.minimumInteritemSpacing
        let reservedWidth = reservedWidthForSpacing + sectionInset.left + sectionInset.right
        let itemWidth: CGFloat = floor((collectionView.bounds.size.width - reservedWidth) / numberOfColumns)
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

extension PhotoListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateSearchResultIfNeeded), userInfo: nil, repeats: false)
    }
}
