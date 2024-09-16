import UIKit

// Protocol to handle button actions in the ProfileViewController
protocol ProfileGridDelegate: AnyObject {
    func navigateToApplyCoupons()
    func navigateToViewPlans()
    func showChatOptions()
    func didTapSettings()
    func openTelegramIcon()
    func shareApplication()
}

class ProfileGrid: UIView {

    weak var delegate: ProfileGridDelegate?

    // Initialization of UI elements
    private let applyCouponsButton = createButton(title: "Apply coupons", iconName: "couponcodeicon")
    private let viewPlansButton = createButton(title: "View plans", iconName: "star")
    private let contactUsButton = createButton(title: "Contact us", iconName: "contactsupporticon")
    private let settingsButton = createButton(title: "Settings", iconName: "settingsicon")
    private let communityButton = createButton(title: "Community", iconName: "communityicon")
    private let referButton = createButton(title: "Refer a friend", iconName: "shareicon")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGrid()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGrid()
        setupActions()
    }

    private static func createButton(title: String, iconName: String) -> UIButton {
        let button = UIButton(type: .system)
        
        let icon = UIImage(named: iconName)
        let imageView = UIImageView(image: icon)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.font = UIFont(name: "Poppins-SemiBold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(imageView)
        button.addSubview(label)
        
        button.backgroundColor = UIColor(hexString: "#EAEAEA")
        button.layer.cornerRadius = 8
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        return button
    }

    private func setupGrid() {
        let topRow = UIStackView(arrangedSubviews: [applyCouponsButton, viewPlansButton])
        let middleRow = UIStackView(arrangedSubviews: [contactUsButton, settingsButton])
        let bottomRow = UIStackView(arrangedSubviews: [communityButton, referButton])

        topRow.distribution = .fillEqually
        topRow.axis = .horizontal
        topRow.spacing = 10
        
        middleRow.distribution = .fillEqually
        middleRow.axis = .horizontal
        middleRow.spacing = 10

        bottomRow.distribution = .fillEqually
        bottomRow.axis = .horizontal
        bottomRow.spacing = 10

        let gridStackView = UIStackView(arrangedSubviews: [topRow, middleRow, bottomRow])
        gridStackView.axis = .vertical
        gridStackView.distribution = .fillEqually
        gridStackView.spacing = 10

        gridStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gridStackView)

        NSLayoutConstraint.activate([
            gridStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            gridStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15),
            gridStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            gridStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15)
        ])
    }

    private func setupActions() {
        applyCouponsButton.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        viewPlansButton.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        contactUsButton.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        communityButton.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        referButton.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
    }

    @objc func handleButtonClick(_ sender: UIButton) {
        if sender == applyCouponsButton {
            delegate?.navigateToApplyCoupons()
        } else if sender == viewPlansButton {
            delegate?.navigateToViewPlans()
        } else if sender == contactUsButton {
            delegate?.showChatOptions()
        } else if sender == settingsButton {
            delegate?.didTapSettings()
        } else if sender == communityButton {
            delegate?.openTelegramIcon()
        } else if sender == referButton {
            delegate?.shareApplication()
        }
    }
}
