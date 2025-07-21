import UIKit
import DJISDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize DJI SDK
        DJISDKManager.registerApp(withDelegate: self)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle (iOS 13+)
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
}

// MARK: - DJISDKManagerDelegate
extension AppDelegate: DJISDKManagerDelegate {
    
    func appRegisteredWithError(_ error: Error?) {
        if let error = error {
            print("DJI SDK Registration Failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.showRegistrationFailureAlert(error: error)
            }
        } else {
            print("DJI SDK Registration Successful")
            DispatchQueue.main.async {
                self.startConnectionToProduct()
            }
        }
    }
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        print("Database download progress: \(progress.fractionCompleted * 100)%")
    }
    
    private func showRegistrationFailureAlert(error: Error) {
        guard let rootViewController = window?.rootViewController else { return }
        
        let alert = UIAlertController(
            title: "DJI SDK Registration Failed",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        rootViewController.present(alert, animated: true)
    }
    
    private func startConnectionToProduct() {
        DJISDKManager.startConnectionToProduct()
    }
}
