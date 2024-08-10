import UIKit
import FirebaseFirestore

struct Question {
    var questionText: String
    var options: [String]
    var correctAnswer: String
    var description: String
    var imageUrl: String
    var questionNumber: Int
    var selectedOption: Int?
    var isMarkedForReview: Bool = false
    var isAnswered: Bool {
        return selectedOption != nil
    }
    
    // Method to check if the selected answer is correct
    func isAnswerCorrect() -> Bool {
        guard let selectedOption = selectedOption else { return false }
        // Convert the selected option index to the corresponding option letter
        let selectedOptionLetter = ["A", "B", "C", "D"][selectedOption]
        return selectedOptionLetter == correctAnswer
    }
}

class ExamPortalViewController: UIViewController, QuestionNavigatorDelegate {
    
    func didSelectQuestion(at index: Int) {
        currentQuestionIndex = index
        updateUIForCurrentQuestion()
    }
    
    func didDismissQuestionNavigator() {
        // Reshow the menu icon after QuestionNavigatorVC is dismissed
        menuButton.isEnabled = true
        menuButton.tintColor = nil
    }
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var segmentedControl: UISegmentedControl!
    private var currentQuestionLabel: UILabel!
    private var questionLabel: UILabel!
    private var instructionLabel: UILabel!
    private var optionsStackView: UIStackView!
    private var previousButton: UIButton!
    private var nextButton: UIButton!
    private var endQuizButton: UIButton!
    private var markForReviewCheckbox: UIButton!
    
    private var questions: [Question] = []
    private var currentQuestionIndex: Int = 0
    
    private var menuButton: UIBarButtonItem!
    private var isQuestionNavigatorVisible = false
    
    var examTitle: String?
    var examID: String?
    
