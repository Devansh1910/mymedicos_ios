import UIKit
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

class Registration2ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var phoneNumber: String?
    var prefix: String?
    var name: String?
    var email: String?
    var states: [[String: Any]] = []
    var interests: [[String: String]] = []
    var selectedState: String?
    var selectedInterest: String?
    var selectedInterest2: String?

    // UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    let stateLabel = UILabel()
    let interestLabel = UILabel()
    let interest2Label = UILabel()
    let stateTextField = UITextField()
    let interestTextField = UITextField()
    let interest2TextField = UITextField()
    let statePicker = UIPickerView()
    let interestPicker = UIPickerView()
    let interest2Picker = UIPickerView()
    let registerButton = UIButton()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        setupUI()
        loadState()
        loadInterests()
        setupActivityIndicator()
    }
    
    func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func setupUI() {
        setupScrollView()
        setupLabels()
        createTextField(placeholder: "Select your state", textField: stateTextField)
        createTextField(placeholder: "Select your interest", textField: interestTextField)
        createTextField(placeholder: "Select your interest 2", textField: interest2TextField)
        setupContinueButton()
        setupConstraints()
        setupPickers()
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
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        contentView.heightAnchor.constraint(equalToConstant: 600).isActive = true
    }
    
    

    func setupLabels() {
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
        
    }

    func createTextField(placeholder: String, textField: UITextField) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.textColor = UIColor.black
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
    }

    func setupPickers() {
        setupPickerView(pickerView: statePicker, textField: stateTextField, doneSelector: #selector(doneStatePicker))
        setupPickerView(pickerView: interestPicker, textField: interestTextField, doneSelector: #selector(doneInterestPicker))
        setupPickerView(pickerView: interest2Picker, textField: interest2TextField, doneSelector: #selector(doneInterest2Picker))
    }

    func setupPickerView(pickerView: UIPickerView, textField: UITextField, doneSelector: Selector) {
        pickerView.delegate = self
        pickerView.dataSource = self
        textField.inputView = pickerView
        
        // Add a toolbar with a Done button to dismiss the picker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: doneSelector)
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolbar
    }

    @objc func doneStatePicker() {
        stateTextField.resignFirstResponder()
    }

    @objc func doneInterestPicker() {
        interestTextField.resignFirstResponder()
    }

    @objc func doneInterest2Picker() {
        interest2TextField.resignFirstResponder()
    }

    func setupContinueButton() {
        let registerNowButton = UIButton(type: .system)
        registerNowButton.backgroundColor = .darkGray
        registerNowButton.setTitle("Register Now", for: .normal)
        registerNowButton.setTitleColor(.white, for: .normal)
        registerNowButton.layer.borderColor = UIColor.gray.cgColor
        registerNowButton.layer.borderWidth = 1
        registerNowButton.layer.cornerRadius = 8
        registerNowButton.translatesAutoresizingMaskIntoConstraints = false
        registerNowButton.addTarget(self, action: #selector(registerNowTapped), for: .touchUpInside)
        view.addSubview(registerNowButton)

        NSLayoutConstraint.activate([
            registerNowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            registerNowButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10), // Adjusted to anchor to the right edge
            registerNowButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            registerNowButton.heightAnchor.constraint(equalToConstant: 45),
        ])

    }

    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            stateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            stateTextField.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 10),
            stateTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stateTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stateTextField.heightAnchor.constraint(equalToConstant: 50),

            interestLabel.topAnchor.constraint(equalTo: stateTextField.bottomAnchor, constant: 20),
            interestLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            interestLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            interestTextField.topAnchor.constraint(equalTo: interestLabel.bottomAnchor, constant: 10),
            interestTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            interestTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            interestTextField.heightAnchor.constraint(equalToConstant: 50),

            interest2Label.topAnchor.constraint(equalTo: interestTextField.bottomAnchor, constant: 20),
            interest2Label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            interest2Label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            interest2TextField.topAnchor.constraint(equalTo: interest2Label.bottomAnchor, constant: 10),
            interest2TextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            interest2TextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            interest2TextField.heightAnchor.constraint(equalToConstant: 50),

        ])
    }


    @objc func registerNowTapped() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false  // Optionally disable user interaction

        registerUser { [weak self] uid in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.view.isUserInteractionEnabled = true
                self?.navigateToLoginViewController()  // Navigate after registration is complete
            }
        }
    }

    func navigateToLoginViewController() {
        let loginViewController = LoginViewController()  // Make sure to instantiate the correct login view controller
        if let navigationController = self.navigationController {
            navigationController.pushViewController(loginViewController, animated: true)
        }
    }



    func updateProfileStatus(uid: String, status: Bool) {
        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.updateData(["UpdatesProfile": status]) { error in
            if let error = error {
                print("Error updating profile status: \(error)")
            } else {
                print("Profile status updated successfully")
            }
        }
    }


    func registerUser(completion: @escaping (String) -> Void) {
        guard let state = selectedState,
              let interest = selectedInterest,
              let interest2 = selectedInterest2,
              let name = name, let email = email, let phoneNumber = phoneNumber, let prefix = prefix else {
            showAlert(message: "All fields are required.")
            return
        }

        // Save the user's data in Firestore without authenticating them
        let userRef = Firestore.firestore().collection("users").document()
        userRef.setData([
            "Name": name,
            "Email ID": email,
            "Location": state,
            "Interest": interest,
            "Interest2": interest2,
            "Prefix": prefix,
            "Phone Number": phoneNumber,
            "DocID": userRef.documentID,  // Use Firestore generated ID
            "MCNVerified": false,
            "UpdatesProfile": false
        ]) { [weak self] error in
            if let error = error {
                self?.showAlert(message: error.localizedDescription)
            } else {
                completion(userRef.documentID)  // Pass the Firestore Document ID to the completion handler
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
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: [[String: String]]] {
                    if let specialties = jsonResult["medical_specialties"] {
                        interests = specialties
                    }
                }
            } catch {
                print("Error loading interests: \(error)")
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
        } else if pickerView == interestPicker {
            return interests.count
        } else if pickerView == interest2Picker {
            return interests.filter { $0["name"] != selectedInterest }.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == statePicker {
            return states[row]["name"] as? String
        } else if pickerView == interestPicker {
            return interests[row]["name"]
        } else if pickerView == interest2Picker {
            return interests.filter { $0["name"] != selectedInterest }[row]["name"]
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == statePicker {
            selectedState = states[row]["name"] as? String
            stateTextField.text = selectedState
        } else if pickerView == interestPicker {
            selectedInterest = interests[row]["name"]
            interestTextField.text = selectedInterest
            interest2Picker.reloadAllComponents()  // Reload Interest 2 picker to update available options
        } else if pickerView == interest2Picker {
            selectedInterest2 = interests.filter { $0["name"] != selectedInterest }[row]["name"]
            interest2TextField.text = selectedInterest2
        }
    }
}
