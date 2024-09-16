import UIKit
import SwiftUI
import Lottie

class ProfileViewController: UIViewController, ProfileGridDelegate, OtherGridDelegate {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let profileGrid = ProfileGrid()
    private let otherGrid = OtherGrid()
    private let completeProfile = CompleteProfileUIView()
    private let userInterface = AccountCardUIView()
    private let featuresLabel = UILabel()
    private let optionsLabel = UILabel()
    private let otherLabel = UILabel()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        overrideUserInterfaceStyle = .light

        profileGrid.delegate = self
        otherGrid.delegate = self
        
        configureNavbar()
        setupScrollView()
        setupViewsAndConstraints()
    }
    
    func navigateToTermsAndConditions() {
        let termsVC = TermsnConditionsViewController()
        termsVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(termsVC, animated: true)
    }
    
    func navigateToReportIssue() {
        let reportVC = ReportIssueViewController()
        reportVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(reportVC, animated: true)
    }
    
    func navigateToaboutus() {
        let aboutUsView = Aboutus() // Your SwiftUI view
        let hostingController = UIHostingController(rootView: aboutUsView)
        hostingController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(hostingController, animated: true)
    }


    // Navigation methods
    func navigateToApplyCoupons() {
        let applyCouponsVC = ApplyCouponViewController()
        applyCouponsVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(applyCouponsVC, animated: true)
    }

    func navigateToViewPlans() {
        let viewPlansVC = PlansViewController()
        viewPlansVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewPlansVC, animated: true)
    }

    func showChatOptions() {
        let alertController = UIAlertController(title: "Contact us", message: "Choose your preferred way to chat with us:", preferredStyle: .actionSheet)
        alertController.overrideUserInterfaceStyle = .light
        
        let whatsappAction = UIAlertAction(title: "Chat on WhatsApp", style: .default) { action in
            self.openWhatsApp()
        }
        let telegramAction = UIAlertAction(title: "Join Telegram Community", style: .default) { action in
            self.openTelegramIcon()
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

    func didTapSettings() {
        let settingsView = SettingsUIView()
        let hostingController = UIHostingController(rootView: settingsView)
        hostingController.hidesBottomBarWhenPushed = true
        hostingController.navigationItem.hidesBackButton = true
        present(hostingController, animated: true)
    }
    
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

    func openTelegramIcon() {
        let urlString = "https://t.me/mymedicos_official"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Telegram is not installed on your device.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }

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

    @objc func didTapNotification() {
        let notificationVC = NotificationViewController()
        notificationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(notificationVC, animated: true)
    }

    // Existing setup methods
    private func configureNavbar() {
        setupLogoInNavbar()
        setupTitleInNavbar()
        setupIcons()
    }

    private func setupLogoInNavbar() {
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
        navigationItem.leftBarButtonItems = [logoItem]
    }

    private func setupTitleInNavbar() {
        let titleLabel = UILabel()
        titleLabel.text = "Profile"
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        let titleItem = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItems?.append(titleItem)
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

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true  // Show scroll indicators
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),  // Pinning the bottom to scrollView's bottom
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),  // Ensure the contentView's width matches the scrollView
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)  // This line is crucial
        ])
    }

    private func setupViewsAndConstraints() {
        var lastView: UIView = setupCompleteProfile()
        lastView = setupOptionsLabel(below: lastView)
        lastView = setupUserInterfaceCard(below: lastView)
        lastView = setupFeaturesLabel(below: lastView)
        lastView = setupProfileGrid(below: lastView)
        lastView = setupOtherLabel(below: lastView)
        lastView = setupOtherGrid(below: lastView)

        contentView.bottomAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 20).isActive = true
    }
    
    private func setupCompleteProfile() -> UIView {
        contentView.addSubview(completeProfile)
        completeProfile.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            completeProfile.topAnchor.constraint(equalTo: contentView.topAnchor),
            completeProfile.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            completeProfile.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            completeProfile.heightAnchor.constraint(equalToConstant: 100)
        ])
        return completeProfile
    }

    private func setupOptionsLabel(below previousView: UIView) -> UIView {
        contentView.addSubview(optionsLabel)
        optionsLabel.text = "ACCOUNT"
        optionsLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        optionsLabel.textColor = .darkGray
        optionsLabel.textAlignment = .left
        optionsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            optionsLabel.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
            optionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            optionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            optionsLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        return optionsLabel
    }

    private func setupUserInterfaceCard(below previousView: UIView) -> UIView {
        contentView.addSubview(userInterface)
        userInterface.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userInterface.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 10),
            userInterface.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            userInterface.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            userInterface.heightAnchor.constraint(equalToConstant: 80)
        ])
        return userInterface
    }

    private func setupFeaturesLabel(below previousView: UIView) -> UIView {
        contentView.addSubview(featuresLabel)
        featuresLabel.text = "FEATURES"
        featuresLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        featuresLabel.textColor = .darkGray
        featuresLabel.textAlignment = .left
        featuresLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            featuresLabel.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
            featuresLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            featuresLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            featuresLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        return featuresLabel
    }

    private func setupProfileGrid(below previousView: UIView) -> UIView {
        contentView.addSubview(profileGrid)
        profileGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileGrid.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 10),
            profileGrid.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            profileGrid.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            profileGrid.heightAnchor.constraint(equalToConstant: 200)
        ])
        return profileGrid
    }

    private func setupOtherLabel(below previousView: UIView) -> UIView {
        contentView.addSubview(otherLabel)
        otherLabel.text = "OTHERS"
        otherLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        otherLabel.textColor = .darkGray
        otherLabel.textAlignment = .left
        otherLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            otherLabel.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 10),
            otherLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            otherLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            otherLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        return otherLabel
    }

    private func setupOtherGrid(below previousView: UIView) -> UIView {
        contentView.addSubview(otherGrid)
        otherGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            otherGrid.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 10),
            otherGrid.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            otherGrid.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            otherGrid.heightAnchor.constraint(equalToConstant: 200)
        ])
        return otherGrid
    }
    

}
