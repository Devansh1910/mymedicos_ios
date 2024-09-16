import UIKit
import FirebaseAuth
import FirebaseFirestore

class MainTabBarViewController: UITabBarController {
    
    var phoneNumber: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.navigationItem.hidesBackButton = true
        
        let savedPhoneNumber = UserDefaults.standard.string(forKey: "savedPhoneNumber")

        if let number = savedPhoneNumber {
            phoneNumber = number
            print("App launched. Retrieved saved phone number: \(number)")
            passPhoneNumberToHomeVC(phoneNumber: number)
        } else {
            print("App launched. No saved phone number found.")
        }
        
        setupTabBarControllers()
        configureTabBarAppearance()
        
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        let vc2 = UINavigationController(rootViewController: SlideshareViewController())
        let vc3 = UINavigationController(rootViewController: ProfileViewController())
        
        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc2.tabBarItem.image = UIImage(systemName: "slider.horizontal.below.rectangle")
        vc3.tabBarItem.image = UIImage(systemName: "person.fill")
        
        vc1.title = "Home"
        vc2.title = "Slideshare"
        vc3.title = "Profile"
        
        tabBar.tintColor = .label
        
        setViewControllers([vc1, vc2, vc3], animated: true)
    }

    private func addBlurBackground() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.insertSubview(blurEffectView, at: 0)
    }
    
    private func passPhoneNumberToHomeVC(phoneNumber: String) {
            if let viewControllers = self.viewControllers {
                for viewController in viewControllers {
                    if let homeVC = viewController as? HomeViewController {
                        homeVC.phoneNumber = phoneNumber
                    } else if let navController = viewController as? UINavigationController {
                        if let homeVC = navController.viewControllers.first as? HomeViewController {
                            homeVC.phoneNumber = phoneNumber
                        }
                    }
                }
            }
        }
    func setupTabBarControllers() {
         let homeVC = HomeViewController()
         homeVC.phoneNumber = phoneNumber
         let navController = UINavigationController(rootViewController: homeVC)
         self.viewControllers = [navController]

         print("Phone number in MainTabBar after setup: \(phoneNumber ?? "None")")
     }

    private func configureTabBarAppearance() {
        tabBar.barTintColor = .white // Set the tab bar background color to white
        tabBar.isTranslucent = false // Make the tab bar non-translucent
        tabBar.backgroundColor = .white // Ensure the background color is white
    }
}
