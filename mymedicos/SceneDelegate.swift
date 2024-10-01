import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        if Auth.auth().currentUser != nil {
            // User is logged in, initialize with splash screen
            let splashScreenVC = SplashScreenViewController()
            let navigationController = UINavigationController(rootViewController: splashScreenVC)
            navigationController.navigationBar.isHidden = true
            window?.rootViewController = navigationController
        } else {
            // No user logged in, directly go to Get Started page
            let getStartedVC = GetStartedViewController()
            let navigationController = UINavigationController(rootViewController: getStartedVC)
            navigationController.navigationBar.isHidden = true
            window?.rootViewController = navigationController
        }
        window?.makeKeyAndVisible()

        if Auth.auth().currentUser != nil {
            // Delayed tasks for logged in users, like loading additional data
            loadDataInBackground { [weak self] in
                guard let navigationController = self?.window?.rootViewController as? UINavigationController,
                      let splashScreenVC = navigationController.viewControllers.first as? SplashScreenViewController else { return }
                splashScreenVC.moveToMainAppScreen()
            }
        }
    }

    private func loadDataInBackground(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            print("Loading data in the background...")
            sleep(3) // Simulating a network call delay
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
