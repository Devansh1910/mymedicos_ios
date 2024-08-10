import UIKit

class TitleButtonsUIView: UIView {
    
    var bookmarkButton: UIButton!
    var titleLabel: UILabel! // Make the titleLabel accessible

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Create the title label
        titleLabel = UILabel() // Initialize titleLabel
        titleLabel.text = "Champions Exam NEET PG - 2"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the share and free buttons
        let shareButton = createButton(title: "Share", imageName: "arrowshape.turn.up.right")
        let freeButton = createButton(title: "Free", imageName: "lock.open")
        
        // Create and configure the bookmark button
        bookmarkButton = createButton(title: "Bookmark", imageName: "bookmark")
        
        // Create the stack view for the share and free buttons
        let shareFreeStackView = UIStackView(arrangedSubviews: [shareButton, freeButton])
        shareFreeStackView.axis = .horizontal
        shareFreeStackView.spacing = 10
        shareFreeStackView.alignment = .center
        shareFreeStackView.distribution = .fillEqually
        shareFreeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a vertical stack view to organize title, shareFreeStackView, and bookmark button
        let mainStackView = UIStackView(arrangedSubviews: [titleLabel, shareFreeStackView, bookmarkButton])
        mainStackView.axis = .vertical
        mainStackView.spacing = 10
        mainStackView.alignment = .center
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the main stack view to the custom view
        addSubview(mainStackView)
        
        // Setup constraints for mainStackView
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            shareFreeStackView.heightAnchor.constraint(equalToConstant: 50),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createButton(title: String, imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 20
        button.backgroundColor = UIColor(white: 0.95, alpha: 1)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Adjust title and image insets for button layout
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        
        // Set padding within the button
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        
        return button
    }
}
