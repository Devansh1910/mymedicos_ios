import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let splashScreenVC = SplashScreenViewController()
        window?.rootViewController = splashScreenVC
        window?.makeKeyAndVisible()

        loadDataInBackground { [weak self] in
            self?.checkAuthStatusAndNavigate(splashScreenVC)
        }
    }

    private func loadDataInBackground(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            print("Loading data in the background...")
            sleep(3) // Simulating network call delay
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    private func checkAuthStatusAndNavigate(_ splashScreenVC: SplashScreenViewController) {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if let user = user {
                print("User is logged in with uid: \(user.uid)")
                splashScreenVC.moveToMainAppScreen() // Navigate to main tab bar
            } else {
                print("No user is logged in.")
                splashScreenVC.moveToMainAppScreen() // Navigate to login screen
            }
            self?.window?.makeKeyAndVisible()
        }
    }
}
