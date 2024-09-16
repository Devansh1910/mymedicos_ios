import UIKit
import Firebase

class PreparationFmgeViewController: UIViewController, UISearchBarDelegate {
    
    let segmentedControl = UISegmentedControl(items: ["All", "Pre", "Para", "Clinical"])
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
        setupSegmentedControl()
        setupScrollView()
        setupStackView()
        setupActivityIndicator()  // Setup activity indicator
        fetchDataForSegment(index: segmentedControl.selectedSegmentIndex)
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

    func setupSegmentedControl() {
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .white
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
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

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        fetchDataForSegment(index: sender.selectedSegmentIndex)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCategories = allCategories
        } else {
            filteredCategories = allCategories.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        updateUIWithCategories(filteredCategories)
    }
    
    func fetchDataForSegment(index: Int) {
        activityIndicator.startAnimating()
        let db = Firestore.firestore()
        let categoriesRef = db.collection("Categories").document("39liVyLEjII6dtzolxSZ")
        
        categoriesRef.getDocument { (document, error) in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    let data = document.data()
                    switch index {
                    case 0:
                        self.allCategories = data?["All"] as? [String] ?? []
                    case 1:
                        self.allCategories = data?["Pre"] as? [String] ?? []
                    case 2:
                        self.allCategories = data?["Para"] as? [String] ?? []
                    case 3:
                        self.allCategories = data?["Clinical"] as? [String] ?? []
                    default:
                        break
                    }
                    self.filteredCategories = self.allCategories
                    self.updateUIWithCategories(self.filteredCategories)
                } else {
                    print("Document does not exist")
                }
                self.activityIndicator.stopAnimating()  // Stop and hide the activity indicator when data is loaded or fails to load
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
    }
    
    func navigateToTabBarViewController(withTitle title: String) {
        let tabBarVC = FmgeInsiderTabbarViewController(title: title)
        tabBarVC.modalPresentationStyle = .fullScreen
        present(tabBarVC, animated: true, completion: nil)
    }

}
