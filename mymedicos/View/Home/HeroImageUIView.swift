import UIKit

class HeroImageUIView: UIView {
    
    private var imageUrls: [String] = []
    private var currentImageIndex = 0
    private var timer: Timer?
    private var shimmerLayer: CAGradientLayer?
    
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        heroImageView.frame = bounds
        shimmerLayer?.frame = heroImageView.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }

    private func fetchImageUrls() {
        guard let url = URL(string: ConstantsDashboard.GET_HOME_SLIDER_URL) else { return }
        
        addShimmerEffect() // Start the shimmer effect when loading begins

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.removeShimmerEffect()
                }
                return
            }
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    self.imageUrls = jsonArray.compactMap { $0["url"] as? String }
                    DispatchQueue.main.async {
                        self.removeShimmerEffect()
                        self.startImageRotation()
                    }
                }
            } catch {
                print("Failed to parse JSON: \(error)")
                DispatchQueue.main.async {
                    self.removeShimmerEffect()
                }
            }
        }
        task.resume()
    }


    private func addShimmerEffect() {
        shimmerLayer?.removeFromSuperlayer() // Remove previous shimmer if exists
        shimmerLayer = CAGradientLayer()
        
        let lightColor = UIColor.white.withAlphaComponent(0.1).cgColor
        let darkColor = UIColor.black.withAlphaComponent(0.08).cgColor

        shimmerLayer?.colors = [darkColor, lightColor, darkColor]
        shimmerLayer?.frame = heroImageView.bounds
        shimmerLayer?.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        shimmerLayer?.locations = [0, 0.5, 1]
        heroImageView.layer.addSublayer(shimmerLayer!)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        
        shimmerLayer?.add(animation, forKey: "shimmer")
    }

    private func removeShimmerEffect() {
        shimmerLayer?.removeFromSuperlayer()
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
    func getCacheDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths.first
    }

    func localFilePath(for url: String) -> URL? {
        guard let cacheDirectory = getCacheDirectory() else { return nil }
        let fileName = url.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: ":", with: "_")
        return cacheDirectory.appendingPathComponent(fileName)
    }

    func loadImage(from url: String) {
        if let filePath = localFilePath(for: url), let savedImage = UIImage(contentsOfFile: filePath.path) {
            self.image = savedImage
            return
        }

        // Load image from network
        guard let imageURL = URL(string: url) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if let filePath = self.localFilePath(for: url) {
                        try? data.write(to: filePath)
                    }
                    self.image = image
                }
            }
        }
    }
}
