import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setUpCache()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let rootViewController = PhotoListViewController()
        window.rootViewController = rootViewController
        
        window.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: - Private methods
    
    func setUpCache() {
        URLCache.shared.diskCapacity = 2 * 1024 * 1024 * 1024 // 2 GB
        URLCache.shared.memoryCapacity = 1024 * 1024 * 1024 // 1 GB
    }
}

