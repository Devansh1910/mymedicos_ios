import UIKit

protocol QuickLinkUIViewDelegate: AnyObject {
    func didTapPGNeetButton()
}

class QuickLinkUIView: UIView {
    
    weak var delegate: QuickLinkUIViewDelegate?

    let pgNeetButton = UIButton(type: .system)
    let fmgeButton = UIButton(type: .system)
    let neetSsButton = UIButton(type: .system)
    let mbbsButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButtons()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureButtons()
        setupView()
    }
    
    private func configureButtons() {
        configureButton(button: pgNeetButton, title: "PG NEET", backgroundColor: UIColor(hexString: "#F8FAFC"), systemIconName: "book.fill", textColor: UIColor(hexString: "#1D4ED8"), iconColor: UIColor(hexString: "#1D4ED8"))
        pgNeetButton.addTarget(self, action: #selector(pgNeetButtonTapped), for: .touchUpInside)
        
        configureButton(button: fmgeButton, title: "FMGE", backgroundColor: UIColor(hexString: "#F8FAFC"), systemIconName: "stethoscope", textColor: UIColor(hexString: "#10B981"), iconColor: UIColor(hexString: "#10B981"))
        configureButton(button: neetSsButton, title: "NEET SS", backgroundColor: UIColor(hexString: "#F8FAFC"), systemIconName: "graduationcap.fill", textColor: UIColor(hexString: "#F59E0B"), iconColor: UIColor(hexString: "#F59E0B"))
        configureButton(button: mbbsButton, title: "MBBS", backgroundColor: UIColor(hexString: "#F8FAFC"), systemIconName: "person.fill", textColor: UIColor(hexString: "#EF4444"), iconColor: UIColor(hexString: "#EF4444"))
    }
    
    @objc private func pgNeetButtonTapped() {
        delegate?.didTapPGNeetButton()
    }
    
    private func setupView() {
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillEqually
        verticalStackView.spacing = 16
        
        let firstRowStackView = UIStackView(arrangedSubviews: [pgNeetButton, fmgeButton])
        firstRowStackView.axis = .horizontal
        firstRowStackView.distribution = .fillEqually
        firstRowStackView.spacing = 10
        
        let secondRowStackView = UIStackView(arrangedSubviews: [neetSsButton, mbbsButton])
        secondRowStackView.axis = .horizontal
        secondRowStackView.distribution = .fillEqually
        secondRowStackView.spacing = 10
        
        verticalStackView.addArrangedSubview(firstRowStackView)
        verticalStackView.addArrangedSubview(secondRowStackView)
        
        addSubview(verticalStackView)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureButton(button: UIButton, title: String, backgroundColor: UIColor, systemIconName: String, textColor: UIColor, iconColor: UIColor) {
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.layer.borderWidth = 0.8
        button.layer.borderColor = UIColor.darkGray.cgColor
        
        let iconImageView = UIImageView(image: UIImage(systemName: systemIconName))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = iconColor
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = textColor
        titleLabel.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5
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
        
        QuickLinkUIView.addInnerShadow(to: button)
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
