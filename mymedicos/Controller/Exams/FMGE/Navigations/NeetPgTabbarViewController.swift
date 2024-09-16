import UIKit
import FirebaseAuth
import FirebaseFirestore

class NeetPgTabbarViewController: UITabBarController {
    
    var titleExaminationCategory: String?
    
    private var heroImageView: HeroImageNeetpgUIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

        print(self.title ?? "No Title")

        self.view.backgroundColor = .white
        setupHeroImageView()
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

    func setupWith(title: String) {
        self.titleExaminationCategory = title
        self.title = title
        heroImageView?.updateTitle(title)
        configureNavigationBar()
    }

    private func setupHeroImageView() {
        let frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 200)
        heroImageView = HeroImageNeetpgUIView(frame: frame, title: self.title ?? "Default Title")
        view.insertSubview(heroImageView, at: 0)
        heroImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .white

        let titleLabel = UILabel()
        titleLabel.text = self.title
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        navigationItem.titleView = titleLabel 
    }
    
    private func configureTabBarAppearance() {
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
    }
}
