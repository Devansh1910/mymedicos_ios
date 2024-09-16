import UIKit
import WebKit

class TermsnConditionsViewController: UIViewController {

    var webView: WKWebView!

    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        view.overrideUserInterfaceStyle = .light
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the custom back button
        setupCustomBackButton()

        let htmlContent = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <title>Privacy Policy - mymedicos</title>
        <style>
            body {
                font-family: 'Inter', sans-serif; /* Ensure Inter is included in your app or accessible via web font */
                font-size: 24px; /* Set the font size to 16px */
                font-weight: 500; /* Medium weight for Inter */
                margin: 40px; /* Optional: adds some spacing around the text */
            }
        </style>
        </head>
        <body>
        <h1>PRIVACY POLICY</h1>
        <p>Last updated on April 17th 2024</p>

        <p>Thank you for using mymedicos, a mobile application designed to provide educational updates and verification services. Your privacy and security are important to us. This Privacy Policy outlines the information we collect, how we use it, and the choices you have regarding your information.</p>

        <h2>1. Information We Collect</h2>
        <ul>
            <li><strong>1.1 Personal Information:</strong> When you register for an account on mymedicos, we may collect personal information such as your name, email address, and mobile phone number. This information is collected for verification purposes and to enhance your user experience.</li><br>
            <li><strong>1.2 Verification Information:</strong> In order to verify your identity, we may collect and process additional information such as your mobile phone number. This information is used solely for verification purposes and is securely stored.</li><br>
            <li><strong>1.3 Usage Information:</strong> We may collect information about how you interact with the mymedicos app, including the pages you visit, the features you use, and the actions you take. This information helps us improve the app and provide a better user experience.</li>
        </ul>

        <h2>2. Use of Information</h2>
        <ul>
            <li><strong>2.1 Personalization:</strong> We may use the information collected to personalize your experience on the mymedicos app, such as providing educational updates tailored to your interests.</li><br>
            <li><strong>2.2 Communication:</strong> We may use your email address and mobile phone number to communicate with you about account-related matters, updates to our services, and educational content.</li><br>
            <li><strong>2.3 Security:</strong> Your information may be used to enhance the security of the mymedicos app and to prevent fraudulent activity.</li>
        </ul>

        <h2>3. Sharing of Information</h2>
        <ul>
            <li><strong>3.1 Third-Party Service Providers:</strong> We may share your information with third-party service providers who assist us in providing and improving the mymedicos app. These service providers are contractually obligated to protect your information and only use it for the purposes specified by us.</li><br>
            <li><strong>3.2 Legal Compliance:</strong> We may disclose your information if required to do so by law or in response to a valid legal request, such as a court order or subpoena.</li>
        </ul>

        <h2>4. Data Security</h2>
        <p>We take the security of your information seriously and implement appropriate technical and organizational measures to protect it against unauthorized access, alteration, disclosure, or destruction.</p>
        <p><strong>4.1 Account Delete:</strong> Please contact Us at <a href="mailto:support@mymedicos.in">support@mymedicos.in</a> if you would like to delete Your account and/or the information associated with it.</p>

        <h2>5. Your Choices</h2>
        <ul>
            <li><strong>5.1 Account Information:</strong> You may review, update, or delete the personal information associated with your mymedicos account at any time by accessing your account settings.</li><br>
            <li><strong>5.2 Communication Preferences:</strong> You can choose to opt out of receiving promotional emails or SMS messages from us by following the instructions provided in the messages or by contacting us directly.</li>
        </ul>

        <h2>6. Children’s Privacy</h2>
        <p>The mymedicos app is not intended for use by children under the age of 13. We do not knowingly collect personal information from children under 13 years of age. If you believe that we have inadvertently collected information from a child under 13, please contact us immediately so that we can take appropriate action.</p>

        <h2>7. Changes to this Privacy Policy</h2>
        <p>We reserve the right to update or modify this Privacy Policy at any time. If we make material changes to this Privacy Policy, we will notify you by email or by posting a notice in the mymedicos app prior to the changes taking effect. Your continued use of the mymedicos app after the effective date of the revised Privacy Policy constitutes your acceptance of the changes.</p>

        <h2>8. Contact Us</h2>
        <p>If you have any questions or concerns about this Privacy Policy or our privacy practices, please contact us at <a href="mailto:contact@mymedicos.in">contact@mymedicos.in</a></p>

        </body>
        </html>
        """

        // Load the HTML string into the WebView
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }

    func setupCustomBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        let barButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = barButtonItem
    }

    @objc func backButtonTapped() {
        // Handle the back action
        navigationController?.popViewController(animated: true)
    }
}
