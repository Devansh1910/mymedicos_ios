import UIKit
import FirebaseFirestore

class PlansViewController: UIViewController {
    
    private var mainScrollView: UIScrollView!
    private var contentStackView: UIStackView!
    private var plansScrollView: UIScrollView!
    
    private let cache = NSCache<NSString, NSArray>()
    private var activityIndicator: UIActivityIndicatorView?
    private var db: Firestore?
    private var segmentControl: UISegmentedControl!
    
    private var updatesTitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        view.backgroundColor = .white
        configureUI()
        setupActivityIndicator()
        db = Firestore.firestore()
        
        fetchPlansAndLayout()
        setupFAQSection()
    }

    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func configureUI() {
        // Create the main scroll view
        mainScrollView = UIScrollView()
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainScrollView)
        
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Create the stack view for content
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 20
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor)  // Ensure stack view takes the full width
        ])
        
        // Container for back button and title
        let headerContainerView = UIView()
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(headerContainerView)
        
        // Back button
        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        if let image = UIImage(systemName: "chevron.backward") {
            backButton.setImage(image, for: .normal)
            backButton.tintColor = .black
        }
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        headerContainerView.addSubview(backButton)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Choose a Plan"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center
        headerContainerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            // Back button constraints
            backButton.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),
            
            // Title label constraints
            titleLabel.centerXAnchor.constraint(equalTo: headerContainerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerContainerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8), // Ensure title and button have some spacing
            
            // Container height constraint
            headerContainerView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Segment Control
        let segments = ["PG", "FMGE", "NEET SS"]
        segmentControl = UISegmentedControl(items: segments)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.selectedSegmentIndex = 0
        contentStackView.addArrangedSubview(segmentControl)

        NSLayoutConstraint.activate([
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

        // Add a container for the plans content
        let plansContainerView = UIView()
        plansContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(plansContainerView)
        
        // Set up the scroll view inside the container
        setupPlansScrollView(in: plansContainerView)
        
        // Set up the updates title label for FAQs
        setupUpdatesTitleLabel()
    }

    
    private func setupPlansScrollView(in containerView: UIView) {
        plansScrollView = UIScrollView() // Reference updated here
        plansScrollView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(plansScrollView)
        
        NSLayoutConstraint.activate([
            plansScrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            plansScrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            plansScrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            plansScrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            plansScrollView.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.center = view.center
        activityIndicator?.hidesWhenStopped = true
        view.addSubview(activityIndicator!)
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        clearScrollViewContent()
        print("Selected Segment Index: \(sender.selectedSegmentIndex)")
        fetchPlansAndLayout()
    }
    
    private func clearScrollViewContent() {
        plansScrollView.subviews.forEach { $0.removeFromSuperview() } // Reference updated here
    }
    
    private func fetchPlansAndLayout() {
        let segmentIndex = segmentControl.selectedSegmentIndex
        let collectionNames = ["PG", "FMGE", "NEET SS"]
        let selectedCollection = collectionNames[segmentIndex]
        let cacheKey = NSString(string: selectedCollection)
        
        if let cachedPlans = cache.object(forKey: cacheKey) {
            layoutPlansFromCache(cachedPlans)
        } else {
            activityIndicator?.startAnimating()
            db?.collection("Plans").document(selectedCollection).collection("Subscriptions").getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self, let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "unknown error")")
                    self?.activityIndicator?.stopAnimating()
                    return
                }
                
                var plansArray = [PlanData]()
                for document in documents {
                    let data = document.data()
                    let planData = PlanData(
                        documentID: document.documentID,
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
                self.cache.setObject(arrayToCache, forKey: cacheKey)
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
            plansScrollView.addSubview(planView)

            // Set the closure to handle navigation when "Enroll Now" is tapped, passing the document ID and title
            planView.enrollAction = { [weak self] documentID in
                self?.navigateToPlanInsiderViewController(with: plan.documentID, planTitle: plan.title)
            }

            offsetX += planView.frame.width + 10
            tallestHeight = max(tallestHeight, planView.frame.height)
        }

        plansScrollView.contentSize = CGSize(width: offsetX, height: tallestHeight)
        plansScrollView.frame.size.height = tallestHeight
    }


    private func navigateToPlanInsiderViewController(with documentID: String, planTitle: String) {
        let planInsiderVC = PlansInderViewController()
        planInsiderVC.title = planTitle
        planInsiderVC.documentID = documentID  // Pass the documentID here
        planInsiderVC.view.backgroundColor = .white
        planInsiderVC.overrideUserInterfaceStyle = .light

        navigationController?.pushViewController(planInsiderVC, animated: true)
    }



    @objc private func planTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view as? PlansNeetPgUIView else { return }
        
        
        let planInsiderVC = PlansInderViewController()
        planInsiderVC.title = "PRO"
        planInsiderVC.view.backgroundColor = .white
        planInsiderVC.overrideUserInterfaceStyle = .light
        
        navigationController?.pushViewController(planInsiderVC, animated: true)
    }


    private func setupUpdatesTitleLabel() {
        updatesTitleLabel = UILabel()
        updatesTitleLabel.text = "Frequently Asked Questions (FAQ's)"
        updatesTitleLabel.textAlignment = .left
        updatesTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        updatesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(updatesTitleLabel)
        
        NSLayoutConstraint.activate([
            updatesTitleLabel.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor, constant: 20),
            updatesTitleLabel.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: -10),
        ])
    }


    private func setupFAQSection() {
        // Add FAQ items directly to the main stack view
        let faqItems = [
            ("What happens to my premium plan if I lose my phone or change my registered mobile number or email?",
             "For our existing students who purchased the premium plan before November 11th, 2020, their account is primarily registered with the email ID used during onboarding. Therefore, if you lose your phone or change your mobile/registered mobile number, you can still log in to your account with the same credentials. All your data, bookmarks, tests, and usage will remain safe on the cloud even if you log in from a new device.\n\nHowever, we strongly recommend that students who log in using their registered phone number keep their phone number intact for a smoother experience. If you encounter any issues, please get in touch with us through live chat or email us at help@mymedicos.com, and our customer care team will respond as soon as possible."),
            
            ("Is it possible to share my mymedicos subscription with others?",
             "No, sharing your subscription is not allowed. You are permitted to be logged in on up to two devices simultaneously. Logging into your account on a third device may result in it being flagged or permanently blocked. So, we do not recommend sharing your login credentials with anyone."),
            
            ("Can I change my plan after purchasing?",
             "Yes, you can upgrade your existing plan from FMGE to NEET PG but not from NEET PG to FMGE. Additionally, you can also extend the duration of your subscription."),
            
            ("I have a subscription for the Premium plan but it is not reflecting on my app.",
             "We request you to please close the app and open it again. Next, try logging out and logging in again. If it still doesn’t work, please get in touch with us through live chat or email us at help@mymedicos.com. Our customer care team will get back to you at the earliest."),
            
            ("Is there an option to buy notes without The ELITE Plan or for a particular subject?",
             "No, printed notes are exclusively available for Premium users who enroll in The ELITE Plan. The ELITE Plan provides a complete set of 19-subject notes, and there is no option to purchase notes for a specific subject separately."),
            
            ("I already have a 2-year (or more) membership. Will I get the updated notes?",
             "As usual, the updated notes will be available for you as a soft copy in the app. For a hard copy of the updated Notes 6.0, you will have to buy the notes again."),
            
            ("Can I take a screenshot of the soft copies of notes?",
             "No. Your account will be instantly blocked if you try to take screenshots of the notes in the app."),
            
            ("Will the notes be coloured or black-and-white?",
             "We provide printed colored notes for all 19 subjects."),
            
            ("How soon will I receive my mymedicos notes?",
             "We strive to deliver your notes at the earliest possible time. However, delivery may take up to 10-12 working days from the address updation date. To make the process smoother, we will send you a tracking ID once the notes are dispatched so you may know when to expect delivery.\n\nPlease note that dispatch might get delayed for certain areas/pin codes that are not serviced by our primary courier partner. In that case, you will receive a message explaining this after submitting your address."),
            
            ("Will notes be shipped to countries outside India?",
             "No, notes will be shipped only within India."),
            
            ("What are the inclusions of the PRO Plan?",
             "mymedicos’s PRO Plan features the most important preparation resources including QBank 6.0, Test Series, Previous Year Questions, and Treasures."),
            
            ("Who is PRO Plan for?",
             "PRO Plan is for everyone appearing for NEET PG 2024 and INI CET exam."),
            
            ("Is PRO Plan enough for NEET PG preparations?",
             "Yes, PRO Plan gives you access to QBank 6.0, which is a complete preparation tool in itself featuring the majority of clinical questions and is India’s Only Clinical QBank with detailed explanations of all the correct and incorrect options. QBank is also equipped with features like learning objectives and active guidance that are designed to enhance information retention and recall. Plus, the test series will familiarize you with the latest exam pattern and help you become fully prepared for the exam."),
            
            ("How is the PRO Plan different from the ELITE Plan?",
             "mymedicos’s ELITE Plan is a comprehensive plan featuring all the necessary resources for NEET PG preparations including the Video Lectures, Notes 6.0, QBank 6.0, Treasures, and Test Series. However, students who do not wish to learn from video lectures need not purchase the complete ELITE Plan. They can simply opt for the PRO Plan which only features QBank 6.0, Test Series, Treasures and Previous Year Questions."),
            
            ("What if I am using any other preparation resource? Can I still benefit from PRO Plan?",
             "Yes, you can still benefit from the PRO Plan. No matter what resource you are using for video lectures and notes, it’s ultimately the QBank that will help you learn how to put the theoretical knowledge to use. With PRO plan you get access to India’s only Clinical QBank featuring 18,000+ questions including PYQS. The QBank covers all key disciplines in an integrated manner, which will help you develop a deep understanding of clinical scenarios and get ready for your exam.")
        ]
        
        for item in faqItems {
            let questionView = createDropdownView(question: item.0, answer: item.1)
            contentStackView.addArrangedSubview(questionView)
            
            let divider = UIView()
            divider.backgroundColor = .lightGray
            divider.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview(divider)
            
            NSLayoutConstraint.activate([
                divider.heightAnchor.constraint(equalToConstant: 1),
                divider.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor, constant: 10),                 divider.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: -10)
            ])
        }
    }

    
    private func createDropdownView(question: String, answer: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Padding inside the container
        let paddingView = UIView()
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(paddingView)
        
        // Question Button
        let questionButton = UIButton(type: .system)
        questionButton.setTitle(question, for: .normal)
        questionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        questionButton.setTitleColor(.darkGray, for: .normal)
        questionButton.contentHorizontalAlignment = .left
        questionButton.titleLabel?.numberOfLines = 0 // Allow multiple lines
        questionButton.titleLabel?.lineBreakMode = .byWordWrapping // Wrap text properly
        questionButton.translatesAutoresizingMaskIntoConstraints = false
        paddingView.addSubview(questionButton)
        
        // Answer Label
        let answerLabel = UILabel()
        answerLabel.text = answer
        answerLabel.font = UIFont.systemFont(ofSize: 12)
        answerLabel.textColor = .darkGray
        answerLabel.numberOfLines = 0
        answerLabel.isHidden = false
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        paddingView.addSubview(answerLabel)
        
        // Constraints for the padding view inside the container
        NSLayoutConstraint.activate([
            paddingView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            paddingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            paddingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            paddingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
        ])
        
        NSLayoutConstraint.activate([
            questionButton.topAnchor.constraint(equalTo: paddingView.topAnchor),
            questionButton.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor),
            questionButton.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor),
            
            answerLabel.topAnchor.constraint(equalTo: questionButton.bottomAnchor, constant: 10),
            answerLabel.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor),
            answerLabel.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor),
            answerLabel.bottomAnchor.constraint(equalTo: paddingView.bottomAnchor)
        ])
        
        questionButton.tag = answerLabel.hash
                    
        questionButton.addTarget(self, action: #selector(toggleAnswer(_:)), for: .touchUpInside)
        
        return containerView
    }



    @objc private func toggleAnswer(_ sender: UIButton) {
        guard let answerLabel = view.viewWithTag(sender.tag) as? UILabel,
              let dropdownImageView = view.viewWithTag(sender.tag + 1) as? UIImageView else { return }
        
        let isCurrentlyHidden = answerLabel.isHidden
        answerLabel.isHidden = !isCurrentlyHidden
        
        UIView.animate(withDuration: 0.3) {
            dropdownImageView.transform = isCurrentlyHidden ? CGAffineTransform(rotationAngle: .pi) : CGAffineTransform.identity
        }
    }

}
