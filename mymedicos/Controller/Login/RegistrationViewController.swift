import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class RegistrationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var phoneNumber: String?
    var states: [[String: Any]] = []
    var interests: [[String: String]] = []
    var prefixes: [[String: String]] = []

    // UI Components
    let titleLabel = UILabel()
    let phoneLabel = UILabel()
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let stateLabel = UILabel()
    let interestLabel = UILabel()
    let prefixLabel = UILabel()
    let nameTextField = UITextField()
    let emailTextField = UITextField()
    let statePicker = UIPickerView()
    let interestPicker = UIPickerView()
    let prefixPicker = UIPickerView()
    let stateContainerView = UIView()
    let interestContainerView = UIView()
    let prefixContainerView = UIView()
    let selectedStateLabel = UILabel()
    let selectedInterestLabel = UILabel()
    let selectedPrefixLabel = UILabel()
    let interestIconImageView = UIImageView()
    let stateButton = UIButton()
    let interestButton = UIButton()
    let prefixButton = UIButton()
    let continueButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        setupUI()
        loadState()
        loadInterests()
        loadPrefixes()
        print("Phone number received: \(phoneNumber ?? "No phone number")")

    }

    func setupUI() {
        setupLabels()
        createTextField(placeholder: "Enter your full name", textField: nameTextField, yPos: 225)
        createTextField(placeholder: "Enter your email address", textField: emailTextField, yPos: 315)
        createStatePicker()
        createInterestPicker()
        createPrefixPicker()
        setupStateContainerView()
        setupInterestContainerView()
        setupPrefixContainerView()
        setupButtons()
    }

    func setupLabels() {
        titleLabel.frame = CGRect(x: 20, y: 120, width: view.frame.size.width - 40, height: 20)
        titleLabel.text = "New Account Details"
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .black
        view.addSubview(titleLabel)

        phoneLabel.frame = CGRect(x: 20, y: 145, width: view.frame.size.width - 40, height: 20)
        phoneLabel.text = "Signing up as \(phoneNumber)"
        phoneLabel.font = UIFont.systemFont(ofSize: 16)
        phoneLabel.textColor = .gray
        view.addSubview(phoneLabel)

        nameLabel.frame = CGRect(x: 20, y: 200, width: view.frame.size.width - 40, height: 20)
        nameLabel.text = "Full Name*"
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = .gray
        view.addSubview(nameLabel)

        emailLabel.frame = CGRect(x: 20, y: 290, width: view.frame.size.width - 40, height: 20)
        emailLabel.text = "Email Address*"
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        emailLabel.textColor = .gray
        view.addSubview(emailLabel)

        stateLabel.frame = CGRect(x: 20, y: 380, width: view.frame.size.width - 40, height: 20)
        stateLabel.text = "Current State*"
        stateLabel.font = UIFont.systemFont(ofSize: 16)
        stateLabel.textColor = .gray
        view.addSubview(stateLabel)

        interestLabel.frame = CGRect(x: 20, y: 475, width: view.frame.size.width - 40, height: 20)
        interestLabel.text = "Select Interest*"
        interestLabel.font = UIFont.systemFont(ofSize: 16)
        interestLabel.textColor = .gray
        view.addSubview(interestLabel)

        prefixLabel.frame = CGRect(x: 20, y: 570, width: view.frame.size.width - 40, height: 20)
        prefixLabel.text = "Prefix*"
        prefixLabel.font = UIFont.systemFont(ofSize: 16)
        prefixLabel.textColor = .gray
        view.addSubview(prefixLabel)
    }

    func setupButtons() {
        continueButton.frame = CGRect(x: 20, y: self.view.frame.height - 120, width: view.frame.size.width - 40, height: 60)
        continueButton.backgroundColor = .gray
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 8
        continueButton.addTarget(self, action: #selector(registerUser), for: .touchUpInside)
        view.addSubview(continueButton)
    }

    func createTextField(placeholder: String, textField: UITextField, yPos: CGFloat) {
        textField.frame = CGRect(x: 20, y: yPos, width: view.frame.size.width - 40, height: 50)
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.textColor = UIColor.gray
        textField.autocapitalizationType = placeholder.contains("email") ? .none : .words
        view.addSubview(textField)
    }

    func createStatePicker() {
        let height: CGFloat = 240
        let width: CGFloat = view.frame.size.width
        statePicker.frame = CGRect(x: 0, y: self.view.frame.height - height, width: width, height: height)
        statePicker.backgroundColor = .white
        statePicker.layer.cornerRadius = 8
        statePicker.layer.shadowColor = UIColor.black.cgColor
        statePicker.layer.shadowOpacity = 0.8
        statePicker.layer.shadowOffset = CGSize(width: 0, height: 4)
        statePicker.layer.shadowRadius = 6
        statePicker.isHidden = true
        statePicker.delegate = self
        statePicker.dataSource = self
        view.addSubview(statePicker)
    }

    func createInterestPicker() {
        let height: CGFloat = 240
        let width: CGFloat = view.frame.size.width
        interestPicker.frame = CGRect(x: 0, y: self.view.frame.height - height, width: width, height: height)
        interestPicker.backgroundColor = .white
        interestPicker.layer.cornerRadius = 8
        interestPicker.layer.shadowColor = UIColor.black.cgColor
        interestPicker.layer.shadowOpacity = 0.8
        interestPicker.layer.shadowOffset = CGSize(width: 0, height: 4)
        interestPicker.layer.shadowRadius = 6
        interestPicker.isHidden = true
        interestPicker.delegate = self
        interestPicker.dataSource = self
        view.addSubview(interestPicker)
    }

    func createPrefixPicker() {
        let height: CGFloat = 240
        let width: CGFloat = view.frame.size.width
        prefixPicker.frame = CGRect(x: 0, y: self.view.frame.height - height, width: width, height: height)
        prefixPicker.backgroundColor = .white
        prefixPicker.layer.cornerRadius = 8
        prefixPicker.layer.shadowColor = UIColor.black.cgColor
        prefixPicker.layer.shadowOpacity = 0.8
        prefixPicker.layer.shadowOffset = CGSize(width: 0, height: 4)
        prefixPicker.layer.shadowRadius = 6
        prefixPicker.isHidden = true
        prefixPicker.delegate = self
        prefixPicker.dataSource = self
        view.addSubview(prefixPicker)
    }

    func setupStateContainerView() {
        stateContainerView.frame = CGRect(x: 20, y: 405, width: view.frame.size.width - 40, height: 50)
        stateContainerView.layer.borderWidth = 0.4
        stateContainerView.layer.borderColor = UIColor.gray.cgColor
        stateContainerView.layer.cornerRadius = 8
        view.addSubview(stateContainerView)

        setupSelectedStateLabel()
        setupStateButton()
    }

    func setupInterestContainerView() {
        interestContainerView.frame = CGRect(x: 20, y: 500, width: view.frame.size.width - 40, height: 50)
        interestContainerView.layer.borderWidth = 0.4
        interestContainerView.layer.borderColor = UIColor.gray.cgColor
        interestContainerView.layer.cornerRadius = 8
        view.addSubview(interestContainerView)

        setupSelectedInterestLabel()
        setupInterestButton()
    }

    func setupPrefixContainerView() {
        prefixContainerView.frame = CGRect(x: 20, y: 595, width: view.frame.size.width - 40, height: 50)
        prefixContainerView.layer.borderWidth = 0.4
        prefixContainerView.layer.borderColor = UIColor.gray.cgColor
        prefixContainerView.layer.cornerRadius = 8
        view.addSubview(prefixContainerView)

        setupSelectedPrefixLabel()
        setupPrefixButton()
    }

    func setupSelectedStateLabel() {
        selectedStateLabel.frame = CGRect(x: 10, y: 0, width: stateContainerView.frame.size.width - 100, height: stateContainerView.frame.size.height)
        selectedStateLabel.text = "Select your state"
        selectedStateLabel.textColor = .gray
        stateContainerView.addSubview(selectedStateLabel)
    }

    func setupStateButton() {
        stateButton.frame = CGRect(x: stateContainerView.frame.size.width - 50, y: 10, width: 40, height: 30)
        stateButton.setTitle("▼", for: .normal)
        stateButton.setTitleColor(.gray, for: .normal)
        stateButton.addTarget(self, action: #selector(showStatePicker), for: .touchUpInside)
        stateContainerView.addSubview(stateButton)
    }

    func setupSelectedInterestLabel() {
        selectedInterestLabel.frame = CGRect(x: 10, y: 0, width: interestContainerView.frame.size.width - 100, height: interestContainerView.frame.size.height)
        selectedInterestLabel.text = "Select your interest"
        selectedInterestLabel.textColor = .gray
        interestContainerView.addSubview(selectedInterestLabel)
    }

    func setupInterestButton() {
        interestButton.frame = CGRect(x: interestContainerView.frame.size.width - 50, y: 10, width: 40, height: 30)
        interestButton.setTitle("▼", for: .normal)
        interestButton.setTitleColor(.gray, for: .normal)
        interestButton.addTarget(self, action: #selector(showInterestPicker), for: .touchUpInside)
        interestContainerView.addSubview(interestButton)
    }

    func setupSelectedPrefixLabel() {
        selectedPrefixLabel.frame = CGRect(x: 10, y: 0, width: prefixContainerView.frame.size.width - 100, height: prefixContainerView.frame.size.height)
        selectedPrefixLabel.text = "Select your prefix"
        selectedPrefixLabel.textColor = .gray
        prefixContainerView.addSubview(selectedPrefixLabel)
    }

    func setupPrefixButton() {
        prefixButton.frame = CGRect(x: prefixContainerView.frame.size.width - 50, y: 10, width: 40, height: 30)
        prefixButton.setTitle("▼", for: .normal)
        prefixButton.setTitleColor(.gray, for: .normal)
        prefixButton.addTarget(self, action: #selector(showPrefixPicker), for: .touchUpInside)
        prefixContainerView.addSubview(prefixButton)
    }

    @objc func showStatePicker() {
        statePicker.isHidden = false
    }

    @objc func showInterestPicker() {
        interestPicker.isHidden = false
    }

    @objc func showPrefixPicker() {
        prefixPicker.isHidden = false
    }

    @objc func registerUser() {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let state = selectedStateLabel.text, !state.isEmpty,
              let interest = selectedInterestLabel.text, !interest.isEmpty,
              let prefix = selectedPrefixLabel.text, !prefix.isEmpty else {
            showAlert(message: "All fields are required.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: "dummyPassword") { [weak self] result, error in
            if let error = error {
                self?.showAlert(message: error.localizedDescription)
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let userRef = Firestore.firestore().collection("users").document(uid)
            userRef.setData([
                "name": name,
                "email": email,
                "state": state,
                "interest": interest,
                "prefix": prefix
            ]) { [weak self] error in
                if let error = error {
                    self?.showAlert(message: error.localizedDescription)
                } else {
                    self?.showAlert(message: "Registration successful!")
                }
            }
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func loadState() {
        // Add logic to load states from a source (e.g., API, Firestore)
    }

    func loadInterests() {
        // Add logic to load interests from a source (e.g., API, Firestore)
    }

    func loadPrefixes() {
        // Add logic to load prefixes from a source (e.g., API, Firestore)
    }

    // MARK: - UIPickerViewDelegate & UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == statePicker {
            return states.count
        } else if pickerView == interestPicker {
            return interests.count
        } else if pickerView == prefixPicker {
            return prefixes.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == statePicker {
            return states[row]["name"] as? String
        } else if pickerView == interestPicker {
            return interests[row]["name"]
        } else if pickerView == prefixPicker {
            return prefixes[row]["name"]
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == statePicker {
            selectedStateLabel.text = states[row]["name"] as? String
            statePicker.isHidden = true
        } else if pickerView == interestPicker {
            selectedInterestLabel.text = interests[row]["name"]
            interestPicker.isHidden = true
        } else if pickerView == prefixPicker {
            selectedPrefixLabel.text = prefixes[row]["name"]
            prefixPicker.isHidden = true
        }
    }
}
