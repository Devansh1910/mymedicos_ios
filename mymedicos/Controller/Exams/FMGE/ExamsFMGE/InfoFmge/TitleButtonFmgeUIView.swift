import UIKit
import FirebaseAuth
import FirebaseFirestore

class TitleButtonFmgeUIView: UIView {
    
    var bookmarkButton: UIButton!
    var titleLabel: UILabel!
    var idLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        // Check bookmark status whenever the view is added to a window
        if self.window != nil, Auth.auth().currentUser != nil {
            checkBookmarkStatus()
        }
    }
    
    
    private func setupUI() {
        // Create the title label
        titleLabel = UILabel()
        titleLabel.text = "Champions Exam NEET PG - 2"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the ID label
        idLabel = UILabel()
        idLabel.text = "#000000"  // Example ID, should be dynamically assigned
        idLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        idLabel.textAlignment = .center
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the share and free buttons
        let shareButton = createButton(title: "Share", imageName: "arrowshape.turn.up.right")
        let freeButton = createButton(title: "Free", imageName: "lock.open")
        
        // Create and configure the bookmark button
        bookmarkButton = createButton(title: "Bookmark", imageName: "bookmark", action: #selector(bookmarkQuiz))
        updateBookmarkButton(isBookmarked: false)  // Initial state as not bookmarked
        
        // Create the stack view for the share and free buttons
        let shareFreeStackView = UIStackView(arrangedSubviews: [shareButton, freeButton])
        shareFreeStackView.axis = .horizontal
        shareFreeStackView.spacing = 10
        shareFreeStackView.alignment = .center
        shareFreeStackView.distribution = .fillEqually
        shareFreeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a vertical stack view to organize title, id label, shareFreeStackView, and bookmark button
        let mainStackView = UIStackView(arrangedSubviews: [titleLabel, idLabel, shareFreeStackView, bookmarkButton])
        mainStackView.axis = .vertical
        mainStackView.spacing = 5  // Adjust spacing to suit your design
        mainStackView.alignment = .center
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the main stack view to the custom view
        addSubview(mainStackView)
        
        // Setup constraints for mainStackView
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            shareFreeStackView.heightAnchor.constraint(equalToConstant: 50),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createButton(title: String, imageName: String, action: Selector? = nil) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 20
        button.backgroundColor = UIColor(white: 0.95, alpha: 1)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        
        if let action = action {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        
        return button
    }
    
    private func updateBookmarkButton(isBookmarked: Bool) {
          DispatchQueue.main.async {
              let bookmarkImageName = isBookmarked ? "bookmark.fill" : "bookmark"
              self.bookmarkButton.setImage(UIImage(systemName: bookmarkImageName), for: .normal)
              self.bookmarkButton.setTitle(isBookmarked ? "Bookmarked" : "Bookmark", for: .normal)
          }
      }

    @objc func bookmarkQuiz() {
        guard let quizId = idLabel.text, let phoneNumber = Auth.auth().currentUser?.phoneNumber else {
            print("Required data not available")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").whereField("Phone Number", isEqualTo: phoneNumber).getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching user: \(error)")
                return
            }

            guard let self = self, let documents = snapshot?.documents, !documents.isEmpty else {
                print("No user found or error in documents")
                return
            }

            let userDocument = documents.first!
            let userId = userDocument.documentID
            let userRef = db.collection("users").document(userId)

            if let bookmarks = userDocument.data()["Bookmarked"] as? [String], bookmarks.contains(quizId) {
                print("Removing bookmark...")
                userRef.updateData([
                    "Bookmarked": FieldValue.arrayRemove([quizId])
                ]) { error in
                    if let error = error {
                        print("Error removing bookmark: \(error)")
                    } else {
                        print("Bookmark successfully removed")
                        self.updateBookmarkButton(isBookmarked: false)
                    }
                }
            } else {
                print("Adding bookmark...")
                userRef.updateData([
                    "Bookmarked": FieldValue.arrayUnion([quizId])
                ]) { error in
                    if let error = error {
                        print("Error adding bookmark: \(error)")
                    } else {
                        print("Bookmark successfully added")
                        self.updateBookmarkButton(isBookmarked: true)
                    }
                }
            }
        }
    }

    private func checkBookmarkStatus() {
        guard let quizId = idLabel.text, let phoneNumber = Auth.auth().currentUser?.phoneNumber else {
            print("Missing quiz ID or user phone number")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").whereField("Phone Number", isEqualTo: phoneNumber).getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching user: \(error)")
                return
            }

            if let documents = snapshot?.documents, !documents.isEmpty {
                let userDocument = documents.first!
                if let bookmarks = userDocument.data()["Bookmarked"] as? [String], bookmarks.contains(quizId) {
                    print("Quiz is bookmarked")
                    self.updateBookmarkButton(isBookmarked: true)
                } else {
                    print("Quiz is not bookmarked")
                    self.updateBookmarkButton(isBookmarked: false)
                }
            } else {
                print("No documents or user found")
                self.updateBookmarkButton(isBookmarked: false)
            }
        }
    }
}
