import UIKit

class ResultGTViewController: UIViewController, RatingBottomSheetDelegate, UIViewControllerTransitioningDelegate {
    
    var examName: String?
    var totalQuestions: Int = 0
    var correctAnswers: Int = 0
    var wrongAnswers: Int = 0
    var unansweredCount: Int = 0
    var totaltimetaken: Double = 0
    var markedCount: Int = 0
    var averageTimePerQuestion: Double = 0
    var successRate: Double = 0
    var submissionDate: String = "Submitted on 21st Aug 2024"
    var examId : String?
    var testRank: String = "#778 / 796"
    var percentile: Double = 2.26
    var comment: String = "Great speed, but consider improving accuracy."

    var answeredCount: Int { totalQuestions - unansweredCount }
    var grandTotal: Int { (correctAnswers * 4) - (wrongAnswers * 1) }
    var totalMarks: Int { totalQuestions * 4 }

    private var examNameLabel: UILabel!
    private var submissionDateLabel: UILabel!
    
    private var pieChartView: PieChartView!
    
    private var totalScoreLabel: UILabel!
    private var percentileLabel: UILabel!
    
    private var answeredQuestionsLabel: UILabel!
    private var correctAnswersLabel: UILabel!
    private var wrongAnswersLabel: UILabel!
    private var unansweredQuestionsLabel: UILabel!
    private var markedQuestionsLabel: UILabel!
    private var averageTimeLabel: UILabel!
    private var successRateLabel: UILabel!
    private var totalTimeTakenLabel: UILabel!
    private var commentLabel: UILabel!
    private var divider: UIView!
    private var divider2: UIView!
    private var divider3: UIView!
    private var segmentControl: UISegmentedControl!
    private var reportLabel: UILabel!
    private var detailLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        setupNavigationItems()
    }
    
    private func setupNavigationItems() {
        let goHomeButton = UIBarButtonItem(title: "Go Home", style: .plain, target: self, action: #selector(handleGoHomeTapped))
        self.navigationItem.rightBarButtonItem = goHomeButton
    }

    @objc private func handleGoHomeTapped() {
        let bottomSheetVC = RatingBottomSheetViewController()
        bottomSheetVC.examId = examId
        bottomSheetVC.modalPresentationStyle = .custom
        bottomSheetVC.transitioningDelegate = self
        bottomSheetVC.delegate = self // Setting the delegate
        present(bottomSheetVC, animated: true, completion: nil)
    }


    
    func didTapSubmit() {
        
        let tabBarController = MainTabBarViewController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true, completion: nil)
    }
    
    func didTapClose() {
        dismiss(animated: true, completion: nil) // Dismiss the bottom sheet
    }


    private func setupUI() {
           view.backgroundColor = .systemBackground
           
           examNameLabel = createLabel(text: examName ?? "Exam", font: UIFont(name: "Inter-SemiBold", size: 20) ?? .systemFont(ofSize: 20, weight: .semibold), color: .black)
           submissionDateLabel = createLabel(text: submissionDate, font: .systemFont(ofSize: 16, weight: .regular), color: .darkGray)
           submissionDateLabel.backgroundColor = UIColor(hex: "#EBEBEB")
           submissionDateLabel.layer.cornerRadius = 5
           submissionDateLabel.layer.masksToBounds = true
           submissionDateLabel.textAlignment = .center
           
           pieChartView = PieChartView()
               pieChartView.translatesAutoresizingMaskIntoConstraints = false
               view.addSubview(pieChartView)
           
           
           commentLabel = createLabel(text: "", font: UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .semibold), color: UIColor(hex: "#383838"))
           commentLabel.textAlignment = .center
           commentLabel.numberOfLines = 0  // Allow multiple lines if needed
           commentLabel.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(commentLabel)
           
           // Initialize divider
           divider = UIView()
           divider.backgroundColor = .lightGray
           divider.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(divider)
           
           // Initialize segmented control
           segmentControl = UISegmentedControl(items: ["Details", "🔒 Summary"])
           segmentControl.translatesAutoresizingMaskIntoConstraints = false
           segmentControl.selectedSegmentIndex = 0
           segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
           view.addSubview(segmentControl)
           
           reportLabel = createLabel(text: "Report", font: UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .semibold), color: UIColor(hex: "#383838"))
           reportLabel.textAlignment = .left
           
           divider2 = UIView()
           divider2.backgroundColor = .lightGray
           divider2.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(divider2)
           
           answeredQuestionsLabel = createLabel(text: "", font: UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .medium), color: UIColor(hex: "#383838"))
           answeredQuestionsLabel.textAlignment = .left
           
           correctAnswersLabel = createLabel(text: "", font: UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .medium), color: UIColor(hex: "#383838"))
           correctAnswersLabel.textAlignment = .left
           
           wrongAnswersLabel = createLabel(text: "", font: UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .medium), color: UIColor(hex: "#383838"))
           wrongAnswersLabel.textAlignment = .left
           
           unansweredQuestionsLabel = createLabel(text: "", font: UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .medium), color: UIColor(hex: "#383838"))
           unansweredQuestionsLabel.textAlignment = .left
           
           markedQuestionsLabel = createLabel(text: "", font: UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .medium), color: UIColor(hex: "#383838"))
           markedQuestionsLabel.textAlignment = .left
           
           detailLabel = createLabel(text: "Detailed", font: UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .semibold), color: UIColor(hex: "#383838"))
           detailLabel.textAlignment = .left
           
           divider3 = UIView()
           divider3.backgroundColor = .lightGray
           divider3.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(divider3)
           
           averageTimeLabel = createLabel(text: "", font: UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .medium), color: UIColor(hex: "#383838"))
           averageTimeLabel.textAlignment = .left
           
           successRateLabel = createLabel(text: "", font: UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .medium), color: UIColor(hex: "#383838"))
           successRateLabel.textAlignment = .left
           
           totalTimeTakenLabel = createLabel(text: "", font: UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .medium), color: UIColor(hex: "#383838"))
           totalTimeTakenLabel.textAlignment = .left
           
           setupConstraints()
       }


    private func createLabel(text: String, font: UIFont, color: UIColor) -> UILabel {
           let label = UILabel()
           label.text = text
           label.font = font
           label.textColor = color
           label.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(label)
           return label
       }


    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            examNameLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            examNameLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.topAnchor.constraint(equalTo: examNameLabel.bottomAnchor, constant: 5),
            
            submissionDateLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 15),
            submissionDateLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            submissionDateLabel.widthAnchor.constraint(equalToConstant: 250),
            submissionDateLabel.heightAnchor.constraint(equalToConstant: 30),
            
            segmentControl.topAnchor.constraint(equalTo: submissionDateLabel.bottomAnchor, constant: 20),
            segmentControl.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            segmentControl.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.9),
            
            pieChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pieChartView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            pieChartView.widthAnchor.constraint(equalToConstant: 150),
            pieChartView.heightAnchor.constraint(equalToConstant: 150),
            
            commentLabel.topAnchor.constraint(equalTo: pieChartView.bottomAnchor, constant: 20),
            commentLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            commentLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            reportLabel.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 20),
            reportLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            reportLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            divider2.heightAnchor.constraint(equalToConstant: 1),
            divider2.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            divider2.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            divider2.topAnchor.constraint(equalTo: reportLabel.bottomAnchor, constant: 5),
            
            answeredQuestionsLabel.topAnchor.constraint(equalTo: divider2.bottomAnchor, constant: 20),
            answeredQuestionsLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            answeredQuestionsLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            correctAnswersLabel.topAnchor.constraint(equalTo: answeredQuestionsLabel.bottomAnchor, constant: 10),
            correctAnswersLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            correctAnswersLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            wrongAnswersLabel.topAnchor.constraint(equalTo: correctAnswersLabel.bottomAnchor, constant: 10),
            wrongAnswersLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            wrongAnswersLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            unansweredQuestionsLabel.topAnchor.constraint(equalTo: wrongAnswersLabel.bottomAnchor, constant: 10),
            unansweredQuestionsLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            unansweredQuestionsLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            markedQuestionsLabel.topAnchor.constraint(equalTo: unansweredQuestionsLabel.bottomAnchor, constant: 10),
            markedQuestionsLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            markedQuestionsLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            detailLabel.topAnchor.constraint(equalTo: markedQuestionsLabel.bottomAnchor, constant: 20),
            detailLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            detailLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            divider3.heightAnchor.constraint(equalToConstant: 1),
            divider3.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            divider3.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            divider3.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 5),
            
            averageTimeLabel.topAnchor.constraint(equalTo: divider3.bottomAnchor, constant: 10),
            averageTimeLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            averageTimeLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            successRateLabel.topAnchor.constraint(equalTo: averageTimeLabel.bottomAnchor, constant: 10),
            successRateLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            successRateLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            
            totalTimeTakenLabel.topAnchor.constraint(equalTo: successRateLabel.bottomAnchor, constant: 10),
            totalTimeTakenLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            totalTimeTakenLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
        ])
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {  // If 'Summary' is selected
            let alert = UIAlertController(title: "Premium Feature", message: "Access to the summary section is a premium feature. Please upgrade to view.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                sender.selectedSegmentIndex = 0  // Revert back to 'Details'
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            // Handle the 'Details' segment logic as necessary
        }
    }

    
    private func updateUI() {
        pieChartView.score = grandTotal
        updateLabel(label: answeredQuestionsLabel, title: "Answered: ", value: "\(answeredCount)", valueColor: UIColor.darkGray)
        updateLabel(label: correctAnswersLabel, title: "Correct Answers: ", value: "\(correctAnswers)", valueColor: UIColor(hex: "#00C637"))
        updateLabel(label: wrongAnswersLabel, title: "Incorrect Answers: ", value: "\(wrongAnswers)", valueColor: UIColor(hex: "#FF0000"))
        updateLabel(label: unansweredQuestionsLabel, title: "Unanswered: ", value: "\(unansweredCount)", valueColor: UIColor(hex: "#797979"))
        updateLabel(label: markedQuestionsLabel, title: "Marked for Review: ", value: "\(markedCount)", valueColor: UIColor(hex: "#0044A9"))
        updateLabel(label: averageTimeLabel, title: "Avg Time/Question: ", value: String(format: "%.2f s", averageTimePerQuestion), valueColor: UIColor(hex: "#FF0000"))
        updateLabel(label: successRateLabel, title: "Success Rate: ", value: String(format: "%.2f%%", successRate), valueColor: UIColor(hex: "#0044A9"))
        updateLabel(label: totalTimeTakenLabel, title: "Total Time Taken: ", value: String(format: "%.2f seconds", totaltimetaken), valueColor: UIColor(hex: "#00C637"))
        commentLabel.text = comment
        submissionDateLabel.text = reformatDateString(submissionDate)
    }

    private func updateLabel(label: UILabel, title: String, value: String, valueColor: UIColor) {
        // Adding a bullet point before the title
        let bulletPoint = "• "
        let fullTitle = bulletPoint + title

        let attributedText = NSMutableAttributedString(string: fullTitle, attributes: [
            .font: UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.darkGray
        ])
        
        attributedText.append(NSAttributedString(string: value, attributes: [
            .font: UIFont(name: "Inter-SemiBold", size: 16) ?? .systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: valueColor
        ]))
        
        label.attributedText = attributedText
    }
        
        private func reformatDateString(_ originalDateString: String) -> String {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "dd MMM yyyy 'at' h:mm a"
            inputFormatter.locale = Locale(identifier: "en_US_POSIX")

            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMMM dd, yyyy 'at' h:mm a"
            outputFormatter.locale = Locale(identifier: "en_US_POSIX")

            if let date = inputFormatter.date(from: originalDateString) {
                return outputFormatter.string(from: date)
            } else {
                return originalDateString
            }
        }
    }
