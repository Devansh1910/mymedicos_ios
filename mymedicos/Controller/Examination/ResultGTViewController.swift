import UIKit

class ResultGTViewController: UIViewController {

    var answeredCount: Int = 0
    var markedCount: Int = 0
    var unansweredCount: Int = 0
    var examName: String = ""
    var totalQuestions: Int = 0
    var correctAnswers: Int = 0
    var wrongAnswers: Int = 0
    var marksForCorrect: Int = 0
    var marksDeductedForWrong: Int = 0
    var grandTotal: Int = 0
    var totalMarksYouCanGet: Int = 0

    private var examNameLabel: UILabel!
    private var totalQuestionsLabel: UILabel!
    private var answeredLabel: UILabel!
    private var markedLabel: UILabel!
    private var unansweredLabel: UILabel!
    private var correctAnswersLabel: UILabel!
    private var wrongAnswersLabel: UILabel!
    private var marksForCorrectLabel: UILabel!
    private var marksDeductedForWrongLabel: UILabel!
    private var grandTotalLabel: UILabel!
    private var totalMarksYouCanGetLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Result"
        setupUI()
        displayResults()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        examNameLabel = createLabel()
        totalQuestionsLabel = createLabel()
        answeredLabel = createLabel()
        markedLabel = createLabel()
        unansweredLabel = createLabel()
        correctAnswersLabel = createLabel()
        wrongAnswersLabel = createLabel()
        marksForCorrectLabel = createLabel()
        marksDeductedForWrongLabel = createLabel()
        grandTotalLabel = createLabel()
        totalMarksYouCanGetLabel = createLabel()
        
        let stackView = UIStackView(arrangedSubviews: [examNameLabel, totalQuestionsLabel, answeredLabel, markedLabel, unansweredLabel, correctAnswersLabel, wrongAnswersLabel, marksForCorrectLabel, marksDeductedForWrongLabel, grandTotalLabel, totalMarksYouCanGetLabel])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }

    private func displayResults() {
        examNameLabel.text = "Exam Name: \(examName)"
        totalQuestionsLabel.text = "Total Questions: \(totalQuestions)"
        answeredLabel.text = "Answered Questions: \(answeredCount)"
        markedLabel.text = "Questions in Review: \(markedCount)"
        unansweredLabel.text = "Unanswered Questions: \(unansweredCount)"
        correctAnswersLabel.text = "Correct Answers: \(correctAnswers)"
        wrongAnswersLabel.text = "Wrong Answers: \(wrongAnswers)"
        marksForCorrectLabel.text = "Marks Obtained for Correct: \(marksForCorrect)"
        marksDeductedForWrongLabel.text = "Marks Deducted for Wrong: \(marksDeductedForWrong)"
        grandTotalLabel.text = "Grand Total: \(grandTotal)"
        totalMarksYouCanGetLabel.text = "Total Marks You Can Get: \(totalMarksYouCanGet)"
    }
}
