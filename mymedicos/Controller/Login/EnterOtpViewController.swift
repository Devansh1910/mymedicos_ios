import UIKit

// NSLayoutConstraint extension to set priority
extension NSLayoutConstraint {
    func withPriority(_ priority: Float) -> NSLayoutConstraint {
        self.priority = UILayoutPriority(rawValue: priority)
    
        return self
    }
}

class EnterOtpViewController: UIViewController, UITextFieldDelegate {
    
    var phoneNumber = "+919838720784"  // Placeholder for dynamic phone number
    
    // UI components
    let titleLabel = UILabel()
    let instructionLabel = UILabel()
    var otpTextFields = [UITextField]()
    let troubleLabel = UILabel()
    let contactLabel = UILabel()
    let verifyButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        // Setup title label
        titleLabel.text = "Verification"
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .black
        view.addSubview(titleLabel)
        
        // Setup instruction label
        instructionLabel.text = "A One time password is sent to \(phoneNumber)"
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        instructionLabel.textColor = .gray
        view.addSubview(instructionLabel)
        
        // Setup OTP text fields
        // Setup OTP Text Fields
        for i in 0..<6 {
            let textField = UITextField()
            textField.tag = 100 + i  // Ensure tags are set to distinguish text fields
            textField.textAlignment = .center
            textField.font = UIFont.systemFont(ofSize: 18)
            textField.textColor = .black  // Ensure text color is black
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 5
            textField.layer.borderColor = UIColor.gray.cgColor
            textField.keyboardType = .numberPad
            textField.textContentType = .oneTimeCode
            textField.isSecureTextEntry = false  // Change to false to show numbers
            textField.delegate = self
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            otpTextFields.append(textField)
            view.addSubview(textField)
        }

        
        // Setup trouble label
        troubleLabel.text = "Having trouble?"
        troubleLabel.font = UIFont.systemFont(ofSize: 14)
        troubleLabel.textColor = .gray
        troubleLabel.textAlignment = .left
        view.addSubview(troubleLabel)
        
        // Setup contact label
        contactLabel.text = "Reach us on contact@mymedicos.in"
        contactLabel.font = UIFont.systemFont(ofSize: 14)
        contactLabel.textColor = .gray
        contactLabel.textAlignment = .left
        view.addSubview(contactLabel)
        
        // Setup verify button
        verifyButton.setTitle("Verify", for: .normal)
        verifyButton.backgroundColor = .gray
        verifyButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(verifyButton)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text
        if text?.count == 1 {
            if let nextTextField = view.viewWithTag(textField.tag + 1) as? UITextField {
                nextTextField.becomeFirstResponder()
            }
        } else if text?.isEmpty == true {
            if let previousTextField = view.viewWithTag(textField.tag - 1) as? UITextField {
                previousTextField.becomeFirstResponder()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // Check if we are adding a character
        if string.count > 0 {
            if updatedText.count > 1 {
                // Prevent more than one character in a text field
                return false
            } else {
                // Set the text manually and move to next text field if there is one
                textField.text = string
                if let nextTextField = view.viewWithTag(textField.tag + 1) as? UITextField {
                    nextTextField.becomeFirstResponder()
                }
                return false
            }
        } else if string.count == 0 && currentText.count > 0 { // Handling backspace
            // Clear the text and move to previous text field if there is one
            textField.text = ""  // Clear the current text field
            if let previousTextField = view.viewWithTag(textField.tag - 1) as? UITextField {
                previousTextField.becomeFirstResponder()
            }
            return false // Do not allow the system to handle backspace (to avoid duplicate handling)
        }
        return true
    }


    
    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        troubleLabel.translatesAutoresizingMaskIntoConstraints = false
        contactLabel.translatesAutoresizingMaskIntoConstraints = false
        verifyButton.translatesAutoresizingMaskIntoConstraints = false
        otpTextFields.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        let totalSpacing = CGFloat(otpTextFields.count - 1) * 15
        let totalWidth = CGFloat(otpTextFields.count * 50) + totalSpacing
        
        NSLayoutConstraint.activate([
            otpTextFields.first!.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -(totalWidth / 2) + 25),
            otpTextFields.first!.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            otpTextFields.first!.widthAnchor.constraint(equalToConstant: 50),
            otpTextFields.first!.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        var previousField: UITextField = otpTextFields.first!
        for i in 1..<otpTextFields.count {
            let textField = otpTextFields[i]
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: previousField.trailingAnchor, constant: 15),
                textField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
                textField.widthAnchor.constraint(equalToConstant: 50),
                textField.heightAnchor.constraint(equalToConstant: 50)
            ])
            previousField = textField
        }
        
        NSLayoutConstraint.activate([
            troubleLabel.topAnchor.constraint(equalTo: otpTextFields.first!.bottomAnchor, constant: 20),
            troubleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            troubleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            contactLabel.topAnchor.constraint(equalTo: troubleLabel.bottomAnchor, constant: 5),
            contactLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            contactLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            verifyButton.topAnchor.constraint(equalTo: contactLabel.bottomAnchor, constant: 20),
            verifyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            verifyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            verifyButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
