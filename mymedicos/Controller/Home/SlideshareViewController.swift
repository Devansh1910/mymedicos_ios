import UIKit
import FirebaseFirestore

struct Slide {
    var id: String
    var fileURL: String
    var images: [ImageCustom]
    var title: String
    var speciality: String
    var type: String
}

struct ImageCustom {
    var id: String
    var url: String
}


class SlideshareViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let searchBar = UISearchBar()
    var selectedOptionIndex = 0
    var categories = [String]()
    var blurEffectView: UIVisualEffectView?
    var collectionView: UICollectionView!
    private var scrollView: UIScrollView!
    
    private var carouselView: CarouselSlideshareUIView!
    private var categoryTitleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .systemBackground
        configureNavbar()
        setupSearchBar()
        setupCollectionView()
        setupCarouselView()  // Setup carousel view
        setupCategoryLabel()
        setupScrollView()
        fetchCategories()
    }

    // MARK: - Navbar Setup
    private func configureNavbar() {
        let logo = UIImage(named: "logoImage")?.withRenderingMode(.alwaysOriginal)
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        let logoContainerView = UIView()
        logoContainerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: logoContainerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: logoContainerView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: logoContainerView.topAnchor, constant: 5),
            imageView.bottomAnchor.constraint(equalTo: logoContainerView.bottomAnchor, constant: -8),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        let logoItem = UIBarButtonItem(customView: logoContainerView)

        let titleLabel = UILabel()
        titleLabel.text = "Slideshare"
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        let titleItem = UIBarButtonItem(customView: titleLabel)

        navigationItem.leftBarButtonItems = [logoItem, titleItem]
        setupIcons()
    }

    private func setupIcons() {
        let notificationButton = UIButton(type: .custom)
        if let notificationImage = UIImage(systemName: "bell")?.withTintColor(.black, renderingMode: .alwaysOriginal) {
            notificationButton.setImage(notificationImage, for: .normal)
        }
        notificationButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        notificationButton.addTarget(self, action: #selector(didTapNotification), for: .touchUpInside)
        let notificationItem = UIBarButtonItem(customView: notificationButton)
        navigationItem.rightBarButtonItems = [notificationItem]
    }

    // MARK: - Search Bar Setup
    private func setupSearchBar() {
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.searchTextField.textColor = .gray
        searchBar.searchTextField.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        searchBar.backgroundImage = UIImage()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            searchBar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Collection View Setup
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 110, height: 40)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        collectionView.backgroundColor = .none
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // Call this in places where your data might change dynamically
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCarouselView() {
        carouselView = CarouselSlideshareUIView()
        view.addSubview(carouselView)
        carouselView.isHidden = true // Initially hidden

        NSLayoutConstraint.activate([
            carouselView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            carouselView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            carouselView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            carouselView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupCategoryLabel() {
        categoryTitleLabel = UILabel()
        categoryTitleLabel.text = "Physiology"
        categoryTitleLabel.textAlignment = .left
        categoryTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.addSubview(categoryTitleLabel)

        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryTitleLabel.topAnchor.constraint(equalTo: carouselView.bottomAnchor, constant: 10),
            categoryTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            categoryTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            categoryTitleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
    
    
    // Collection Defining ...
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let isActive = indexPath.row == selectedOptionIndex
        cell.configure(with: categories[indexPath.item], isActive: isActive)
        return cell
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedOptionIndex = indexPath.row
        collectionView.reloadData()
        print("Selected Category: \(categories[indexPath.item])")
        carouselView.isHidden = !(categories[indexPath.item] == "Exclusive")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = categories[indexPath.item]
        let cellWidth = text.size(withAttributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ]).width + 30
        
        return CGSize(width: max(110, cellWidth), height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at index: \(indexPath.row)")
        selectedOptionIndex = indexPath.row
    }
    
    // Data Fetching ........
    
    private func fetchCategories() {
        let db = Firestore.firestore()
        db.collection("Categories").document("39liVyLEjII6dtzolxSZ").getDocument { (document, error) in
            if let document = document, document.exists, let fetchedCategories = document.data()?["All"] as? [String] {
                self.categories = ["Exclusive"] + fetchedCategories
                self.selectedOptionIndex = 0
                self.collectionView.reloadData()
                self.carouselView.isHidden = !(self.categories[self.selectedOptionIndex] == "Exclusive")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // Navigation Setting....

    @objc func didTapNotification() {
        let notificationVC = NotificationViewController()
        notificationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(notificationVC, animated: true)
    }
}
