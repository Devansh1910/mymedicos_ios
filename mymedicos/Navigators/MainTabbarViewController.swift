import UIKit
import FirebaseAuth
import FirebaseFirestore

// MainTabBarViewController
class MainTabBarViewController: UITabBarController {
    
    var phoneNumber: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.navigationItem.hidesBackButton = true
        
        // Retrieve the phone number from UserDefaults
        let savedPhoneNumber = UserDefaults.standard.string(forKey: "savedPhoneNumber")

        // Check if a number was retrieved and log it
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
        
        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc2.tabBarItem.image = UIImage(systemName: "slider.horizontal.below.rectangle")
        
        vc1.title = "Home"
        vc2.title = "Slideshare"
        
        tabBar.tintColor = .label
        
        setViewControllers([vc1, vc2], animated: true)
    }

    private func addBlurBackground() {
        let blurEffect = UIBlurEffect(style: .light) // You can change to .dark or .extraLight as needed
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        // Setting the frame to cover the entire view
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Adding the blur effect view to the view hierarchy
        view.insertSubview(blurEffectView, at: 0) // Insert at index 0 to place it behind all other subviews
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
