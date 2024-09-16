import UIKit

protocol ReminderBottomSheetDelegate: AnyObject {
    func didTapSetReminder(for examID: String, title: String, startDate: Date)
}

class ReminderBottomSheetViewController: UIViewController {
    
    weak var delegate: ReminderBottomSheetDelegate?
    var examID: String?
    var examTitle: String?
    var startDate: Date?
    
    private let reminderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Set Reminder", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(reminderButton)
        reminderButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            reminderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reminderButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            reminderButton.widthAnchor.constraint(equalToConstant: 200),
            reminderButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        reminderButton.addTarget(self, action: #selector(reminderButtonTapped), for: .touchUpInside)
    }
    
    @objc private func reminderButtonTapped() {
        guard let examID = examID, let title = examTitle, let startDate = startDate else { return }
        delegate?.didTapSetReminder(for: examID, title: title, startDate: startDate)
    }
}
