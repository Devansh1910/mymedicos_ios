import UIKit
import FirebaseFirestore

struct QuestionPrep {
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

class PreparationPortalViewController: UIViewController, QuestionNavigatorDelegate {
    
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
    private var currentQuestionLabel: UILabel!
    private var questionLabel: UILabel!
    private var instructionLabel: UILabel!
    private var optionsStackView: UIStackView!
    private var descriptionLabel: UILabel!
    private var previousButton: UIButton!
    private var nextButton: UIButton!
    private var endQuizButton: UIButton!
    private var markForReviewCheckbox: UIButton!
    
    private var questions: [QuestionPrep] = []
    private var currentQuestionIndex: Int = 0
    
    private var menuButton: UIBarButtonItem!
    private var isQuestionNavigatorVisible = false
    
    var examTitle: String?
    var examID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.title = examTitle ?? "Exam Question"
        setupMenuButton()
        fetchQuestions()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupScrollView()
        setupCurrentQuestionLabel()
        setupQuestionLabel()
        setupInstructionLabel()
        setupOptionsStackView()
        setupDescriptionLabel()
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
        let prepquestionNavigatorVC = PreparationQuestionNavigatorViewController(questions: questions, delegate: self)
        prepquestionNavigatorVC.modalPresentationStyle = .overFullScreen
        prepquestionNavigatorVC.modalTransitionStyle = .crossDissolve
        
        present(prepquestionNavigatorVC, animated: false) {
            let topMargin: CGFloat = 160
            prepquestionNavigatorVC.view.frame = CGRect(x: 0, y: topMargin, width: self.view.frame.width, height: self.view.frame.height - topMargin)
        }
        
        menuButton.isEnabled = false
        menuButton.tintColor = .clear
    }

    func closeQuestionNavigator() {
        menuButton.isEnabled = true
        menuButton.tintColor = nil
    }
    
    func dismissQuestionNavigator() {
        self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "line.horizontal.3")
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
                
                return QuestionPrep(
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
    
    private func setupCurrentQuestionLabel() {
        currentQuestionLabel = UILabel()
        currentQuestionLabel.translatesAutoresizingMaskIntoConstraints = false
        currentQuestionLabel.textAlignment = .left
        currentQuestionLabel.font = UIFont(name: "Inter-Regular", size: 12)
        contentView.addSubview(currentQuestionLabel)
        
        NSLayoutConstraint.activate([
            currentQuestionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
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
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    private func setupDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.isHidden = true
        contentView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func markForReviewTapped() {
        questions[currentQuestionIndex].isMarkedForReview.toggle()
        updateMarkForReviewCheckboxAppearance()
    }

    private func updateMarkForReviewCheckboxAppearance() {
        let imageName = questions[currentQuestionIndex].isMarkedForReview ? "checkmark.square.fill" : "square"
        markForReviewCheckbox.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func displayDescription(for question: QuestionPrep) {
        if let selectedOptionIndex = question.selectedOption {
            if let attributedString = convertHTMLToAttributedString(html: question.description) {
                descriptionLabel.attributedText = attributedString
            } else {
                descriptionLabel.text = question.description
            }
            descriptionLabel.isHidden = false
        }
    }

    private func updateUIForCurrentQuestion() {
        guard !questions.isEmpty else { return }
        let question = questions[currentQuestionIndex]

        questionLabel.text = question.questionText
        currentQuestionLabel.text = "\(currentQuestionIndex + 1)/\(questions.count)"

        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        descriptionLabel.isHidden = true
        descriptionLabel.text = ""

        for (index, option) in question.options.enumerated() {
            let optionView = createOptionStackView(label: "\(index + 1)", description: option)
            optionView.tag = index
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
            optionView.addGestureRecognizer(tapGesture)
            optionsStackView.addArrangedSubview(optionView)

            if let selectedOption = question.selectedOption {
                if selectedOption == index {
                    let iconView = optionView.arrangedSubviews[0] as! UIImageView
                    iconView.image = UIImage(systemName: question.isAnswerCorrect() ? "checkmark.circle.fill" : "xmark.circle.fill")
                    iconView.tintColor = question.isAnswerCorrect() ? .green : .red
                    optionView.layer.borderColor = question.isAnswerCorrect() ? UIColor.green.cgColor : UIColor.red.cgColor
                    optionView.layer.borderWidth = 2.0
                } else if index == correctAnswerIndex(for: question.correctAnswer) {
                    let iconView = optionView.arrangedSubviews[0] as! UIImageView
                    iconView.image = UIImage(systemName: "checkmark.circle.fill")
                    iconView.tintColor = .green
                    optionView.layer.borderColor = UIColor.green.cgColor
                    optionView.layer.borderWidth = 2.0
                }
            }
        }

        if let selectedOption = question.selectedOption {
            displayDescription(for: question)
        }

        previousButton.isHidden = currentQuestionIndex == 0
        nextButton.isHidden = currentQuestionIndex == questions.count - 1
        endQuizButton.isHidden = currentQuestionIndex != questions.count - 1
    }

    @objc private func optionTapped(_ sender: UITapGestureRecognizer) {
        guard let viewTapped = sender.view else { return }
        let index = viewTapped.tag

        let currentQuestion = questions[currentQuestionIndex]

        if currentQuestion.selectedOption == nil {
            questions[currentQuestionIndex].selectedOption = index
            updateUIForCurrentQuestion()
        }
    }

    private func convertHTMLToAttributedString(html: String) -> NSAttributedString? {
        let modifiedFont = """
        <style>
            body, h1, h2, h3, h4, h5, h6, p, div {
                font-family: 'Inter-SemiBold', 'HelveticaNeue';
                font-size: 16px;
                color: #242424;
            }
        </style>
        <div>\(html)</div>
        """
        
        guard let data = modifiedFont.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil)
        } catch {
            print("Error converting HTML to NSAttributedString: \(error)")
            return nil
        }
    }

    private func correctAnswerIndex(for correctAnswer: String) -> Int? {
        switch correctAnswer {
        case "A": return 0
        case "B": return 1
        case "C": return 2
        case "D": return 3
        default: return nil
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
        
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        iconView.image = nil  // Start with no icon, will be set later if needed
        
        let prefixLabel = UILabel()
        prefixLabel.text = label + "."
        prefixLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        prefixLabel.widthAnchor.constraint(equalToConstant: 28).isActive = true
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        horizontalStackView.addArrangedSubview(iconView)
        horizontalStackView.addArrangedSubview(prefixLabel)
        horizontalStackView.addArrangedSubview(descriptionLabel)
        
        return horizontalStackView
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
        let answeredCount = questions.filter { $0.isAnswered }.count
        let markedCount = questions.filter { $0.isMarkedForReview }.count
        let unansweredCount = questions.count - answeredCount
        
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

        let resultVC = ResultGTViewController()
        
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
        
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.pushViewController(resultVC, animated: true)
    }
}
