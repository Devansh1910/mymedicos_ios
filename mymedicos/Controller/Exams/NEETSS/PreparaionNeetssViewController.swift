import UIKit
import Firebase

class PreparationNeetssViewController: UIViewController, UISearchBarDelegate {
    
    let scrollView = UIScrollView()
    var stackView = UIStackView()
    var searchBar = UISearchBar()
    var titleLabel = UILabel()
    var detailLabel = UILabel()
    var allCategories = [String]()
    var filteredCategories = [String]()
    var activityIndicator = UIActivityIndicatorView()  // Declare the activity indicator

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        extendBackground()
        setupLabels()
        setupSearchBar()
        setupScrollView()
        setupStackView()
        setupActivityIndicator()  // Setup activity indicator
        fetchData()
    }
    
    func extendBackground() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundView, at: 0)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func setupLabels() {
        titleLabel.text = "Topics"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        detailLabel.text = "19 Topics . Notes . QBanks . Grand Test"
        detailLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        detailLabel.textColor = .gray
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    

    func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search Specialities"
        searchBar.searchTextField.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        searchBar.searchTextField.textColor = .gray
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }

    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupStackView() {
        scrollView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 10
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    func setupActivityIndicator() {
        activityIndicator.style = .large
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func fetchData() {
        guard let userPhoneNumber = Auth.auth().currentUser?.phoneNumber else {
            print("No user phone number available")
            return
        }

        let ref = Database.database().reference()
        activityIndicator.startAnimating()

        ref.child("profiles").child(userPhoneNumber).child("Neetss").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? String else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    print("Neetss value not found")
                }
                return
            }
            
            let categoryDocument: String
            switch value {
            case "medical":
                categoryDocument = "Medical"
            case "surgical":
                categoryDocument = "Surgical"
            case "paediatrics":
                categoryDocument = "Paediatric"
            default:
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    print("No relevant category found for \(value)")
                }
                return
            }
            
            // Now fetching the categories from Firestore using the determined categoryDocument
            let db = Firestore.firestore()
            let categoriesRef = db.collection("CategoriesNeetss").document(categoryDocument)
            
            categoriesRef.getDocument { (document, error) in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    if let document = document, document.exists, let data = document.data() {
                        self.allCategories = data["Data"] as? [String] ?? []
                        self.filteredCategories = self.allCategories
                        self.updateUIWithCategories(self.filteredCategories)
                    } else {
                        print("Document does not exist or data is not in the expected format.")
                    }
                }
            }
        }) { error in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                print(error.localizedDescription)
            }
        }
    }
    
    func updateUIWithCategories(_ categories: [String]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for category in categories {
            let categoryView = CategoryView(categoryName: category)
            categoryView.onTap = { [weak self] in
                self?.navigateToTabBarViewController(withTitle: category)
            }
            stackView.addArrangedSubview(categoryView)
        }

        // Update the detailLabel with the count of categories/topics
        DispatchQueue.main.async {
            self.detailLabel.text = "\(categories.count) Courses . Notes . QBanks . Grand Test"
        }
    }


    
    func navigateToTabBarViewController(withTitle title: String) {
        let tabBarVC = FmgeInsiderTabbarViewController(title: title)
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true, completion: nil)
    }
}
