import UIKit

class CustomPresentationController: UIPresentationController {
    private var blurEffectView: UIVisualEffectView?
    private var tapGestureRecognizer: UITapGestureRecognizer?

    override var shouldRemovePresentersView: Bool {
        return false
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        setupBlurEffect()
        attachDismissGestureRecognizer()
    }

    private func setupBlurEffect() {
        guard let containerView = containerView else { return }

        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = containerView.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.insertSubview(blurEffectView!, at: 0)

        blurEffectView?.alpha = 0
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.blurEffectView?.alpha = 1
        })
    }

    private func attachDismissGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        blurEffectView?.addGestureRecognizer(tapGestureRecognizer!)
    }

    @objc private func dismissController() {
        presentedViewController.dismiss(animated: true)
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.blurEffectView?.alpha = 0
        }, completion: { _ in
            self.blurEffectView?.removeFromSuperview()
        })
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return .zero
        }

        let height = containerView.bounds.height * 0.3
        return CGRect(x: 0, y: containerView.bounds.height - height, width: containerView.bounds.width, height: height)
    }
}
