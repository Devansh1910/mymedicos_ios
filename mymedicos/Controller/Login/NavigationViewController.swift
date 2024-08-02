import UIKit

class NavigationViewController: UIViewController, UIScrollViewDelegate {

    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    let pageCount = 3
    var pageTitles: [String] = [
        "Doctor's connect, Learn, Grow.",
        "Med pros exclusive hub.",
        "Recruitment partner of healthcare sector"
    ]
    var pageDescriptions: [String] = [
        "It’s a transformative hub where the medical community connects, learns, and grows together.",
        "mymedicos: India's Premier Affordable App for NEET PG, FMGE, NEET SS.",
        "Our team is dedicated to identifying and connecting top-tier candidates with leading healthcare organizations, ensuring a seamless and effective recruitment process."
    ]
    var pageImages: [String] = ["new1", "new2", "new3"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupPageControl()
        setupPages()
    }

    func setupScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(pageCount), height: view.frame.height)  // Ensure the content size height matches the view height exactly
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = false  // Prevent vertical bouncing
        view.addSubview(scrollView)
    }


    func setupPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 50))
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageControlChanged(_:)), for: .valueChanged)
        view.addSubview(pageControl)
    }

    func setupPages() {
        for i in 0..<pageCount {
            let page = UIView(frame: CGRect(x: CGFloat(i) * view.frame.width, y: 0, width: view.frame.width, height: view.frame.height))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 160)) // Adjusted height and y
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: pageImages[i])
            
            let titleLabel = UILabel(frame: CGRect(x: 20, y: 190, width: view.frame.width - 40, height: 30)) // Adjusted y
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
            titleLabel.text = pageTitles[i]
            
            let descriptionLabel = UILabel(frame: CGRect(x: 20, y: 230, width: view.frame.width - 40, height: 70)) // Adjusted y and height
            descriptionLabel.textAlignment = .center
            descriptionLabel.font = UIFont.systemFont(ofSize: 16)
            descriptionLabel.numberOfLines = 0
            descriptionLabel.text = pageDescriptions[i]
            
            page.addSubview(imageView)
            page.addSubview(titleLabel)
            page.addSubview(descriptionLabel)
            scrollView.addSubview(page)
        }
    }


    @objc func pageControlChanged(_ sender: UIPageControl) {
        let page = sender.currentPage
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: true)
    }
}
