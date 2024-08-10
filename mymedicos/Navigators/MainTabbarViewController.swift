import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.navigationItem.hidesBackButton = true
        
        // Adding blur effect to the background (if needed)
        addBlurBackground()
        
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        let vc3 = UINavigationController(rootViewController: SlideshareViewController())
        
        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc3.tabBarItem.image = UIImage(systemName: "shared.with.you")
        
        vc1.title = "Home"
        vc3.title = "Slideshow"
        
        tabBar.tintColor = .label
        
        // Configure tab bar appearance
        configureTabBarAppearance()
        
        setViewControllers([vc1, vc3], animated: true)
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

    private func configureTabBarAppearance() {
        tabBar.barTintColor = .white // Set the tab bar background color to white
        tabBar.isTranslucent = false // Make the tab bar non-translucent
        tabBar.backgroundColor = .white // Ensure the background color is white
    }
}
