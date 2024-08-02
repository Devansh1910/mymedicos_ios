import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
        
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        let vc2 = UINavigationController(rootViewController: CommunityViewController())
        let vc3 = UINavigationController(rootViewController: SlideshareViewController())
        
        
        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc2.tabBarItem.image = UIImage(systemName: "globe")
        vc3.tabBarItem.image = UIImage(systemName: "shared.with.you")
        
        
        vc1.title = "Home"
        vc2.title = "Community"
        vc3.title = "Slideshow"
        
        tabBar.tintColor = .label
        
        
        setViewControllers([vc1, vc2, vc3], animated: true)
        
    }
    
}

