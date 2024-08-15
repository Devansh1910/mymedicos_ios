import UIKit
import FirebaseFirestore

class CustomizeProfileViewController: UIViewController {

    // UI Elements
    var profileImageView: UIImageView!
    var changePictureButton: UIButton!
    var genderSegmentedControl: UISegmentedControl!
    var dateOfBirthPicker: UIDatePicker!
    var saveButton: UIButton!
    
    var userDocID: String? // Pass user document ID from previous VC
    var onProfileComplete: (() -> Void)? // Closure to handle profile completion

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Setup the UI
        setupProfileImageView()
        setupChangePictureButton()
        setupGenderSegmentedControl()
        setupDateOfBirthPicker()
        setupSaveButton()
    }
    
    func setupProfileImageView() {
        profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.masksToBounds = true
        profileImageView.image = UIImage(named: "defaultProfilePicture")

        view.addSubview(profileImageView)

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupChangePictureButton() {
        changePictureButton = UIButton(type: .system)
        changePictureButton.translatesAutoresizingMaskIntoConstraints = false
        changePictureButton.setTitle("Change Picture", for: .normal)

        view.addSubview(changePictureButton)

        NSLayoutConstraint.activate([
            changePictureButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            changePictureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        changePictureButton.addTarget(self, action: #selector(changePictureTapped), for: .touchUpInside)
    }
    
    func setupGenderSegmentedControl() {
        let genderOptions = ["Male", "Female", "Non Binary", "Prefer not to say"]
        genderSegmentedControl = UISegmentedControl(items: genderOptions)
        genderSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        genderSegmentedControl.selectedSegmentIndex = 0

        view.addSubview(genderSegmentedControl)

        NSLayoutConstraint.activate([
            genderSegmentedControl.topAnchor.constraint(equalTo: changePictureButton.bottomAnchor, constant: 20),
            genderSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func setupDateOfBirthPicker() {
        dateOfBirthPicker = UIDatePicker()
        dateOfBirthPicker.translatesAutoresizingMaskIntoConstraints = false
        dateOfBirthPicker.datePickerMode = .date
        dateOfBirthPicker.preferredDatePickerStyle = .wheels
        dateOfBirthPicker.maximumDate = Date()

        view.addSubview(dateOfBirthPicker)

        NSLayoutConstraint.activate([
            dateOfBirthPicker.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 20),
            dateOfBirthPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateOfBirthPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupSaveButton() {
        saveButton = UIButton(type: .system)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .gray
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8

        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: dateOfBirthPicker.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            saveButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        saveButton.addTarget(self, action: #selector(saveProfileTapped), for: .touchUpInside)
    }
    
    @objc func changePictureTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func saveProfileTapped() {
        guard let userDocID = userDocID else {
            print("User Doc ID is nil")
            return
        }
        let gender = genderSegmentedControl.titleForSegment(at: genderSegmentedControl.selectedSegmentIndex) ?? "Prefer not to say"
        let dateOfBirth = dateOfBirthPicker.date

        let userRef = Firestore.firestore().collection("users").document(userDocID)
        userRef.updateData([
            "Gender": gender,
            "DOB": dateOfBirth
        ]) { error in
            if let error = error {
                print("Error updating profile: \(error)")
            } else {
                self.onProfileComplete?() // Notify that profile update is complete
                let alert = UIAlertController(title: "Profile Updated", message: "Your profile has been updated successfully.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension CustomizeProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
