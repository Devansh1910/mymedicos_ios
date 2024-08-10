//
//  ShareUIView.swift
//  mymedicos
//
//  Created by Devansh Saxena on 07/08/24.
//

import UIKit

class ShareUIView: UIView {

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "square.and.arrow.up") // Substitute with your image asset name if using a custom image
        imageView.tintColor = UIColor.orange
        imageView.backgroundColor = UIColor(red: 1.00, green: 0.93, blue: 0.80, alpha: 1.00) // Light orange background
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SHARE APP"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Invite your friends to mymedicos and learn together"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        backgroundColor = UIColor(red: 1.00, green: 0.98, blue: 0.94, alpha: 1.00) // Light beige background
        layer.cornerRadius = 10

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)

        // Constraints for iconView
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48)
        ])

        // Constraints for titleLabel
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16)
        ])

        // Constraints for descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

}
