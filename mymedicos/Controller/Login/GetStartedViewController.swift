import UIKit
import FirebaseAuth
import Lottie

class GetStartedViewController: UIViewController {
    let partToShow = UIView()
    let startButton = UIButton()
    let helpSupportButton = UIButton()
    let textForHeading = UILabel()
    let textForCoats = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if isLoggedIn() {
            let homeVC = LoginViewController()
            navigationController?.pushViewController(homeVC, animated: true)
        } else {
            partToShow.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.fadeInAnimation(view: self.partToShow)
                self.partToShow.isHidden = false
            }
        }
    }

    func setupUI() {
        view.backgroundColor = UIColor.white
        let lottieAnimationView = AnimationView(name: "new_dc")
        let animationWidth = view.frame.width
        let animationHeight = view.frame.height / 2
        lottieAnimationView.frame = CGRect(x: (view.frame.width - animationWidth) / 2, y: 100, width: animationWidth, height: animationHeight)
        lottieAnimationView.contentMode = .scaleAspectFill
        lottieAnimationView.layer.cornerRadius = animationWidth / 2
        lottieAnimationView.clipsToBounds = true
        lottieAnimationView.loopMode = .loop
        lottieAnimationView.animationSpeed = 1
        lottieAnimationView.play()
        view.addSubview(lottieAnimationView)

        partToShow.frame = CGRect(x: 0, y: lottieAnimationView.frame.maxY + 20, width: view.frame.width, height: view.frame.height * 0.4)
        view.addSubview(partToShow)
        
        textForHeading.text = "mymedicos"
        textForHeading.font = UIFont.boldSystemFont(ofSize: 20)
        textForHeading.textAlignment = .center
        textForHeading.textColor = UIColor.black
        partToShow.addSubview(textForHeading)
        
        textForCoats.text = "Bharat’s first premier medical community app, connecting healthcare experts seamlessly"
        textForCoats.font = UIFont.systemFont(ofSize: 14)
        textForCoats.textAlignment = .center
        textForCoats.numberOfLines = 0
        textForCoats.textColor = UIColor.black
        partToShow.addSubview(textForCoats)
        
        startButton.setTitle("Let's Start", for: .normal)
        startButton.backgroundColor = UIColor.darkGray
        startButton.layer.cornerRadius = 20
        startButton.setTitleColor(UIColor.white, for: .normal)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        partToShow.addSubview(startButton)
        
        helpSupportButton.setTitle("Having trouble? Click here", for: .normal)
        helpSupportButton.setTitleColor(UIColor.darkGray, for: .normal)
        helpSupportButton.addTarget(self, action: #selector(helpSupportTapped), for: .touchUpInside)
        partToShow.addSubview(helpSupportButton)

        layoutSubviews()
    }

    func layoutSubviews() {
        textForHeading.translatesAutoresizingMaskIntoConstraints = false
        textForHeading.centerXAnchor.constraint(equalTo: partToShow.centerXAnchor).isActive = true
        textForHeading.topAnchor.constraint(equalTo: partToShow.topAnchor, constant: 20).isActive = true

        textForCoats.translatesAutoresizingMaskIntoConstraints = false
        textForCoats.leadingAnchor.constraint(equalTo: partToShow.leadingAnchor, constant: 20).isActive = true
        textForCoats.trailingAnchor.constraint(equalTo: partToShow.trailingAnchor, constant: -20).isActive = true
        textForCoats.topAnchor.constraint(equalTo: textForHeading.bottomAnchor, constant: 10).isActive = true

        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.leadingAnchor.constraint(equalTo: partToShow.leadingAnchor, constant: 30).isActive = true
        startButton.trailingAnchor.constraint(equalTo: partToShow.trailingAnchor, constant: -30).isActive = true
        startButton.topAnchor.constraint(equalTo: textForCoats.bottomAnchor, constant: 20).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        helpSupportButton.translatesAutoresizingMaskIntoConstraints = false
        helpSupportButton.centerXAnchor.constraint(equalTo: partToShow.centerXAnchor).isActive = true
        helpSupportButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 10).isActive = true
    }

    @objc func startButtonTapped() {
        let loginViewController = LoginViewController()
        navigationController?.pushViewController(loginViewController, animated: true)
    }

    @objc func helpSupportTapped() {
        let bottomSheetVC = BottomSheetViewController()
        bottomSheetVC.modalPresentationStyle = .custom
        bottomSheetVC.transitioningDelegate = self
        present(bottomSheetVC, animated: true)
    }

    func fadeInAnimation(view: UIView) {
        UIView.animate(withDuration: 1.0) {
            view.alpha = 1.0
        }
    }

    func isLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}

extension GetStartedViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
