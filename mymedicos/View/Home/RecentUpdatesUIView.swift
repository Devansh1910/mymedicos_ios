import UIKit

class RecentUpdatesUIView: UIView {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "megaphone.fill")
        imageView.tintColor = UIColor.white
        imageView.backgroundColor = UIColor(red: 0.29, green: 0.59, blue: 1.00, alpha: 1.00)
        imageView.layer.cornerRadius = 12
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Recent updates"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Updated on 28 August 2024"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right") // System icon
        imageView.tintColor = UIColor.lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        backgroundColor = UIColor(red: 0.95, green: 0.98, blue: 1.00, alpha: 1.00) // Light blue background
        layer.cornerRadius = 10

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(arrowImageView)

        // Constraints for iconView
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Constraints for titleLabel
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10)
        ])

        // Constraints for subtitleLabel
        NSLayoutConstraint.activate([
            subtitleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])

        // Constraints for arrowImageView
        NSLayoutConstraint.activate([
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

}
