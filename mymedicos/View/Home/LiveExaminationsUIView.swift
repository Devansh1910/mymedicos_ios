import UIKit
import FirebaseFirestore

protocol LiveExaminationsUIViewDelegate: AnyObject {
    func navigateToExamPortal(withTitle title: String, examID: String)
}

class LiveExaminationsUIView: UIView {
    weak var delegate: LiveExaminationsUIViewDelegate?
    private var examID: String? // Store the examID
    private var shimmerLayer: CAGradientLayer?

    // Red Circle View
    private let redCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 5 // Half of the height/width to make it a circle
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        styleStaticComponents()
        fetchData()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
        styleStaticComponents()
        fetchData()
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerLayer?.frame = self.bounds // Adjust if needed to cover specific areas
    }

    // During initialization or styling, set background colors to compatible ones
    private func styleStaticComponents() {
        liveLabel.backgroundColor = .clear
        neetButton.backgroundColor = .clear
        lockButton.backgroundColor = .clear
        questionLabel.backgroundColor = .clear
        infoStackView.arrangedSubviews.forEach { subview in
            if let label = subview as? UILabel {
                label.backgroundColor = .clear
            } else if let imageView = subview as? UIImageView {
                imageView.backgroundColor = .clear
            }
        }
    }

    
    // LIVE Label
    private let liveLabel: UILabel = {
        let label = UILabel()
        label.text = "LIVE"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Horizontal StackView to hold the red circle and LIVE label
    private let liveStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5 // Spacing between red circle and LIVE label
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Lock/Unlock Button
    private let lockButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.backgroundColor = .lightGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // NEET PG Button
    private let neetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("NEET PG", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .lightGray.withAlphaComponent(0.2)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // Question Label
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 0 // Limit to 2 lines
        label.lineBreakMode = .byTruncatingTail // Add ellipsis if text exceeds 2 lines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MCCs and Time Info StackView
    private let infoStackView: UIStackView = {
        let playIcon = UIImageView(image: UIImage(systemName: "play.circle.fill"))
        playIcon.tintColor = .darkGray
        playIcon.translatesAutoresizingMaskIntoConstraints = false
        playIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        playIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let timeIcon = UIImageView(image: UIImage(systemName: "clock.fill"))
        timeIcon.tintColor = .darkGray
        timeIcon.translatesAutoresizingMaskIntoConstraints = false
        timeIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        timeIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let mccLabel = UILabel()
        mccLabel.text = "200 MCC's"
        mccLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        mccLabel.textColor = .darkGray
        
        let timeLabel = UILabel()
        timeLabel.text = "210 mins"
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        timeLabel.textColor = .darkGray
        
        let stackView = UIStackView(arrangedSubviews: [playIcon, mccLabel, timeIcon, timeLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // Attempt Button
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Solve now", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleAttempt), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc private func handleAttempt() {
        if let title = questionLabel.text, let examID = examID {
            delegate?.navigateToExamPortal(withTitle: title, examID: examID)
        }
    }
    
    private func addShimmerEffect() {
        shimmerLayer?.removeFromSuperlayer()
        shimmerLayer = CAGradientLayer()
        let lightColor = UIColor.white.withAlphaComponent(0.1).cgColor
        let darkColor = UIColor.black.withAlphaComponent(0.08).cgColor

        shimmerLayer?.colors = [darkColor, lightColor, darkColor]
        shimmerLayer?.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        shimmerLayer?.locations = [0, 0.5, 1]
        shimmerLayer?.frame = self.bounds
        layer.insertSublayer(shimmerLayer!, at: 0) // Ensure it's below all other subviews

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = Float.infinity
        shimmerLayer?.add(animation, forKey: "shimmer")
    }

    private func removeShimmerEffect() {
        shimmerLayer?.removeFromSuperlayer()
    }

    
    
    private func setupLayout() {
        // Add red circle and LIVE label to the stack view
        liveStackView.addArrangedSubview(redCircleView)
        liveStackView.addArrangedSubview(liveLabel)
        
        // Add all subviews to the main view
        addSubview(liveStackView)
        addSubview(lockButton)
        addSubview(neetButton)
        addSubview(questionLabel)
        addSubview(infoStackView)
        addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            // Red Circle Size Constraints
            redCircleView.widthAnchor.constraint(equalToConstant: 10),
            redCircleView.heightAnchor.constraint(equalToConstant: 10),
            
            // LIVE Stack View (Red Circle + LIVE Label)
            liveStackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            liveStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            // Lock Button
            lockButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            lockButton.trailingAnchor.constraint(equalTo: neetButton.leadingAnchor, constant: -10),
            lockButton.widthAnchor.constraint(equalToConstant: 40), // Make it same size as NEET PG button
            lockButton.heightAnchor.constraint(equalToConstant: 30),
            
            // NEET PG Button
            neetButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            neetButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            // Question Label
            questionLabel.topAnchor.constraint(equalTo: liveStackView.bottomAnchor, constant: 10),
            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            // MCCs and Time Info StackView and Attempt Button horizontally aligned
            infoStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            infoStackView.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            actionButton.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10),
            actionButton.widthAnchor.constraint(equalToConstant: 100), // Adjusted width to make button shorter
            actionButton.heightAnchor.constraint(equalToConstant: 35),  // Adjusted height to make it smaller
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10), // Ensures dynamic height
            
            // Align infoStackView with Solve Now button
            infoStackView.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -10)
        ])
        
        // Main View Styling
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
    }

    private func fetchData() {
        addShimmerEffect()
        let db = Firestore.firestore()
        let today = Date()

        db.collection("PGupload")
            .document("Weekley")
            .collection("Quiz")
            .whereField("to", isGreaterThanOrEqualTo: today)
            .getDocuments { [weak self] (querySnapshot, error) in
                self?.removeShimmerEffect()
                if let error = error {
                    print("Error fetching documents: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No documents found")
                    return
                }
                
                for document in documents {
                    print("Document ID: \(document.documentID)")
                    
                    if let fromTimestamp = document.data()["from"] as? Timestamp,
                       let toTimestamp = document.data()["to"] as? Timestamp {
                        let fromDate = fromTimestamp.dateValue()
                        let toDate = toTimestamp.dateValue()
                        
                        if today >= fromDate && today <= toDate {
                            if let title = document.data()["title"] as? String,
                               let type = document.data()["type"] as? Bool,
                               let examID = document.data()["qid"] as? String { // Fetch the qid (examID)
                                DispatchQueue.main.async {
                                    self?.questionLabel.text = title
                                    
                                    // Set the lock/unlock icon based on 'type'
                                    let iconName = type ? "lock.fill" : "lock.open.fill"
                                    self?.lockButton.setImage(UIImage(systemName: iconName), for: .normal)
                                    self?.lockButton.imageView?.contentMode = .scaleAspectFit
                                    
                                    // Store the examID (qid) to be used when navigating to the exam portal
                                    self?.examID = examID
                                }
                                break // Stop after finding the first valid document
                            } else {
                                print("Title, type, or qid field is missing in document: \(document.documentID)")
                            }
                        } else {
                            print("Document is out of date range: \(fromDate) to \(toDate)")
                        }
                    } else {
                        print("from or to date not found in document: \(document.documentID)")
                    }
                }
            }
    }



    func configure(with question: String) {
        questionLabel.text = question
    }
}
