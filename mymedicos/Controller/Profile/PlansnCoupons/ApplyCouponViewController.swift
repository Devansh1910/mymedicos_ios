import UIKit
import FirebaseFirestore

class ApplyCouponViewController: UIViewController, UITextFieldDelegate {
    
    let db = Firestore.firestore() // Firestore reference
    
    // Store a reference to the coupon text field
    var couponTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the background image
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Updating")
        backgroundImage.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        
        // Set up the main UI
        setupUI()
        customizeBackButton()

        
        view.backgroundColor = .white
        view.overrideUserInterfaceStyle = .light
    }
    
    func customizeBackButton() {
        // Set the back button to be just an arrow with black color
        let backButtonImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.backIndicatorImage = backButtonImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backButtonImage
        
        // This removes the text from the back button
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    func setupUI() {
        // Container view for the card
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 5)
        cardView.layer.shadowRadius = 10
        view.addSubview(cardView)
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 300),
            cardView.heightAnchor.constraint(equalToConstant: 340)
        ])
        
        // Emoji label
        let emojiLabel = UILabel()
        emojiLabel.text = "🔥"
        emojiLabel.font = UIFont.systemFont(ofSize: 50)
        cardView.addSubview(emojiLabel)
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            emojiLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        ])
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = "Having a Coupon Code ?"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .black
        cardView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
        
        // Subtitle label
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Step into the unknown! Apply now and embark on a journey filled with exciting surprises tailored just for you"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.textAlignment = .left
        subtitleLabel.numberOfLines = 0
        cardView.addSubview(subtitleLabel)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
        
        // Text field for coupon code
        couponTextField = UITextField()
        couponTextField.placeholder = "Enter coupon code here"
        couponTextField.borderStyle = .roundedRect
        couponTextField.delegate = self // Set the delegate to self
        cardView.addSubview(couponTextField)
        
        couponTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            couponTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            couponTextField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            couponTextField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            couponTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Button to apply coupon code
        let applyButton = UIButton(type: .system)
        applyButton.setTitle("Apply Coupon Code", for: .normal)
        applyButton.backgroundColor = .darkGray
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.cornerRadius = 10
        applyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cardView.addSubview(applyButton)
        
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            applyButton.topAnchor.constraint(equalTo: couponTextField.bottomAnchor, constant: 30),
            applyButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            applyButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            applyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        applyButton.addTarget(self, action: #selector(applyCouponTapped), for: .touchUpInside)
    }
    
    @objc func applyCouponTapped() {
        guard let couponCode = couponTextField.text?.uppercased(), !couponCode.isEmpty else {
            displayInvalidCouponMessage(for: couponTextField)
            return
        }
        
        checkCouponInFirestore(code: couponCode) { [weak self] isValid in
            if isValid {
                self?.displayCouponAppliedMessage()
            } else {
                self?.displayInvalidCouponMessage(for: self?.couponTextField)
            }
        }
    }
    
    func checkCouponInFirestore(code: String, completion: @escaping (Bool) -> Void) {
        let couponsCollection = db.collection("Coupons")
        
        couponsCollection.whereField("code", isEqualTo: code).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(false)
            } else {
                if let snapshot = querySnapshot, !snapshot.isEmpty {
                    // Coupon found
                    completion(true)
                } else {
                    // Coupon not found
                    completion(false)
                }
            }
        }
    }
    
    func displayCouponAppliedMessage() {
        let alert = UIAlertController(title: "Success", message: "Coupon Applied", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func displayInvalidCouponMessage(for textField: UITextField?) {
        guard let textField = textField else { return }
        textField.layer.borderColor = UIColor.red.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5.0
        
        let invalidLabel = UILabel()
        invalidLabel.text = "Invalid Coupon"
        invalidLabel.textColor = .red
        invalidLabel.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(invalidLabel)
        
        invalidLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            invalidLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 5),
            invalidLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor)
        ])
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text as NSString? else { return true }
        let newText = currentText.replacingCharacters(in: range, with: string).uppercased()
        return newText.count <= 10
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.text = textField.text?.uppercased()
    }
}
