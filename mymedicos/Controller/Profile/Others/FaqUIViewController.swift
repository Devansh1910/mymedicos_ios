import UIKit
import FirebaseFirestore

class FAQViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupFAQSection()
    }

    private func setupFAQSection() {
        let faqStackView = UIStackView()
        faqStackView.axis = .vertical
        faqStackView.alignment = .fill
        faqStackView.distribution = .equalSpacing
        faqStackView.spacing = 10
        faqStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(faqStackView)
        
        NSLayoutConstraint.activate([
            faqStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            faqStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            faqStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Add FAQ items
        let faqItems = [
            ("What is the purpose of this app?", "This app is designed to help users prepare for their exams by providing question banks, mock tests, and study materials."),
            ("How do I reset my password?", "To reset your password, go to the settings, select 'Reset Password,' and follow the instructions."),
            ("How do I contact support?", "You can contact support by emailing support@domain.com or using the chat feature in the app."),
            ("Where can I find the study materials?", "Study materials are available in the 'Resources' section of the app."),
            ("Can I access the app offline?", "Some features are available offline, but a majority require an internet connection."),
            ("How do I update the app?", "You can update the app through the App Store by checking for updates.")
        ]
        
        for item in faqItems {
            let questionView = createDropdownView(question: item.0, answer: item.1)
            faqStackView.addArrangedSubview(questionView)
        }
    }
    
    private func createDropdownView(question: String, answer: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let questionButton = UIButton(type: .system)
        questionButton.setTitle(question, for: .normal)
        questionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        questionButton.contentHorizontalAlignment = .left
        questionButton.translatesAutoresizingMaskIntoConstraints = false
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        arrowImageView.tintColor = .black
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        questionButton.addSubview(arrowImageView)
        
        let answerLabel = UILabel()
        answerLabel.text = answer
        answerLabel.font = UIFont.systemFont(ofSize: 14)
        answerLabel.textColor = .darkGray
        answerLabel.numberOfLines = 0
        answerLabel.isHidden = true
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(questionButton)
        containerView.addSubview(answerLabel)
        
        NSLayoutConstraint.activate([
            questionButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            questionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            questionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            arrowImageView.trailingAnchor.constraint(equalTo: questionButton.trailingAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: questionButton.centerYAnchor),
            
            answerLabel.topAnchor.constraint(equalTo: questionButton.bottomAnchor, constant: 10),
            answerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            answerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            answerLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
        questionButton.addTarget(self, action: #selector(toggleAnswer(_:)), for: .touchUpInside)
        questionButton.tag = answerLabel.hash
        
        return containerView
    }
    
    @objc private func toggleAnswer(_ sender: UIButton) {
        if let answerLabel = view.viewWithTag(sender.tag) as? UILabel {
            answerLabel.isHidden.toggle()
            if let arrowImageView = sender.subviews.compactMap({ $0 as? UIImageView }).first {
                UIView.animate(withDuration: 0.3) {
                    arrowImageView.transform = answerLabel.isHidden ? .identity : CGAffineTransform(rotationAngle: .pi)
                }
            }
        }
    }
}
