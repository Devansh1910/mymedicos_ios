import UIKit

class CustomPresentationController2: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        let containerBounds = containerView!.bounds
        let width: CGFloat = containerBounds.width
        let height: CGFloat = 400 // Adjust height as needed
        let x: CGFloat = (containerBounds.width - width) / 2
        let y: CGFloat = containerBounds.height - height // Adjust for bottom spacing
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    override func dismissalTransitionWillBegin() {
        containerView?.backgroundColor = UIColor.clear
    }
}
