import UIKit
import FirebaseFirestore
import Razorpay

struct Plan {
    let plan: String
    let price: String
    let originalPrice: String
    var isRecommended: Bool
}

class PlansInderViewController: UIViewController, RazorpayProtocol {
 
    private var tableView: UITableView!
    private var footerView: UIView!
    private var finalPriceLabel: UILabel!
    private var backgroundImageView: UIImageView!
    
    private var selectedPlanIndex: Int? = nil
    private var plans: [Plan] = []
    
    var documentID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupBackgroundImage()
        setupView()
        setupTableView()
        setupFooterView()
        fetchPlansFromFirestore()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
    }

    private func setupBackgroundImage() {
        backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: "PriceBg")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupView() {
        view.backgroundColor = .clear
        overrideUserInterfaceStyle = .light
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.backgroundColor = UIColor(hexString: "#F4F4F4").withAlphaComponent(0.8)
        tableView.dataSource = self
        tableView.register(PlanCell.self, forCellReuseIdentifier: PlanCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupFooterView() {
        footerView = UIView()
        footerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerView)
        
        let footerBackgroundImageView = UIImageView()
        footerBackgroundImageView.image = UIImage(named: "bottomfooter")
        footerBackgroundImageView.contentMode = .scaleAspectFill
        footerBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(footerBackgroundImageView)
        
        NSLayoutConstraint.activate([
            footerBackgroundImageView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor),
            footerBackgroundImageView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor),
            footerBackgroundImageView.topAnchor.constraint(equalTo: footerView.topAnchor),
            footerBackgroundImageView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor)
        ])
        
        let priceSummaryLabel = UILabel()
        priceSummaryLabel.text = "Price Summary"
        priceSummaryLabel.font = UIFont.systemFont(ofSize: 14)
        priceSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(priceSummaryLabel)
        
        finalPriceLabel = UILabel()
        finalPriceLabel.text = "₹55,659"
        finalPriceLabel.font = UIFont(name: "Poppins-SemiBold", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .semibold)
        finalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(finalPriceLabel)
        
        let proceedButton = UIButton(type: .system)
        proceedButton.setTitle("Proceed to Pay", for: .normal)
        proceedButton.backgroundColor = UIColor.darkGray
        proceedButton.setTitleColor(.white, for: .normal)
        proceedButton.layer.cornerRadius = 5
        proceedButton.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(proceedButton)

        proceedButton.addTarget(self, action: #selector(proceedToPayment), for: .touchUpInside)

        setupFooterConstraints(priceSummaryLabel: priceSummaryLabel, rupeeLabel: finalPriceLabel, proceedButton: proceedButton)
    }


    @objc private func proceedToPayment() {
        // Ensure that a plan is selected before proceeding
        guard let selectedPlanIndex = selectedPlanIndex else {
            // Show an alert or message that no plan is selected
            let alert = UIAlertController(title: "No Plan Selected", message: "Please select a plan before proceeding.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        let selectedPlan = plans[selectedPlanIndex]
        let amountInPaise = (Double(selectedPlan.price.replacingOccurrences(of: "₹", with: "")) ?? 0.0) * 100 // Convert rupees to paise

        let razorpay = RazorpayCheckout.initWithKey("rzp_live_mgbdzdpY69jVbV", andDelegate: self)
        let options: [String: Any] = [
            "amount": String(format: "%.0f", amountInPaise), // Amount in paise
            "currency": "INR",
            "description": selectedPlan.plan,
            "order_id": "order_OtsVhjmHElEyHL", // Ensure to generate this order ID from your backend
            "name": "mymedicos",
            "prefill": [
                "contact": "+919305506538",
                "email": "devanshsaxena1019@gmail.com"
            ],
            "theme": [
                "color": "#2BD0BF"
            ]
        ]
        razorpay.open(options)
    }

    func onPaymentSuccess(_ payment_id: String) {
        print("Payment Success: \(payment_id)")
    }

    func onPaymentError(_ code: Int32, description str: String) {
        print("Payment Failed: \(str)")
    }

    private func setupFooterConstraints(priceSummaryLabel: UILabel, rupeeLabel: UILabel, proceedButton: UIButton) {
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 120),
            
            priceSummaryLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 10),
            priceSummaryLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
            
            rupeeLabel.topAnchor.constraint(equalTo: priceSummaryLabel.bottomAnchor, constant: 10),
            rupeeLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
            
            proceedButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            proceedButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
            proceedButton.widthAnchor.constraint(equalToConstant: 150),
            proceedButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func fetchPlansFromFirestore() {
        guard let documentID = documentID else {
            print("Document ID is nil.")
            return
        }
        
        let db = Firestore.firestore()
        let docRef = db.collection("Plans").document("PG").collection("Subscriptions").document(documentID)
        
        print("Document id is this: \(documentID)")

        docRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                print("Document data: \(document.data() ?? [:])")
                
                if let durations = document.data()?["Durations"] as? [String: NSNumber] {
                    print("Durations: \(durations)")
                } else {
                    print("Durations field is missing or not a map of String to NSNumber.")
                }
                
                if let discountPrice = document.data()?["Discount_Price"] as? String {
                    print("Discount_Price: \(discountPrice)")
                } else {
                    print("Discount_Price field is missing or not a String.")
                }
                
                if let planName = document.data()?["PlanName"] as? String {
                    print("PlanName: \(planName)")
                } else {
                    print("PlanName field is missing or not a String.")
                }
                
                if let durations = document.data()?["Durations"] as? [String: NSNumber],
                   let discountPrice = document.data()?["Discount_Price"] as? String {
                    
                    self?.plans = durations.map { key, value in
                        let priceString = value.stringValue
                        let originalPrice = String(format: "₹%.2f", (value.floatValue * 1.35))
                        let isRecommended = priceString == discountPrice
                        return Plan(plan: "\(key) Months", price: "₹\(priceString)", originalPrice: originalPrice, isRecommended: isRecommended)
                    }.sorted { $0.plan < $1.plan }

                    DispatchQueue.main.async {
                        self?.selectRecommendedPlan()
                        self?.tableView.reloadData()
                    }
                } else {
                    print("Document data is missing or in an unexpected format.")
                }
            } else {
                print("Document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    private func updatePriceSummary() {
        if let selectedPlanIndex = selectedPlanIndex, let finalPriceLabel = finalPriceLabel {
            let selectedPlan = plans[selectedPlanIndex]
            UIView.transition(with: finalPriceLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
                finalPriceLabel.text = "\(selectedPlan.price)"
            }, completion: nil)
        }
    }

    private func selectRecommendedPlan() {
        if let recommendedIndex = plans.firstIndex(where: { $0.isRecommended }) {
            selectedPlanIndex = recommendedIndex
            tableView.reloadData()
            updatePriceSummary()
        }
    }
}

extension PlansInderViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanCell.reuseIdentifier, for: indexPath) as? PlanCell else {
            return UITableViewCell()
        }
        
        let isSelected = indexPath.row == selectedPlanIndex
        cell.configure(with: plans[indexPath.row], isSelected: isSelected)

        cell.setRadioButtonAction { [weak self] in
            self?.selectedPlanIndex = indexPath.row
            self?.tableView.reloadData()
            self?.updatePriceSummary()
        }
        
        return cell
    }
}
