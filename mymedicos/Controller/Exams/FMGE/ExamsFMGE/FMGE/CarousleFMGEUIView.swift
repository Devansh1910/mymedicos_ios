import UIKit

class CarousleFMGEUIView: UIView {
    
    private var imageUrls: [String] = []
    private var currentImageIndex = 0
    private var timer: Timer?
    
    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(heroImageView)
        fetchImageUrls()
        setupAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heroImageView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAppearance() {
        self.layer.cornerRadius = 10  // Sets the corner radius
        self.layer.borderWidth = 1.0  // Sets the border width
        self.layer.borderColor = UIColor.gray.cgColor  // Sets the border color to grey
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 100)  // Sets the height to 40 points
        ])
    }
    
    private func fetchImageUrls() {
        guard let url = URL(string: ConstantsDashboard.GET_HOME_SLIDER_URL) else { return }
        
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
