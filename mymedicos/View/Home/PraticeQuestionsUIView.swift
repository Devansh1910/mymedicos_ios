import UIKit

class PraticeQuestionsUIView: UIView {
    
    // Initializing the subviews
    let mainButton = UIButton()
    let actionButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Adding a border to the entire view
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        layer.masksToBounds = true

        // Main Button setup
        mainButton.backgroundColor = UIColor.white
        mainButton.layer.cornerRadius = 5 // Adjust the corner radius as needed
        mainButton.clipsToBounds = true
        
        mainButton.setTitle("Practice with QBank 6.0", for: .normal)
        mainButton.setTitleColor(.black, for: .normal) // Set the text color to black for better visibility on white background
        mainButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        mainButton.contentHorizontalAlignment = .left
        mainButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        
        // Action Button setup
        actionButton.backgroundColor = UIColor.darkGray
        actionButton.setTitle("Solve now", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        actionButton.layer.cornerRadius = 10
        actionButton.clipsToBounds = true
        
        // Adding buttons to the main view
        addSubview(mainButton)
        mainButton.addSubview(actionButton)
        
        // Layout constraints
        mainButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Main button constraints
            mainButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainButton.topAnchor.constraint(equalTo: topAnchor),
            mainButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Action button constraints
            actionButton.trailingAnchor.constraint(equalTo: mainButton.trailingAnchor, constant: -10),
            actionButton.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 100),
            actionButton.heightAnchor.constraint(equalTo: mainButton.heightAnchor, multiplier: 0.6)
        ])
    }
}
