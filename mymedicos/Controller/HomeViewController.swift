import UIKit

class HomeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        return table
    }()

    let dropdownButton = UIButton(type: .system)
    let options = ["Education", "Community"]
    let sectionTitle = ["Daily Questions"]
    
    private let dailyQuestionView = DailyQuestionUIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        view.addSubview(homeFeedTable)

        configureNavbar()

        // Setup HeroImageUIView
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 500)) // Increased height to fit new label
        let heroImageView = HeroImageUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 225))
        headerView.addSubview(heroImageView)

        // Add title label for Daily Question
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 225, width: view.bounds.width - 10, height: 15))
        titleLabel.text = "Daily Question"
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(titleLabel)
        
        // Add DailyQuestionUIView below the title
        let dailyQuestionViewWidth = view.bounds.width - 10 // 5 points margin from each side
        dailyQuestionView.frame = CGRect(x: 5, y: 255, width: dailyQuestionViewWidth, height: 115)
        dailyQuestionView.backgroundColor = .systemBackground // Assigns a grey background color
        headerView.addSubview(dailyQuestionView)

        // Add another title label after DailyQuestionUIView
        let additionalTitleLabel = UILabel(frame: CGRect(x: 10, y: 380, width: view.bounds.width - 10, height: 20))
        additionalTitleLabel.text = "Live Exams"
        additionalTitleLabel.textAlignment = .left
        additionalTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        headerView.addSubview(additionalTitleLabel)
        
        homeFeedTable.tableHeaderView = headerView
    }



    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }

    private func configureNavbar() {
        guard let logo = UIImage(named: "logoImage")?.withRenderingMode(.alwaysOriginal) else {
            return
        }
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        let containerView = UIView()
        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0), // Reduced margin
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0), // Reduced space between logo and edge
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        let logoItem = UIBarButtonItem(customView: containerView)

        dropdownButton.setTitle("\(options[0]) ▼", for: .normal)
        dropdownButton.setTitleColor(.black, for: .normal) // Set dropdown text color to black
        dropdownButton.addTarget(self, action: #selector(didTapDropdown), for: .touchUpInside)
        dropdownButton.titleLabel?.font = UIFont.systemFont(ofSize: 16) // Adjusted font size

        // Custom view to manage space between logo and dropdown
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 0,height: 20)) // You can adjust the width for less space
        let spacerItem = UIBarButtonItem(customView: spacerView)

        let dropdownItem = UIBarButtonItem(customView: dropdownButton)

        // Include a spacer item to finely control the space
        navigationItem.leftBarButtonItems = [logoItem, spacerItem, dropdownItem]

        setupIcons()
    }



    private func setupDropdown() {
        dropdownButton.setTitle("\(options[0]) ▼", for: .normal)
        dropdownButton.addTarget(self, action: #selector(didTapDropdown), for: .touchUpInside)
        
        let dropdownItem = UIBarButtonItem(customView: dropdownButton)
        // Set the dropdown next to the logo
        navigationItem.rightBarButtonItems = [dropdownItem]
    }

    private func setupIcons() {
        let notificationButton = UIButton(type: .custom)
        let personButton = UIButton(type: .custom)

        if let notificationImage = UIImage(systemName: "bell")?.withTintColor(.black, renderingMode: .alwaysOriginal),
           let personImage = UIImage(systemName: "person")?.withTintColor(.black, renderingMode: .alwaysOriginal) {
            notificationButton.setImage(notificationImage, for: .normal)
            personButton.setImage(personImage, for: .normal)
        }

        notificationButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        personButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

        notificationButton.addTarget(self, action: #selector(didTapNotification), for: .touchUpInside)
        personButton.addTarget(self, action: #selector(didTapPerson), for: .touchUpInside)

        let notificationItem = UIBarButtonItem(customView: notificationButton)
        let personItem = UIBarButtonItem(customView: personButton)

        // Set notification and person icons on the right side
        navigationItem.rightBarButtonItems = [personItem, notificationItem]
    }

    @objc func didTapDropdown() {
        let alertController = UIAlertController(title: "Shift to ?", message: "\n\n\n\n\n\n", preferredStyle: .actionSheet)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 20, width: alertController.view.bounds.size.width, height: 140))
        pickerView.dataSource = self
        pickerView.delegate = self

        alertController.view.addSubview(pickerView)
        let selectAction = UIAlertAction(title: "Select", style: .default, handler: { [weak self] alert in
            let selectedIndex = pickerView.selectedRow(inComponent: 0)
            guard let self = self else { return }
            
            if self.options[selectedIndex] == "Community" {
                // Show toast message if 'Community' is selected
                self.showToast(message: "Community coming soon.")
            } else {
                // Update dropdown button title if any other option is selected
                self.dropdownButton.setTitle("\(self.options[selectedIndex]) ▼", for: .normal)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    func showToast(message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }


    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }

    @objc func didTapNotification() {
        print("Notification icon tapped")
    }

    @objc func didTapPerson() {
        print("Person icon tapped")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateIconColors()
        }
    }

    private func updateIconColors() {
        let currentTheme = traitCollection.userInterfaceStyle
        let color = currentTheme == .dark ? UIColor.white : UIColor.black
        navigationController?.navigationBar.tintColor = color
    }
}
