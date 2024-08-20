import UIKit
import FirebaseFirestore

protocol NotesNeetPgUIViewDelegate: AnyObject {
    func navigateToDownloadQuestionBankPortal(withTitle title: String, examID: String)
}

class NotesNeetPgUIView: UIView {
    // MARK: - Properties
    weak var delegate: NotesNeetPgUIViewDelegate?
    private var examID: String?
    private var fileURL: String?
    var specialty: String? // The specialty to fetch data for

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
        label.numberOfLines = 0
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAttempt), for: .touchUpInside)
        return button
    }()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
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

    func fetchData() {
        guard let specialty = specialty else {
            print("Specialty is not set")
            return
        }

        let db = Firestore.firestore()
        db.collection("PGupload")
          .document("Notes")
          .collection("Note")
          .whereField("speciality", isEqualTo: specialty)
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
                     let descriptionHTML = data["Description"] as? String,
                     let file = data["file"] as? String,
                     let pdf = data["pdf"] as? String,
                     let type = data["type"] as? String,
                     let time = data["Time"] as? String {

                      let description = self?.convertHTMLToAttributedString(html: descriptionHTML)

                      DispatchQueue.main.async {
                          self?.questionLabel.text = title
                          self?.descriptionLabel.attributedText = description
                          self?.fileURL = type == "Premium" ? pdf : file
                          self?.examID = document.documentID
                      }
                  } else {
                      print("Document does not contain valid 'Title', 'Description', 'file', 'pdf', 'type', or 'Time'")
                  }
              }
          }
    }

    private func convertHTMLToAttributedString(html: String) -> NSAttributedString? {
        let modifiedFont = """
        <style>
            body { font-family: '-apple-system', 'HelveticaNeue'; font-size: 16px; color: #242424; }
        </style>
        <div>\(html)</div>
        """
        
        guard let data = modifiedFont.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil)
        } catch {
            print("Error converting HTML to NSAttributedString: \(error)")
            return nil
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
