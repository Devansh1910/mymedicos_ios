import UIKit
import Lottie

class UpdatingModuleViewController: UIViewController {
    
    let backgroundImageView = UIImageView()
    let animationView = LottieAnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundImage()
        setupLottieAnimation()
    }
    
    func setupBackgroundImage() {
        backgroundImageView.image = UIImage(named: "Updating")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.frame = view.bounds
        view.addSubview(backgroundImageView)
    }
    
    func setupLottieAnimation() {
        let animation = LottieAnimation.named("newupdatedanimation")
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        // Center the animationView in the view and increase its size
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 300),  // Increased size
            animationView.heightAnchor.constraint(equalToConstant: 300)  // Increased size
        ])
    }
    
    
}
