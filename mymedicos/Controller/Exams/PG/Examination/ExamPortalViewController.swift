import UIKit
import FirebaseAuth
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
    
    func isAnswerCorrect() -> Bool {
        guard let selectedOption = selectedOption else { return false }
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
    
    private var questionImageView: UIImageView!
    private var questionImageViewHeightConstraint: NSLayoutConstraint!
    
    private var correctAnswersCount: Int = 0
    private var wrongAnswersCount: Int = 0
    
    private var quizStartTime: Date?
    
    var examTitle: String?
    var examID: String?
    
    private var timer: Timer?
    private var totalTime: Int = 210 * 60
    private var timeRemaining: Int = 210 * 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.title = examTitle ?? "Exam Question"
        setupMenuButton()
        fetchQuestions()
        startTimer()
        setupQuestionImageView()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupScrollView()
        setupSegmentedControl()
        setupCurrentQuestionLabel()
        setupQuestionLabel()
        setupInstructionLabel()
        setupQuestionImageView()
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
           
           present(questionNavigatorVC, animated: false) {
               let topMargin: CGFloat = 160
               questionNavigatorVC.view.frame = CGRect(x: 0, y: topMargin, width: self.view.frame.width, height: self.view.frame.height - topMargin)
           }
           
           menuButton.isEnabled = false
           menuButton.tintColor = .clear
       }

    func closeQuestionNavigator() {
        menuButton.isEnabled = true
        menuButton.tintColor = nil
    }
    
    private func presentQuestionNavigator() {
        let questionNavigatorVC = QuestionNavigatorViewController(questions: questions, delegate: self)
        questionNavigatorVC.modalPresentationStyle = .overFullScreen
        questionNavigatorVC.modalTransitionStyle = .crossDissolve
        
        present(questionNavigatorVC, animated: false) {
            let topMargin: CGFloat = 100
            questionNavigatorVC.view.frame = CGRect(x: 0, y: topMargin, width: self.view.frame.width, height: self.view.frame.height - topMargin)
        }
        
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
        let documentRef = db.collection("PGupload").document("CWT").collection("Quiz").document(examID)
        
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

        // Adjust image view and options layout based on the presence of an image
        if question.imageUrl == "https://res.cloudinary.com/dmzp6notl/image/upload/v1711436528/noimage_qtiaxj.jpg" || question.imageUrl.lowercased() == "noimage" {
            questionImageView.isHidden = true
            questionImageViewHeightConstraint.constant = 0
            // Clear previous options before setting up new stack view
            optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            setupOptions2StackView()  // Use alternative layout when no image
        } else {
            questionImageView.isHidden = false
            questionImageViewHeightConstraint.constant = 200
            loadImage(from: URL(string: question.imageUrl)!) { [weak self] image in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    if strongSelf.questions[strongSelf.currentQuestionIndex].imageUrl == question.imageUrl {
                        strongSelf.questionImageView.image = image
                    } else {
                        // Load a default placeholder image if the image is not available
                        strongSelf.questionImageView.image = UIImage(named: "defaultPlaceholder")
                    }
                }
            }
            // Clear previous options before setting up new stack view
            optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            setupOptionsStackView()  // Use the regular layout when there is an image
        }

        contentView.layoutIfNeeded()

        // Update mark for review checkbox appearance
        markForReviewCheckbox.isSelected = question.isMarkedForReview
        updateMarkForReviewCheckboxAppearance()

        // Adding options to the stack view for the current question
        for (index, option) in question.options.enumerated() {
            let optionView = createOptionStackView(label: "\(index + 1)", description: option)
            optionView.tag = index
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
            optionView.addGestureRecognizer(tapGesture)
            optionsStackView.addArrangedSubview(optionView)

            if let selectedOption = question.selectedOption, selectedOption == index {
                optionView.backgroundColor = UIColor(red: 218/255.0, green: 218/255.0, blue: 218/255.0, alpha: 1.0)
            } else {
                optionView.backgroundColor = UIColor.white
            }
        }

        // Adjust navigation buttons visibility
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


    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    

    private func setupScrollView() {
        scrollView = UIScrollView()
         scrollView.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(scrollView)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
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
    
    private func setupQuestionImageView() {
            questionImageView = UIImageView()
            questionImageView.translatesAutoresizingMaskIntoConstraints = false
            questionImageView.contentMode = .scaleAspectFit
            contentView.addSubview(questionImageView)

            questionImageViewHeightConstraint = questionImageView.heightAnchor.constraint(equalToConstant: 200)
            
            NSLayoutConstraint.activate([
                questionImageView.topAnchor.constraint(equalTo: markForReviewCheckbox.bottomAnchor, constant: 20),
                questionImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                questionImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
                questionImageViewHeightConstraint
            ])
        }
    
    
    @objc private func imageTapped() {
        
        guard let image = questionImageView.image else { return }
        let imagePopupVC = ImagePopupViewController()
        imagePopupVC.modalPresentationStyle = .overFullScreen
        imagePopupVC.image = image
        present(imagePopupVC, animated: true, completion: nil)
        
    }
    

    @objc private func markForReviewTapped() {
        
        questions[currentQuestionIndex].isMarkedForReview.toggle()
        updateMarkForReviewCheckboxAppearance()
        
    }

    private func updateMarkForReviewCheckboxAppearance() {
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
            optionsStackView.topAnchor.constraint(equalTo: questionImageView.bottomAnchor, constant: 20),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            optionsStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -100)
        ])
    }
    
    private func setupOptions2StackView() {
        optionsStackView = UIStackView()
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.axis = .vertical
        optionsStackView.distribution = .fillProportionally
        optionsStackView.spacing = 20
        contentView.addSubview(optionsStackView)
        
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: markForReviewCheckbox.bottomAnchor, constant: 20),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            optionsStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -100)
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
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
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
        let endTime = Date()
        let timeTaken = endTime.timeIntervalSince(quizStartTime ?? endTime)
        let averageTimePerQuestion = timeTaken / Double(questions.count)
        let successRate = Double(correctAnswersCount) / Double(questions.count) * 100
        // Determine comment based on time and accuracy
        let timeThreshold = 60.0  // Example threshold in seconds
        let highAccuracyThreshold = 80.0
        let lowAccuracyThreshold = 50.0
        var comment = "Well done!"

        if timeTaken < timeThreshold && successRate >= highAccuracyThreshold {
            comment = "Excellent speed and accuracy!"
        } else if timeTaken > timeThreshold && successRate < lowAccuracyThreshold {
            comment = "Needs improvement in both speed and accuracy."
        } else if timeTaken < timeThreshold {
            comment = "Great speed, but consider improving accuracy."
        } else if successRate >= highAccuracyThreshold {
            comment = "High accuracy, try to increase your speed next time."
        } else {
            comment = "Good effort, keep practicing!"
        }

        // Calculate the final scores based on answers
        let answeredCount = questions.filter { $0.isAnswered }.count
        let markedCount = questions.filter { $0.isMarkedForReview }.count
        let unansweredCount = questions.count - answeredCount

        guard let user = Auth.auth().currentUser, let phoneNumber = user.phoneNumber else {
            print("User is not logged in or phone number is unavailable")
            return
        }

        let results: [String: Any] = [
            "Total Questions": questions.count,
            "Correct Answers": correctAnswersCount,
            "Wrong Answers": wrongAnswersCount,
            "Marked for Review": markedCount,
            "Unanswered": unansweredCount,
            "Quiz ID": examID ?? "Unknown ID",
            "Time of Submission": FieldValue.serverTimestamp(),
            "Total Marks Obtained": (correctAnswersCount * 4) - (wrongAnswersCount * 1),
            "Time Taken (seconds)": timeTaken,
            "Average Time Per Question (seconds)": averageTimePerQuestion,
            "Success Rate (%)": successRate,
            "Comment": comment  // Save the personalized comment
        ]

        let db = Firestore.firestore()
        let resultsRef = db.collection("QuizResults").document(phoneNumber)
                                .collection("Weekley").document(examID ?? "Unknown Exam")

        resultsRef.setData(results) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
                self.navigateToResultsScreen()
            }
        }
    }

    @objc private func optionTapped(_ sender: UITapGestureRecognizer) {
        guard let viewTapped = sender.view else { return }

        var currentQuestion = questions[currentQuestionIndex]
        let previousOption = currentQuestion.selectedOption

        // Update the selected option
        currentQuestion.selectedOption = viewTapped.tag

        // Update correct and wrong counts based on the new selection
        if previousOption != nil {
            // There was a previous selection, adjust counts
            if currentQuestion.isAnswerCorrect() && previousOption != currentQuestion.selectedOption {
                // Changed to a correct answer
                correctAnswersCount += 1
                if !questions[previousOption!].isAnswerCorrect() {
                    wrongAnswersCount -= 1
                }
            } else if !currentQuestion.isAnswerCorrect() && previousOption != currentQuestion.selectedOption {
                // Changed to a wrong answer
                wrongAnswersCount += 1
                if questions[previousOption!].isAnswerCorrect() {
                    correctAnswersCount -= 1
                }
            }
        } else {
            // No previous selection, just update based on current selection
            if currentQuestion.isAnswerCorrect() {
                correctAnswersCount += 1
            } else {
                wrongAnswersCount += 1
            }
        }

        // Update the question in the list
        questions[currentQuestionIndex] = currentQuestion

        // Refresh the UI
        updateUIForCurrentQuestion()
    }


    
    private func navigateToResultsScreen() {
        let resultVC = ResultGTViewController()
        let endTime = Date()
        let timeTaken = quizStartTime.map { endTime.timeIntervalSince($0) } ?? 0
        
        let averageTimePerQuestion = timeTaken / Double(questions.count)
        let successRate = Double(correctAnswersCount) / Double(questions.count) * 100
        let totalMarksObtained = (correctAnswersCount * 4) - (wrongAnswersCount * 1)
        let comment = determineComment(timeTaken: timeTaken, successRate: successRate)
        let formattedSubmissionDate = DateFormatter.localizedString(from: endTime, dateStyle: .medium, timeStyle: .short)
        
        resultVC.examName = examTitle ?? "Unknown Exam"
        resultVC.totalQuestions = questions.count
        resultVC.correctAnswers = correctAnswersCount
        resultVC.wrongAnswers = wrongAnswersCount
        resultVC.unansweredCount = questions.count - (correctAnswersCount + wrongAnswersCount)
        resultVC.markedCount = questions.filter { $0.isMarkedForReview }.count
        resultVC.averageTimePerQuestion = averageTimePerQuestion
        resultVC.successRate = successRate
        resultVC.totaltimetaken = timeTaken
        resultVC.comment = comment
        resultVC.submissionDate = formattedSubmissionDate
        
        navigationController?.pushViewController(resultVC, animated: true)
    }

    private func determineComment(timeTaken: Double, successRate: Double) -> String {
        let timeThreshold = 60.0  // seconds
        let highAccuracyThreshold = 80.0
        let lowAccuracyThreshold = 50.0
        
        switch (timeTaken < timeThreshold, successRate) {
        case (true, let rate) where rate >= highAccuracyThreshold:
            return "Excellent speed and accuracy!"
        case (false, let rate) where rate < lowAccuracyThreshold:
            return "Needs improvement in both speed and accuracy."
        case (true, _):
            return "Great speed, but consider improving accuracy."
        case (_, let rate) where rate >= highAccuracyThreshold:
            return "High accuracy, try to increase your speed next time."
        default:
            return "Good effort, keep practicing!"
        }
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
