import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import Razorpay

struct Plan {
    let plan: String
    let price: String
    let originalPrice: String
    var isRecommended: Bool
    var selectedCollection: String!
    let duration: Int
    let planId: String
}


class PlansInderViewController: UIViewController, RazorpayPaymentCompletionProtocolWithData {
    private var tableView: UITableView!
    private var footerView: UIView!
    private var finalPriceLabel: UILabel!
    private var backgroundImageView: UIImageView!
    private var name: String = ""
    private var email: String = ""
    private var phoneNumber: String = ""
    private var whatsappNumber: String = ""
    private var dob: Date = Date()
    private var gender: String = "Not Specified"
    private var selectedPlanIndex: Int? = nil
    private var plans: [Plan] = []
    var documentID: String!
    var selectedCollection: String!
    
    var currentOrderId: String?
    private let locationManager = CLLocationManager()
    private let myQueue = DispatchQueue(label: "myOwnQueue")

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserDetails()
        setupNavigationBar()
        setupBackgroundImage()
        setupView()
        setupTableView()
        setupFooterView()
        fetchPlansFromFirestore()
        checkLocationServices()
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
        tableView.dataSource = self
        tableView.register(PlanCell.self, forCellReuseIdentifier: PlanCell.reuseIdentifier)
        tableView.backgroundColor = UIColor(hexString: "#F4F4F4").withAlphaComponent(0.8)
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
    
    private func checkLocationServices() {
        myQueue.async {
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    // Perform any operations that need to be on the main thread here
                    self.locationManager.requestWhenInUseAuthorization()
                }
            } else {
                DispatchQueue.main.async {
                    // Alert the user that location services are not enabled
                    let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services in settings.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    @objc private func proceedToPayment() {
        guard let selectedPlanIndex = selectedPlanIndex else {
            let alert = UIAlertController(title: "No Plan Selected", message: "Please select a plan before proceeding.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        // Use global queue for checking location services to avoid UI freeze
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.continuePayment()
                }
            } else {
                DispatchQueue.main.async {
                    // Alert the user if location services are not enabled
                    let alert = UIAlertController(title: "Location Services Disabled", message: "Location services are required to proceed with the payment. Please enable them in settings.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                        // Open settings to let the user enable location services
                        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    })
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    private func continuePayment() {
        let selectedPlan = plans[selectedPlanIndex!]
        let amountInPaise = (Double(selectedPlan.price.replacingOccurrences(of: "₹", with: "")) ?? 0.0) * 100
        let planId = selectedPlan.planId
        let duration = selectedPlan.duration

        fetchOrderId(planId: planId, section: selectedCollection, duration: String(duration)) { [weak self] orderId in
            guard let orderId = orderId else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Failed to generate order ID.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
                return
            }

            DispatchQueue.main.async {
                let razorpay = RazorpayCheckout.initWithKey("rzp_test_U1DrG1wBsNz008", andDelegate: self!)
                let options: [String: Any] = [
                    "amount": String(format: "%.0f", amountInPaise),
                    "currency": "INR",
                    "description": selectedPlan.plan,
                    "order_id": orderId,
                    "name": self?.title ?? "mymedicos",
                    "prefill": [
                        "contact": self?.phoneNumber ?? "",
                        "email": self?.email ?? ""
                    ],
                    "theme": [
                        "color": "#2BD0BF"
                    ]
                ]
                razorpay.open(options)
            }
        }
    }


    func fetchUserDetails() {
        guard let user = Auth.auth().currentUser, let currentPhoneNumber = user.phoneNumber else {
            print("User not authenticated or phone number not available")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").whereField("Phone Number", isEqualTo: currentPhoneNumber).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching user data: \(error)")
                return
            }

            guard let document = snapshot?.documents.first else {
                print("No matching user found")
                return
            }

            let data = document.data()
            self.name = data["Name"] as? String ?? "Unknown"
            self.email = data["Email ID"] as? String ?? "Unknown"
            self.phoneNumber = data["Phone Number"] as? String ?? "Unknown"
            self.documentID = data["DocID"] as? String ?? "Unknown"
            self.whatsappNumber = data["Phone Number"] as? String ?? "Unknown"
            self.dob = (data["DOB"] as? Timestamp)?.dateValue() ?? Date()
            self.gender = data["Gender"] as? String ?? "Not Specified"
        }
    }

    func fetchOrderId(planId: String, section: String, duration: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://admin.mymedicos.in/api/plans/generate") else {
            completion(nil)
            return
        }

        var adjustedSection = section
        switch section {
        case "PG":
            adjustedSection = "PGNEET"
        case "NEET SS":
            adjustedSection = "NEETSS"
        default:
            break
        }

        // Safely unwrap documentID or use a default value
        let userDocumentID = documentID ?? "No Document ID Available"

        let parameters: [String: Any] = [
            "section": adjustedSection,
            "planID": planId,
            "duration": duration,
            "userDocID": userDocumentID
        ]

        // Print the userDocumentID to verify it
        print("User documentID being used: \(userDocumentID)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            if let json = try? JSONDecoder().decode([String: String].self, from: data),
               let orderId = json["order_id"] {
                completion(orderId)
            } else {
                completion(nil)
            }
        }.resume()
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
        guard let documentID = documentID, let selectedCollection = selectedCollection else {
            print("Document ID or Selected Collection is nil.")
            return
        }

        let db = Firestore.firestore()
        let docRef = db.collection("Plans").document(selectedCollection).collection("Subscriptions").document(documentID)
        
        docRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                if let planData = document.data() {
                    print("Document data: \(planData)")

                    if let durations = planData["Durations"] as? [String: NSNumber],
                       let discountPrice = planData["Discount_Price"] as? String,
                       let planName = planData["PlanName"] as? String,
                       let planID = planData["planID"] as? String {  // Ensure planID is fetched correctly here

                        self?.plans = durations.map { key, value in
                            let priceString = value.stringValue
                            let originalPrice = String(format: "₹%.2f", (value.floatValue * 1.35))
                            let isRecommended = priceString == discountPrice
                            let duration = Int(key) ?? 0
                            return Plan(plan: "\(key) Months", price: "₹\(priceString)", originalPrice: originalPrice, isRecommended: isRecommended, selectedCollection: selectedCollection, duration: duration, planId: planID)
                        }.sorted { $0.plan < $1.plan }

                        DispatchQueue.main.async {
                            self?.selectRecommendedPlan()
                            self?.tableView.reloadData()
                        }
                    } else {
                        print("Required fields are missing or in an unexpected format.")
                    }
                } else {
                    print("Document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
                }
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

    func onPaymentSuccess(_ payment_id: String, andData data: [AnyHashable: Any]?) {
        let signature = data?["razorpay_signature"] as? String ?? "No Signature"
        let orderId = currentOrderId ?? "No Order ID"
        print("Payment Success: \(payment_id)")
        DispatchQueue.main.async {
            let message = "Payment ID: \(payment_id)\nOrder ID: \(orderId)\nSignature: \(signature)"
            let alert = UIAlertController(title: "Payment Success", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func onPaymentError(_ code: Int32, description str: String, andData data: [AnyHashable: Any]?) {
        print("Payment Failed: \(str)")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Payment Failed", message: str, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
