import UIKit

protocol DailyQuestionUIViewDelegate: AnyObject {
    func didTapLearnMore()
}

class DailyQuestionUIView: UIView {
    
    weak var delegate: DailyQuestionUIViewDelegate?

    private let questionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Solve now", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.tintColor = .white
         button.addTarget(self, action: #selector(handleLearnMore), for: .touchUpInside)
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
    
    @objc private func handleLearnMore() {
        delegate?.didTapLearnMore()
    }
    
    private func setupLayout() {
        addSubview(questionLabel)
        addSubview(actionButton)
        
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            actionButton.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            actionButton.widthAnchor.constraint(equalToConstant: 100), // Adjusted width to make button shorter
            actionButton.heightAnchor.constraint(equalToConstant: 35)  // Adjusted height to make it smaller
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
                   let first = data.first,
                   let question = first["Question"] as? String {
                    DispatchQueue.main.async {
                        self?.questionLabel.text = question
                    }
                }
            } catch {
                print("Failed to parse JSON: \(error)")
            }
        }.resume()
    }
    
    func configure(with question: String) {
        questionLabel.text = question
    }
}
