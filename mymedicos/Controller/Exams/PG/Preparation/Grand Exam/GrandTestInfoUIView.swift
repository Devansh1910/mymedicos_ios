import UIKit

class GrandTestInfoUIView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Setting up Duration view
        let durationView = createDetailView(imageName: "calendar.circle.fill", title: "210 mins Time Limit", subtitle: "Duration")
        
        // Setting up Marking Scheme view
        let markingView = createDetailView(imageName: "square.and.pencil.circle.fill", title: "Correct +4  Incorrect -1", subtitle: "Marking scheme")
        
        // Setting up Language view
        let languageView = createDetailView(imageName: "globe.badge.chevron.backward", title: "English", subtitle: "Language")
        
        // Creating a stack view to arrange the views vertically
        let stackView = UIStackView(arrangedSubviews: [durationView, markingView, languageView])
        stackView.axis = .vertical
        stackView.spacing = 0 // Removed spacing to use separator views instead
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        // Constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    private func createDetailView(imageName: String, title: String, subtitle: String) -> UIView {
        let imageView = UIImageView(image: UIImage(systemName: imageName))
        imageView.tintColor = .gray // Set the icon color to grey
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        // Add bottom border
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5) // Light grey color
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 32), // Increased size
            imageView.heightAnchor.constraint(equalToConstant: 32), // Increased size
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4),
            titleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5) // Thin line
        ])
        
        return view
    }
}
