import UIKit
import FirebaseAuth
import FirebaseFirestore
import SkeletonView

struct QuestionPrep {
    var questionText: String
    var options: [String]
    var correctAnswer: String
    var description: String
    var imageUrl: String
    var questionNumber: Int
    var selectedOption: Int?
    var isMarkedForReview: Bool = false
    var hasBeenCorrectlyAnswered: Bool = false
    var isAnswered: Bool {
        return selectedOption != nil
    }
    
    mutating func isAnswerCorrect() -> Bool {
            guard let selectedOption = selectedOption else {
                print("No option selected")
                return false
            }
            let selectedOptionLetter = ["A", "B", "C", "D"][selectedOption]
            print("Selected Option: \(selectedOptionLetter), Correct Answer: \(correctAnswer)")
            return selectedOptionLetter == correctAnswer
        }

}

class PreparationPortalViewController: UIViewController, QuestionNavigatorDelegate, UIViewControllerTransitioningDelegate {
    
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
    
    private var questionImageView: UIImageView!
    private var questionImageViewHeightConstraint: NSLayoutConstraint!

    private var instructionLabel: UILabel!
    private var optionsStackView: UIStackView!
    private var descriptionLabel: UILabel!
    private var previousButton: UIButton!
    private var nextButton: UIButton!
    private var endQuizButton: UIButton!
    private var markForReviewCheckbox: UIButton!
    
    private var questions: [QuestionPrep] = []
    var currentQuestionIndex: Int = 0
    
    private var menuButton: UIBarButtonItem!
    private var isQuestionNavigatorVisible = false
    
    var examTitle: String?
    var examID: String?
    
    private var correctAnswersCount: Int = 0
    private var wrongAnswersCount: Int = 0
    
    private var quizStartTime: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.title = examTitle ?? "Exam Question"
        setupMenuButton()
        
        startShimmeringEffect()
        setupCustomNavigationBar()
        
        fetchQuestions()
        quizStartTime = Date()  // Record the start time
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupScrollView()
        setupCurrentQuestionLabel()
        setupQuestionLabel()
        setupInstructionLabel()
        
