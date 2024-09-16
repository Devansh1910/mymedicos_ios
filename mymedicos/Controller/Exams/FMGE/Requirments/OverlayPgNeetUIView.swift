import UIKit
import FirebaseFirestore

class OverlayPgNeetUIView: UIView {
    
    // Views declarations
    private var dragHandle: UIView!
    private var carouselView: CarousleNeetPgUIView!
    private var examinationTitleLabel: UILabel!
    private var examinationView: ExaminationNeetPgUIView!
    private var plansTitleLabel: UILabel!
    private var scrollView: UIScrollView!
    private var updatesTitleLabel: UILabel!
    private var updatesView: RecentUpdatesUIView!
    private var activityIndicator: UIActivityIndicatorView?

    private var db: Firestore?
    private let cache = NSCache<NSString, NSArray>()
    var examCategory: String = "Default Title"

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        db = Firestore.firestore()
        setupSubViewsInContentView(contentView: self)
        setupActivityIndicator()
        fetchPlansAndLayout()
        addTopBorder()
    }

    private func setupSubViewsInContentView(contentView: UIView) {
        setupDragHandle(contentView: contentView)
        setupCarouselView(contentView: contentView)
        setupExaminationTitleLabel(contentView: contentView)
        setupExaminationView(contentView: contentView)
        setupPlansTitleLabel(contentView: contentView)
        setupScrollView(contentView: contentView)
        setupUpdatesTitleLabel(contentView: contentView)
        setupUpdatesView(contentView: contentView)

        if let lastView = contentView.subviews.last {
            lastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        }
    }

    private func setupActivityIndicator() {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = self.center
        self.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        self.activityIndicator = indicator
    }

    private func addTopBorder() {
        let border = UIView()
        border.backgroundColor = UIColor.systemGray6
        self.addSubview(border)
        
        border.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            border.topAnchor.constraint(equalTo: self.topAnchor),
            border.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    

    private func setupDragHandle(contentView: UIView) {
        dragHandle = UIView()
        dragHandle.backgroundColor = UIColor.systemGray4
        dragHandle.layer.cornerRadius = 5
        contentView.addSubview(dragHandle)
        
        dragHandle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dragHandle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            dragHandle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dragHandle.widthAnchor.constraint(equalToConstant: 40),
            dragHandle.heightAnchor.constraint(equalToConstant: 5)
        ])
    }

    private func setupCarouselView(contentView: UIView) {
        carouselView = CarousleNeetPgUIView(frame: CGRect.zero)
        contentView.addSubview(carouselView)
        
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            carouselView.topAnchor.constraint(equalTo: dragHandle.bottomAnchor, constant: 10),
            carouselView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            carouselView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            carouselView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setupExaminationTitleLabel(contentView: UIView) {
        examinationTitleLabel = UILabel()
        examinationTitleLabel.text = "Live Examination"
        examinationTitleLabel.textAlignment = .left
        examinationTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(examinationTitleLabel)
        
        examinationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            examinationTitleLabel.topAnchor.constraint(equalTo: carouselView.bottomAnchor, constant: 10),
            examinationTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            examinationTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            examinationTitleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func setupExaminationView(contentView: UIView) {
        examinationView = ExaminationNeetPgUIView(frame: CGRect.zero)
        contentView.addSubview(examinationView)
        
        examinationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            examinationView.topAnchor.constraint(equalTo: examinationTitleLabel.bottomAnchor, constant: 10),
            examinationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            examinationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            examinationView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    private func setupPlansTitleLabel(contentView: UIView) {
        plansTitleLabel = UILabel()
        plansTitleLabel.text = "Explore Plans"
        plansTitleLabel.textAlignment = .left
        plansTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(plansTitleLabel)

        plansTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            plansTitleLabel.topAnchor.constraint(equalTo: examinationView.bottomAnchor, constant: 10),
            plansTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            plansTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            plansTitleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func setupScrollView(contentView: UIView) {
        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: plansTitleLabel.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 500)
        ])
    }

    private func fetchPlansAndLayout() {
        let cacheKey = "plansCacheKey"
        if let cachedPlans = cache.object(forKey: cacheKey as NSString) {
            layoutPlansFromCache(cachedPlans)
        } else {
            activityIndicator?.startAnimating()
            db?.collection("Plans").document("PG").collection("Subscriptions").getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self, let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "unknown error")")
                    self?.activityIndicator?.stopAnimating()
                    return
                }
                
                var plansArray = [PlanData]()
                
                for document in documents {
                    let data = document.data()
                    let planData = PlanData(
                        title: data["PlanName"] as? String ?? "N/A",
                        subtitle: data["PlanTagline"] as? String ?? "N/A",
                        startingPrice: "\(data["Discount_Price"] as? Int ?? 0)",
                        discountedPrice: "\(data["PlanPrice"] as? Int ?? 0)",
                        originalPrice: "\(data["PlanPrice"] as? Int ?? 0)",
                        features: (data["PlanFeatures"] as? [String]) ?? []
                    )
                    
                    plansArray.append(planData)
                }
                
                let arrayToCache = NSArray(array: plansArray)
                self.cache.setObject(arrayToCache, forKey: cacheKey as NSString)
                self.layoutPlansFromCache(arrayToCache)
                self.activityIndicator?.stopAnimating()
            }
        }
    }

    private func layoutPlansFromCache(_ cachedPlans: NSArray) {
        var offsetX: CGFloat = 10
        var tallestHeight: CGFloat = 0
        
        for plan in cachedPlans as! [PlanData] {
            let planView = PlansNeetPgUIView(frame: CGRect(x: offsetX, y: 0, width: 280, height: 500))
            planView.configure(with: plan)
            self.scrollView.addSubview(planView)
            offsetX += planView.frame.width + 10
            
            if planView.frame.height > tallestHeight {
                tallestHeight = planView.frame.height
            }
        }
        
        self.scrollView.contentSize = CGSize(width: offsetX, height: tallestHeight)
        self.scrollView.frame.size.height = tallestHeight
    }

    private func setupUpdatesTitleLabel(contentView: UIView) {
        updatesTitleLabel = UILabel()
        updatesTitleLabel.text = "Recent Updates"
        updatesTitleLabel.textAlignment = .left
        updatesTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(updatesTitleLabel)

        updatesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            updatesTitleLabel.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 10),
            updatesTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            updatesTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            updatesTitleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func setupUpdatesView(contentView: UIView) {
        updatesView = RecentUpdatesUIView(frame: CGRect.zero)
        contentView.addSubview(updatesView)
        
        updatesView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            updatesView.topAnchor.constraint(equalTo: updatesTitleLabel.bottomAnchor, constant: 10),
            updatesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            updatesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            updatesView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
