import UIKit

class CompleteProfileUIView: UIView {
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let percentageLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.90, alpha: 1.00) // Adjusted to match the screenshot background
        
        // Title label setup
        titleLabel.text = "Complete your profile"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Description label setup
        descriptionLabel.text = "TO give you personalized learning experience we recommend to complete your profile."
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Progress view setup
        progressView.progress = 0.75
        progressView.trackTintColor = UIColor.lightGray
        progressView.progressTintColor = UIColor.green
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        // Percentage label setup
        percentageLabel.text = "75%"
        percentageLabel.font = UIFont.boldSystemFont(ofSize: 14)
        percentageLabel.textColor = .black
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding subviews
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(progressView)
        addSubview(percentageLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            
            progressView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -200), // leaving space for percentage label
            
            percentageLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            percentageLabel.leadingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: 5),
            percentageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            
            bottomAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20)
        ])
    }
}
