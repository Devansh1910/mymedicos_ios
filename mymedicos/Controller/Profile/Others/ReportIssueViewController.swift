import UIKit
import WebKit
import MessageUI

class ReportIssueViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!

    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        view.overrideUserInterfaceStyle = .light
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
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
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Report an Issue</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    margin: 0;
                    padding: 20px;
                    background-color: #f7f7f7;
                    color: #333;
                }
                h1 {
                    color: #2c3e50;
                    font-size: 26px;
                    margin-bottom: 10px;
                }
                p {
                    font-size: 16px;
                    color: #555;
                    line-height: 1.7;
                    margin-bottom: 20px;
                }
                form {
                    margin-top: 20px;
                }
                label {
                    display: block;
                    margin-bottom: 10px;
                    font-weight: bold;
                    color: #333;
                }
                input[type="text"],
                input[type="email"],
                select,
                textarea {
                    width: 100%;
                    padding: 12px;
                    margin-bottom: 20px;
                    border: 1px solid #ccc;
                    border-radius: 4px;
                    font-size: 16px;
                    box-sizing: border-box;
                }
                textarea {
                    resize: vertical;
                }
                button {
                    background-color: #292929;
                    color: #fff;
                    padding: 14px 22px;
                    border: none;
                    border-radius: 4px;
                    cursor: pointer;
                    font-size: 16px;
                }
                button:hover {
                    background-color: #218838;
                }
                .message {
                    margin-top: 30px;
                    font-size: 14px;
                    color: #888;
                }
            </style>
        </head>
        <body>

            <h1>Report an Issue</h1>
            <p>
                Your experience with our medical detection application is of utmost importance to us. If you encounter any issues, glitches, or inaccuracies, please use this form to report them. By sharing your feedback, you are directly contributing to the improvement and reliability of our service.
            </p>
            
            <p>
                Our team is committed to addressing any issues promptly. Whether it's a bug affecting the performance, a problem with the user interface, or concerns about the accuracy of the detection, your insights are invaluable. The information you provide will help us understand and resolve these issues more effectively.
            </p>
            
            <p>
                We understand that detailed information is key to diagnosing and fixing issues quickly. Please take a moment to provide as much detail as possible about the issue you encountered. The more specific you can be, the better we can assist you.
            </p>
            
            <form id="issueForm">
                <label for="issueType">Issue Type:</label>
                <select id="issueType" name="issueType" required>
                    <option value="" disabled selected>Select an issue type</option>
                    <option value="bug">Bug</option>
                    <option value="performance">Performance Issue</option>
                    <option value="accuracy">Detection Accuracy</option>
                    <option value="ui">User Interface</option>
                    <option value="other">Other</option>
                </select>

                <label for="description">Issue Description:</label>
                <textarea id="description" name="description" rows="6" placeholder="Please provide a detailed description of the issue, including what you were doing when it occurred..." required></textarea>

                <label for="steps">Steps to Reproduce:</label>
                <textarea id="steps" name="steps" rows="6" placeholder="Please describe the steps to reproduce the issue, if possible. This helps us to replicate and address the issue more effectively..." required></textarea>

                <label for="impact">Impact on Your Experience:</label>
                <textarea id="impact" name="impact" rows="4" placeholder="Please describe how this issue impacted your experience or ability to use the app effectively..." required></textarea>

                <label for="email">Your Email (optional):</label>
                <input type="email" id="email" name="email" placeholder="Your email address (optional, but useful if we need to follow up with you)">

                <label for="screenshot">Upload Screenshot (optional):</label>
                <input type="file" id="screenshot" name="screenshot" accept="image/*">
                
                <br><br>
                <button type="button" onclick="submitForm()">Report Issue</button>
            </form>

            <script type="text/javascript">
                function submitForm() {
                    var issueType = document.getElementById('issueType').value;
                    var description = document.getElementById('description').value;
                    var steps = document.getElementById('steps').value;
                    var impact = document.getElementById('impact').value;
                    var email = document.getElementById('email').value;

                    var body = 'Issue Type: ' + issueType + '\\n\\n' +
                               'Description: ' + description + '\\n\\n' +
                               'Steps to Reproduce: ' + steps + '\\n\\n' +
                               'Impact: ' + impact + '\\n\\n' +
                               'Email: ' + email;

                    window.location.href = 'mailto:mymedicosconsultancy@gmail.com?subject=Issue Report&body=' + encodeURIComponent(body);
                    
                    document.body.innerHTML = "<h1>Thank You</h1><p>Thanks for submitting your issue. We'll check your issue shortly.</p>";
                }
            </script>

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
