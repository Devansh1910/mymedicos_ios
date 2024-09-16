import UIKit
import Firebase

protocol DailyQuestionUIViewDelegate: AnyObject {
    func didTapLearnMore()
}

class DailyQuestionUIView: UIView {
    
    private var shimmerLayer: CAGradientLayer?
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerLayer?.frame = self.bounds // Ensure the shimmer layer matches the view size
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
            actionButton.widthAnchor.constraint(equalToConstant: 100),
            actionButton.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
    }

    private func fetchData() {
        addShimmerEffect() // Start the shimmer when loading starts

        let db = Firestore.firestore()
        db.collection("PGupload").document("Daily").collection("Quiz")
            .whereField("speciality", isEqualTo: "home")
            .getDocuments { (querySnapshot, err) in
                self.removeShimmerEffect() // Stop the shimmer when data is loaded or error occurs
                if let err = err {
                    print("Error getting documents: \(err)")
                } else if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                    let documents = querySnapshot.documents
                    let randomDoc = documents.randomElement()!
                    let data = randomDoc.data()
                    let question = data["Question"] as? String ?? "No question available"
                    DispatchQueue.main.async {
                        self.questionLabel.text = question
                    }
                }
            }
    }

    func configure(with question: String) {
        questionLabel.text = question
    }
    
    private func addShimmerEffect() {
        shimmerLayer?.removeFromSuperlayer() // Remove previous shimmer if exists
        shimmerLayer = CAGradientLayer()

        let lightColor = UIColor.white.withAlphaComponent(0.1).cgColor
        let darkColor = UIColor.black.withAlphaComponent(0.08).cgColor

        shimmerLayer?.colors = [darkColor, lightColor, darkColor]
        shimmerLayer?.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        shimmerLayer?.locations = [0, 0.5, 1]

        // Set shimmer effect to cover the entire view initially
        shimmerLayer?.frame = self.bounds
        self.layer.addSublayer(shimmerLayer!)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity

        shimmerLayer?.add(animation, forKey: "shimmer")

        // Update button appearance for loading
        updateButtonForLoading(true)
    }

    private func removeShimmerEffect() {
        shimmerLayer?.removeFromSuperlayer()
        // Update button appearance after loading
        updateButtonForLoading(false)
    }

    
    private func updateButtonForLoading(_ isLoading: Bool) {
        if isLoading {
            actionButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.01)
            actionButton.setTitle("", for: .normal)
            actionButton.isEnabled = false  // Optionally disable the button
        } else {
            actionButton.backgroundColor = UIColor.darkGray
            actionButton.setTitle("Solve now", for: .normal)
            actionButton.isEnabled = true
        }
    }

}
