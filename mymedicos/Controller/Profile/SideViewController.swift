import UIKit

class SideViewController: UIViewController {
    
    // UI Components
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let profileImageView = UIImageView()
    let titleLabel = UILabel()
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let phoneLabel = UILabel()
    let specialityLabel = UILabel()
    let tableView = UITableView()
    let freeBadgeLabel = UILabel()
    let socialMediaStackView = UIStackView()
    
    // Menu Sections

    let menuSections = [
        ("Account Verification", ["Account Verification"]),
        ("Customize Profile", ["Customize Profile"]),
        ("More", ["Chat with us", "Join Community", "Settings", "Refer to a Friend"]),
        ("Others", ["Log Out", "Delete Account"])
    ]
    
    // Implementatons

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupLayout()
        styleComponents()
    }
    
    // Setting up the layout Structuring

    func setupLayout() {
        view.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        specialityLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        freeBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        socialMediaStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(profileImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(phoneLabel)
        contentView.addSubview(specialityLabel)
        contentView.addSubview(socialMediaStackView)
        contentView.addSubview(tableView)
        contentView.addSubview(freeBadgeLabel)

        tableView.dataSource = self
        tableView.delegate = self

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -100),
            titleLabel.widthAnchor.constraint(equalToConstant: 30),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),

            freeBadgeLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: -5),
            freeBadgeLabel.rightAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 5),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),


            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            emailLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            phoneLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            phoneLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            specialityLabel.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 10),
            specialityLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            specialityLabel.heightAnchor.constraint(equalToConstant: 30),
            specialityLabel.widthAnchor.constraint(equalToConstant: 150),

            socialMediaStackView.topAnchor.constraint(equalTo: specialityLabel.bottomAnchor, constant: 20),
            socialMediaStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            socialMediaStackView.heightAnchor.constraint(equalToConstant: 30),

            tableView.topAnchor.constraint(equalTo: socialMediaStackView.bottomAnchor, constant: 20),
            tableView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
    
    // Styling up the above fiedlds (name and other)

    func styleComponents() {
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(named: "brain") // Add your image name

        nameLabel.text = "Dr. Devansh Saxena"
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)

        emailLabel.text = "test@gmail.com"
        phoneLabel.text = "+919876543210"

        specialityLabel.text = "Neurologist"
        specialityLabel.textAlignment = .center
        specialityLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        specialityLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        specialityLabel.layer.cornerRadius = 15
        specialityLabel.clipsToBounds = true

        freeBadgeLabel.text = "Free"
        freeBadgeLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        freeBadgeLabel.textColor = .white
        freeBadgeLabel.backgroundColor = .red
        freeBadgeLabel.layer.cornerRadius = 10
        freeBadgeLabel.clipsToBounds = true
        freeBadgeLabel.textAlignment = .center
        freeBadgeLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        freeBadgeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let instagramImageView = createSocialMediaImageView(named: "instagram")
        let telegramImageView = createSocialMediaImageView(named: "telegram")

        socialMediaStackView.axis = .horizontal
        socialMediaStackView.alignment = .center
        socialMediaStackView.distribution = .equalSpacing
        socialMediaStackView.spacing = 20

        socialMediaStackView.addArrangedSubview(instagramImageView)
        socialMediaStackView.addArrangedSubview(telegramImageView)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // Setting up the social media handles

    func createSocialMediaImageView(named: String) -> UIImageView {
        let imageView = UIImageView()

        if let image = UIImage(named: named) {
            imageView.image = image
        } else {
            switch named {
            case "instagram":
                imageView.image = UIImage(systemName: "photo")
            case "telegram":
                imageView.image = UIImage(systemName: "paperplane")
            default:
                imageView.image = UIImage(systemName: "questionmark.circle")
            }
        }

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        if named == "instagram" || named == "telegram" {
            imageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: named == "instagram" ? #selector(openInstagram) : #selector(openTelegramIcon))
            imageView.addGestureRecognizer(tapGesture)
        }

        return imageView
    }
    
    // Opening Instagram on clicking on the icon

    @objc func openInstagram() {
        let urlString = "https://www.instagram.com/mymedicos_official?utm_source=ig_web_button_share_sheet&igsh=ZDNlZDc0MzIxNw=="
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Instagram is not installed on your device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    // Opening Telegram on clicking on the Icons
    
    @objc func openTelegramIcon() {
        let urlString = "https://t.me/mymedicos_official"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Telegram is not installed on your device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    // Navigations throughout the application Sidebar View
    
    @objc func didTapAccountVc() {
        let accountVC = AccountVerificationViewController()
        accountVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(accountVC, animated: true)
    }
    
    @objc func didTapCustomizeProfile() {
        let customizeprofileVC = CustomizeProfileViewController()
        customizeprofileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(customizeprofileVC, animated: true)
    }
    
    @objc func didTapSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    // icons setup

    private func iconName(for menuItem: String) -> String {
        switch menuItem {
        case "Verify Email": return "envelope.open"
        case "Verify Phone": return "phone.circle"
        case "Customize Profile": return "person.crop.circle"
        case "Chat with us": return "message"
        case "Join Community": return "person.3"
        case "Settings": return "gear"
        case "Refer to a Friend": return "person.badge.plus"
        case "Log Out": return "arrow.right.square"
        case "Delete Account": return "trash"
        default: return "questionmark.circle"
        }
    }
}

extension SideViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Telegram Connection
    
    func openTelegram() {
        let link = "https://t.me/+DEYzADSaLuoxNzM1"  // Replace 'yourcommunityname' with your actual Telegram group/channel name.
        if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Optionally, alert the user if Telegram is not installed
            let alert = UIAlertController(title: "Error", message: "Telegram is not installed on your device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuSections[section].1.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menuSections[section].0
    }
    
    // Logout and Delete Account functionality
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let menuItem = menuSections[indexPath.section].1[indexPath.row]
        cell.textLabel?.text = menuItem
        cell.imageView?.image = UIImage(systemName: iconName(for: menuItem))
        
        if menuItem == "Log Out" || menuItem == "Delete Account" {
            cell.textLabel?.textColor = .red
            cell.imageView?.tintColor = .red
        } else {
            cell.textLabel?.textColor = .black
            cell.imageView?.tintColor = .black
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // Setting up the Options to Navigate from teh SideViewController
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let menuItem = menuSections[indexPath.section].1[indexPath.row]
        
        switch menuItem {
        case "Customize Profile":
            didTapCustomizeProfile()
        case "Settings":
            didTapSettings()
        case "Account Verification":
            didTapAccountVc()
        case "Chat with us":
            showChatOptions()
        case "Join Community":
            openTelegram()
        case "Refer to a Friend":
            shareApplication()
        case "Log Out":
            logout()
        default:
            break
        }
    }
    
    // Opening Whatsapp and Telegram Selection Bottom up box for Chat Operations
    
    func showChatOptions() {
        let alertController = UIAlertController(title: "Contact us", message: "Choose your preferred way to chat with us:", preferredStyle: .actionSheet)
        alertController.overrideUserInterfaceStyle = .light
        
        let whatsappAction = UIAlertAction(title: "Chat on WhatsApp", style: .default) { action in
            self.openWhatsApp()
        }
        let telegramAction = UIAlertAction(title: "Join Telegram Community", style: .default) { action in
            self.openTelegram()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(whatsappAction)
        alertController.addAction(telegramAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(alertController, animated: true)
    }
    
    // opening Whatsapp Number : mymedicos : official contact number
    
    func openWhatsApp() {
        let link = "https://wa.me/message/AB2QUXAZYEV2E1"
        if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "WhatsApp is not installed on your device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    // sharing application to other : Link have to be updated of the Appstore
    
    func shareApplication() {
        let appLink = "https://apps.apple.com/in/app/marginnote-3/id1423522373?mt=12"
        let message = "Check out our medical app! Download now: \(appLink)"
        let items = [message]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        activityViewController.popoverPresentationController?.permittedArrowDirections = []
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // Logout functionality
    
    func logout() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to Logout as @Devansh?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { [weak self] _ in
            self?.showLogoutProgress()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    // Tries to showcase username while logging out.

    
    private func attributedUsername() -> NSAttributedString {
        let username = "@Devansh"
        let attributedString = NSMutableAttributedString(string: username)
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: NSRange(location: 0, length: username.count))
        return attributedString
    }
    
    // Logging out Dialogue
    
    private func showLogoutProgress() {
        let alert = UIAlertController(title: nil, message: "Logging out..", preferredStyle: .alert)
        present(alert, animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Simulate logout process duration
                alert.dismiss(animated: true) { [weak self] in
                    self?.navigateToLoginViewController()
                }
            }
        })
    }
    
    // After logout Success navigate to the LoginViewController
    
    private func navigateToLoginViewController() {
        let loginViewController = LoginViewController() // Assume you have a LoginViewController
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = loginViewController
            window.makeKeyAndVisible()
        }
    }
}
