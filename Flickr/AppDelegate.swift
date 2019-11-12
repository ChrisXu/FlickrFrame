import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var urlSession: URLSessionProtocol = {
        return URLSession.shared
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setUpCache()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let rootViewModel = PhotoListViewModel(urlSession: urlSession)
        let photoListViewController = PhotoListViewController(viewModel: rootViewModel)
        let rootViewController = UINavigationController(rootViewController: photoListViewController)
        window.rootViewController = rootViewController
        
        window.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: - Private methods
    
    private func setUpCache() {
        URLCache.shared.diskCapacity = 2 * 1024 * 1024 * 1024 // 2 GB
        URLCache.shared.memoryCapacity = 500 * 1024 * 1024 // 500 MB
    }
}
