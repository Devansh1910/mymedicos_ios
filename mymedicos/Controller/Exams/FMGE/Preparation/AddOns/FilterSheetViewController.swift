import UIKit
import FirebaseFirestore

class FilterSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var options = [String]()
    var counts = [String: Int]()  // Dictionary to hold index counts
    var selectedOptions = Set<String>()
    var blurEffectView: UIVisualEffectView?
    var tableView: UITableView!
    var completionHandler: (() -> Void)?
    
    // Closure to handle the selected filter options
    var applyFilter: ((Set<String>) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        overrideUserInterfaceStyle = .light
        tableView.register(IndexTableViewCell.self, forCellReuseIdentifier: "IndexCell")
        
        // Add tap gesture recognizer to detect taps outside the filter sheet
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func configureWithIndexes(_ indexes: [String: Int]) {
        options = indexes.keys.sorted()  // Sort if needed
        counts = indexes
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAnimatedBlurEffect()
    }

    private func setupAnimatedBlurEffect() {
        guard let parentView = view.superview else { return }
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = parentView.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView?.alpha = 0
        parentView.insertSubview(blurEffectView!, at: 0)

        UIView.animate(withDuration: 0.2) {
            self.blurEffectView?.alpha = 1
        }
    }

    @objc private func dismissController() {
        UIView.animate(withDuration: 0.2, animations: {
            self.blurEffectView?.alpha = 0
        }) { _ in
            self.blurEffectView?.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let parentView = self.view.superview {
            self.view.frame = CGRect(
                x: 0,
                y: parentView.frame.height - 450,
                width: parentView.frame.width,
                height: 450
            )
        }
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.clipsToBounds = true

        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.darkGray, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        closeButton.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            tableView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IndexCell", for: indexPath) as? IndexTableViewCell else {
            return UITableViewCell()
        }

        let index = options[indexPath.row]
        let countText = "\(counts[index] ?? 0) QBanks"

        cell.indexLabel.text = index
        cell.countLabel.text = countText

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIndex = options[indexPath.row]
        selectedOptions.insert(selectedIndex)

        // Call the applyFilter closure when an index is selected
        applyFilter?(selectedOptions)
        dismissController()
    }
}
