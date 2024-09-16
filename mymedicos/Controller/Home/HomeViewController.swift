import UIKit
import SwiftUI
import Lottie

class HomeViewController: UIViewController, DailyQuestionUIViewDelegate, UITableViewDataSource, UITableViewDelegate, LiveExaminationsUIViewDelegate, QuickLinkUIViewDelegate, RecentUpdatesDelegate, ShareUIViewDelegate, UISearchBarDelegate, ContinueSolvingCardViewDelegate {
    
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
        table.backgroundColor = UIColor(hexString: "#F4F4F4")
        return table
    }()
    
    let dropdownButton = UIButton(type: .system)
    let options = ["Education", "Community"]
    
    private var customPickerTableView: UITableView?
    private var customPickerContainerView: UIView?
    private var selectedOptionIndex = 0
    private var blurEffectView: UIVisualEffectView?
    
    private let dailyQuestionView = DailyQuestionUIView()
    private let liveQuestionView = LiveExaminationsUIView()
    private let practiceQuestionView = PraticeQuestionsUIView()
    private let quickLinkView = QuickLinkUIView()
    private let recentQuestionView = RecentUpdatesUIView()
    private let shareApplicationwithOthers = ShareUIView()
    
    private let continueSolvingCard = ContinueSolvingCardView()
    
    private let searchBar = UISearchBar()
    
    var documentId: String? {
        didSet {
            if let id = documentId {
                UserDefaults.standard.set(id, forKey: "Phone Number")
                print("Document ID saved: \(id)")
            }
        }
    }
    
    var phoneNumber: String? {
        didSet {
            if let number = phoneNumber {
                UserDefaults.standard.set(number, forKey: "savedPhoneNumber")
                print("Phone number saved: \(number)")
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        continueSolvingCard.delegate = self
        searchBar.delegate = self
        quickLinkView.delegate = self
        
        recentQuestionView.delegate = self
        shareApplicationwithOthers.delegate = self
        
        if let retrievedId = UserDefaults.standard.string(forKey: "Phone Number") {
            documentId = retrievedId
            print("Retrieved Document ID: \(retrievedId)")
        }
        
        if let retrievedNumber = UserDefaults.standard.string(forKey: "savedPhoneNumber") {
            phoneNumber = retrievedNumber
            print("HomeViewController loaded with phoneNumber: \(retrievedNumber)")
        } else {
            print("No phone number was saved in UserDefaults")
        }
        
        view.backgroundColor = .white
        view.addSubview(homeFeedTable)
        view.addSubview(quickLinkView)
        view.bringSubviewToFront(quickLinkView)

        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .black
        
        configureNavbar()
        
        setupHeaderView()
        setupContinueSolvingCard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }
    
    // MARK: - Setup UI
    private func configureNavbar() {
        let logo = UIImage(named: "logoImage")?.withRenderingMode(.alwaysOriginal)
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        let containerView = UIView()
        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        let logoItem = UIBarButtonItem(customView: containerView)
        
        dropdownButton.setTitle("\(options[selectedOptionIndex]) ▼", for: .normal)
        dropdownButton.setTitleColor(.black, for: .normal)
        dropdownButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        dropdownButton.addTarget(self, action: #selector(didTapDropdown), for: .touchUpInside)
        
        let dropdownItem = UIBarButtonItem(customView: dropdownButton)
        
        navigationItem.leftBarButtonItems = [logoItem, dropdownItem]
        
        setupIcons()
    }
    
    private func setupHeaderView() {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 0)
        var currentHeight: CGFloat = 0
        
        let educationTitleLabel = UILabel(frame: CGRect(x: 15, y: currentHeight + 15, width: view.bounds.width - 20, height: 20))
        educationTitleLabel.text = "Education"
        educationTitleLabel.textAlignment = .left
        educationTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(educationTitleLabel)
        currentHeight += 30
        
        quickLinkView.frame = CGRect(x: 13, y: currentHeight + 15, width: view.bounds.width + 10, height: 90)
        headerView.addSubview(quickLinkView)
        quickLinkView.layer.zPosition = 1
        currentHeight += 105
        
        let heroImageView = HeroImageUIView(frame: CGRect(x: 13, y: currentHeight + 15, width: view.bounds.width - 25, height: 100))
        heroImageView.layer.cornerRadius = 10
        heroImageView.clipsToBounds = true
        headerView.addSubview(heroImageView)
        currentHeight += 100
        
        let titleLabel = UILabel(frame: CGRect(x: 15, y: currentHeight + 25, width: view.bounds.width - 10, height: 15))
        titleLabel.text = "Daily Question"
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(titleLabel)
        currentHeight += 25
        
        dailyQuestionView.frame = CGRect(x: 13, y: currentHeight + 25, width: view.bounds.width - 25, height: 100)
        dailyQuestionView.backgroundColor = .systemBackground
        dailyQuestionView.delegate = self
        headerView.addSubview(dailyQuestionView)
        currentHeight += 110
        
        let additionalTitleLabel = UILabel(frame: CGRect(x: 15, y: currentHeight + 25, width: view.bounds.width - 10, height: 20))
        additionalTitleLabel.text = "Live Exams"
        additionalTitleLabel.textAlignment = .left
        additionalTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(additionalTitleLabel)
        currentHeight += 30
        
        liveQuestionView.translatesAutoresizingMaskIntoConstraints = false
        liveQuestionView.backgroundColor = .white
        liveQuestionView.delegate = self
        headerView.addSubview(liveQuestionView)
        
        NSLayoutConstraint.activate([
            liveQuestionView.topAnchor.constraint(equalTo: additionalTitleLabel.bottomAnchor, constant: 10),
            liveQuestionView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 13),
            liveQuestionView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -13)
        ])
        
        currentHeight += liveQuestionView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 20
        
        let additionalTitleLabel2 = UILabel(frame: CGRect(x: 15, y: currentHeight + 25, width: view.bounds.width - 10, height: 40))
        additionalTitleLabel2.text = "Practice MCQ's"
        additionalTitleLabel2.textAlignment = .left
        additionalTitleLabel2.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(additionalTitleLabel2)
        currentHeight += 40
        
        practiceQuestionView.frame = CGRect(x: 13, y: currentHeight + 25, width: view.bounds.width - 25, height: 60)
        practiceQuestionView.backgroundColor = .systemBackground
        headerView.addSubview(practiceQuestionView)
        currentHeight += 70
        
        let additionalTitleLabel4 = UILabel(frame: CGRect(x: 13, y: currentHeight + 25, width: view.bounds.width - 15, height: 20))
        additionalTitleLabel4.text = "Recent Updates"
        additionalTitleLabel4.textAlignment = .left
        additionalTitleLabel4.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(additionalTitleLabel4)
        currentHeight += 30
        
        recentQuestionView.frame = CGRect(x: 13, y: currentHeight + 25, width: view.bounds.width - 25, height: 60)
        recentQuestionView.backgroundColor = .systemBackground
        headerView.addSubview(recentQuestionView)
        currentHeight += 70
        
        let additionalTitleLabel5 = UILabel(frame: CGRect(x: 13, y: currentHeight + 25, width: view.bounds.width - 15, height: 20))
        additionalTitleLabel5.text = "Share Application with Others"
        additionalTitleLabel5.textAlignment = .left
        additionalTitleLabel5.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(additionalTitleLabel5)
        currentHeight += 30
        
        shareApplicationwithOthers.frame = CGRect(x: 13, y: currentHeight + 25, width: view.bounds.width - 25, height: 100)
        shareApplicationwithOthers.backgroundColor = .systemBackground
        headerView.addSubview(shareApplicationwithOthers)
        currentHeight += 110
        
        headerView.frame.size.height = currentHeight
        homeFeedTable.tableHeaderView = headerView
    }
    
    private func setupContinueSolvingCard() {
        continueSolvingCard.isHidden = true
        
        view.addSubview(continueSolvingCard)
        continueSolvingCard.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            continueSolvingCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            continueSolvingCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            continueSolvingCard.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            continueSolvingCard.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        continueSolvingCard.configure(
            withTitle: "Loading...",
            progress: 0.35,
            progressText: "Loading... | Loading...",
            image: UIImage(named: "")
        )
        
        if let phoneNumber = self.phoneNumber {
            continueSolvingCard.fetchQuizProgress(for: phoneNumber)
        } else {
            print("No phone number available to fetch quiz progress.")
        }
    }
    
    private func setupIcons() {
        let notificationButton = UIButton(type: .custom)
        if let notificationImage = UIImage(systemName: "bell")?.withTintColor(.black, renderingMode: .alwaysOriginal) {
            notificationButton.setImage(notificationImage, for: .normal)
        }
        notificationButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        notificationButton.addTarget(self, action: #selector(didTapNotification), for: .touchUpInside)
        let notificationItem = UIBarButtonItem(customView: notificationButton)

        let lottieAnimationView = AnimationView(name: "premiumlottie")
        lottieAnimationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        lottieAnimationView.contentMode = .scaleAspectFit
        lottieAnimationView.loopMode = .playOnce
        lottieAnimationView.play()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapLottieAnimation))
        lottieAnimationView.isUserInteractionEnabled = true
        lottieAnimationView.addGestureRecognizer(tapGestureRecognizer)

        let lottieItem = UIBarButtonItem(customView: lottieAnimationView)

        navigationItem.rightBarButtonItems = [notificationItem, lottieItem]
    }

    @objc private func didTapLottieAnimation() {
        let plansVC = PlansViewController()
        plansVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(plansVC, animated: true)
    }

    // MARK: - Actions
    @objc func didTapDropdown() {
        showCustomPickerView()
    }
    
    @objc func didTapNotification() {
        let notificationVC = NotificationViewController()
        notificationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    private func showCustomPickerView() {
        guard customPickerTableView == nil else { return }
        
        let containerView = UIView(frame: CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 250))
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        self.blurEffectView = blurEffectView
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 50, width: view.bounds.width, height: 200), style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomPickerCell.self, forCellReuseIdentifier: "CustomPickerCell")
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        containerView.addSubview(tableView)
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(dismissCustomPickerView), for: .touchUpInside)
        containerView.addSubview(doneButton)
        doneButton.frame = CGRect(x: view.bounds.width - 70, y: 10, width: 60, height: 30)
        
        self.customPickerContainerView = containerView
        self.customPickerTableView = tableView
        
        view.bringSubviewToFront(containerView)
        
        UIView.animate(withDuration: 0.3) {
            containerView.frame.origin.y = self.view.bounds.height - 250
        }
    }
    
    @objc private func dismissCustomPickerView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.customPickerContainerView?.frame.origin.y = self.view.bounds.height
            self.blurEffectView?.alpha = 0
        }, completion: { _ in
            self.customPickerContainerView?.removeFromSuperview()
            self.customPickerTableView?.removeFromSuperview()
            self.blurEffectView?.removeFromSuperview()
            self.customPickerContainerView = nil
            self.customPickerTableView = nil
            self.blurEffectView = nil
        })
    }
    
    private func updateDropdownSelection(with index: Int) {
        dropdownButton.setTitle("\(options[index]) ▼", for: .normal)
    }
    
    func didTapContinueSolvingCard(withExamID examID: String, lastQuestionIndex: Int) {
        let prepPortalVC = PreparationPortalViewController()
        prepPortalVC.examID = examID
        prepPortalVC.currentQuestionIndex = lastQuestionIndex
        prepPortalVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(prepPortalVC, animated: true)
    }

    
    func didTapRecentUpdates() {
        let notificationVC = NotificationViewController()
        notificationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    func didTapShareApp() {
        let itemsToShare = ["Check out mymedicos! Here's the link to download the app: [App Link]"]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true)
    }
    
    func didTapLearnMore() {
        let detailedVC = DailyQuestionDetailedViewController()
        detailedVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailedVC, animated: true)
    }
    
    func didTapPGNeetButton() {
        print("PG NEET button tapped")
        let pgneetVC = NeetPgTabbarViewController()
        pgneetVC.setupWith(title: "PGNEET")
        pgneetVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(pgneetVC, animated: true)
    }

    func didTapFMGEButton() {
        print("FMGE button tapped")
        let fmgeVC = FmgeTabbarViewController()
        fmgeVC.setupWith(title: "FMGE")
        fmgeVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(fmgeVC, animated: true)
    }

    
    func didTapNeetssButton() {
        let neetssVC = NeetssTabbarViewController()
        neetssVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(neetssVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomPickerCell", for: indexPath) as! CustomPickerCell
        cell.titleLabel.text = options[indexPath.row]
        cell.radioButton.isSelected = (indexPath.row == selectedOptionIndex)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = options[indexPath.row]
        if selectedOption == "Community" {
            let alert = UIAlertController(title: "Notice", message: "Community is under maintenance right now.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            selectedOptionIndex = indexPath.row
            tableView.reloadData()
            updateDropdownSelection(with: selectedOptionIndex)
        }
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
    
    private func updateIconColors() {
        let currentTheme = traitCollection.userInterfaceStyle
        let color = currentTheme == .dark ? UIColor.white : UIColor.black
        navigationController?.navigationBar.tintColor = color
    }
}
