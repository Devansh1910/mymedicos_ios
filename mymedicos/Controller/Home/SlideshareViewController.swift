import UIKit

// Enum for organizing sections
enum Sections: Int {
    case trendingMovies = 0
    case trendingTV = 1
    case popular = 2
    case upcoming = 3
    case topRated = 4
}

class SlideshareViewController: UIViewController {
    
    private var headerView: HeroHeaderUIView?
    private let sectionTitles = ["Trending Movies", "Trending TV", "Popular", "Upcoming Movies", "Top Rated"]
    
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        table.backgroundColor = .white
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        view.overrideUserInterfaceStyle = .light
        setupTableView()
        configureNavigationBar()
        configureHeaderView()
    }
    
    private func setupTableView() {
        view.addSubview(homeFeedTable)
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        homeFeedTable.backgroundColor = .white
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        configureNavigationItems()
    }
    
    private func configureHeaderView() {
        headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300))
        homeFeedTable.tableHeaderView = headerView
    }
    
    private func configureNavigationItems() {
        let logoImage = UIImage(named: "logoImage")?.withRenderingMode(.alwaysOriginal)
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.contentMode = .scaleAspectFit
        let logoContainerView = UIView()
        logoContainerView.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: logoContainerView.leadingAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: logoContainerView.trailingAnchor),
            logoImageView.topAnchor.constraint(equalTo: logoContainerView.topAnchor, constant: 5),
            logoImageView.bottomAnchor.constraint(equalTo: logoContainerView.bottomAnchor, constant: -8),
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40)
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
        let notificationButton = createBarButton(imageName: "bell", action: #selector(didTapNotification))
        let notificationItem = UIBarButtonItem(customView: notificationButton)
        
        let downloadButton = createBarButton(imageName: "arrow.down.to.line", action: #selector(didTapDownload))
        let downloadItem = UIBarButtonItem(customView: downloadButton)
        
        navigationItem.rightBarButtonItems = [notificationItem, downloadItem]
    }
    
    private func createBarButton(imageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        if let image = UIImage(systemName: imageName)?.withTintColor(.black, renderingMode: .alwaysOriginal) {
            button.setImage(image, for: .normal)
        }
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc func didTapDownload() {
        print("Download button tapped")
    }
    
    @objc func didTapNotification() {
        let notificationVC = NotificationViewController()
        notificationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SlideshareViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        
        fetchDataForCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func fetchDataForCell(_ cell: CollectionViewTableViewCell, atIndexPath indexPath: IndexPath) {
        switch indexPath.section {
        case Sections.trendingMovies.rawValue:
            APICaller.shared.getTrendingMovies { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.trendingTV.rawValue:
            APICaller.shared.getTrendingTvs { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.popular.rawValue:
            APICaller.shared.getPopular { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.upcoming.rawValue:
            APICaller.shared.getUpcomingMovies { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case Sections.topRated.rawValue:
            APICaller.shared.getTopRated { result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error)
                }
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.textColor = .black
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
}

// MARK: - CollectionViewTableViewCellDelegate
extension SlideshareViewController: CollectionViewTableViewCellDelegate {
    func collectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: TitlePreviewViewModel) {
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
