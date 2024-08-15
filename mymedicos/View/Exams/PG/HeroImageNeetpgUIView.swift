import UIKit

class HeroImageNeetpgUIView: UIView {
    
    private var imageUrls: [String] = []
    private var currentImageIndex = 0
    private var timer: Timer?
    
    private let heroImageNeetpgView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(heroImageNeetpgView)
        fetchImageUrls()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heroImageNeetpgView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        heroImageNeetpgView.loadImage(from: imageUrls[currentImageIndex])
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(changeImage), userInfo: nil, repeats: true)
    }
    
    @objc private func changeImage() {
        currentImageIndex = (currentImageIndex + 1) % imageUrls.count
        let nextImageUrl = imageUrls[currentImageIndex]
        
        UIView.transition(with: heroImageNeetpgView, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.heroImageNeetpgView.loadImage(from: nextImageUrl)
        }, completion: nil)
    }
}
