import UIKit
import FirebaseFirestore

protocol ContinueSolvingCardViewDelegate: AnyObject {
    func didTapContinueSolvingCard(withExamID examID: String, lastQuestionIndex: Int)
}

class ContinueSolvingCardView: UIView {
    
    weak var delegate: ContinueSolvingCardViewDelegate?
    
    private var currentExamID: String?
    private var lastQuestionIndex: Int?
    
    private let titleLabelContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true // Ensure scrolling text doesn't overflow the container
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading.."
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.lineBreakMode = .byClipping // This ensures the label text doesn't break but keeps scrolling
        label.numberOfLines = 1
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading.. | Loading.."
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progress = 0.35 // Example progress
        progress.tintColor = .systemRed
        return progress
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.white.cgColor, UIColor.black.withAlphaComponent(0.05).cgColor]
        gradient.startPoint = CGPoint(x: 1, y: 0.9)
        gradient.endPoint = CGPoint(x: 1, y: 1.9)
        return gradient
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup View
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 4
        
        layer.insertSublayer(gradientLayer, at: 0) // Add the gradient layer
        
        addSubview(titleLabelContainer)
        titleLabelContainer.addSubview(titleLabel)
        addSubview(progressLabel)
        addSubview(progressView)
        addSubview(closeButton)
        addSubview(imageView)
        
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        self.addGestureRecognizer(tapGesture)
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        adjustTitleAnimation() // Ensure animation is adjusted after layout changes
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        titleLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabelContainer.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabelContainer.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20), // 20-point margin from the image
            titleLabelContainer.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -20), // 20-point margin from the close button
            titleLabelContainer.heightAnchor.constraint(equalTo: titleLabel.heightAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: titleLabelContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleLabelContainer.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleLabelContainer.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleLabelContainer.bottomAnchor),
            
            progressLabel.topAnchor.constraint(equalTo: titleLabelContainer.bottomAnchor, constant: 5),
            progressLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20),
            
            progressView.leadingAnchor.constraint(equalTo: titleLabelContainer.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -20),
            progressView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 5),
            progressView.heightAnchor.constraint(equalToConstant: 2),
            
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 25),  // Ensure button has width
            closeButton.heightAnchor.constraint(equalToConstant: 25)  // Ensure button has height
        ])
    }
    
    private func startTitleAnimation() {
        titleLabel.layer.removeAllAnimations()
        adjustTitleAnimation()
    }
    
    private func adjustTitleAnimation() {
        titleLabel.sizeToFit() // Ensure the titleLabel has the correct width
        let titleWidth = titleLabel.bounds.width
        let containerWidth = titleLabelContainer.bounds.width
        
        print("Title Width: \(titleWidth), Container Width: \(containerWidth)")  // Debugging print
        
        guard titleWidth > containerWidth else { return }
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: titleWidth, height: titleLabelContainer.bounds.height)
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = containerWidth
        animation.toValue = -titleWidth
        animation.duration = Double(titleWidth) / 30.0
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        titleLabel.layer.add(animation, forKey: "marquee")
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        removeFromSuperview()
    }
    
    @objc private func cardTapped() {
        // Ensure the currentExamID and lastQuestionIndex are not nil before notifying the delegate
        if let examID = currentExamID, let index = lastQuestionIndex {
            delegate?.didTapContinueSolvingCard(withExamID: examID, lastQuestionIndex: index)
        }
    }
    
    // MARK: - Public Methods
    func configure(withTitle title: String, progress: Float, progressText: String, image: UIImage?) {
        titleLabel.text = title
        progressView.progress = progress
        progressLabel.text = progressText
        imageView.image = image
        startTitleAnimation() // Restart the animation every time the title is set
    }
    
    func fetchQuizProgress(for phoneNumber: String) {
        // Initially keep the view fully transparent and hidden
        self.alpha = 0.0
        self.isHidden = true
        
        fetchAndUpdateQuizProgress(for: phoneNumber)
    }
    
    private func fetchAndUpdateQuizProgress(for phoneNumber: String) {
        let db = Firestore.firestore()
        let docRef = db.collection("QuizProgress").document(phoneNumber).collection("pgneet")
        
        docRef.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            // Error handling
            if let error = error {
                print("Error fetching documents: \(error)")
                self.isHidden = true
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                self.isHidden = true
                return
            }
            
            var foundIncompleteQuiz = false
            var examID: String?
            var progress: [String: String] = [:]
            
            for document in documents {
                let data = document.data()
                if let submitted = data["submitted"] as? Bool, !submitted {
                    if let fetchedExamID = data["docID"] as? String,
                       let fetchedProgress = data["progress"] as? [String: String] {
                        foundIncompleteQuiz = true
                        examID = fetchedExamID
                        progress = fetchedProgress
                        break
                    }
                }
            }
            
            // Update the UI based on whether an incomplete quiz was found
            if foundIncompleteQuiz, let examID = examID {
                self.currentExamID = examID
                self.lastQuestionIndex = progress.keys.compactMap { Int($0) }.max() ?? 0
                self.showCardWithFadeIn()
                self.fetchExamDetails(for: examID, progress: progress)
            } else {
                self.isHidden = true
            }
        }
    }

    private func fetchExamDetails(for examID: String, progress: [String: String]) {
        let db = Firestore.firestore()
        let docRef = db.collection("PGupload").document("Weekley").collection("Quiz").document(examID)
        
        docRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            // Error handling
            if let error = error {
                print("Error fetching exam details: \(error)")
                return
            }
            
            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }
            
            guard let data = document.data(),
                  let title = data["title"] as? String,
                  let index = data["index"] as? String,
                  let questions = data["Data"] as? [[String: Any]],
                  let imageUrl = data["thumbnail"] as? String else {
                print("Data missing or format is incorrect")
                return
            }
            
            let totalQuestions = questions.count
            let answeredQuestions = progress.count
            let pendingQuestions = totalQuestions - answeredQuestions
            let progressFraction = Float(answeredQuestions) / Float(totalQuestions)
            
            self.updateUI(with: title, pendingQuestions: pendingQuestions, index: index, progressFraction: progressFraction, imageUrl: imageUrl)
        }
    }

    private func updateUI(with title: String, pendingQuestions: Int, index: String, progressFraction: Float, imageUrl: String) {
        DispatchQueue.main.async {
            let progressText = "\(pendingQuestions) Ques left | \(index)"
            self.configure(withTitle: title, progress: progressFraction, progressText: progressText, image: UIImage(named: ""))  // Set a placeholder image if needed
            
            if let url = URL(string: imageUrl) {
                self.loadImage(from: url) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }
            
            self.isHidden = false
        }
    }

    private func showCardWithFadeIn() {
        // Ensure the view is visible and fade it in
        self.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1.0
        }
    }
}
