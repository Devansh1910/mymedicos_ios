import UIKit

class CustomPickerCell: UITableViewCell {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    let radioButton: UIButton = {
        let button = UIButton(type: .custom)
        
        // Set the gray color for both normal and selected states
        let normalImage = UIImage(systemName: "circle")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        let selectedImage = UIImage(systemName: "circle.inset.filled")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        return button
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Add containerView to contentView
        contentView.addSubview(containerView)
        
        // Add titleLabel and radioButton to the containerView
        containerView.addSubview(titleLabel)
        containerView.addSubview(radioButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        radioButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Container view constraints for margin
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            // titleLabel constraints
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20), // Internal padding
            
            // radioButton constraints
            radioButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            radioButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20) // Internal padding
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 10
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 1
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: contentView.frame.width, height: 60) // Adjust the height here as needed
    }
}
