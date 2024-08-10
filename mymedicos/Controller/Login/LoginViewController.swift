import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController, UITextFieldDelegate {

    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let logoImageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    let phoneNumberContainerView = UIView()
    let countrySelectorButton = UIButton()
    let phoneNumberTextField = UITextField()
    
    let continueButton = UIButton()
    let termsLabel = UILabel()
    
    var countryCodeData: [[String: Any]] = []
    var phoneNumberLimit: Int = 10  // Default phone number limit
    var countryPickerAlertController: UIAlertController?
    
    private let firestore = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        
        loadCountryCodes()
        setupScrollView()
        setupUI()
        setupCountrySelectorButtonAction()
        phoneNumberTextField.delegate = self
        preloadCountryPicker()
        setupContinueButtonAction() // Set up continue button action
    }

    private func loadCountryCodes() {
        if let path = Bundle.main.path(forResource: "CountryCode", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [[String: Any]] {
                    countryCodeData = jsonResult
                    setInitialCountry()
                }
            } catch {
                print("Error loading country codes: \(error)")
            }
        }
    }

    private func setInitialCountry() {
        if let defaultCountry = countryCodeData.first(where: { $0["id"] as? String == "0101" }) {
            if let name = defaultCountry["name"] as? String,
               let dialCode = defaultCountry["dial_code"] as? String,
               let flag = defaultCountry["flag"] as? String,
               let limit = defaultCountry["limit"] as? Int {
                countrySelectorButton.setTitle("\(flag) \(dialCode)", for: .normal)
                phoneNumberLimit = limit
            }
        }
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupUI() {
        addLogo()
        addTextLabels()
        addPhoneNumberInput()
        addContinueButton()
        addTermsText()
        setupConstraints()
    }

    private func addLogo() {
        logoImageView.image = UIImage(named: "logoImage")
        logoImageView.contentMode = .scaleAspectFit
        contentView.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func addTextLabels() {
        titleLabel.text = "India’s first premier medical community app, connecting healthcare experts seamlessly."
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)

        subtitleLabel.text = "MADE IN BHARAT ❤️"
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .gray
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
    }

    private func addPhoneNumberInput() {
        phoneNumberContainerView.layer.borderWidth = 1.0
        phoneNumberContainerView.layer.borderColor = UIColor.gray.cgColor
        phoneNumberContainerView.layer.cornerRadius = 10.0
        contentView.addSubview(phoneNumberContainerView)
        
        countrySelectorButton.setTitleColor(.black, for: .normal)
        countrySelectorButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        countrySelectorButton.backgroundColor = .white
        phoneNumberContainerView.addSubview(countrySelectorButton)

        phoneNumberTextField.placeholder = "Enter your phone number"
        phoneNumberTextField.borderStyle = .none
        phoneNumberTextField.font = UIFont.systemFont(ofSize: 14)
        phoneNumberTextField.keyboardType = .phonePad  // Set the keyboard type to phonePad
        phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberContainerView.addSubview(phoneNumberTextField)

        let leftBorder = UIView()
        leftBorder.backgroundColor = UIColor.gray
        leftBorder.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberContainerView.addSubview(leftBorder)

        NSLayoutConstraint.activate([
            leftBorder.leadingAnchor.constraint(equalTo: phoneNumberContainerView.leadingAnchor, constant: 80),
            leftBorder.widthAnchor.constraint(equalToConstant: 1),
            leftBorder.topAnchor.constraint(equalTo: phoneNumberContainerView.topAnchor),
            leftBorder.bottomAnchor.constraint(equalTo: phoneNumberContainerView.bottomAnchor),
            
            countrySelectorButton.leadingAnchor.constraint(equalTo: phoneNumberContainerView.leadingAnchor),
            countrySelectorButton.topAnchor.constraint(equalTo: phoneNumberContainerView.topAnchor),
            countrySelectorButton.bottomAnchor.constraint(equalTo: phoneNumberContainerView.bottomAnchor),
            countrySelectorButton.widthAnchor.constraint(equalToConstant: 100),
            
            phoneNumberTextField.leadingAnchor.constraint(equalTo: leftBorder.trailingAnchor, constant: 10),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: phoneNumberContainerView.trailingAnchor, constant: -10),
            phoneNumberTextField.topAnchor.constraint(equalTo: phoneNumberContainerView.topAnchor),
            phoneNumberTextField.bottomAnchor.constraint(equalTo: phoneNumberContainerView.bottomAnchor)
        ])
    }

    private func addContinueButton() {
        continueButton.setTitle("Continue", for: .normal)
        continueButton.backgroundColor = .darkGray
        continueButton.layer.cornerRadius = 5.0
        contentView.addSubview(continueButton)
    }

    private func addTermsText() {
        termsLabel.text = "By Clicking, I accept the terms of service and privacy policy"
        termsLabel.textAlignment = .center
        termsLabel.numberOfLines = 0
        termsLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(termsLabel)
    }

    private func setupConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberContainerView.translatesAutoresizingMaskIntoConstraints = false
        countrySelectorButton.translatesAutoresizingMaskIntoConstraints = false
        phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            phoneNumberContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            phoneNumberContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            phoneNumberContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            phoneNumberContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            countrySelectorButton.leadingAnchor.constraint(equalTo: phoneNumberContainerView.leadingAnchor),
            countrySelectorButton.topAnchor.constraint(equalTo: phoneNumberContainerView.topAnchor),
            countrySelectorButton.bottomAnchor.constraint(equalTo: phoneNumberContainerView.bottomAnchor),
            countrySelectorButton.widthAnchor.constraint(equalToConstant: 100),
            
            phoneNumberTextField.leadingAnchor.constraint(equalTo: countrySelectorButton.trailingAnchor, constant: 10),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: phoneNumberContainerView.trailingAnchor, constant: -10),
            phoneNumberTextField.topAnchor.constraint(equalTo: phoneNumberContainerView.topAnchor),
            phoneNumberTextField.bottomAnchor.constraint(equalTo: phoneNumberContainerView.bottomAnchor),
            
            continueButton.topAnchor.constraint(equalTo: phoneNumberContainerView.bottomAnchor, constant: 20),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            
            termsLabel.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 20),
            termsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            termsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            termsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setupCountrySelectorButtonAction() {
        countrySelectorButton.addTarget(self, action: #selector(showCountryPicker), for: .touchUpInside)
    }

    private func preloadCountryPicker() {
        countryPickerAlertController = UIAlertController(title: "Select Country", message: nil, preferredStyle: .actionSheet)
        for country in countryCodeData {
            if let name = country["name"] as? String, let dialCode = country["dial_code"] as? String, let flag = country["flag"] as? String {
                let action = UIAlertAction(title: "\(flag) \(name) (\(dialCode))", style: .default) { [weak self] _ in
                    self?.countrySelectorButton.setTitle("\(flag) \(dialCode)", for: .normal)
                    self?.phoneNumberLimit = country["limit"] as? Int ?? 10
                }
                countryPickerAlertController?.addAction(action)
            }
        }
        countryPickerAlertController?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }

    @objc private func showCountryPicker() {
        if let countryPickerAlertController = countryPickerAlertController {
            present(countryPickerAlertController, animated: true, completion: nil)
        }
    }

    @objc private func continueButtonTapped() {
        guard let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty else {
            // Handle empty phone number
            return
        }

        // Extract dial code from countrySelectorButton title
        guard let countryTitle = countrySelectorButton.titleLabel?.text else {
            print("Country code not found")
            return
        }
        
        // The title format is "🇮🇳 +91", so split it to get the dial code
        let components = countryTitle.split(separator: " ")
        guard components.count > 1 else {
            print("Country code format is incorrect")
            return
        }
        
        let dialCode = components[1] // "+91" in this example
        let fullPhoneNumber = "\(dialCode)\(phoneNumber)"
        
        checkIfUserExists(phoneNumber: fullPhoneNumber)
    }

    private func checkIfUserExists(phoneNumber: String) {
        firestore.collection("users").whereField("Phone Number", isEqualTo: phoneNumber).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error checking user existence: \(error.localizedDescription)")
                return
            }

            let documentCount = snapshot?.documents.count ?? 0
            print("Documents found: \(documentCount)")
            
            if let documents = snapshot?.documents, !documents.isEmpty {
                self.sendOTP(to: phoneNumber)
            } else {
                self.navigateToRegistration(with: phoneNumber)
            }
        }
    }

    private func navigateToRegistration(with phoneNumber: String) {
        let registrationViewController = RegistrationViewController()
        registrationViewController.phoneNumber = phoneNumber // Pass the phone number
        navigationController?.pushViewController(registrationViewController, animated: true)
    }

    private func sendOTP(to phoneNumber: String) {
        print("sendOTP called with phoneNumber: \(phoneNumber)")
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            guard let self = self else { return }
            if let error = error {
                print("Error sending OTP: \(error)")
                return
            }

            guard let verificationID = verificationID else {
                print("Verification ID not received")
                return
            }

            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")

            print("Navigating to EnterOtpViewController")
            self.navigateToEnterOTP(phoneNumber: phoneNumber)
        }
    }


    private func navigateToEnterOTP(phoneNumber: String) {
        let enterOTPViewController = EnterOtpViewController()
        enterOTPViewController.phoneNumber = phoneNumber // Pass the phone number to the next view controller
        self.navigationController?.pushViewController(enterOTPViewController, animated: true)
    }

    private func setupContinueButtonAction() {
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }

    // UITextFieldDelegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= phoneNumberLimit
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.navigationController == nil {
            print("LoginViewController is not embedded in a UINavigationController.")
        } else {
            print("LoginViewController is embedded in a UINavigationController.")
        }
    }

    
}
