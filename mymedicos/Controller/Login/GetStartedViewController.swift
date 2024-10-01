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
            DispatchQueue.main.async {
                let homeVC = HomeViewController()  // Adjust according to your actual home view controller
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
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
        setupLottieAnimation()
        setupPartToShow()
        
        // Make sure user interactions are enabled
        view.isUserInteractionEnabled = true
        partToShow.isUserInteractionEnabled = true
        startButton.isUserInteractionEnabled = true
    }

    func setupLottieAnimation() {
        let lottieAnimationView = LottieAnimationView(name: "new_dc")
        lottieAnimationView.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: view.frame.height / 2)
        lottieAnimationView.contentMode = .scaleAspectFill
        lottieAnimationView.loopMode = .loop
        lottieAnimationView.animationSpeed = 1
        lottieAnimationView.play()
        view.addSubview(lottieAnimationView)
    }

    func setupPartToShow() {
        partToShow.frame = CGRect(x: 0, y: view.frame.height / 2 + 120, width: view.frame.width, height: view.frame.height * 0.4)
        view.addSubview(partToShow)
        
        configureTextAndButtons()
    }

    func configureTextAndButtons() {
        configureHeading()
        configureCoats()
        configureButtons()
    }

    func configureHeading() {
        textForHeading.text = "mymedicos"
        textForHeading.font = UIFont.boldSystemFont(ofSize: 20)
        textForHeading.textAlignment = .center
        textForHeading.textColor = UIColor.black
        partToShow.addSubview(textForHeading)
        
        textForHeading.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textForHeading.centerXAnchor.constraint(equalTo: partToShow.centerXAnchor),
            textForHeading.topAnchor.constraint(equalTo: partToShow.topAnchor, constant: 20)
        ])
    }

    func configureCoats() {
        textForCoats.text = "Bharat’s first premier medical community app, connecting healthcare experts seamlessly"
        textForCoats.font = UIFont.systemFont(ofSize: 14)
        textForCoats.textAlignment = .center
        textForCoats.numberOfLines = 0
        textForCoats.textColor = UIColor.black
        partToShow.addSubview(textForCoats)
        
        textForCoats.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textForCoats.leadingAnchor.constraint(equalTo: partToShow.leadingAnchor, constant: 20),
            textForCoats.trailingAnchor.constraint(equalTo: partToShow.trailingAnchor, constant: -20),
            textForCoats.topAnchor.constraint(equalTo: textForHeading.bottomAnchor, constant: 10)
        ])
    }

    func configureButtons() {
        startButton.setTitle("Let's Start", for: .normal)
        startButton.backgroundColor = UIColor.darkGray
        startButton.layer.cornerRadius = 20
        startButton.setTitleColor(UIColor.white, for: .normal)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        partToShow.addSubview(startButton)
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.leadingAnchor.constraint(equalTo: partToShow.leadingAnchor, constant: 30),
            startButton.trailingAnchor.constraint(equalTo: partToShow.trailingAnchor, constant: -30),
            startButton.topAnchor.constraint(equalTo: textForCoats.bottomAnchor, constant: 20),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        helpSupportButton.setTitle("Having trouble? Click here", for: .normal)
        helpSupportButton.setTitleColor(UIColor.darkGray, for: .normal)
        helpSupportButton.addTarget(self, action: #selector(helpSupportTapped), for: .touchUpInside)
        partToShow.addSubview(helpSupportButton)

        helpSupportButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            helpSupportButton.centerXAnchor.constraint(equalTo: partToShow.centerXAnchor),
            helpSupportButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 10)
        ])
    }

    @objc func startButtonTapped() {
        print("Start button tapped")
        let loginViewController = LoginViewController()
        navigationController?.pushViewController(loginViewController, animated: true)
    }

    @objc func helpSupportTapped() {
        let bottomSheetVC = BottomSheetViewController()  // Ensure this is the correct view controller for your needs
        bottomSheetVC.modalPresentationStyle = .custom
        bottomSheetVC.transitioningDelegate = self
        present(bottomSheetVC, animated: true)
    }

    func fadeInAnimation(view: UIView) {
        UIView.animate(withDuration: 1.0, animations: {
            view.alpha = 1.0
        })
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
