import UIKit
import FirebaseDatabase

protocol QuickLinkUIViewDelegate: AnyObject {
    func didTapPGNeetButton()
    func didTapFMGEButton()
    func didTapNeetssButton()
}

class QuickLinkUIView: UIView {

    weak var delegate: QuickLinkUIViewDelegate?

    let scrollView = UIScrollView()
    let stackView = UIStackView()

    let pgNeetButton = EnlargedTapAreaButton(type: .system)
    let fmgeButton = EnlargedTapAreaButton(type: .system)
    let neetSsButton = EnlargedTapAreaButton(type: .system)
    let mbbsButton = EnlargedTapAreaButton(type: .system)

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
        pgNeetButton.addTarget(self, action: #selector(pgNeetButtonTapped), for: .touchDown)

        configureButton(button: fmgeButton, title: "FMGE", backgroundColor: UIColor(hexString: "#F8FAFC"), systemIconName: "stethoscope", textColor: UIColor(hexString: "#10B981"), iconColor: UIColor(hexString: "#10B981"))
        fmgeButton.addTarget(self, action: #selector(fmgeButtonTapped), for: .touchDown)

        configureButton(button: neetSsButton, title: "NEET SS", backgroundColor: UIColor(hexString: "#F8FAFC"), systemIconName: "graduationcap.fill", textColor: UIColor(hexString: "#F59E0B"), iconColor: UIColor(hexString: "#F59E0B"))
        neetSsButton.addTarget(self, action: #selector(neetssButtonTapped), for: .touchDown)

        configureButton(button: mbbsButton, title: "MBBS", backgroundColor: UIColor(hexString: "#F8FAFC"), systemIconName: "person.fill", textColor: UIColor(hexString: "#EF4444"), iconColor: UIColor(hexString: "#EF4444"))
    }

    private func addElevation() {
        // Adding elevation to the QuickLinkUIView
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.25
        self.layer.masksToBounds = false
    }

    @objc private func pgNeetButtonTapped() {
        print("PG NEET Tapped")
        delegate?.didTapPGNeetButton()
    }

    @objc private func fmgeButtonTapped() {
        print("FMGE Tapped")
        delegate?.didTapFMGEButton()
    }

    @objc private func neetssButtonTapped() {
        guard let parentVC = self.parentViewController(), let phoneNumber = UserDefaults.standard.string(forKey: "savedPhoneNumber") else {
            print("Error: No parent view controller or phone number found")
            return
        }

        let ref = Database.database().reference()
        ref.child("profiles").child(phoneNumber).child("Neetss").observeSingleEvent(of: .value, with: { snapshot in
            if let value = snapshot.value as? String, !value.isEmpty {
                // If there is a value, push NeetssTabbarViewController
                DispatchQueue.main.async {
                    let neetssVC = NeetssTabbarViewController()
                    neetssVC.hidesBottomBarWhenPushed = true
                    parentVC.navigationController?.pushViewController(neetssVC, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    let groupVC = GroupSelectionBottomSheetViewController()
                    groupVC.completion = { selectedGroup in
                        self.delegate?.didTapNeetssButton()
                    }
                    parentVC.present(groupVC, animated: true, completion: nil)
                }
            }
        }) { error in
            print(error.localizedDescription)
        }
    }

    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    private func setupView() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.isUserInteractionEnabled = true

        stackView.addArrangedSubview(pgNeetButton)
        stackView.addArrangedSubview(fmgeButton)
        stackView.addArrangedSubview(neetSsButton)
        stackView.addArrangedSubview(mbbsButton)

        scrollView.addSubview(stackView)
        addSubview(scrollView)

        scrollView.showsHorizontalScrollIndicator = false // Hide horizontal scrollbar

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }

    private func configureButton(button: UIButton, title: String, backgroundColor: UIColor, systemIconName: String, textColor: UIColor, iconColor: UIColor) {
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.layer.borderWidth = 0.8
        button.layer.borderColor = UIColor.darkGray.cgColor

        let iconImage = UIImage(systemName: systemIconName)?.withTintColor(iconColor, renderingMode: .alwaysOriginal)
        button.setImage(iconImage, for: .normal)
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)

        button.isUserInteractionEnabled = true

        // Set width and height constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 140),
            button.heightAnchor.constraint(equalToConstant: 40)
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
