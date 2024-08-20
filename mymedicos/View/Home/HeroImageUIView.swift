import UIKit

class HeroImageUIView: UIView {
    
    private var imageUrls: [String] = []
    private var currentImageIndex = 0
    private var timer: Timer?
    
    private let exploreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "globe"), for: .normal)
        button.layer.borderColor = UIColor.white.cgColor // Initial border color setup
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(heroImageView)
        addSubview(exploreButton)
        applyConstraint()
        fetchImageUrls()
        configureButtonColors()
    }
    
    private func applyConstraint() {
        let exploreButtonConstraints = [
            exploreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            exploreButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            exploreButton.widthAnchor.constraint(equalToConstant: 40),
            exploreButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(exploreButtonConstraints)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heroImageView.frame = bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureButtonColors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButtonColors() {
        exploreButton.tintColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        exploreButton.layer.borderColor = (traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black).cgColor
    }
    
    private func fetchImageUrls() {
        guard let url = URL(string: ConstantsDashboard.GET_HOME_IOS_SLIDER_URL) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    for item in jsonArray {
                        if let imageUrl = item["url"] as? String {
                            self.imageUrls.append(imageUrl)
                        }
                    }
                    DispatchQueue.main.async {
                        self.startImageRotation()
                    }
                }
            } catch {
                print("Failed to parse JSON: \(error)")
            }
        }
        task.resume()
    }
    
    private func startImageRotation() {
        guard !imageUrls.isEmpty else { return }
        heroImageView.loadImage(from: imageUrls[currentImageIndex])
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(changeImage), userInfo: nil, repeats: true)
    }
    
    @objc private func changeImage() {
        currentImageIndex = (currentImageIndex + 1) % imageUrls.count
        let nextImageUrl = imageUrls[currentImageIndex]
        
        UIView.transition(with: heroImageView, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.heroImageView.loadImage(from: nextImageUrl)
        }, completion: nil)
    }
}

extension UIImageView {
    func loadImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: imageURL) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
