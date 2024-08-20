import UIKit
import FirebaseAuth
import FirebaseFirestore

class NeetPgTabbarViewController: UITabBarController {
    
    private let heroImageView = HeroImageNeetpgUIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.view.backgroundColor = .white
        self.navigationItem.title = "PG NEET"

        setupHeroImageView()  // Set up the hero image first
        configureNavigationBar()
        configureTabBarAppearance()

        let vc1 = UINavigationController(rootViewController: FeedViewController())
        let vc2 = UINavigationController(rootViewController: PreparationViewController())
        let vc3 = UINavigationController(rootViewController: GrandTestViewController())

        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc2.tabBarItem.image = UIImage(systemName: "list.bullet.indent")
        vc3.tabBarItem.image = UIImage(systemName: "book.pages")

        vc1.title = "Home"
        vc2.title = "Preparation"
        vc3.title = "Grand Test"

        tabBar.tintColor = .label

        setViewControllers([vc1, vc2, vc3], animated: true)
    }

    private func setupHeroImageView() {
        view.insertSubview(heroImageView, at: 0)  // Ensures it is behind all other subviews
        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalToConstant: 200)  // Set the fixed height
        ])
    }

    
    private func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .white

        let titleLabel = UILabel()
        titleLabel.text = self.navigationItem.title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
    
    private func configureTabBarAppearance() {
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
    }
}
