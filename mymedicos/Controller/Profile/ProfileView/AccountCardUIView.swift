import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class AccountCardUIView: UIView {
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let subscriptionLabel = UILabel()
    private let userIDLabel = UILabel()
    
    // Properties to store user data fetched from Firestore
    private var name: String?
    private var email: String?
    private var phoneNumber: String?
    private var whatsappNumber: String?
    private var dob: Date?
    private var gender: String?
    private var prefix: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        fetchData()
        fetchProfileImage()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        fetchData()
        fetchProfileImage()
    }
    
    private func setupViews() {
        backgroundColor = UIColor(hexString: "#EAEAEA")
        layer.cornerRadius = 10
        clipsToBounds = true
        
        profileImageView.image = UIImage(named: "placeholder_image") // Default placeholder image
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 10
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.text = "Loading..."
        nameLabel.textColor = .black
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subscriptionLabel.text = "Loading..."
        subscriptionLabel.textColor = UIColor(hexString: "#797979")
        subscriptionLabel.font = UIFont.systemFont(ofSize: 14)
        subscriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        userIDLabel.text = "Loading..."
        userIDLabel.textColor = .darkGray
        userIDLabel.font = UIFont.systemFont(ofSize: 12)
        userIDLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(subscriptionLabel)
        addSubview(userIDLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            subscriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            subscriptionLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            subscriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            userIDLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            userIDLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            userIDLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
    private func fetchData() {
        guard let user = Auth.auth().currentUser, let currentPhoneNumber = user.phoneNumber else {
            print("User not authenticated or phone number not available")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").whereField("Phone Number", isEqualTo: currentPhoneNumber).getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error)")
                return
            }
            
            guard let document = snapshot?.documents.first else {
                print("No matching user found")
                return
            }
            
            let data = document.data()
            self?.updateUIWithData(data)
        }
    }
    
    private func updateUIWithData(_ data: [String: Any]) {
        DispatchQueue.main.async {
            let prefix = data["Prefix"] as? String ?? ""
            let name = data["Name"] as? String ?? "Unknown"
            self.nameLabel.text = "\(prefix.isEmpty ? "" : "\(prefix). ")\(name)"
            self.subscriptionLabel.text = data["Interest"] as? String ?? "None"
            
            if let docID = data["DocID"] as? String, docID.count >= 4 {
                let index = docID.index(docID.endIndex, offsetBy: -4)
                let lastFourDigits = docID[index...]
                self.userIDLabel.text = "#user_\(lastFourDigits)"
            } else {
                self.userIDLabel.text = "#user_N/A"
            }
        }
    }
    
    func fetchProfileImage() {
        guard let user = Auth.auth().currentUser, let phoneNumber = user.phoneNumber else {
            return
        }

        let storageRef = Storage.storage().reference(withPath: "users/\(phoneNumber)/profile_image.jpg")
        let localURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("profile_image.jpg")

        storageRef.write(toFile: localURL) { url, error in
            if let error = error {
                print("Error downloading image: \(error)")
            } else if let url = url, let image = UIImage(contentsOfFile: url.path) {
                DispatchQueue.main.async {
                    self.profileImageView.image = image
                }
            }
        }
    }

    func saveProfileImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.75),
              let user = Auth.auth().currentUser,
              let phoneNumber = user.phoneNumber else {
            return
        }

        let storageRef = Storage.storage().reference(withPath: "users/\(phoneNumber)/profile_image.jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error)")
            } else {
                print("Profile image successfully uploaded with MIME type: \(metadata?.contentType ?? "unknown")")
            }
        }
    }
}
