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
    let scrollView = UIScrollView()
    let contentView = UIView()
    let titleLabel = UILabel()
    let phoneLabel = UILabel()
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let stateLabel = UILabel()
    let interestLabel = UILabel()
    let interest2Label = UILabel()
    let prefixLabel = UILabel()
    let nameTextField = UITextField()
    let emailTextField = UITextField()
    let statePicker = UIPickerView()
    let interestPicker = UIPickerView()
    let interest2Picker = UIPickerView()
    let prefixPicker = UIPickerView()
    let stateContainerView = UIView()
    let interestContainerView = UIView()
    let interest2ContainerView = UIView()
    let prefixContainerView = UIView()
    let selectedStateLabel = UILabel()
    let selectedInterestLabel = UILabel()
    let selectedInterest2Label = UILabel()
    let selectedPrefixLabel = UILabel()
    let stateButton = UIButton()
    let interestButton = UIButton()
    let interest2Button = UIButton()
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
        setupScrollView()
        setupLabels()
        createTextField(placeholder: "Enter your full name", textField: nameTextField, yPos: 225)
        createTextField(placeholder: "Enter your email address", textField: emailTextField, yPos: 315)
        createStatePicker()
        createInterestPicker()
        createInterest2Picker()
        createPrefixPicker()
        setupStateContainerView()
        setupInterestContainerView()
        setupInterest2ContainerView()
        setupPrefixContainerView()
        setupButtons()
        setupConstraints()
    }

    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    func setupLabels() {
        titleLabel.text = "New Account Details"
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        phoneLabel.text = "Signing up as \(phoneNumber ?? "")"
        phoneLabel.font = UIFont.systemFont(ofSize: 16)
        phoneLabel.textColor = .gray
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(phoneLabel)

        nameLabel.text = "Full Name*"
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = .gray
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        emailLabel.text = "Email Address*"
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        emailLabel.textColor = .gray
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailLabel)

        stateLabel.text = "Current State*"
        stateLabel.font = UIFont.systemFont(ofSize: 16)
        stateLabel.textColor = .gray
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stateLabel)

        interestLabel.text = "Select Interest*"
        interestLabel.font = UIFont.systemFont(ofSize: 16)
        interestLabel.textColor = .gray
        interestLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(interestLabel)
        
        interest2Label.text = "Select Interest 2*"
        interest2Label.font = UIFont.systemFont(ofSize: 16)
        interest2Label.textColor = .gray
        interest2Label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(interest2Label)

        prefixLabel.text = "Prefix*"
        prefixLabel.font = UIFont.systemFont(ofSize: 16)
        prefixLabel.textColor = .gray
        prefixLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(prefixLabel)
    }

    func setupButtons() {
        continueButton.backgroundColor = .darkGray
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 8
        continueButton.addTarget(self, action: #selector(registerUser), for: .touchUpInside)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            continueButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func createTextField(placeholder: String, textField: UITextField, yPos: CGFloat) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.textColor = UIColor.gray
        textField.autocapitalizationType = placeholder.contains("email") ? .none : .words
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
    }

    func createStatePicker() {
        setupPickerView(pickerView: statePicker)
    }

    func createInterestPicker() {
        setupPickerView(pickerView: interestPicker)
    }
    
    func createInterest2Picker() {
        setupPickerView(pickerView: interest2Picker)
    }

    func createPrefixPicker() {
        setupPickerView(pickerView: prefixPicker)
    }
    
    func setupPickerView(pickerView: UIPickerView) {
        pickerView.backgroundColor = .white
        pickerView.layer.cornerRadius = 8
        pickerView.layer.shadowColor = UIColor.black.cgColor
        pickerView.layer.shadowOpacity = 0.8
        pickerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        pickerView.layer.shadowRadius = 6
        pickerView.isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)
    }

    func setupStateContainerView() {
        setupContainerView(containerView: stateContainerView, label: selectedStateLabel, button: stateButton, placeholder: "Select your state")
        stateButton.addTarget(self, action: #selector(showStatePicker), for: .touchUpInside)
    }

    func setupInterestContainerView() {
        setupContainerView(containerView: interestContainerView, label: selectedInterestLabel, button: interestButton, placeholder: "Select your interest")
        interestButton.addTarget(self, action: #selector(showInterestPicker), for: .touchUpInside)
    }

    func setupInterest2ContainerView() {
        setupContainerView(containerView: interest2ContainerView, label: selectedInterest2Label, button: interest2Button, placeholder: "Select your interest 2")
        interest2Button.addTarget(self, action: #selector(showInterest2Picker), for: .touchUpInside)
    }

    func setupPrefixContainerView() {
        setupContainerView(containerView: prefixContainerView, label: selectedPrefixLabel, button: prefixButton, placeholder: "Select your prefix")
        prefixButton.addTarget(self, action: #selector(showPrefixPicker), for: .touchUpInside)
    }

    func setupContainerView(containerView: UIView, label: UILabel, button: UIButton, placeholder: String) {
        containerView.layer.borderWidth = 0.4
        containerView.layer.borderColor = UIColor.gray.cgColor
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        label.text = placeholder
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)

        button.setTitle("▼", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(button)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            button.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            phoneLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            phoneLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            phoneLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            nameLabel.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            emailLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            stateLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            stateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            stateContainerView.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 10),
            stateContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stateContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stateContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            interestLabel.topAnchor.constraint(equalTo: stateContainerView.bottomAnchor, constant: 20),
            interestLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            interestLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            interestContainerView.topAnchor.constraint(equalTo: interestLabel.bottomAnchor, constant: 10),
            interestContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            interestContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            interestContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            interest2Label.topAnchor.constraint(equalTo: interestContainerView.bottomAnchor, constant: 20),
            interest2Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            interest2Label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            interest2ContainerView.topAnchor.constraint(equalTo: interest2Label.bottomAnchor, constant: 10),
            interest2ContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            interest2ContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            interest2ContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            prefixLabel.topAnchor.constraint(equalTo: interest2ContainerView.bottomAnchor, constant: 20),
            prefixLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            prefixLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            prefixContainerView.topAnchor.constraint(equalTo: prefixLabel.bottomAnchor, constant: 10),
            prefixContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            prefixContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            prefixContainerView.heightAnchor.constraint(equalToConstant: 50),
            prefixContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20) // Adjust the bottom anchor
        ])
    }

    @objc func showStatePicker() {
        statePicker.isHidden = false
    }

    @objc func showInterestPicker() {
        interestPicker.isHidden = false
    }
    
    @objc func showInterest2Picker() {
        interest2Picker.isHidden = false
    }

    @objc func showPrefixPicker() {
        prefixPicker.isHidden = false
    }

    @objc func registerUser() {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let state = selectedStateLabel.text, !state.isEmpty,
              let interest = selectedInterestLabel.text, !interest.isEmpty,
              let interest2 = selectedInterest2Label.text, !interest2.isEmpty,
              let prefix = selectedPrefixLabel.text, !prefix.isEmpty,
              let phoneNumber = phoneNumber else {
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
                "Name": name,
                "Email ID": email,
                "Location": state,
                "Interest": interest,
                "Interest2": interest2,
                "Prefix": prefix,
                "Phone Number": phoneNumber
            ]) { [weak self] error in
                if let error = error {
                    self?.showAlert(message: error.localizedDescription)
                } else {
                    self?.showAlert(message: "Registration successful!")
                    self?.navigationController?.popViewController(animated: true)
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
        if let path = Bundle.main.path(forResource: "States", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [[String: Any]] {
                    states = jsonResult
                }
            } catch {
                print("Error loading states: \(error)")
            }
        }
    }

    func loadInterests() {
        if let path = Bundle.main.path(forResource: "Interest", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [[String: String]] {
                    interests = jsonResult
                }
            } catch {
                print("Error loading interests: \(error)")
            }
        }
    }

    func loadPrefixes() {
        if let path = Bundle.main.path(forResource: "Prefix", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [[String: String]] {
                    prefixes = jsonResult
                }
            } catch {
                print("Error loading prefixes: \(error)")
            }
        }
    }

    // MARK: - UIPickerViewDelegate & UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == statePicker {
            return states.count
        } else if pickerView == interestPicker || pickerView == interest2Picker {
            return interests.count
        } else if pickerView == prefixPicker {
            return prefixes.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == statePicker {
            return states[row]["name"] as? String
        } else if pickerView == interestPicker || pickerView == interest2Picker {
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
        } else if pickerView == interest2Picker {
            selectedInterest2Label.text = interests[row]["name"]
            interest2Picker.isHidden = true
        } else if pickerView == prefixPicker {
            selectedPrefixLabel.text = prefixes[row]["name"]
            prefixPicker.isHidden = true
        }
    }
}
