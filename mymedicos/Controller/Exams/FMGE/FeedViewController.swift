import UIKit

class FeedViewController: UIViewController, UIScrollViewDelegate {
    
    var phoneNumber: String?
    var heroImageView: HeroImageNeetpgUIView!
    var overlayView: OverlayPgNeetUIView!
    var scrollView: UIScrollView!
    var contentView: UIView!
    var heroImageViewHeightConstraint: NSLayoutConstraint!
    
    var examCategory: String = "Default Title" 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupScrollView()
        setupViews()
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

    }
    
    func setupViews() {
        setupHeroImageView()
        setupOverlayView()
    }
    
    private func setupHeroImageView() {
        heroImageView = HeroImageNeetpgUIView(frame: CGRect.zero, title: examCategory)
        contentView.addSubview(heroImageView)
        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        heroImageViewHeightConstraint = heroImageView.heightAnchor.constraint(equalToConstant: 200)
        heroImageView.layer.shouldRasterize = true
        heroImageView.layer.rasterizationScale = UIScreen.main.scale
        
        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func setupOverlayView() {
        overlayView = OverlayPgNeetUIView(frame: CGRect.zero)
        overlayView.backgroundColor = .white
        contentView.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: heroImageView.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        if scrollOffset < 0 {
            heroImageViewHeightConstraint.constant = 200 - scrollOffset
        } else {
            heroImageViewHeightConstraint.constant = max(0, 200 - scrollOffset)
        }
        if view.needsUpdateConstraints() {
            view.layoutIfNeeded()
        }
    }
}
