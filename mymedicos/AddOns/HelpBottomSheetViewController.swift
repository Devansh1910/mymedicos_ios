import UIKit

class HelpBottomSheetViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        // Determine content size dynamically, e.g., based on subviews
        let contentHeight = calculateContentHeight()
        preferredContentSize = CGSize(width: view.bounds.width, height: contentHeight)
        
        setupSubviews()
    }
    
    private func calculateContentHeight() -> CGFloat {
        // Calculate the total height of the content that needs to be displayed
        return 300 // Example static height
    }

    private func setupSubviews() {
        // Add your subviews and their constraints here
    }
}
