import UIKit
import FirebaseFirestore

// Define a structure for the plan data
struct PlanData {
    var title: String
    var subtitle: String
    var startingPrice: String
    var discountedPrice: String
    var originalPrice: String
    var features: [String]
}

// Plans view with labels, stack view for features, and an action button
class PlansNeetPgUIView: UIView {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let startingAtLabel = UILabel()
    let priceLabel = UILabel()
    let whatYouGetLabel = UILabel()
    let featureListView = UIStackView()
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enroll now", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        button.clipsToBounds = false
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleAttempt() {
        print("Enroll button tapped")
    }

    func setupViews() {
        backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 245/255, alpha: 1)
        layer.cornerRadius = 10
        clipsToBounds = true
        
        setupLabels()
        setupFeatureList()
        
        addSubviews(titleLabel, subtitleLabel, startingAtLabel, priceLabel, whatYouGetLabel, featureListView, actionButton)
        setupConstraints()
    }

    private func setupLabels() {
        titleLabel.text = "🔥 PRO Plan"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .black
        
        subtitleLabel.text = "India's Only Clinical QBank"
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = .darkGray
        
        startingAtLabel.text = "Starting at:"
        startingAtLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        startingAtLabel.textAlignment = .left
        startingAtLabel.textColor = .darkGray
        
        whatYouGetLabel.text = "WHAT YOU'LL GET"
        whatYouGetLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        whatYouGetLabel.textAlignment = .left
        whatYouGetLabel.textColor = .darkGray
    }

    private func setupFeatureList() {
        featureListView.axis = .vertical
        featureListView.distribution = .equalSpacing
        featureListView.alignment = .leading
        featureListView.spacing = 10

        let features = [
            "Unlimited access to QBank & Tests only.",
            "QBank 6.0 featuring 18,000+ questions",
            "Test Series with 1 Lakh+ Participants.",
            "Previous Year Questions",
            "Concise summary of Topics",
            "Proven effective Rapid Revision QBank"
        ]

        for feature in features {
            let label = UILabel()
            label.text = "✓ \(feature)"
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .darkGray
            label.numberOfLines = 0
            featureListView.addArrangedSubview(label)
        }
    }

    private func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }

    func configure(with planData: PlanData) {
        titleLabel.text = planData.title
        subtitleLabel.text = planData.subtitle

        let priceText = NSMutableAttributedString(string: "\(formatPrice(planData.discountedPrice)) ", attributes: [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.black
        ])
        priceText.append(NSAttributedString(string: formatPrice(planData.originalPrice), attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.gray,
            .strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]))
        priceLabel.attributedText = priceText

        featureListView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for feature in planData.features {
            let label = UILabel()
            label.text = "✓ \(feature)"
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .darkGray
            label.numberOfLines = 0
            featureListView.addArrangedSubview(label)
        }

        layer.borderColor = colorForPlan(planData.title).cgColor
        layer.borderWidth = 1
    }

    private func colorForPlan(_ planName: String) -> UIColor {
        switch planName {
            case "ELITE Plan":
                return UIColor.systemGray
            case "Foundation Plan":
                return UIColor.systemGray
            case "PRO Plan":
                return UIColor.systemGray
            default:
                return UIColor.clear
        }
    }

    private func formatPrice(_ price: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.currencyGroupingSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: Int(price) ?? 0)) ?? "₹0"
    }

    private func setupConstraints() {
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),

            startingAtLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            startingAtLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),

            priceLabel.topAnchor.constraint(equalTo: startingAtLabel.bottomAnchor, constant: 5),
            priceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),

            whatYouGetLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 20),
            whatYouGetLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),

            featureListView.topAnchor.constraint(equalTo: whatYouGetLabel.bottomAnchor, constant: 15),
            featureListView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            featureListView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            actionButton.topAnchor.constraint(equalTo: featureListView.bottomAnchor, constant: 30),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            actionButton.heightAnchor.constraint(equalToConstant: 40),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}
