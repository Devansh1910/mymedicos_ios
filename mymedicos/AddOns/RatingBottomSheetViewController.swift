import UIKit
import FirebaseDatabase
import FirebaseFirestore

protocol RatingBottomSheetDelegate: AnyObject {
    func didTapSubmit()
    func didTapClose()
}

class RatingBottomSheetViewController: UIViewController {
    
    weak var delegate: RatingBottomSheetDelegate?
    let containerView = UIView()
    
    var examId: String? // Add this line
    
    
    // UI Components
    let experienceLabel = UILabel()
    let starStackView = UIStackView()
    let commentTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareForFadeIn()
    }
    
    private func prepareForFadeIn() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        containerView.transform = CGAffineTransform(translationX: 0, y: 250)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.containerView.transform = .identity
        })
    }
    
    private func setupViews() {
        setupContainerView()
        setupExperienceLabel()
        setupStarRating()
        setupCommentBox()
        setupButtons()
    }
    
    private func setupContainerView() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    private func setupExperienceLabel() {
        experienceLabel.text = "How was your experience?"
        experienceLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        experienceLabel.textAlignment = .center
        containerView.addSubview(experienceLabel)
        experienceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            experienceLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            experienceLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
    
    private func setupStarRating() {
        starStackView.axis = .horizontal
        starStackView.distribution = .fillEqually
        starStackView.spacing = 20 // Increase the spacing
        starStackView.distribution = .fillEqually
        containerView.addSubview(starStackView)
        
        for _ in 1...5 {
            let starButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100)) // Increase width and height
            starButton.setImage(UIImage(systemName: "heart"), for: .normal)
            let largeIcon = UIImage(systemName: "heart.fill")?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
            starButton.setImage(largeIcon, for: .selected)
            starButton.tintColor = .red
            starButton.imageView?.contentMode = .scaleAspectFill
            starButton.addTarget(self, action: #selector(handleStarTapped(_:)), for: .touchUpInside)
            starStackView.addArrangedSubview(starButton)
        }
        
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            starStackView.topAnchor.constraint(equalTo: experienceLabel.bottomAnchor, constant: 10),
            starStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            starStackView.heightAnchor.constraint(equalToConstant: 80), // Adjust based on new button sizes
            starStackView.widthAnchor.constraint(equalToConstant: 200)
        ])
        
    }
    
    @objc private func handleStarTapped(_ sender: UIButton) {
        guard let index = starStackView.arrangedSubviews.firstIndex(of: sender) else { return }
        for (i, star) in starStackView.arrangedSubviews.enumerated() {
            (star as? UIButton)?.isSelected = i <= index
        }
    }
    
    private func setupCommentBox() {
        commentTextView.font = UIFont.systemFont(ofSize: 16)
        commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.cornerRadius = 5
        commentTextView.text = "Leave a comment (optional)"
        commentTextView.textColor = UIColor.lightGray
        commentTextView.delegate = self
        containerView.addSubview(commentTextView)
        
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentTextView.topAnchor.constraint(equalTo: starStackView.bottomAnchor, constant: 20),
            commentTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            commentTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            commentTextView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        let closeButton = UIButton()
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.gray, for: .normal)
        closeButton.layer.cornerRadius = 5
        closeButton.addTarget(self, action: #selector(handleCloseTapped), for: .touchUpInside)
        
        let submitButton = UIButton()
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = .darkGray
        submitButton.layer.cornerRadius = 5
        submitButton.addTarget(self, action: #selector(handleSubmitTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(closeButton)
        stackView.addArrangedSubview(submitButton)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func handleCloseTapped() {
        delegate?.didTapClose()
    }
    
    @objc private func handleSubmitTapped() {
        delegate?.didTapSubmit()
        updateRatingInRealtimeDatabase()
    }
    
    private func updateRatingInRealtimeDatabase() {
        let dbRef = Database.database().reference()  // Get a reference to the database
        let ratingPath = dbRef.child("Ratings").child("PGNEET").child("quiz").child(examId ?? "UnknownID")
        
        ratingPath.observeSingleEvent(of: .value, with: { snapshot in
            // Check if the node exists and if it has the initial setup for ratings
            if snapshot.exists() {
                // Node exists, now increment the rating count based on user's selection
                guard let selectedRating = self.starStackView.arrangedSubviews.enumerated().first(where: { ($1 as? UIButton)?.isSelected == true })?.offset else { return }
                let ratingKey = "\(selectedRating + 1)" // This adjusts for zero indexing of the array
                ratingPath.child(ratingKey).runTransactionBlock({ currentData in
                    var value = currentData.value as? Int ?? 0
                    value += 1
                    currentData.value = value
                    return TransactionResult.success(withValue: currentData)
                })
            } else {
                // Node does not exist, create it with initial values
                let initialData = [
                    "qid": self.examId ?? "Unknown ExamId",
                    "1": 0, "2": 0, "3": 0, "4": 0, "5": 0  // Set initial counts for each rating to zero
                ]
                ratingPath.setValue(initialData, withCompletionBlock: { error, _ in
                    if let error = error {
                        print("Error creating node: \(error.localizedDescription)")
                    } else {
                        print("Node successfully created")
                        // After creation, initiate the rating update again to ensure this user's rating is counted
                        self.updateRatingInRealtimeDatabase()
                    }
                })
            }
        })
    }

}
// UITextViewDelegate methods for handling placeholder text
extension RatingBottomSheetViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Leave a comment (optional)" {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Leave a comment (optional)"
            textView.textColor = .lightGray
        }
    }
}
