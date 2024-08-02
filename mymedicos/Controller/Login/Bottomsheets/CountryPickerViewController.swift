import UIKit

class CountryPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var countryData: [[String: Any]] = []
    var onSelectCountry: ((String, String, String) -> Void)?
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        overrideUserInterfaceStyle = .light
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.white
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Cancel", for: .normal)
        closeButton.addTarget(self, action: #selector(closePicker), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    @objc private func closePicker() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let country = countryData[indexPath.row]
        
        if let name = country["name"] as? String, let dialCode = country["dial_code"] as? String, let flag = country["flag"] as? String {
            cell.textLabel?.text = "\(flag) \(name) \(dialCode)"
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = countryData[indexPath.row]
        
        if let name = country["name"] as? String, let dialCode = country["dial_code"] as? String, let flag = country["flag"] as? String {
            onSelectCountry?(name, dialCode, flag)
            closePicker()
        }
    }
}
