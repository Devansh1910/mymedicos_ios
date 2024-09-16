import UIKit
import SwiftUI
import Firebase


class SideViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var phoneNumber: String?
    var userData: [String: Any]?
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
    
    
    let menuSections = [
//        ("Account Verification", ["Account Verification"]),
        ("Customize Profile", ["Customize Profile"]),
        ("More", ["Chat with us", "Join Community", "Refer to a Friend"]),
        ("Others", ["Log Out", "Delete Account"])
    ]
    
    // Implementatons

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupLayout()
        styleComponents()
        fetchUserDetails()
        fetchUserProfileImage() // Fetch the profile image
        
        if let phone = phoneNumber {
            print("Received phone number in SideViewController: \(phone)")
            phoneLabel.text = phone // Update phone label with the received phone number
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let phone = phoneNumber {
            fetchUserDetails()  // Re-fetch user details if there's a phone number set
        }
    }


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
            specialityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            specialityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            specialityLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            specialityLabel.heightAnchor.constraint(equalToConstant: 30),            specialityLabel.widthAnchor.constraint(equalToConstant: 150),

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
    
    func fetchUserDetails() {
        guard let phone = phoneNumber else {
            print("No phone number provided")
            return
        }

        // First, try to load cached user data
        if let cachedUserData = UserDefaults.standard.dictionary(forKey: "cachedUserData_\(phone)") {
            self.updateUserInterface(with: cachedUserData)
            return
        }

        let usersRef = Firestore.firestore().collection("users")
        let query = usersRef.whereField("Phone Number", isEqualTo: phone)

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }

            guard let querySnapshot = querySnapshot, querySnapshot.documents.count > 0 else {
                print("No documents found")
                return
            }

            let document = querySnapshot.documents.first
            if let data = document?.data() {
                UserDefaults.standard.set(data, forKey: "cachedUserData_\(phone)") // Cache the user data
                self.updateUserInterface(with: data)
            }
        }
    }

    private func clearCachedImage(phone: String) {
        let imagePath = getLocalImagePath(phone: phone)
        try? FileManager.default.removeItem(at: imagePath)
    }

    private func clearUserData() {
        if let phone = phoneNumber {
            clearCachedImage(phone: phone)
        }
        DispatchQueue.main.async { [weak self] in
            self?.nameLabel.text = "Loading.."
            self?.emailLabel.text = "Loading.."
            self?.phoneLabel.text = "Loading.."
            self?.specialityLabel.text = "Loading.."
            self?.profileImageView.image = nil
        }
    }

    func updateUserInterface(with userData: [String: Any]?) {
        DispatchQueue.main.async {
            self.nameLabel.text = userData?["Name"] as? String ?? "Name not available"
            self.emailLabel.text = userData?["Email ID"] as? String ?? "Email not available"
            self.phoneLabel.text = userData?["Phone Number"] as? String ?? "Phone not available"
            self.specialityLabel.text = userData?["Interest"] as? String ?? "Speciality not available"
            
            self.view.layoutIfNeeded()
        }
    }


    func styleComponents() {
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(named: "brain")

        nameLabel.text = "Loading.."
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)

        emailLabel.text = "Loading.."
        phoneLabel.text = "Loading.."

        specialityLabel.text = "Loading.."
        specialityLabel.numberOfLines = 0
        specialityLabel.textAlignment = .center
        specialityLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        specialityLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        specialityLabel.layer.cornerRadius = 15
        specialityLabel.clipsToBounds = true
        specialityLabel.adjustsFontSizeToFitWidth = true
        specialityLabel.minimumScaleFactor = 0.5

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
        let customizeProfileView = CustomizeProfileView()
        let hostingController = UIHostingController(rootView: customizeProfileView)
        hostingController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    // icons setup

    private func iconName(for menuItem: String) -> String {
        switch menuItem {
        case "Verify Email": return "envelope.open"
        case "Verify Phone": return "phone.circle"
        case "Customize Profile": return "person.crop.circle"
        case "Chat with us": return "message"
        case "Join Community": return "person.3"
//        case "Settings": return "gear"
        case "Refer to a Friend": return "person.badge.plus"
        case "Log Out": return "arrow.right.square"
        case "Delete Account": return "trash"
        default: return "questionmark.circle"
        }
    }
    
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
//        case "Settings":
//            didTapSettings()
//        case "Account Verification":
//            didTapAccountVc()
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
        
    func logout() {
        let userName = userData?["Name"] as? String ?? "user"
        let message = "Are you sure you want to logout as \(userName)?"
        let alertController = UIAlertController(title: "Logout", message: message, preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { [weak self] _ in
            self?.clearAllUserData()  // Clears all user data including cached data
            self?.showLogoutProgress()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    private func clearAllUserData() {
        if let phone = phoneNumber {
            // Clear cached data specific to the user
            UserDefaults.standard.removeObject(forKey: "cachedUserData_\(phone)")
            clearCachedImage(phone: phone)
        }
        // Reset labels and image to default state
        DispatchQueue.main.async { [weak self] in
            self?.nameLabel.text = "Loading.."
            self?.emailLabel.text = "Loading.."
            self?.phoneLabel.text = "Loading.."
            self?.specialityLabel.text = "Loading.."
            self?.profileImageView.image = nil
        }
    }

    private func showLogoutProgress() {
        let alert = UIAlertController(title: nil, message: "Logging out...", preferredStyle: .alert)
        
        if #available(iOS 13.0, *) {
            alert.overrideUserInterfaceStyle = .light
        }
        
        present(alert, animated: true, completion: {
            do {
                try Auth.auth().signOut()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Short delay to ensure user sees the logout process
                    alert.dismiss(animated: true) { [weak self] in
                        self?.clearUserData()
                        self?.navigateToLoginViewController()
                    }
                }
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
                alert.dismiss(animated: true) { [weak self] in
                    self?.presentErrorAlert(message: "Failed to log out: \(signOutError.localizedDescription)")
                }
            }
        })
    }
    
    func fetchUserProfileImage() {
        guard let phone = phoneNumber else {
            print("No phone number provided")
            return
        }
        
        let imagePath = getLocalImagePath(phone: phone)
        
        if let image = UIImage(contentsOfFile: imagePath.path) {
            self.profileImageView.image = image
            return
        }

        let firebaseImagePath = "users/\(phone)/profile_image.jpg"
        let storageRef = Storage.storage().reference(withPath: firebaseImagePath)

        let localFile = getLocalImagePath(phone: phone)

        storageRef.write(toFile: localFile) { url, error in
            if let error = error {
                print("Error downloading image to file: \(error)")
                return
            }
            if let url = url {
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(contentsOfFile: url.path)
                }
            }
        }

    }

    private func getLocalImagePath(phone: String) -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent("profile_image_\(phone).jpg")
    }

    // Display an error message if logout fails
    private func presentErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Logout Error", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }

    private func navigateToLoginViewController() {
        let getStartedViewController = GetStartedViewController()
        getStartedViewController.hidesBottomBarWhenPushed = true
        if let navigationController = self.navigationController {
            navigationController.setViewControllers([getStartedViewController], animated: true)
        }
    }
}
