import UIKit
import FirebaseFirestore

protocol QuestionBankNeetssUIViewDelegate: AnyObject {
    func navigateToDownloadQuestionBankPortal(withTitle title: String, examID: String)
}

class QuestionBankNeetssUIView: UIView {
    // MARK: - Properties
    weak var delegate: QuestionBankNeetssUIViewDelegate?
    private var examID: String?
    private var fileURL: String?

    // MARK: - UI Components
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray
        label.numberOfLines = 3  // Allowing more lines for detailed descriptions
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Download now", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.darkGray
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAttempt), for: .touchUpInside)
        return button
    }()

    // MARK: - Initializers
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

    // MARK: - Setup Methods
    private func setupLayout() {
        addSubview(questionLabel)
        addSubview(descriptionLabel)
        addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            questionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            questionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),

            actionButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            actionButton.heightAnchor.constraint(equalToConstant: 35),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
    }

    private func fetchData() {
        let db = Firestore.firestore()
        db.collection("Fmge")
          .document("Notes")
          .collection("Note")
          .whereField("speciality", isEqualTo: "home")
          .getDocuments { [weak self] (querySnapshot, error) in
              if let error = error {
                  print("Error fetching documents: \(error)")
                  return
              }

              guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                  print("No documents found")
                  return
              }

              if let document = documents.first {
                  let data = document.data()
                  if let title = data["Title"] as? String,
                     let description = data["Description"] as? String,
                     let file = data["file"] as? String {
                      DispatchQueue.main.async {
                          self?.questionLabel.text = title
                          self?.descriptionLabel.text = description
                          self?.fileURL = file
                          self?.examID = document.documentID
                      }
                  } else {
                      print("Document does not contain valid 'Title', 'Description', or 'file'")
                  }
              }
          }
    }

    // MARK: - Actions
    @objc private func handleAttempt() {
        guard let urlString = fileURL, let url = URL(string: urlString) else {
            print("Invalid file URL")
            return
        }
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location = location, error == nil else {
                print("Error downloading file: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            let fileManager = FileManager.default
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
            try? fileManager.removeItem(at: destinationURL) // Remove existing file if necessary
            do {
                try fileManager.moveItem(at: location, to: destinationURL)
                print("File downloaded to: \(destinationURL)")
                DispatchQueue.main.async {
                    // Optionally, update the UI or open the file
                }
            } catch let error {
                print("Could not move downloaded file to destination: \(error)")
            }
        }
        task.resume()
    }
}
