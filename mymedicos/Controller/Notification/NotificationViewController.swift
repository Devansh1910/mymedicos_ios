import UIKit

class NotificationViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Notifications"
        
        navigationController?.navigationBar.tintColor = .black
        setupView()
    }
    
    private func setupView() {
        // Set background color for the view
        view.backgroundColor = .white
        
        // Create the container view
        let containerView = UIView()
        containerView.backgroundColor = UIColor(hex: "#FFF6D8")
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Create the title label
        let titleLabel = UILabel()
        titleLabel.text = "Welcome Onboard!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Create the description label
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Get ready to explore! We're excited to have you on board. Let's make something great together."
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descriptionLabel)
        
        // Create the explore button
        let exploreButton = UIButton(type: .system)
        exploreButton.setTitle("Explore", for: .normal)
        exploreButton.backgroundColor = .darkGray
        exploreButton.setTitleColor(.white, for: .normal)
        exploreButton.layer.cornerRadius = 5
        exploreButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(exploreButton)
        
        // Set constraints for containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), // Aligns container at the top with 20pt margin
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10), // Left margin
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10), // Right margin
            containerView.heightAnchor.constraint(equalToConstant: 120) // Adjusted height
        ])
        
        // Set constraints for titleLabel
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 10)
        ])
        
        // Set constraints for descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        ])
        
        // Set constraints for exploreButton
        NSLayoutConstraint.activate([
            exploreButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            exploreButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            exploreButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 10),
            exploreButton.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
}
