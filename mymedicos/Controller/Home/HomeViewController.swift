import UIKit
class HomeViewController: UIViewController, DailyQuestionUIViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, LiveExaminationsUIViewDelegate {
    
    // MARK: - LiveExaminationsUIViewDelegate
    
    func navigateToExamPortal(withTitle title: String, examID: String) {
        let liveExamVC = LiveExaminationViewController()
        liveExamVC.hidesBottomBarWhenPushed = true
        liveExamVC.examTitle = title
        liveExamVC.examID = examID // Pass the examID to the next view controller
        navigationController?.pushViewController(liveExamVC, animated: true)
    }
    
    // MARK: - Properties
    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        return table
    }()

    let dropdownButton = UIButton(type: .system)
    let options = ["Education", "Community"]
    let sectionTitle = ["Daily Questions"]
    
    private let dailyQuestionView = DailyQuestionUIView()
    private let liveQuestionView = LiveExaminationsUIView()
    private let practiceQuestionView = PraticeQuestionsUIView()
    private let quickLinkView = QuickLinkUIView()
    private let recentQuestionView = RecentUpdatesUIView()
    private let shareApplicationwithOthers = ShareUIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTable)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .black

        configureNavbar()

        // Adjust the header view size dynamically
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 0)
        var currentHeight: CGFloat = 0
        
        // Hero Image (Carousel)
        let heroImageView = HeroImageUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 225))
        headerView.addSubview(heroImageView)
        currentHeight += 225
        
        // Daily Question will come here.
        let titleLabel = UILabel(frame: CGRect(x: 10, y: currentHeight + 10, width: view.bounds.width - 10, height: 15))
        titleLabel.text = "Daily Question"
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(titleLabel)
        currentHeight += 25

        dailyQuestionView.frame = CGRect(x: 5, y: currentHeight + 10, width: view.bounds.width - 10, height: 100)
        dailyQuestionView.backgroundColor = .systemBackground
        dailyQuestionView.delegate = self
        headerView.addSubview(dailyQuestionView)
        currentHeight += 110
        
        // Live Examination will come here.
        let additionalTitleLabel = UILabel(frame: CGRect(x: 10, y: currentHeight + 10, width: view.bounds.width - 10, height: 20))
        additionalTitleLabel.text = "Live Exams"
        additionalTitleLabel.textAlignment = .left
        additionalTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(additionalTitleLabel)
        currentHeight += 30

        liveQuestionView.translatesAutoresizingMaskIntoConstraints = false
        liveQuestionView.backgroundColor = .white
        liveQuestionView.delegate = self // Set the delegate to handle navigation
        headerView.addSubview(liveQuestionView)

        // Constraints for liveQuestionView
        NSLayoutConstraint.activate([
            liveQuestionView.topAnchor.constraint(equalTo: additionalTitleLabel.bottomAnchor, constant: 10),
            liveQuestionView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 5),
            liveQuestionView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -5)
        ])

        // Adjust currentHeight based on the liveQuestionView's content size
        currentHeight += liveQuestionView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 20
        
        // Practice Examination will come here.
        let additionalTitleLabel2 = UILabel(frame: CGRect(x: 10, y: currentHeight + 10, width: view.bounds.width - 10, height: 40))
        additionalTitleLabel2.text = "Practice MCQ's"
        additionalTitleLabel2.textAlignment = .left
        additionalTitleLabel2.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(additionalTitleLabel2)
        currentHeight += 40

        practiceQuestionView.frame = CGRect(x: 5, y: currentHeight + 10, width: view.bounds.width - 10, height: 60)
        practiceQuestionView.backgroundColor = .systemBackground
        headerView.addSubview(practiceQuestionView)
        currentHeight += 70
        
        // Quick Access will come here.
        let additionalTitleLabel3 = UILabel(frame: CGRect(x: 10, y: currentHeight + 10, width: view.bounds.width - 10, height: 20))
        additionalTitleLabel3.text = "Quick Access"
        additionalTitleLabel3.textAlignment = .left
        additionalTitleLabel3.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(additionalTitleLabel3)
        currentHeight += 30

        quickLinkView.frame = CGRect(x: 5, y: currentHeight + 10, width: view.bounds.width - 10, height: 250)
        quickLinkView.backgroundColor = .systemBackground
        headerView.addSubview(quickLinkView)
        currentHeight += 260
        
        // Recent Updates will come here.
        let additionalTitleLabel4 = UILabel(frame: CGRect(x: 10, y: currentHeight + 10, width: view.bounds.width - 10, height: 20))
        additionalTitleLabel4.text = "Recent Updates"
        additionalTitleLabel4.textAlignment = .left
        additionalTitleLabel4.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(additionalTitleLabel4)
        currentHeight += 30

        recentQuestionView.frame = CGRect(x: 5, y: currentHeight + 10, width: view.bounds.width - 10, height: 60)
        recentQuestionView.backgroundColor = .systemBackground
        headerView.addSubview(recentQuestionView)
        currentHeight += 70
        
        // Share Option will come here.
        let additionalTitleLabel5 = UILabel(frame: CGRect(x: 10, y: currentHeight + 10, width: view.bounds.width - 10, height: 20))
        additionalTitleLabel5.text = "Share Application with Others"
        additionalTitleLabel5.textAlignment = .left
        additionalTitleLabel5.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(additionalTitleLabel5)
        currentHeight += 30

        shareApplicationwithOthers.frame = CGRect(x: 5, y: currentHeight + 10, width: view.bounds.width - 10, height: 100)
        shareApplicationwithOthers.backgroundColor = .systemBackground
        headerView.addSubview(shareApplicationwithOthers)
        currentHeight += 70
        
        headerView.frame.size.height = currentHeight
        homeFeedTable.tableHeaderView = headerView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }

    private func configureNavbar() {
        let logo = UIImage(named: "logoImage")?.withRenderingMode(.alwaysOriginal)
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        let containerView = UIView()
        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        let logoItem = UIBarButtonItem(customView: containerView)

        dropdownButton.setTitle("\(options[0]) ▼", for: .normal)
        dropdownButton.setTitleColor(.black, for: .normal)
        dropdownButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        dropdownButton.addTarget(self, action: #selector(didTapDropdown), for: .touchUpInside)

        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let spacerItem = UIBarButtonItem(customView: spacerView)

        let dropdownItem = UIBarButtonItem(customView: dropdownButton)

        navigationItem.leftBarButtonItems = [logoItem, spacerItem, dropdownItem]

        setupIcons()
    }

    @objc func didTapDropdown() {
        let alertController = UIAlertController(title: "Shift to ?", message: nil, preferredStyle: .actionSheet)
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        alertController.view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 20),
            pickerView.leftAnchor.constraint(equalTo: alertController.view.leftAnchor),
            pickerView.rightAnchor.constraint(equalTo: alertController.view.rightAnchor),
            pickerView.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -45)
        ])
        
        let selectAction = UIAlertAction(title: "Select", style: .default) { [weak self] _ in
            self?.updateDropdownSelection(with: pickerView.selectedRow(inComponent: 0))
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }

    private func updateDropdownSelection(with index: Int) {
        dropdownButton.setTitle("\(options[index]) ▼", for: .normal)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }

    private func setupIcons() {
        let notificationButton = UIButton(type: .custom)
        let personButton = UIButton(type: .custom)

        if let notificationImage = UIImage(systemName: "bell")?.withTintColor(.black, renderingMode: .alwaysOriginal),
           let personImage = UIImage(systemName: "person")?.withTintColor(.black, renderingMode: .alwaysOriginal) {
            notificationButton.setImage(notificationImage, for: .normal)
            personButton.setImage(personImage, for: .normal)
        }

        notificationButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        personButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

        notificationButton.addTarget(self, action: #selector(didTapNotification), for: .touchUpInside)
        personButton.addTarget(self, action: #selector(didTapPerson), for: .touchUpInside)

        let notificationItem = UIBarButtonItem(customView: notificationButton)
        let personItem = UIBarButtonItem(customView: personButton)

        navigationItem.rightBarButtonItems = [personItem, notificationItem]
    }

    @objc func didTapNotification() {
        let notificationVC = NotificationViewController()
        notificationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(notificationVC, animated: true)
    }

    @objc func didTapPerson() {
        let profileVC = SideViewController()
        profileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func didTapLearnMore() {
        let detailedVC = DailyQuestionDetailedViewController()
        detailedVC.hidesBottomBarWhenPushed = true  // Hide the tab bar
        navigationController?.pushViewController(detailedVC, animated: true)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateIconColors()
        }
    }

    private func updateIconColors() {
        let currentTheme = traitCollection.userInterfaceStyle
        let color = currentTheme == .dark ? UIColor.white : UIColor.black
        navigationController?.navigationBar.tintColor = color
    }
}
