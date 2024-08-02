import UIKit
import WebKit

class TermsandConditionsViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    let backButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupWebView()
        loadHTMLContent()
    }

    func setupUI() {
        // Setup UI properties
        view.backgroundColor = UIColor(named: "backgroundcolor")
        
        // Setup back button
        backButton.setImage(UIImage(named: "arrow_bk"), for: .normal)
        backButton.frame = CGRect(x: 10, y: 50, width: 35, height: 35)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
    }

    func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        // Setup Auto Layout constraints
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func loadHTMLContent() {
        let htmlContent = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Terms and Conditions</title>
        <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.6; color: #333; margin: 20px; padding: 0; background: #F5F5F5 }
        h1 { text-align: center; color: #353535; }
        h2 { color: #353535; border-bottom: 1px solid #ccc; padding-bottom: 5px; }
        p { margin-bottom: 15px; }
        ul { list-style-type: none; padding-left: 0; }
        ul li { margin-bottom: 10px; }
        .section-header { font-weight: bold; margin-top: 20px; }
        </style>
        </head>
        <body>
        <h1>Terms and Conditions</h1>
        <h2>Introduction</h2>
        <p>Welcome to the mymedicos app, a mobile application and website (collectively, the “App”) owned and operated by Broverg Corporation Private Limited (“Broverg”, “we”, “us”, or “our”). The App is designed to provide medical and healthcare community students and professionals with access to a variety of educational resources, including clinical practice guidelines, medical news, and drug information.</p>
        <h2>Acceptance of Terms</h2>
        <p>By accessing or using the App, you agree to be bound by these Terms and Conditions. If you do not agree to these Terms and Conditions, you may not access or use the App.</p>
        <h2>Eligibility</h2>
        <p>The App is intended for use by medical and healthcare community students and professionals. You must be at least 18 years of age to use the App.</p>
        <h2>Account Registration</h2>
        <p>To access certain features of the App, you may be required to register for an account. When registering for an account, you agree to provide accurate and complete information about yourself. You are responsible for maintaining the confidentiality of your account login information and for all activities that occur under your account.</p>
        <h2>User Conduct</h2>
        <p>You agree to use the App in a manner that is lawful, responsible, and respectful of others. You agree not to use the App for any illegal or unauthorized purpose, including, but not limited to, the following:</p>
        <ul>
        <li>Infringing the intellectual property rights of others</li>
        <li>Transmitting or posting any material that is harmful, obscene, threatening, harassing, or otherwise objectionable</li>
        <li>Engaging in any activity that could disrupt or interfere with the operation of the App</li>
        <li>Using the App to create a false identity or to impersonate another person</li>
        </ul>
        <h2>Intellectual Property</h2>
        <p>The App and all content contained therein, including, but not limited to, text, images, and videos, are protected by copyright, trademark, and other intellectual property laws. You may not reproduce, distribute, modify, or create derivative works of the App or its content without the prior written consent of Broverg.</p>
        <h2>User Data</h2>
        <p>We collect certain information from users of the App, including, but not limited to, your name, email address, and usage data. We use this information to provide you with the services and features of the App, to personalize your experience, and to improve the App. We may also share your information with third-party service providers who help us operate the App. We will not share your information with any third-party advertisers without your consent.</p>
        <h2>Third-Party Links</h2>
        <p>The App may contain links to third-party websites and services. We are not responsible for the content of any third-party websites or services, and we do not endorse any products or services offered by third parties.</p>
        <h2>Disclaimer of Warranties</h2>
        <p>The App is provided “as is” and without warranty of any kind, express or implied. Broverg disclaims all warranties, including, but not limited to, the implied warranties of merchantability, fitness for a particular purpose, and non-infringement.</p>
        <h2>Limitation of Liability</h2>
        <p>In no event shall Broverg be liable for any direct, indirect, incidental, special, or consequential damages arising out of or in connection with the use of or inability to use the App, even if Broverg has been advised of the possibility of such damages.</p>
        <h2>Indemnification</h2>
        <p>You agree to indemnify, defend, and hold harmless Broverg, its officers, directors, employees, agents, and affiliates from and against any and all claims, liabilities, damages, losses, costs, expenses, and fees (including reasonable attorneys’ fees) arising out of or in connection with your use of the App or your violation of these Terms and Conditions.</p>
        <h2>Changes to Terms</h2>
        <p>We may update these Terms and Conditions from time to time. We will notify you of any material changes by posting a notice on the App or by sending you an email. Your continued use of the App following the posting of any changes constitutes your acceptance of such changes.</p>
        <h2>Entire Agreement</h2>
        <p>These Terms and Conditions constitute the entire agreement between you and Broverg with respect to the App.</p>
        <h2>Governing Law</h2>
        <p>These Terms and Conditions shall be governed by and construed in accordance with the laws of the Republic of India, without regard to its conflict of laws principles.</p>
        <h2>Severability</h2>
        <p>If any provision of these Terms and Conditions is held to be invalid or unenforceable, such provision shall be struck from these Terms and Conditions and the remaining provisions shall remain in full force and effect.</p>
        <h2>Waiver</h2>
        <p>No waiver of any provision of these Terms and Conditions shall be deemed a further or continuing waiver of such provision or any other provision.</p>
        </body>
        </html>
        """
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }

    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
