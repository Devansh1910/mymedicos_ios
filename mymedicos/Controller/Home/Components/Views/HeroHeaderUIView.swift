import UIKit

class HeroHeaderUIView: UIView {
    
    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "aboutuscover")
        return imageView
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Generate Presentation", for: .normal)
        let goldColor = UIColor(hexString: "#E1FAF2")
    
        button.layer.borderColor = goldColor.cgColor
        button.layer.borderWidth = 1
        button.backgroundColor = UIColor(hexString: "#2BD0BF")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor(hexString: "#F4F4F4").cgColor
        ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(heroImageView)
        addGradient()
        addSubview(actionButton)
        applyConstraints()
        addBorderSparkle()
        addShimmerEffect()
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            actionButton.widthAnchor.constraint(equalToConstant: 240),
            actionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func addBorderSparkle() {
        // Emitter layer setup (same as previous)
    }

    private func addShimmerEffect() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]  // Set the distribution of colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = CGRect(x: -actionButton.bounds.size.width, y: 0, width: actionButton.bounds.size.width * 3, height: actionButton.bounds.size.height)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5  // Control the speed of the shimmer effect
        animation.repeatCount = Float.infinity
        
        gradientLayer.add(animation, forKey: "shimmer")
        actionButton.layer.addSublayer(gradientLayer)
    }
    
    public func configure(with model: TitleViewModel) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterURL)") else {
            return
        }
        heroImageView.sd_setImage(with: url, completed: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heroImageView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
