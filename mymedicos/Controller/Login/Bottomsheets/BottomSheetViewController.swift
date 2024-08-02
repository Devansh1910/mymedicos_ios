import UIKit
import MessageUI

class BottomSheetViewController: UIViewController, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDismissGesture()
    }

    func setupUI() {
        view.backgroundColor = .white

        // Help Section
        let helpLabel = UILabel()
        helpLabel.text = "Having trouble? Reach us on help@mymedicos.com"
        helpLabel.textAlignment = .center
        helpLabel.textColor = .black
        helpLabel.numberOfLines = 0
        helpLabel.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(helpLabel)
        helpLabel.translatesAutoresizingMaskIntoConstraints = false

        let helpButton = UIButton()
        helpButton.setTitle("help@mymedicos.com", for: .normal)
        helpButton.setTitleColor(.blue, for: .normal)
        helpButton.backgroundColor = .clear
        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        helpButton.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)
        view.addSubview(helpButton)
        helpButton.translatesAutoresizingMaskIntoConstraints = false

        let helpDivider = UIView()
        helpDivider.backgroundColor = .lightGray
        view.addSubview(helpDivider)
        helpDivider.translatesAutoresizingMaskIntoConstraints = false

        // Privacy Section
        let privacyLabel = UILabel()
        privacyLabel.text = "Concerned about your Data? Checkout our Privacy Policy"
        privacyLabel.textAlignment = .center
        privacyLabel.textColor = .black
        privacyLabel.numberOfLines = 0
        privacyLabel.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(privacyLabel)
        privacyLabel.translatesAutoresizingMaskIntoConstraints = false

        let privacyButton = UIButton()
        privacyButton.setTitle("Privacy Policy", for: .normal)
        privacyButton.setTitleColor(.blue, for: .normal)
        privacyButton.backgroundColor = .clear
        privacyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        view.addSubview(privacyButton)
        privacyButton.translatesAutoresizingMaskIntoConstraints = false

        let privacyDivider = UIView()
        privacyDivider.backgroundColor = .lightGray
        view.addSubview(privacyDivider)
        privacyDivider.translatesAutoresizingMaskIntoConstraints = false

        // Terms Section
        let termsLabel = UILabel()
        termsLabel.text = "Want to learn more about mymedicos? Checkout our Terms of Use"
        termsLabel.textAlignment = .center
        termsLabel.numberOfLines = 0
        termsLabel.textColor = .black
        termsLabel.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(termsLabel)
        termsLabel.translatesAutoresizingMaskIntoConstraints = false

        let termsButton = UIButton()
        termsButton.setTitle("Terms of Use", for: .normal)
        termsButton.setTitleColor(.blue, for: .normal)
        termsButton.backgroundColor = .clear
        termsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        termsButton.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)
        view.addSubview(termsButton)
        termsButton.translatesAutoresizingMaskIntoConstraints = false

        // Layout
        NSLayoutConstraint.activate([
            helpLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            helpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            helpLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),

            helpButton.topAnchor.constraint(equalTo: helpLabel.bottomAnchor, constant: 2),
            helpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            helpDivider.topAnchor.constraint(equalTo: helpButton.bottomAnchor, constant: 5),
            helpDivider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            helpDivider.widthAnchor.constraint(equalTo: view.widthAnchor),
            helpDivider.heightAnchor.constraint(equalToConstant: 1),

            privacyLabel.topAnchor.constraint(equalTo: helpDivider.bottomAnchor, constant: 15),
            privacyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            privacyLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),

            privacyButton.topAnchor.constraint(equalTo: privacyLabel.bottomAnchor, constant: 2),
            privacyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            privacyDivider.topAnchor.constraint(equalTo: privacyButton.bottomAnchor, constant: 5),
            privacyDivider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            privacyDivider.widthAnchor.constraint(equalTo: view.widthAnchor),
            privacyDivider.heightAnchor.constraint(equalToConstant: 1),

            termsLabel.topAnchor.constraint(equalTo: privacyDivider.bottomAnchor, constant: 15),
            termsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            termsLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),

            termsButton.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 2),
            termsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissBottomSheet))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissBottomSheet() {
        dismiss(animated: true)
    }

    @objc func helpTapped() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients(["contact@mymedicos.in"])
            mailComposer.setSubject("Would like to get connected, Received an Issue")
            present(mailComposer, animated: true)
        } else {
            print("Mail services are not available")
        }
    }

    @objc func privacyTapped() {
        let privacyVC = UINavigationController(rootViewController: HomeViewController())
    }

    @objc func termsTapped() {
        let termsVC = TermsandConditionsViewController()
        navigationController?.pushViewController(termsVC, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Check if the touch is on a button, if so, don't recognize the gesture
        if touch.view is UIButton {
            return false
        }
        return true
    }
}
