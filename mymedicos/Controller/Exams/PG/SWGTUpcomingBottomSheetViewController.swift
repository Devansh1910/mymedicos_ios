import UIKit
import Lottie

protocol SWGTUpcomingBottomSheetDelegate: AnyObject {
    func didSetReminder(forExamID examID: String)
}

class SWGTUpcomingBottomSheetViewController: UIViewController {
    var examID: String?
    weak var delegate: SWGTUpcomingBottomSheetDelegate?
    let containerView = UIView()
    
    let animationView = LottieAnimationView()
    let descriptionLabel = UILabel()
    let setReminderButton = UIButton(type: .system)
    let closeButton = UIButton(type: .system)  // Declare the close button

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareForFadeIn()
    }

    private func prepareForFadeIn() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        containerView.transform = CGAffineTransform(translationX: 0, y: 300)
        UIView.animate(withDuration: 0.5, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.containerView.transform = .identity
        })
    }

    private func setupViews() {
        setupContainerView()
        setupAnimationView()
        setupDescriptionLabel()
        setupSetReminderButton()
        setupCloseButton()  // Call the setup for the close button
    }

    private func setupContainerView() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }

    private func setupAnimationView() {
        let animation = LottieAnimation.named("calendaranimation")
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        containerView.addSubview(animationView)
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.heightAnchor.constraint(equalToConstant: 100),
            animationView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setupDescriptionLabel() {
        descriptionLabel.text = "You can set a reminder to be notified when this Quiz Set goes live."
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        containerView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
    }

    private func setupSetReminderButton() {
        setReminderButton.setTitle("Set Reminder", for: .normal)
        setReminderButton.backgroundColor = .darkGray
        setReminderButton.setTitleColor(.white, for: .normal)
        setReminderButton.layer.cornerRadius = 5
        setReminderButton.addTarget(self, action: #selector(handleSetReminder), for: .touchUpInside)
        containerView.addSubview(setReminderButton)
        setReminderButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            setReminderButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            setReminderButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            setReminderButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            setReminderButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupCloseButton() {
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.gray, for: .normal)
        closeButton.layer.borderColor = UIColor.gray.cgColor
        closeButton.layer.borderWidth = 1
        closeButton.layer.cornerRadius = 5
        closeButton.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        containerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: setReminderButton.bottomAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc func handleSetReminder() {
        guard let examID = examID else { return }
        delegate?.didSetReminder(forExamID: examID)
        dismissWithFadeOut()
    }

    @objc func handleClose() {
        dismissWithFadeOut()
    }

    private func dismissWithFadeOut() {
        UIView.animate(withDuration: 0.5, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.containerView.transform = CGAffineTransform(translationX: 0, y: 300)
        }) { _ in
            self.dismiss(animated: false)
        }
    }
}
