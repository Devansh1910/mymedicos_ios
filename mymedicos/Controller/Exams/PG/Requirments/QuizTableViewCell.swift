import UIKit

protocol QuizTableViewCellDelegate: AnyObject {
    func didTapSolveButton(examID: String, examTitle: String)
    func didTapLockedQuiz(examID: String)
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
               attemptButton.heightAnchor.constraint(equalToConstant: 40)
           ])
       }
    
    func configure(with data: String, examID: String) {
        self.examID = examID
        let components = data.split(separator: ";").map { String($0).trimmingCharacters(in: .whitespaces) }
        self.examTitle = components.first  // Store the exam title
        titleLabel.text = components.count > 0 ? components[0] : "No Title"
        detailLabel.text = components.count > 1 ? components[1] : "No Details"
        indexLabel.text = components.count > 2 ? components[2] : "No Index"  // Convert index to uppercase

        quizImageView.image = UIImage(named: "brain")

        let isLocked = ["Standard", "Premium", "Pro"].contains(components.last ?? "")
        attemptButton.setTitle(isLocked ? "" : "Solve", for: .normal)
        attemptButton.setImage(isLocked ? UIImage(systemName: "lock.fill") : nil, for: .normal)
        attemptButton.backgroundColor = isLocked ? UIColor.lightGray : UIColor.darkGray
    }

    
    @objc private func attemptButtonTapped() {
            if let examID = self.examID {
                if attemptButton.currentTitle == "Solve" {
                    if let examTitle = self.examTitle {
                        delegate?.didTapSolveButton(examID: examID, examTitle: examTitle)
                    }
                } else {
                    // This means the quiz is locked
                    delegate?.didTapLockedQuiz(examID: examID)
                }
            }
        }
}
