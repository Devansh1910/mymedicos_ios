import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol GroupSelectionBottomSheetDelegate: AnyObject {
    func didChooseViewPlans()
}

class GroupSelectionBottomSheetViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    weak var delegate: GroupSelectionBottomSheetDelegate?
    
    var completion: ((String) -> Void)?
    var pickerView = UIPickerView()
    let buttonStack = UIStackView()
    let viewNeetssButton = UIButton(type: .system)
    let maybeLaterButton = UIButton(type: .system)
    let groupOptions = [" Medical Group", " Surgical Group", " Paediatrics Group"," Obstetrics & Gynaecology Group"," Orthopaedics Group"," Anaesthesia Group"," Radiodiagonis Group"," Respiratory Medicine Group"," Microbiology Group"," Pathology Group"," Psychiatry Group"," Pharmacology Group","ENT Group"]
    
    var selectedGroup: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        setupViews()
        updateConfirmButtonState(selectedGroup: groupOptions[0])
        
        if let defaultGroupIndex = groupOptions.firstIndex(of: " Medical Group") {
            pickerView.selectRow(defaultGroupIndex, inComponent: 0, animated: false)
            selectedGroup = groupOptions[defaultGroupIndex]
            updateConfirmButtonState(selectedGroup: selectedGroup!)
        }
    }


    private func setupViews() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 20

        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "Premium-3")
        imageView.backgroundColor = .lightGray

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = "Select Your Specialty Group"
        messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        messageLabel.textAlignment = .left
        messageLabel.numberOfLines = 0
        messageLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Welcome to the NEET SS preparation section! To help you get started on the right track, please select your specialty group. This will allow us to tailor the best resources and study materials just for you. Here's what you can expect:"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 0

        let featuresStack = UIStackView()
        featuresStack.translatesAutoresizingMaskIntoConstraints = false
        featuresStack.axis = .vertical
        
        featuresStack.spacing = 10

        let features = [
            ("Access group-specific study materials.", "video"),
            ("Learn from top specialists.", "text.badge.checkmark"),
            ("Practice with group-focused tests.", "photo.on.rectangle"),
            ("Monitor your performance.", "note.text.badge.plus"),
            ("Stay informed with relevant notifications.", "tag.fill"),
        ]

        for feature in features {
            let iconImageView = UIImageView(image: UIImage(systemName: feature.1))
            iconImageView.tintColor = .systemBlue
            let featureLabel = UILabel()
            featureLabel.text = feature.0
            featureLabel.numberOfLines = 0

            let featureStack = UIStackView(arrangedSubviews: [iconImageView, featureLabel])
            featureStack.axis = .horizontal
            featureStack.alignment = .center
            featureStack.spacing = 8

            featuresStack.addArrangedSubview(featureStack)
        }
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self

        view.addSubview(pickerView)

        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .vertical
        buttonStack.spacing = 10

        viewNeetssButton.setTitle("Confirm", for: .normal)
        viewNeetssButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        viewNeetssButton.backgroundColor = .systemBlue
        viewNeetssButton.tintColor = .white
        viewNeetssButton.layer.cornerRadius = 10
        viewNeetssButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        viewNeetssButton.addTarget(self, action: #selector(viewNeetssTapped), for: .touchUpInside)

        maybeLaterButton.setTitle("Maybe Later", for: .normal)
        maybeLaterButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        maybeLaterButton.tintColor = .black
        maybeLaterButton.layer.cornerRadius = 10
        maybeLaterButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        maybeLaterButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        buttonStack.addArrangedSubview(viewNeetssButton)
        buttonStack.addArrangedSubview(maybeLaterButton)

        view.addSubview(closeButton)
        view.addSubview(imageView)
        view.addSubview(messageLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(featuresStack)
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),

            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            featuresStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            featuresStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            featuresStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pickerView.topAnchor.constraint(equalTo: featuresStack.bottomAnchor, constant: 20),
             pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
             pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
             pickerView.heightAnchor.constraint(equalToConstant: 150),

            buttonStack.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 30),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Number of columns in picker view
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return groupOptions.count // Number of rows
    }

    // UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return groupOptions[row] // Text for each row
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let myView = view as? UIStackView ?? UIStackView()
        myView.axis = .horizontal
        myView.alignment = .fill
        myView.distribution = .fill

        myView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let logoImageView = UIImageView()
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true

        let groupNameLabel = UILabel()
        groupNameLabel.text = groupOptions[row]
        groupNameLabel.font = UIFont.systemFont(ofSize: 18)

        let subjectsLabel = UILabel()
        let subjectCounts = ["13 Courses", "12 Courses", "15 Courses", "10 Courses", "20 Courses", "8 Courses", "16 Courses", "14 Courses", "9 Courses", "11 Courses", "7 Courses", "17 Courses", "18 Courses"]
        subjectsLabel.text = subjectCounts[row % subjectCounts.count]
        subjectsLabel.font = UIFont.systemFont(ofSize: 14)
        subjectsLabel.textAlignment = .right

        switch groupOptions[row] {
            case " Medical Group":
                logoImageView.image = UIImage(systemName: "staroflife.fill")
                logoImageView.tintColor = .blue
            case " Paediatrics Group":
                logoImageView.image = UIImage(systemName: "figure.walk")
                logoImageView.tintColor = .blue
            case " Surgical Group":
                logoImageView.image = UIImage(systemName: "scissors")
                logoImageView.tintColor = .blue
            default:
                logoImageView.image = UIImage(systemName: "lock.fill")
                logoImageView.tintColor = .gray
        }

        myView.addArrangedSubview(logoImageView)
        myView.addArrangedSubview(groupNameLabel)
        myView.addArrangedSubview(subjectsLabel)

        myView.isLayoutMarginsRelativeArrangement = true
        myView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        groupNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        subjectsLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        return myView
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGroup = groupOptions[row]
        updateConfirmButtonState(selectedGroup: selectedGroup ?? "Medical")
    }



    private func updateConfirmButtonState(selectedGroup: String) {
        if selectedGroup == " Medical Group" || selectedGroup == " Surgical Group" || selectedGroup == " Paediatrics Group" {
            viewNeetssButton.isEnabled = true
            viewNeetssButton.backgroundColor = .systemBlue
        } else {
            viewNeetssButton.isEnabled = false
            viewNeetssButton.backgroundColor = .systemGray
        }
    }




    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }

    @objc private func viewNeetssTapped() {
        if viewNeetssButton.isEnabled {
            guard let selectedGroup = selectedGroup else { return }
            
            self.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.storeSelectedGroup(selectedGroup)
                
                // Handling different root view controller setups
                if let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController,
                   let navigationController = tabBarController.selectedViewController as? UINavigationController {
                    self.presentUpdatingModule(on: navigationController)
                } else if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                    self.presentUpdatingModule(on: navigationController)
                } else {
                    print("No suitable UINavigationController found")
                }
            }
        }
    }

    private func presentUpdatingModule(on navigationController: UINavigationController) {
        let updatingModuleVC = UpdatingModuleViewController()
        updatingModuleVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            navigationController.present(updatingModuleVC, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    updatingModuleVC.dismiss(animated: true) {
                        let tabBarController = NeetssTabbarViewController()
                        var viewControllers = navigationController.viewControllers
                        tabBarController.hidesBottomBarWhenPushed = true
                        viewControllers = viewControllers.filter { $0 is HomeViewController }
                        viewControllers.append(tabBarController)
                        navigationController.setViewControllers(viewControllers, animated: true)
                    }
                }
            }
        }
    }


    
    private func storeSelectedGroup(_ group: String) {
        let mappedGroupName: String
        switch group {
        case " Medical Group":
            mappedGroupName = "medical"
        case " Surgical Group":
            mappedGroupName = "surgical"
        case " Paediatrics Group":
            mappedGroupName = "paediatrics"
        default:
            return  // If the group is not one of the specified, do nothing
        }

        let ref = Database.database().reference()
        guard let userPhoneNumber = Auth.auth().currentUser?.phoneNumber else { return }
        ref.child("profiles").child(userPhoneNumber).child("Neetss").setValue(mappedGroupName) { error, _ in
            if let error = error {
                print("Error saving data: \(error)")
            } else {
                print("Data saved successfully!")
            }
        }
    }



    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("hideTabBar"), object: nil)
    }
}
