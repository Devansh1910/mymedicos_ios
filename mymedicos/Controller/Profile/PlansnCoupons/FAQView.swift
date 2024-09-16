//import UIKit
//
//class FAQView: UIView {
//    var faq: FAQ
//    var questionLabel: UILabel
//    var answerLabel: UILabel
//    
//    init(faq: FAQ) {
//        self.faq = faq
//        questionLabel = UILabel()
//        answerLabel = UILabel()
//        super.init(frame: .zero)
//        setupViews()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupViews() {
//        questionLabel.text = faq.question
//        questionLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//        answerLabel.text = faq.answer
//        answerLabel.font = UIFont.systemFont(ofSize: 14)
//        answerLabel.numberOfLines = 0
//        answerLabel.isHidden = !faq.isExpanded
//        
//        addSubview(questionLabel)
//        addSubview(answerLabel)
//        
//        questionLabel.translatesAutoresizingMaskIntoConstraints = false
//        answerLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            questionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
//            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//            questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
//            
//            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 5),
//            answerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//            answerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
//            answerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
//        ])
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleExpand))
//        addGestureRecognizer(tapGesture)
//    }
//    
//    @objc func toggleExpand() {
//        faq.isExpanded.toggle()
//        answerLabel.isHidden = !faq.isExpanded
//        layoutIfNeeded()
//    }
//}
//
