import UIKit

class GrandTestInfoViewController: UIViewController {
    
    private var isBookmarked = false
    private var isCheckboxChecked = false
    private var heroView: TitleButtonsUIView!
    private var startButton: UIButton!
    private var checkbox: UIButton!
    private var blurEffectView: UIVisualEffectView?
    
    var examTitle: String? // Property to hold the passed title
    var examID: String? // Property to hold the exam ID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showAlert() // Show the alert when the view loads
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor) // Allow scrollView to fill the bottom
        ])
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        heroView = TitleButtonsUIView()
        heroView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(heroView)
        
        heroView.titleLabel.text = examTitle
        heroView.idLabel.text = examID
        
        NSLayoutConstraint.activate([
            heroView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            heroView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16)
        ])
        
        let examDetailsView = GrandTestInfoUIView()
        examDetailsView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(examDetailsView)
        
        // Constraints for ExamDetailsUIView
        NSLayoutConstraint.activate([
            examDetailsView.topAnchor.constraint(equalTo: heroView.bottomAnchor, constant: 0),
            examDetailsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            examDetailsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
        ])
        
        // Add InstructionsUIView below the ExamDetailsUIView
        let instructionView = InstructionsUIView()
        instructionView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(instructionView)
        
        // Updated constraints for InstructionsUIView to be below ExamDetailsUIView
        NSLayoutConstraint.activate([
            instructionView.topAnchor.constraint(equalTo: examDetailsView.bottomAnchor, constant: 10),
            instructionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            instructionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
        ])
        
        // Diagnostic view with large height
        let diagnosticView = UIView()
        diagnosticView.backgroundColor = .clear // Change color to visualize
        diagnosticView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(diagnosticView)
        
        NSLayoutConstraint.activate([
            diagnosticView.topAnchor.constraint(equalTo: instructionView.bottomAnchor, constant: 10),
            diagnosticView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            diagnosticView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            diagnosticView.heightAnchor.constraint(equalToConstant: 400), // Large height to force scroll
            diagnosticView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
        // Add the fixed bottom view with a white background
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 110) // Adjust height as needed
        ])
        
        // Create a vertical stack view to hold checkbox and button
        let bottomStackView = UIStackView()
        bottomStackView.axis = .vertical
        bottomStackView.spacing = 10
        bottomStackView.alignment = .leading // Align content to the left
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(bottomStackView)
        
        NSLayoutConstraint.activate([
            bottomStackView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            bottomStackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16),
            bottomStackView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 10), // Top padding
            bottomStackView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -20) // Bottom padding
        ])
        
        // Checkbox
        checkbox = UIButton(type: .custom)
        checkbox.setImage(UIImage(systemName: "square"), for: .normal)
        checkbox.setTitle(" I have read all the instructions", for: .normal)
        checkbox.setTitleColor(.black, for: .normal)
        checkbox.contentHorizontalAlignment = .left // Align checkbox content to the left
        checkbox.tintColor = .gray // Set the checkbox color to grey
        checkbox.addTarget(self, action: #selector(toggleCheckbox), for: .touchUpInside)
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.addArrangedSubview(checkbox)
        
        // Start Button
        startButton = UIButton(type: .system)
        startButton.setTitle("Start test", for: .normal)
        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        startButton.backgroundColor = .darkGray
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 8
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.isEnabled = false
        startButton.alpha = 0.5 // Make the button appear disabled
        startButton.addTarget(self, action: #selector(startTest), for: .touchUpInside) // Add target action for startButton
        bottomStackView.addArrangedSubview(startButton)
        
        NSLayoutConstraint.activate([
            startButton.widthAnchor.constraint(equalTo: bottomStackView.widthAnchor),
            startButton.heightAnchor.constraint(equalToConstant: 44)  // Adjust button height as needed
        ])
        
        heroView.bookmarkButton.addTarget(self, action: #selector(toggleBookmark), for: .touchUpInside)
    }
    
    @objc private func toggleBookmark() {
        isBookmarked.toggle()
        
        let newTitle = isBookmarked ? "Bookmarked" : "Bookmark"
        let newImageName = isBookmarked ? "bookmark.fill" : "bookmark"
        
        heroView.bookmarkButton.setTitle(newTitle, for: .normal)
        heroView.bookmarkButton.setImage(UIImage(systemName: newImageName), for: .normal)
    }
    
    @objc private func toggleCheckbox() {
        isCheckboxChecked.toggle()
        let newImageName = isCheckboxChecked ? "checkmark.square.fill" : "square"
        checkbox.setImage(UIImage(systemName: newImageName), for: .normal)
        
        startButton.isEnabled = isCheckboxChecked
        startButton.alpha = isCheckboxChecked ? 1.0 : 0.5
    }

    
    @objc private func startTest() {
        print("Starting test...")
        let examPortalVC = GrandTestExamPortalViewController()
        examPortalVC.examTitle = examTitle
        examPortalVC.examID = examID
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(examPortalVC, animated: true)
            print("Pushing ExamPortalViewController")
        } else {
            let navController = UINavigationController(rootViewController: examPortalVC)
            navController.modalPresentationStyle = .fullScreen
            print("No navigation controller available. Attempting full-screen modal presentation.")
            self.present(navController, animated: true, completion: nil)
        }
    }


    private func showAlert() {
        let alert = UIAlertController(title: nil, message: "Take the test on Laptop/Desktop for better examination experience", preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .light
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 120))
        backgroundView.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)
        backgroundView.layer.cornerRadius = 13
        backgroundView.layer.masksToBounds = true
        alert.view.insertSubview(backgroundView, at: 0)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: alert.view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor)
        ])
        
        let gotItAction = UIAlertAction(title: "Got it", style: .default, handler: nil)
        alert.addAction(gotItAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView!)
    }
    
    @objc func backButtonTapped() {
        if let navController = navigationController {
            if navController.viewControllers.first == self {
                dismiss(animated: true)
            } else {
                navController.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
    
    private func removeBlurEffect() {
        blurEffectView?.removeFromSuperview()
    }
}
