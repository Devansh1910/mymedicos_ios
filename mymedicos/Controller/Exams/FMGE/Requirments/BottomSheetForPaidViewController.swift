import UIKit

protocol BottomSheetDelegate: AnyObject {
    func didChooseViewPlans()
}

class BottomSheetForPaidSheetViewController: UIViewController {
    weak var delegate: BottomSheetDelegate?
    var examID: String = ""

    let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0
        return blurEffectView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupViews()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let parentView = self.view.superview {
            self.view.frame = CGRect(
                x: 0,
                y: parentView.frame.height - 650,
                width: parentView.frame.width,
                height: 650
            )
        }
    }

    private func setupViews() {
        view.backgroundColor = UIColor.white.withAlphaComponent(1)
        view.layer.cornerRadius = 20

        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .black
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "Premium")
        imageView.backgroundColor = .lightGray

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = "This is a premium feature"
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Get ELITE Plan now for unstoppable learning! Upgrade your Medical PG prep with High-yield QBank & get:"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let featuresStack = UIStackView()
        featuresStack.translatesAutoresizingMaskIntoConstraints = false
        featuresStack.axis = .vertical
        featuresStack.spacing = 10

        let features = [
            ("Integration with video lectures to strengthen concepts.", "video"),
            ("Questions framed as per the latest exam patterns.", "text.badge.checkmark"),
            ("Integrated, Image-based, and PYQ-based segregation of questions.", "photo.on.rectangle"),
            ("Integration with relevant Treasures (summary notes).", "note.text.badge.plus"),
            ("Enhanced tagging for easy & hassle-free learning.", "tag.fill"),
            ("Leaderboard to get insights into in-depth performance analysis.", "chart.bar")
        ]

        for feature in features {
            let iconImageView = UIImageView(image: UIImage(systemName: feature.1))
            iconImageView.tintColor = .systemOrange
            let featureLabel = UILabel()
            featureLabel.text = feature.0
            featureLabel.numberOfLines = 0

            let featureStack = UIStackView(arrangedSubviews: [iconImageView, featureLabel])
            featureStack.axis = .horizontal
            featureStack.alignment = .center
            featureStack.spacing = 8

            featuresStack.addArrangedSubview(featureStack)
        }

        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .vertical
        buttonStack.spacing = 10

        let viewPlansButton = UIButton(type: .system)
        viewPlansButton.setTitle("View Plans", for: .normal)
        viewPlansButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        viewPlansButton.backgroundColor = .systemYellow
        viewPlansButton.tintColor = .white
        viewPlansButton.layer.cornerRadius = 10
        viewPlansButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        viewPlansButton.addTarget(self, action: #selector(viewPlansTapped), for: .touchUpInside)

        let maybeLaterButton = UIButton(type: .system)
        maybeLaterButton.setTitle("Maybe Later", for: .normal)
        maybeLaterButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        maybeLaterButton.tintColor = .black
        maybeLaterButton.layer.cornerRadius = 10
        maybeLaterButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        maybeLaterButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        buttonStack.addArrangedSubview(viewPlansButton)
        buttonStack.addArrangedSubview(maybeLaterButton)

        view.addSubview(blurEffectView)
        view.addSubview(closeButton)
        view.addSubview(imageView)
        view.addSubview(messageLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(featuresStack)
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),

            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            featuresStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            featuresStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            featuresStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            buttonStack.topAnchor.constraint(equalTo: featuresStack.bottomAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func viewPlansTapped() {
        dismiss(animated: true, completion: { [weak self] in
            self?.delegate?.didChooseViewPlans()
        })
    }

    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addBlurEffectToParent()
        fadeInBlurEffect()
        NotificationCenter.default.post(name: NSNotification.Name("hideTabBar"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        fadeOutBlurEffect {
            self.blurEffectView.removeFromSuperview()
        }
        NotificationCenter.default.post(name: NSNotification.Name("showTabBar"), object: nil)
    }

    private func addBlurEffectToParent() {
        if let parentView = self.view.superview {
            blurEffectView.frame = parentView.bounds
            parentView.addSubview(blurEffectView)
            parentView.bringSubviewToFront(self.view)
        }
    }

    private func fadeInBlurEffect() {
        UIView.animate(withDuration: 0.2) {
            self.blurEffectView.alpha = 1
        }
    }

    private func fadeOutBlurEffect(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurEffectView.alpha = 0
        }, completion: { _ in
            completion()
        })
    }
}
