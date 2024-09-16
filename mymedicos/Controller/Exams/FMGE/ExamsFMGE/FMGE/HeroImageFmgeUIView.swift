import UIKit

class HeroImageFmgeUIView: UIView {
    
    private var imageUrls: [String] = []
    private var currentImageIndex = 0
    private var timer: Timer?
    
    private let heroImageFmgeView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var titleExaminationCategory: String
    
    // Initialize with a frame and a title
    init(frame: CGRect, title: String) {
        self.titleExaminationCategory = title
        super.init(frame: frame)
        addSubview(heroImageFmgeView)
        fetchImageUrls()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heroImageFmgeView.frame = bounds
    }
    
    func updateTitle(_ title: String) {
        if titleExaminationCategory != title {
            titleExaminationCategory = title
            fetchImageUrls()
        }
    }
    
    private func fetchImageUrls() {
        let urlString: String
        switch titleExaminationCategory {
        case "FMGE":
            urlString = ConstantsDashboard.GET_HOME_IOS_SLIDER_URL
        default:
            urlString = ConstantsDashboard.GET_HOME_IOS_SLIDER_URL
        }

        guard let url = URL(string: urlString) else { return }
        
        timer?.invalidate()
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    self.imageUrls.removeAll()
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
        heroImageFmgeView.loadImage(from: imageUrls[currentImageIndex])
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(changeImage), userInfo: nil, repeats: true)
    }
    
    @objc private func changeImage() {
        currentImageIndex = (currentImageIndex + 1) % imageUrls.count
        let nextImageUrl = imageUrls[currentImageIndex]
        
        UIView.transition(with: heroImageFmgeView, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.heroImageFmgeView.loadImage(from: nextImageUrl)
        }, completion: nil)
    }
}
