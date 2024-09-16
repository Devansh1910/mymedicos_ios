import UIKit
import Kingfisher

protocol ExamQuizLiveTableViewCellDelegate: AnyObject {
    func didTapSolveButton(examID: String, examTitle: String)
    func didTapLockedQuiz(examID: String)
    func didTapComingSoon(examID: String)
    func showAlert(title: String, message: String)
}


class ExamQuizLiveTableViewCell: UITableViewCell {
    
    weak var delegate: ExamQuizLiveTableViewCellDelegate?
    
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let indexLabel = UILabel()
    private let attemptButton = UIButton(type: .system)
    
    private var examID: String?  // To store exam ID
    private var examTitle: String?  // To store exam title
    private let quizImageView = UIImageView()

    // Define the custom color for the lock icon
    private let lockIconColor = UIColor(hex: "#BDBDBD")  // Custom grey color

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        layoutUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        detailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = UIColor.gray
        indexLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        indexLabel.textColor = UIColor.lightGray
        
        // Configure the image view for center cropping
        quizImageView.contentMode = .scaleAspectFill
        quizImageView.clipsToBounds = true
        quizImageView.layer.cornerRadius = 5 // Optional: if you want rounded corners
        quizImageView.image = UIImage(named: "brain")  // Set a default image

        attemptButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        attemptButton.setTitleColor(.white, for: .normal)
        attemptButton.layer.cornerRadius = 5
        attemptButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        attemptButton.imageView?.contentMode = .scaleAspectFit
        attemptButton.tintColor = lockIconColor  // Apply custom color for icons
        attemptButton.addTarget(self, action: #selector(attemptButtonTapped), for: .touchUpInside)
    }
    
    private func layoutUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(quizImageView)
        contentView.addSubview(indexLabel)
        contentView.addSubview(attemptButton)

        quizImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        attemptButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            quizImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            quizImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            quizImageView.widthAnchor.constraint(equalToConstant: 50),
            quizImageView.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: quizImageView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            indexLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 5),
            indexLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            indexLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            attemptButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            attemptButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            attemptButton.widthAnchor.constraint(equalToConstant: 100),
            attemptButton.heightAnchor.constraint(equalToConstant: 40),
            
        ])
    }
    
    func configure(with data: String, examID: String, thumbnailURL: String?, isUpcoming: Bool = false, startDate: Date? = nil, isPast: Bool = false) {
        self.examID = examID
        let components = data.split(separator: ";").map { String($0).trimmingCharacters(in: .whitespaces) }
        self.examTitle = components.first

        // Adjust the title to show ellipsis if longer than 25 characters
        if let title = components.first, title.count > 20 {
            titleLabel.text = title.prefix(18) + "..."
        } else {
            titleLabel.text = components.first ?? "No Title"
        }

        detailLabel.text = components.count > 1 ? components[1] : "Details unavailable"
        indexLabel.text = components.count > 2 ? components[2] : "No index"

        if let urlString = thumbnailURL, let url = URL(string: urlString) {
            quizImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        } else {
            quizImageView.image = UIImage(named: "placeholder")
        }

        let isLocked = components.contains { $0 == "Pro" || $0 == "Premium" || $0 == "Standard" }
        attemptButton.isEnabled = true

        if isUpcoming {
            configureButton(title: "Coming", backgroundColor: UIColor.darkGray, showShadow: true)
        } else if isPast {
            configureButton(title: "Ended", backgroundColor: UIColor.gray, showShadow: false)
        } else if isLocked {
            configureButton(title: components.last!, backgroundColor: UIColor.gray, showShadow: true)
        } else {
            configureButton(title: "Solve", backgroundColor: UIColor.darkGray, showShadow: true)
        }
        
    }

    private func configureButton(title: String, backgroundColor: UIColor, showShadow: Bool) {
        attemptButton.setTitle(title, for: .normal)
        attemptButton.backgroundColor = backgroundColor
        attemptButton.layer.cornerRadius = 5
        attemptButton.layer.shadowOpacity = showShadow ? 0.5 : 0
        attemptButton.layer.shadowRadius = showShadow ? 1 : 0
        attemptButton.layer.shadowOffset = CGSize(width: 0, height: showShadow ? 1 : 0)
        attemptButton.layer.shadowColor = UIColor.black.cgColor
    }



    // Helper function to calculate time until a certain date
    private func timeUntil(date: Date) -> String {
        let interval = date.timeIntervalSinceNow
        if interval <= 0 {
            return "Live now!"
        } else {
            let hours = Int(interval) / 3600
            let minutes = (Int(interval) % 3600) / 60
            return String(format: "%02dh %02dm", hours, minutes)
        }
    }

    
    @objc private func attemptButtonTapped() {
        guard let examID = self.examID, let examTitle = self.examTitle else { return }
        let isLocked = attemptButton.currentTitle == "Pro" || attemptButton.currentTitle == "Premium" || attemptButton.currentTitle == "Standard"
        
        if isLocked {
            delegate?.didTapLockedQuiz(examID: examID)
        } else {
            switch attemptButton.currentTitle {
                case "Solve":
                    delegate?.didTapSolveButton(examID: examID, examTitle: examTitle)
                case "Coming":
                    delegate?.didTapComingSoon(examID: examID)
                case "Ended":
                    delegate?.showAlert(title: "Quiz Ended", message: "This quiz is no longer available.")
                default:
                    print("No action for this button state.")
            }
        }
    }


}