    // Timer properties
    private var timer: Timer?
    private var totalTime: Int = 210 * 60 // 210 minutes in seconds
    private var timeRemaining: Int = 210 * 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.title = examTitle ?? "Exam Question"
        setupMenuButton()
        fetchQuestions()
        startTimer() // Start the timer when the view loads
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupScrollView()
        setupSegmentedControl()
        setupCurrentQuestionLabel()
        setupQuestionLabel()
        setupInstructionLabel()
        setupOptionsStackView()
        setupNavigationButtons()
    }
    
    private func setupMenuButton() {
        menuButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(menuButtonTapped))
        self.navigationItem.rightBarButtonItem = menuButton
    }
    
    @objc private func menuButtonTapped() {
           let questionNavigatorVC = QuestionNavigatorViewController(questions: questions, delegate: self)
           questionNavigatorVC.modalPresentationStyle = .overFullScreen
           questionNavigatorVC.modalTransitionStyle = .crossDissolve
           
           // Present the QuestionNavigatorViewController
           present(questionNavigatorVC, animated: false) {
               // Adjust frame after presenting to ensure layout is properly set
               let topMargin: CGFloat = 160 // Adjust this value based on your timer height
               questionNavigatorVC.view.frame = CGRect(x: 0, y: topMargin, width: self.view.frame.width, height: self.view.frame.height - topMargin)
           }
           
           // Hide the menu button while the QuestionNavigatorVC is visible
           menuButton.isEnabled = false
           menuButton.tintColor = .clear
       }

    func closeQuestionNavigator() {
        // Reshow the menu icon after QuestionNavigatorVC is dismissed
        menuButton.isEnabled = true
        menuButton.tintColor = nil
    }
    
    private func presentQuestionNavigator() {
        let questionNavigatorVC = QuestionNavigatorViewController(questions: questions, delegate: self)
        questionNavigatorVC.modalPresentationStyle = .overFullScreen
        questionNavigatorVC.modalTransitionStyle = .crossDissolve
        
        present(questionNavigatorVC, animated: false) {
            // Adjust frame after presenting to ensure layout is properly set
            let topMargin: CGFloat = 100 // Adjust this value based on your timer height
            questionNavigatorVC.view.frame = CGRect(x: 0, y: topMargin, width: self.view.frame.width, height: self.view.frame.height - topMargin)
        }
        
        // Change the menu icon to a cross icon
        menuButton.image = UIImage(systemName: "xmark")
        isQuestionNavigatorVisible = true
    }
    
    func dismissQuestionNavigator() {
        self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "line.horizontal.3")
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            let hours = timeRemaining / 3600
            let minutes = (timeRemaining % 3600) / 60
            let seconds = timeRemaining % 60
            segmentedControl.setTitle(String(format: "%02d:%02d:%02d", hours, minutes, seconds), forSegmentAt: 1)
        } else {
            timer?.invalidate()
            timer = nil
            handleTimerEnd()
        }
    }
    
    private func handleTimerEnd() {
        let alertController = UIAlertController(title: "Time's Up!", message: "The time for this quiz has ended.", preferredStyle: .alert)
        alertController.overrideUserInterfaceStyle = .light
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.finishQuiz()
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func fetchQuestions() {
        guard let examID = examID else { return }
        let db = Firestore.firestore()
        let documentRef = db.collection("PGupload").document("Weekley").collection("Quiz").document(examID)
        
        documentRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching questions: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, let dataArray = document.data()?["Data"] as? [[String: Any]] else { return }
            
            self.questions = dataArray.compactMap { data in
                guard let questionText = data["Question"] as? String,
                      let optionA = data["A"] as? String,
                      let optionB = data["B"] as? String,
                      let optionC = data["C"] as? String,
                      let optionD = data["D"] as? String,
                      let correctAnswer = data["Correct"] as? String,
                      let description = data["Description"] as? String,
                      let imageUrl = data["Image"] as? String,
                      let questionNumber = data["number"] as? Int else {
                    return nil
                }
                
                return Question(
                    questionText: questionText,
                    options: [optionA, optionB, optionC, optionD],
                    correctAnswer: correctAnswer,
                    description: description,
                    imageUrl: imageUrl,
                    questionNumber: questionNumber,
                    selectedOption: nil,
                    isMarkedForReview: false
                )
            }
            
            self.updateUIForCurrentQuestion()
        }
    }
    
    private func updateUIForCurrentQuestion() {
        guard !questions.isEmpty else { return }
        let question = questions[currentQuestionIndex]
        questionLabel.text = question.questionText
        currentQuestionLabel.text = "\(currentQuestionIndex + 1)/\(questions.count)"
        
        // Update options for the current question
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, option) in question.options.enumerated() {
            let optionView = createOptionStackView(label: "\(index + 1)", description: option)
            optionView.tag = index
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
            optionView.addGestureRecognizer(tapGesture)
            optionsStackView.addArrangedSubview(optionView)
            
            // Highlight the selected option with grey background, if any
            if let selectedOption = question.selectedOption, selectedOption == index {
                optionView.backgroundColor = UIColor(red: 218/255.0, green: 218/255.0, blue: 218/255.0, alpha: 1.0)
            } else {
                optionView.backgroundColor = UIColor.white
            }
        }
        
        // Update the markForReviewCheckbox based on the current question's state
        markForReviewCheckbox.isSelected = question.isMarkedForReview
        updateMarkForReviewCheckboxAppearance()
        
        // Show/hide buttons based on the current question index
        if currentQuestionIndex == 0 {
            previousButton.isHidden = true
            nextButton.isHidden = false
            endQuizButton.isHidden = true
        } else if currentQuestionIndex == questions.count - 1 {
            previousButton.isHidden = false
            nextButton.isHidden = true
            endQuizButton.isHidden = false
        } else {
            previousButton.isHidden = false
            nextButton.isHidden = false
            endQuizButton.isHidden = true
        }
    }

    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func setupSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["TIMING", "TIME PENDING"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.isUserInteractionEnabled = false
        contentView.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            segmentedControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        ])
    }
    
    private func setupCurrentQuestionLabel() {
        currentQuestionLabel = UILabel()
        currentQuestionLabel.translatesAutoresizingMaskIntoConstraints = false
        currentQuestionLabel.textAlignment = .left
        currentQuestionLabel.font = UIFont(name: "Inter-Regular", size: 12)
        contentView.addSubview(currentQuestionLabel)
        
        NSLayoutConstraint.activate([
            currentQuestionLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            currentQuestionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }
    
    private func setupQuestionLabel() {
        questionLabel = UILabel()
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .left
        questionLabel.font = UIFont(name: "Inter-SemiBold", size: 14)
        contentView.addSubview(questionLabel)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: currentQuestionLabel.bottomAnchor, constant: 10),
            questionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    private func setupInstructionLabel() {
        instructionLabel = UILabel()
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        instructionLabel.textColor = .gray
        instructionLabel.text = "Select an option"
        instructionLabel.textAlignment = .left
        contentView.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        
        // Use UIButton.Configuration for more control over the button's appearance
        var config = UIButton.Configuration.plain()
        config.title = " Mark for review"
        config.image = UIImage(systemName: "square")
        config.imagePadding = 5
        config.baseForegroundColor = .gray
        config.background.backgroundColor = .clear
        
        markForReviewCheckbox = UIButton(configuration: config, primaryAction: nil)
        markForReviewCheckbox.addTarget(self, action: #selector(markForReviewTapped), for: .touchUpInside)
        markForReviewCheckbox.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(markForReviewCheckbox)
        
        NSLayoutConstraint.activate([
            markForReviewCheckbox.centerYAnchor.constraint(equalTo: instructionLabel.centerYAnchor),
            markForReviewCheckbox.leadingAnchor.constraint(equalTo: instructionLabel.trailingAnchor, constant: 10),
            markForReviewCheckbox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    @objc private func markForReviewTapped() {
        // Toggle the isMarkedForReview state of the current question
        questions[currentQuestionIndex].isMarkedForReview.toggle()
        
        // Update the appearance of the markForReviewCheckbox based on the new state
        updateMarkForReviewCheckboxAppearance()
    }

    private func updateMarkForReviewCheckboxAppearance() {
        // Set the checkbox image based on the isMarkedForReview state of the current question
        let imageName = questions[currentQuestionIndex].isMarkedForReview ? "checkmark.square.fill" : "square"
        markForReviewCheckbox.setImage(UIImage(systemName: imageName), for: .normal)
    }

    private func setupOptionsStackView() {
        optionsStackView = UIStackView()
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.axis = .vertical
        optionsStackView.distribution = .fillProportionally
        optionsStackView.spacing = 20
        contentView.addSubview(optionsStackView)
        
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            optionsStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupNavigationButtons() {
        previousButton = UIButton(type: .system)
        previousButton.setTitle("Previous", for: .normal)
        previousButton.setTitleColor(.darkGray, for: .normal)
        previousButton.layer.borderWidth = 1.0
        previousButton.layer.borderColor = UIColor.darkGray.cgColor
        previousButton.layer.cornerRadius = 10
        previousButton.backgroundColor = .white
        previousButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        
        nextButton = UIButton(type: .system)
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = .darkGray
        nextButton.layer.cornerRadius = 10
        nextButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        endQuizButton = UIButton(type: .system)
        endQuizButton.setTitle("End Quiz", for: .normal)
        endQuizButton.setTitleColor(.white, for: .normal)
        endQuizButton.backgroundColor = .red
        endQuizButton.layer.cornerRadius = 10
        endQuizButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        endQuizButton.translatesAutoresizingMaskIntoConstraints = false
        endQuizButton.isHidden = true
        endQuizButton.addTarget(self, action: #selector(endQuizButtonTapped), for: .touchUpInside)
        
        let buttonStackView = UIStackView(arrangedSubviews: [previousButton, nextButton, endQuizButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func previousButtonTapped() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            updateUIForCurrentQuestion()
        }
    }
    
    @objc private func nextButtonTapped() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            updateUIForCurrentQuestion()
        }
    }
    
    @objc private func endQuizButtonTapped() {
        let alertController = UIAlertController(title: "End Quiz",
                                                message: "Are you sure you would like to end this quiz right now?",
                                                preferredStyle: .alert)
        
        alertController.overrideUserInterfaceStyle = .light
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
            self.finishQuiz()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func finishQuiz() {
        // Calculate the counts
        let answeredCount = questions.filter { $0.isAnswered }.count
        let markedCount = questions.filter { $0.isMarkedForReview }.count
        let unansweredCount = questions.count - answeredCount
        
        // Calculate correct and wrong answers
        var correctAnswers = 0
        var wrongAnswers = 0
        
        for question in questions {
            if question.isAnswered {
                if question.isAnswerCorrect() {
                    correctAnswers += 1
                } else {
                    wrongAnswers += 1
                }
            }
        }
        
        let marksForCorrect = correctAnswers * 4
        let marksDeductedForWrong = wrongAnswers * 1
        let grandTotal = marksForCorrect - marksDeductedForWrong
        let totalMarksYouCanGet = questions.count * 4

        // Create an instance of ResultGTViewController
        let resultVC = ResultGTViewController()
        
        // Pass the data to the result view controller
        resultVC.answeredCount = answeredCount
        resultVC.markedCount = markedCount
        resultVC.unansweredCount = unansweredCount
        resultVC.examName = examTitle ?? "Unknown Exam"
        resultVC.totalQuestions = questions.count
        resultVC.correctAnswers = correctAnswers
        resultVC.wrongAnswers = wrongAnswers
        resultVC.marksForCorrect = marksForCorrect
        resultVC.marksDeductedForWrong = marksDeductedForWrong
        resultVC.grandTotal = grandTotal
        resultVC.totalMarksYouCanGet = totalMarksYouCanGet
        
        // Clear the back button title of the current view controller
        self.navigationItem.backButtonTitle = ""
        
        // Navigate to the result view controller
        self.navigationController?.pushViewController(resultVC, animated: true)
    }

    @objc private func optionTapped(_ sender: UITapGestureRecognizer) {
        guard let viewTapped = sender.view else { return }
        
        let currentQuestion = questions[currentQuestionIndex]
        
        if currentQuestion.selectedOption == viewTapped.tag {
            // If the tapped option is already selected, unselect it
            questions[currentQuestionIndex].selectedOption = nil
        } else {
            // If it's a new selection, update the selected option
            questions[currentQuestionIndex].selectedOption = viewTapped.tag
        }
        
        updateUIForCurrentQuestion()
    }

    private func createOptionStackView(label: String, description: String) -> UIStackView {
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.distribution = .fill
        horizontalStackView.spacing = 10
        horizontalStackView.layoutMargins = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        horizontalStackView.isLayoutMarginsRelativeArrangement = true
        horizontalStackView.layer.borderColor = UIColor.lightGray.cgColor
        horizontalStackView.layer.borderWidth = 1.0
        horizontalStackView.layer.cornerRadius = 10
        horizontalStackView.backgroundColor = UIColor.white
        horizontalStackView.layer.shadowColor = UIColor.black.cgColor
        horizontalStackView.layer.shadowOpacity = 0.1
        horizontalStackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        horizontalStackView.layer.shadowRadius = 4
        horizontalStackView.layer.masksToBounds = false
        
        let prefixLabel = UILabel()
        prefixLabel.text = label + "."
        prefixLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        prefixLabel.widthAnchor.constraint(equalToConstant: 28).isActive = true
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        let feedbackLabel = UILabel()
        feedbackLabel.font = UIFont.systemFont(ofSize: 14)
        feedbackLabel.textAlignment = .right
        feedbackLabel.textColor = .clear
        feedbackLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        horizontalStackView.addArrangedSubview(prefixLabel)
        horizontalStackView.addArrangedSubview(descriptionLabel)
        horizontalStackView.addArrangedSubview(feedbackLabel)
        
        return horizontalStackView
    }
}
