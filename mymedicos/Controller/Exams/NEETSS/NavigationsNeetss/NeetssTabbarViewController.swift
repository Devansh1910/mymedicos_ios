import UIKit
import FirebaseAuth
import FirebaseDatabase

class NeetssTabbarViewController: UITabBarController {
    
    var titleExaminationCategory: String?
    private var heroImageView: HeroImageNeetssUIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

        self.view.backgroundColor = .white
        setupHeroImageView()
        configureNavigationBar()
        configureTabBarAppearance()
        
        let backItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(handleBack))
        navigationItem.leftBarButtonItem = backItem

        fetchTitleFromFirebase()

        let vc1 = UINavigationController(rootViewController: FeedNeetssViewController())
        let vc2 = UINavigationController(rootViewController: PreparationNeetssViewController())
        let vc3 = UINavigationController(rootViewController: GrandTestNeetssViewController())

        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc2.tabBarItem.image = UIImage(systemName: "list.bullet.indent")
        vc3.tabBarItem.image = UIImage(systemName: "book.pages")

        vc1.title = "Home"
        vc2.title = "Preparation"
        vc3.title = "Grand Test"

        tabBar.tintColor = .label

        setViewControllers([vc1, vc2, vc3], animated: true)
    }

    private func fetchTitleFromFirebase() {
        guard let userPhoneNumber = Auth.auth().currentUser?.phoneNumber else {
            print("No user phone number available.")
            return
        }

        let dbRef = Database.database().reference()
        dbRef.child("profiles").child(userPhoneNumber).child("Neetss").observeSingleEvent(of: .value, with: { snapshot in
            if let title = snapshot.value as? String {
                self.titleExaminationCategory = title
                self.title = title
                self.heroImageView?.updateTitle(title)
                self.configureNavigationBar()

            } else {
                print("Failed to fetch title for Neetss.")
            }
        }) { error in
            print("Firebase fetch error: \(error.localizedDescription)")
        }
    }

    
    @objc private func handleBack() {
        self.navigationController?.popViewController(animated: true)
    }

    private func setupHeroImageView() {
        let frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 200)
        heroImageView = HeroImageNeetssUIView(frame: frame, title: self.title ?? "Default Title")
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
