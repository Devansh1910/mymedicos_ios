import UIKit
import FirebaseFirestore

class OverlayPgNeetUIView: UIView {
    
    // Views declarations
    private var dragHandle: UIView!
    private var carouselView: CarousleNeetPgUIView!
    private var examinationTitleLabel: UILabel!
    private var examinationView: ExaminationNeetPgUIView!
    private var questionBankTitleLabel: UILabel!
    private var questionBankView: QuestionBankNeetPgUIView!
    private var plansTitleLabel: UILabel!
    private var scrollView: UIScrollView!  // ScrollView to hold multiple plans

    private var db: Firestore!

    override init(frame: CGRect) {
        super.init(frame: frame)
        db = Firestore.firestore()  // Initialize Firestore
        setupSubViewsInContentView(contentView: self)
        fetchPlansAndLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        db = Firestore.firestore()  // Initialize Firestore
        setupSubViewsInContentView(contentView: self)
        fetchPlansAndLayout()
    }
    
    private func setupSubViewsInContentView(contentView: UIView) {
        setupDragHandle(contentView: contentView)
        setupCarouselView(contentView: contentView)
        setupExaminationTitleLabel(contentView: contentView)
        setupExaminationView(contentView: contentView)
        setupQuestionBankTitleLabel(contentView: contentView)
        setupQuestionBankView(contentView: contentView)
        setupPlansTitleLabel(contentView: contentView)
        setupScrollView(contentView: contentView)
        
        if let lastView = contentView.subviews.last {
            lastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        }
    }

    private func setupDragHandle(contentView: UIView) {
        dragHandle = UIView()
        dragHandle.backgroundColor = UIColor.systemGray4
        dragHandle.layer.cornerRadius = 5
        contentView.addSubview(dragHandle)
        
        dragHandle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dragHandle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
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
        examinationTitleLabel.text = "Suggested Live Examination"
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

    private func setupQuestionBankTitleLabel(contentView: UIView) {
        questionBankTitleLabel = UILabel()
        questionBankTitleLabel.text = "Suggested Question Banks"
        questionBankTitleLabel.textAlignment = .left
        questionBankTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(questionBankTitleLabel)
        
        questionBankTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            questionBankTitleLabel.topAnchor.constraint(equalTo: examinationView.bottomAnchor, constant: 10),
            questionBankTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            questionBankTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            questionBankTitleLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func setupQuestionBankView(contentView: UIView) {
        questionBankView = QuestionBankNeetPgUIView(frame: CGRect.zero)
        contentView.addSubview(questionBankView)
        
        questionBankView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            questionBankView.topAnchor.constraint(equalTo: questionBankTitleLabel.bottomAnchor, constant: 10),
            questionBankView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            questionBankView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            questionBankView.heightAnchor.constraint(equalToConstant: 100)
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
            plansTitleLabel.topAnchor.constraint(equalTo: questionBankView.bottomAnchor, constant: 10),
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
            scrollView.heightAnchor.constraint(equalToConstant: 600)  // Adjust height as needed
        ])
        
        fetchPlansAndLayout()
    }
    
    private func fetchPlansAndLayout() {
            db.collection("Plans").document("PG").collection("Subscriptions").getDocuments { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "unknown error")")
                    return
                }
                
                var offsetX: CGFloat = 10
                var tallestHeight: CGFloat = 0  // Track the tallest view
                
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
                    
                    let planView = PlansNeetPgUIView(frame: CGRect(x: offsetX, y: 0, width: 280, height: 500))
                    planView.configure(with: planData)
                    self?.scrollView.addSubview(planView)
                    offsetX += planView.frame.width + 10  // Add spacing between items
                    
                    // Update tallestHeight if this view is taller
                    if planView.frame.height > tallestHeight {
                        tallestHeight = planView.frame.height
                    }
                }
                
                // Update scrollView contentSize and height to match tallest plan view
                self?.scrollView.contentSize = CGSize(width: offsetX, height: tallestHeight)
                self?.scrollView.frame.size.height = tallestHeight  // Set the height of the scrollView to the height of the tallest view
            }
        }
    }