        setupQuestionImageView()
        setupOptionsStackView()
        setupDescriptionLabel()
        setupNavigationButtons()
    }
    
    private func startShimmeringEffect() {
        questionLabel.showAnimatedSkeleton()
        questionImageView.showAnimatedSkeleton()
        optionsStackView.showAnimatedSkeleton()
        descriptionLabel.showAnimatedSkeleton()
        previousButton.showAnimatedSkeleton()
        nextButton.showAnimatedSkeleton()
        endQuizButton.showAnimatedSkeleton()
    }

    private func stopShimmeringEffect() {
        questionLabel.hideSkeleton()
        questionImageView.hideSkeleton()
        optionsStackView.hideSkeleton()
        descriptionLabel.hideSkeleton()
        previousButton.hideSkeleton()
        nextButton.hideSkeleton()
        endQuizButton.hideSkeleton()
    }


    private func setupInstructionLabel() {
        instructionLabel = UILabel()
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        instructionLabel.textColor = .gray
        instructionLabel.text = "Select an option"
        instructionLabel.textAlignment = .left
        contentView.addSubview(instructionLabel)
        
        markForReviewCheckbox = UIButton(type: .system)
        markForReviewCheckbox.setTitle(" Mark for review", for: .normal)
        markForReviewCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
        markForReviewCheckbox.tintColor = .gray
        markForReviewCheckbox.addTarget(self, action: #selector(markForReviewTapped), for: .touchUpInside)
        markForReviewCheckbox.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(markForReviewCheckbox)
        
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            markForReviewCheckbox.centerYAnchor.constraint(equalTo: instructionLabel.centerYAnchor),
            markForReviewCheckbox.leadingAnchor.constraint(equalTo: instructionLabel.trailingAnchor, constant: 10),
            markForReviewCheckbox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupCustomNavigationBar() {
        let pauseButton = UIBarButtonItem(image: UIImage(systemName: "pause.circle"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(pauseButtonTapped))
        
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(menuButtonTapped))
        
        self.navigationItem.rightBarButtonItem = menuButton
        
        self.navigationItem.leftBarButtonItem = pauseButton
    }


    @objc private func imageTapped() {
        guard let image = questionImageView.image else { return }
        
        let imagePopupVC = ImagePopupViewController()
        imagePopupVC.modalPresentationStyle = .overFullScreen
        imagePopupVC.image = image
        present(imagePopupVC, animated: true, completion: nil)
    }
    
    private func setupMenuButton() {
        menuButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(menuButtonTapped))
        self.navigationItem.rightBarButtonItem = menuButton
    }
    
    @objc private func pauseButtonTapped() {
        let pauseVC = PauseBottomSheetViewController()
        
        // Set up the pause action callback
        pauseVC.onPause = { [weak self] in
            // Pop the current view controller to navigate back to the previous screen
            self?.navigationController?.popViewController(animated: true)
        }
        
        pauseVC.modalPresentationStyle = .custom
        pauseVC.transitioningDelegate = self  // Set the custom presentation delegate
        
        present(pauseVC, animated: true, completion: nil)
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
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
        guard let examID = examID, let user = Auth.auth().currentUser else { return }
        let phoneNumber = user.phoneNumber ?? ""
        let db = Firestore.firestore()
        let documentRef = db.collection("PGupload").document("Weekley").collection("Quiz").document(examID)
        
        documentRef.getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching questions: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, let dataArray = document.data()?["Data"] as? [[String: Any]] else {
                print("Document does not exist or data format is incorrect")
                return
            }
            
            self?.questions = dataArray.compactMap { data in
                guard let questionText = data["Question"] as? String,
                      let optionA = data["A"] as? String,
                      let optionB = data["B"] as? String,
                      let optionC = data["C"] as? String,
                      let optionD = data["D"] as? String,
                      let correctAnswer = data["Correct"] as? String,
                      let description = data["Description"] as? String,
                      let imageUrl = data["Image"] as? String,
                      let questionNumber = data["number"] as? Int else {
                    print("Error in data fields")
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
            
            // Fetch the saved progress for this exam
            self?.fetchSavedProgress(for: examID, phoneNumber: phoneNumber)
            
            // Stop the shimmer effect once data is loaded
            self?.stopShimmeringEffect()
        }
    }


    private func fetchSavedProgress(for examID: String, phoneNumber: String) {
        let db = Firestore.firestore()
        let documentRef = db.collection("QuizProgress").document(phoneNumber).collection("pgneet").document(examID)
        
        documentRef.getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching progress: \(error.localizedDescription)")
                return
            }
            
            // If the document doesn't exist or doesn't contain progress data
            guard let document = document, document.exists, let progressMap = document.data()?["progress"] as? [String: String] else {
                print("No progress found or data format is incorrect. Navigating to the 0th index.")
                
                // Navigate to the 0th index by default
                self?.currentQuestionIndex = 0
                self?.updateUIForCurrentQuestion()
                return
            }
            
            // Update questions with saved progress
            for (indexString, selectedOptionLetter) in progressMap {
                if let index = Int(indexString), index < self?.questions.count ?? 0 {
                    let selectedOptionIndex = self?.letterToOptionIndex(selectedOptionLetter)
                    self?.questions[index].selectedOption = selectedOptionIndex
                }
            }
            
            // Navigate to the last attempted question, or 0th index if no valid index is found
            if let currentIndex = document.data()?["current"] as? Int, currentIndex < self?.questions.count ?? 0 {
                self?.currentQuestionIndex = currentIndex
            } else {
                self?.currentQuestionIndex = 0
            }
            
            // Update the UI for the current question
            self?.updateUIForCurrentQuestion()
        }
    }


    private func letterToOptionIndex(_ letter: String) -> Int? {
        switch letter {
        case "A": return 0
        case "B": return 1
        case "C": return 2
        case "D": return 3
        default: return nil
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
    
    
    private func setupQuestionImageView() {
        questionImageView = UIImageView()
        questionImageView.translatesAutoresizingMaskIntoConstraints = false
        questionImageView.contentMode = .scaleAspectFit
        questionImageView.isUserInteractionEnabled = true  // Enable interaction
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        questionImageView.addGestureRecognizer(tapGesture)
        
        contentView.addSubview(questionImageView)
        
        questionImageViewHeightConstraint = questionImageView.heightAnchor.constraint(equalToConstant: 200)
        
        NSLayoutConstraint.deactivate(questionImageView.constraints)
        NSLayoutConstraint.activate([
            questionImageView.topAnchor.constraint(equalTo: markForReviewCheckbox.bottomAnchor, constant: 20),
            questionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            questionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            questionImageViewHeightConstraint
        ])
    }

    private func setupOptionsStackView() {
        optionsStackView = UIStackView()
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.axis = .vertical
        optionsStackView.distribution = .fillProportionally
        optionsStackView.spacing = 20
        contentView.addSubview(optionsStackView)
        
        NSLayoutConstraint.deactivate(optionsStackView.constraints)
        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: questionImageView.bottomAnchor, constant: 20),
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
        let isMarked = questions[currentQuestionIndex].isMarkedForReview
        let imageName = isMarked ? "checkmark.square.fill" : "square"
        markForReviewCheckbox.setImage(UIImage(systemName: imageName), for: .normal)
        markForReviewCheckbox.tintColor = isMarked ? .systemBlue : .gray
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
        var question = questions[currentQuestionIndex]

        questionLabel.text = question.questionText
        currentQuestionLabel.text = "\(currentQuestionIndex + 1)/\(questions.count)"
        
        questionImageView.image = nil
        questionImageViewHeightConstraint.constant = 200
        questionImageView.isHidden = false

        // Check if the image URL indicates there is no image to display
        let noImageURLs = ["https://res.cloudinary.com/dmzp6notl/image/upload/v1711436528/noimage_qtiaxj.jpg", "noimage"]
        if noImageURLs.contains(question.imageUrl) {
            questionImageView.isHidden = true
            questionImageViewHeightConstraint.constant = 0
        } else {
            questionImageView.isHidden = false
            questionImageViewHeightConstraint.constant = 200
            
            if let url = URL(string: question.imageUrl) {
                // Load image using Kingfisher with a placeholder that uses SkeletonView shimmer
                questionImageView.kf.setImage(
                    with: url,
                    placeholder: nil,
                    options: nil,
                    progressBlock: nil
                ) { [weak self] result in
                    switch result {
                    case .success(_):
                        // Stop shimmering for the image view once the image is successfully loaded
                        self?.questionImageView.hideSkeleton()
                    case .failure(let error):
                        print("Error loading image: \(error.localizedDescription)")
                        // Handle error, e.g., by showing a default image or error message
                    }
                }
            }
        }

        updateMarkForReviewCheckboxAppearance()

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

        view.layoutIfNeeded()
    }



    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    @objc private func optionTapped(_ sender: UITapGestureRecognizer) {
        guard let viewTapped = sender.view else { return }
        let index = viewTapped.tag
        var currentQuestion = questions[currentQuestionIndex]

        if currentQuestion.selectedOption == nil {
            currentQuestion.selectedOption = index
            questions[currentQuestionIndex] = currentQuestion

            if currentQuestion.isAnswerCorrect() {
                correctAnswersCount += 1
                print("Correct answer selected. Total correct: \(correctAnswersCount)")
            } else {
                wrongAnswersCount += 1
                print("Wrong answer selected. Total wrong: \(wrongAnswersCount)")
            }

            // Save the selected option to Firestore
            saveSelectedOptionToFirestore(questionIndex: currentQuestionIndex, selectedOption: index)

            updateUIForCurrentQuestion()
        }
    }

    
    private func saveSelectedOptionToFirestore(questionIndex: Int, selectedOption: Int) {
        guard let user = Auth.auth().currentUser, let phoneNumber = user.phoneNumber, let examID = examID else {
            print("User is not logged in or phone number/exam ID is unavailable")
            return
        }

        let db = Firestore.firestore()
        let documentRef = db.collection("QuizProgress").document(phoneNumber)
                            .collection("pgneet").document(examID)

        // Create a map for the progress
        let selectedOptionLetter = ["A", "B", "C", "D"][selectedOption]
        let progressUpdate = ["\(questionIndex)": selectedOptionLetter]

        // Update the progress map within Firestore
        documentRef.setData(["progress": progressUpdate], merge: true) { error in
            if let error = error {
                print("Error updating selected option in Firestore: \(error.localizedDescription)")
            } else {
                print("Selected option \(selectedOptionLetter) for question \(questionIndex) saved successfully.")
            }
        }

        documentRef.setData(["current": questionIndex], merge: true)
        let sectionName = "pgneet"
        let correctCount = questions.map { var question = $0; return question.isAnswerCorrect() }.filter { $0 }.count
        let wrongCount = questions.map { var question = $0; return question.isAnswered && !question.isAnswerCorrect() }.filter { $0 }.count
        let totalScore = (correctCount * 4) - (wrongCount * 1)

        let allQuestionsAnswered = questions.allSatisfy { $0.isAnswered }

        let scoreData: [String: Any] = [
            "docID" : examID,
            "section": sectionName,
            "score": totalScore,
            "submitted": allQuestionsAnswered 
        ]

        documentRef.setData(scoreData, merge: true) { error in
            if let error = error {
                print("Error updating score and section in Firestore: \(error.localizedDescription)")
            } else {
                print("Score, section, and submission status updated successfully.")
            }
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
        let endTime = Date()
        let timeTaken = endTime.timeIntervalSince(quizStartTime ?? endTime)
        let averageTimePerQuestion = timeTaken / Double(questions.count)
        let successRate = Double(correctAnswersCount) / Double(questions.count) * 100
        
        // Determine if the quiz is fully answered and calculate the final score
        let answeredCount = questions.filter { $0.isAnswered }.count
        let markedCount = questions.filter { $0.isMarkedForReview }.count
        let unansweredCount = questions.count - answeredCount
        let correctCount = questions.map { var question = $0; return question.isAnswerCorrect() }.filter { $0 }.count
        let wrongCount = questions.map { var question = $0; return question.isAnswered && !question.isAnswerCorrect() }.filter { $0 }.count
        let totalScore = (correctCount * 4) - (wrongCount * 1)
        let isSubmitted = unansweredCount == 0

        var comment = "Well done!"
        if timeTaken < 60 && successRate >= 80 {
            comment = "Excellent speed and accuracy!"
        } else if timeTaken > 60 && successRate < 50 {
            comment = "Needs improvement in both speed and accuracy."
        } else if timeTaken < 60 {
            comment = "Great speed, but consider improving accuracy."
        } else if successRate >= 80 {
            comment = "High accuracy, try to increase your speed next time."
        } else {
            comment = "Good effort, keep practicing!"
        }
        
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
            "Total Marks Obtained": totalScore,
            "Time Taken (seconds)": timeTaken,
            "Average Time Per Question (seconds)": averageTimePerQuestion,
            "Success Rate (%)": successRate,
            "Comment": comment,
            "section": "pgneet",
            "score": totalScore,
            "submitted": isSubmitted
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
        resultVC.examId = examID ?? "Unknown Exam Id"
        
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
}
class BottomSheetPresentationController: UIPresentationController {
    
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        view.alpha = 0.0
        return view
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        dimmingView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let height: CGFloat = 250
        return CGRect(x: 0, y: containerView.bounds.height - height, width: containerView.bounds.width, height: height)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        dimmingView.frame = containerView.bounds
        containerView.addSubview(dimmingView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        }, completion: { _ in
            self.dimmingView.removeFromSuperview()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}

