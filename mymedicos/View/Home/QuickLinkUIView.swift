import UIKit

class QuickLinkUIView: UIView {

    // Initialize the quick link buttons
    let pgNeetButton: UIButton = {
        let color = UIColor(hexString: "#F8FAFC")
        let textColor = UIColor(hexString: "#1D4ED8") // Custom text color for PG NEET
        let iconColor = UIColor(hexString: "#1D4ED8") // Custom icon color for PG NEET
        let button = createCustomButton(title: "PG NEET", backgroundColor: color, systemIconName: "book.fill", textColor: textColor, iconColor: iconColor)
        addInnerShadow(to: button)
        return button
    }()
    
    let fmgeButton: UIButton = {
        let color = UIColor(hexString: "#F8FAFC")
        let textColor = UIColor(hexString: "#10B981") // Custom text color for FMGE
        let iconColor = UIColor(hexString: "#10B981") // Custom icon color for FMGE
        let button = createCustomButton(title: "FMGE", backgroundColor: color, systemIconName: "stethoscope", textColor: textColor, iconColor: iconColor)
        addInnerShadow(to: button)
        return button
    }()
    
    let neetSsButton: UIButton = {
        let color = UIColor(hexString: "#F8FAFC")
        let textColor = UIColor(hexString: "#F59E0B") // Custom text color for NEET SS
        let iconColor = UIColor(hexString: "#F59E0B") // Custom icon color for NEET SS
        let button = createCustomButton(title: "NEET SS", backgroundColor: color, systemIconName: "graduationcap.fill", textColor: textColor, iconColor: iconColor)
        addInnerShadow(to: button)
        return button
    }()
    
    let mbbsButton: UIButton = {
        let color = UIColor(hexString: "#F8FAFC")
        let textColor = UIColor(hexString: "#EF4444") // Custom text color for MBBS
        let iconColor = UIColor(hexString: "#EF4444") // Custom icon color for MBBS
        let button = createCustomButton(title: "MBBS", backgroundColor: color, systemIconName: "person.fill", textColor: textColor, iconColor: iconColor)
        addInnerShadow(to: button)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Create a vertical stack view for the two rows
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillEqually
        verticalStackView.spacing = 16
        
        // Create a horizontal stack view for the first row
        let firstRowStackView = UIStackView(arrangedSubviews: [pgNeetButton, fmgeButton])
        firstRowStackView.axis = .horizontal
        firstRowStackView.distribution = .fillEqually
        firstRowStackView.spacing = 10
        
        // Create a horizontal stack view for the second row
        let secondRowStackView = UIStackView(arrangedSubviews: [neetSsButton, mbbsButton])
        secondRowStackView.axis = .horizontal
        secondRowStackView.distribution = .fillEqually
        secondRowStackView.spacing = 10
        
        // Add the two rows to the vertical stack view
        verticalStackView.addArrangedSubview(firstRowStackView)
        verticalStackView.addArrangedSubview(secondRowStackView)
        
        // Add the stack view to the main view
        addSubview(verticalStackView)
        
        // Set stack view constraints
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
    }
    
    private static func createCustomButton(title: String, backgroundColor: UIColor, systemIconName: String, textColor: UIColor, iconColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        
        // Add a black border
        button.layer.borderWidth = 0.8
        button.layer.borderColor = UIColor.darkGray.cgColor
        
        // Create the icon and title label
        let iconImageView = UIImageView(image: UIImage(systemName: systemIconName))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = iconColor
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = textColor
        titleLabel.textAlignment = .center
        
        // Create stack view to hold the icon and label
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5
        
        // Add padding to the stack view
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        button.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: button.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: button.bottomAnchor, constant: -16)
        ])
        
        return button
    }

    private static func addInnerShadow(to button: UIButton) {
        let shadowLayer = CALayer()
        shadowLayer.frame = button.bounds
        shadowLayer.cornerRadius = button.layer.cornerRadius

        let shadowPath = UIBezierPath(roundedRect: shadowLayer.bounds.insetBy(dx: -2, dy: -2), cornerRadius: shadowLayer.cornerRadius)
        let cutout = UIBezierPath(roundedRect: shadowLayer.bounds, cornerRadius: shadowLayer.cornerRadius).reversing()

        shadowPath.append(cutout)
        shadowLayer.shadowPath = shadowPath.cgPath
        shadowLayer.masksToBounds = true
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 3)
        shadowLayer.shadowOpacity = 0.25
        shadowLayer.shadowRadius = 5

        button.layer.addSublayer(shadowLayer)
    }
}

// Extension to convert Hex color code to UIColor
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
