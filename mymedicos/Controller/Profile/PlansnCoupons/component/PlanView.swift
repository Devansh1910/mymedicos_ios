import UIKit

class PlanView: UIView {

    private let planLabel = UILabel()
    private let priceLabel = UILabel()
    private let recommendedBadge = UILabel()
    private let radioButton = UIButton()
    private let originalPriceLabel = UILabel()

    private var isSelectedPlan: Bool = false {
        didSet {
            updateSelectionState()
        }
    }

    var isRecommended: Bool = false {
        didSet {
            updateRecommendedStyle()
        }
    }

    var didTapRadioButton: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 10
        clipsToBounds = true
        
        setupLabels()
        setupRadioButton()
        setupRecommendedBadge()
        
        addConstraints()
    }

    private func setupLabels() {
        planLabel.font = UIFont.systemFont(ofSize: 16)
        planLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(planLabel)
        
        originalPriceLabel.font = UIFont.systemFont(ofSize: 14)
        originalPriceLabel.textColor = .gray
        originalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        originalPriceLabel.attributedText = NSAttributedString(string: "", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        addSubview(originalPriceLabel)
        
        priceLabel.font = UIFont.boldSystemFont(ofSize: 16)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(priceLabel)
    }

    private func setupRadioButton() {
        radioButton.tintColor = .systemOrange  // Set the tint color to yellow
        radioButton.setImage(UIImage(systemName: "circle"), for: .normal)
        radioButton.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .selected)
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButton.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
        addSubview(radioButton)
    }


    private func setupRecommendedBadge() {
        recommendedBadge.text = "RECOMMENDED"
        recommendedBadge.font = UIFont.boldSystemFont(ofSize: 10)
        recommendedBadge.textColor = .white
        recommendedBadge.backgroundColor = .orange
        recommendedBadge.textAlignment = .center
        recommendedBadge.translatesAutoresizingMaskIntoConstraints = false
        recommendedBadge.isHidden = true
        addSubview(recommendedBadge)

        let maskPath = UIBezierPath(roundedRect: recommendedBadge.bounds,
                                    byRoundingCorners: [.bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: 5, height: 5))

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        recommendedBadge.layer.mask = shape
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let maskPath = UIBezierPath(roundedRect: recommendedBadge.bounds,
                                    byRoundingCorners: [.bottomLeft, .bottomRight],
                                    cornerRadii: CGSize(width: 5, height: 5))

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        recommendedBadge.layer.mask = shape
    }


    private func addConstraints() {
        NSLayoutConstraint.activate([
            radioButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            radioButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            radioButton.widthAnchor.constraint(equalToConstant: 30),
            radioButton.heightAnchor.constraint(equalToConstant: 30),
            
            planLabel.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: 10),
            planLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            originalPriceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            originalPriceLabel.bottomAnchor.constraint(equalTo: priceLabel.topAnchor, constant: -2),
            
            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            priceLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Adjust the recommended badge to overlap with the border
            recommendedBadge.topAnchor.constraint(equalTo: topAnchor, constant: 0), // Move it above the view's top
            recommendedBadge.centerXAnchor.constraint(equalTo: centerXAnchor),
            recommendedBadge.widthAnchor.constraint(equalToConstant: 100),
            recommendedBadge.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    func configure(with plan: Plan, isSelected: Bool) {
        planLabel.text = plan.plan
        priceLabel.text = plan.price
        originalPriceLabel.attributedText = NSAttributedString(
            string: plan.originalPrice,
            attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
        )
        isRecommended = plan.isRecommended
        self.isSelectedPlan = isSelected
    }

    private func updateSelectionState() {
        if isSelectedPlan {
            layer.borderWidth = 2
            layer.borderColor = UIColor.systemYellow.cgColor
            
            // Add shadow when selected
            layer.shadowColor = UIColor.systemOrange.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowRadius = 5
            layer.shadowOpacity = 0.2
            layer.masksToBounds = false
        } else {
            layer.borderWidth = 0
            layer.borderColor = UIColor.systemOrange.cgColor
            
            // Remove shadow when not selected
            layer.shadowColor = UIColor.clear.cgColor
            layer.shadowOffset = CGSize.zero
            layer.shadowRadius = 0
            layer.shadowOpacity = 0
        }
        updateRadioButton()
    }


    private func updateRadioButton() {
        radioButton.isSelected = isSelectedPlan
    }

    private func updateRecommendedStyle() {
        // Update recommended badge visibility
        recommendedBadge.isHidden = !isRecommended
        
        // Ensure the border color reflects selection or recommendation state
        if isRecommended && !isSelectedPlan {
            layer.borderWidth = 2
            layer.borderColor = UIColor.systemYellow.cgColor
        } else if isSelectedPlan {
            layer.borderWidth = 2
            layer.borderColor = UIColor.systemYellow.cgColor
        } else {
            layer.borderWidth = 0
            layer.borderColor = UIColor.clear.cgColor
        }
    }

    @objc private func radioButtonTapped() {
        didTapRadioButton?()
    }
}
