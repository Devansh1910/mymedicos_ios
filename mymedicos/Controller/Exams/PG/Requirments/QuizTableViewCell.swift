import UIKit
import Kingfisher

protocol QuizTableViewCellDelegate: AnyObject {
    func didTapSolveButton(examID: String, examTitle: String)
    func didTapLockedQuiz(examID: String)
    func didTapResultButton(examID: String, examTitle: String)
}

class QuizTableViewCell: UITableViewCell {
    
    weak var delegate: QuizTableViewCellDelegate?
    
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
        
        quizImageView.contentMode = .scaleAspectFit
        quizImageView.clipsToBounds = true
        quizImageView.image = UIImage(named: "brain")  // Set a default image
        
        attemptButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        attemptButton.setTitleColor(.white, for: .normal)
        attemptButton.layer.cornerRadius = 5
        attemptButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        attemptButton.imageView?.contentMode = .scaleAspectFit
        attemptButton.tintColor = lockIconColor  // Apply custom color for icons
        
        // Remove the generic action and define it later based on the quiz state
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
            attemptButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with data: String, examID: String, thumbnailURL: String?, isAttempted: Bool) {
        self.examID = examID
        let components = data.split(separator: ";").map { String($0).trimmingCharacters(in: .whitespaces) }
        self.examTitle = components.first
        
        titleLabel.text = components.first.map { $0.count > 20 ? "\($0.prefix(20))..." : $0 } ?? "No Title"
        detailLabel.text = components.dropFirst().first.map { $0.count > 20 ? "\($0.prefix(20))..." : $0 } ?? "No Details"
        indexLabel.text = components.dropFirst(2).first ?? "No Index"
        
        if let urlString = thumbnailURL, let url = URL(string: urlString) {
            quizImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
        } else {
            quizImageView.image = UIImage(named: "placeholder")
        }
        
        let isLocked = components.contains { ["Pro", "Premium", "Standard"].contains($0) }
        setupButtonState(isLocked: isLocked, isAttempted: isAttempted)
    }
    
    private func setupButtonState(isLocked: Bool, isAttempted: Bool) {
        attemptButton.removeTarget(nil, action: nil, for: .allEvents)  // Clear existing actions

        if isAttempted {
            attemptButton.setTitle("Results", for: .normal)
            attemptButton.backgroundColor = UIColor.systemBlue
            attemptButton.addTarget(self, action: #selector(showResults), for: .touchUpInside)
        } else if isLocked {
            attemptButton.setTitle("Unlock", for: .normal)
            attemptButton.backgroundColor = UIColor.lightGray
            attemptButton.addTarget(self, action: #selector(unlockQuiz), for: .touchUpInside)
        } else {
            attemptButton.setTitle("Solve", for: .normal)
            attemptButton.backgroundColor = UIColor.darkGray
            attemptButton.addTarget(self, action: #selector(solveQuiz), for: .touchUpInside)
        }
    }


    @objc private func solveQuiz() {
        if let examID = self.examID, let examTitle = self.examTitle {
            delegate?.didTapSolveButton(examID: examID, examTitle: examTitle)
        }
    }

    @objc private func showResults() {
        if let examID = self.examID, let examTitle = self.examTitle {
            delegate?.didTapResultButton(examID: examID, examTitle: examTitle)
        }
    }

    @objc private func unlockQuiz() {
        if let examID = self.examID {
            delegate?.didTapLockedQuiz(examID: examID)
        }
    }
}
