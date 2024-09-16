import UIKit

class FmgeInsiderTabbarViewController: UITabBarController {
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        
        let vc1 = UINavigationController(rootViewController: IndexFmgeViewController(title: title))
        let vc2 = UINavigationController(rootViewController: CWTFmgeViewController(title: title))
        let vc3 = UINavigationController(rootViewController: SWGTFmgeViewController(title: title))

        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc2.tabBarItem.image = UIImage(systemName: "checklist")
        vc3.tabBarItem.image = UIImage(systemName: "square.and.pencil")

        vc1.title = "Index"
        vc2.title = "CWT"
        vc3.title = "SWGT"

        tabBar.tintColor = .label

        setViewControllers([vc1, vc2, vc3], animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        tabBar.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideTabBar), name: NSNotification.Name("hideTabBar"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showTabBar), name: NSNotification.Name("showTabBar"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func hideTabBar() {
        UIView.animate(withDuration: 0.3) {
            self.tabBar.alpha = 0
        } completion: { _ in
            self.tabBar.isHidden = true
        }
    }

    @objc func showTabBar() {
        self.tabBar.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.tabBar.alpha = 1
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
