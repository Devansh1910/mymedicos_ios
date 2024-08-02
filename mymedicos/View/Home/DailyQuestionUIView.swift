import UIKit

class DailyQuestionUIView: UIView {
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lightGray
        label.numberOfLines = 0
        return label
    }()
    
    // Adding the button
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Learn More", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = UIColor(red: 43/255, green: 208/255, blue: 191/255, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        fetchData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        fetchData()
    }
    
    private func setupLayout() {
        addSubview(questionLabel)
        addSubview(descriptionLabel)
        addSubview(actionButton) // Add the button to the view
        
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            // Constraints for the button
            actionButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            actionButton.heightAnchor.constraint(equalToConstant: 44) // Standard height for buttons
        ])
        
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
    }

    private func fetchData() {
        guard let url = URL(string: ConstantsDashboard.GET_DAILY_QUESTIONS_URL) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let data = json["data"] as? [[String: Any]],
                   let first = data.first {
                    DispatchQueue.main.async {
                        self?.questionLabel.text = first["Question"] as? String
                        self?.descriptionLabel.text = first["Description"] as? String
                    }
                }
            } catch {
                print("Failed to parse JSON: \(error)")
            }
        }.resume()
    }
    
    func configure(with question: String, description: String) {
        questionLabel.text = question
        descriptionLabel.text = description
    }
}
