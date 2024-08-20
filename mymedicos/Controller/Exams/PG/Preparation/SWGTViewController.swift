import UIKit

class SWGTViewController: UIViewController {
    var specialtyTitle: String

    init(title: String) {
        self.specialtyTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        configureNavigationBar()
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white // Set the background color of the navigation bar
        navigationController?.navigationBar.backgroundColor = .white // Additional background color setting
        navigationController?.navigationBar.tintColor = .black // Set the color of navigation bar items

        // Set the navigation bar title attributes
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black, // Set the title text color to black
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold) // Customize the font
        ]

        navigationItem.title = specialtyTitle  // Set the specialty as the navigation title

        // Add custom back arrow button
        let backArrowImage = UIImage(systemName: "chevron.left")  // Using system image
        let backButton = UIBarButtonItem(image: backArrowImage, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }

    @objc func backButtonTapped() {
        // Determine the style of presentation and dismiss accordingly
        if let navController = navigationController {
            if navController.viewControllers.first == self {
                dismiss(animated: true) // dismiss if it's the root of the navigation controller
            } else {
                navController.popViewController(animated: true) // pop if it's pushed onto the navigation stack
            }
        } else {
            dismiss(animated: true) // dismiss if it's presented modally without a navigation controller
        }
    }
}
