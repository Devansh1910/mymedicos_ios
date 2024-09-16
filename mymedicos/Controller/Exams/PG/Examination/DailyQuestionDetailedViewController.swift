import UIKit
import Firebase

class DailyQuestionDetailedViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var segmentedControl: UISegmentedControl!
    private var questionLabel: UILabel!
    private var instructionLabel: UILabel!
    private var optionsStackView: UIStackView!
    private var correctAnswer: String?
    private var currentDescription: String?
    private var questionID: String?
    private var options: [String] = []
    private var isAnswerSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addCustomBackButton()
        self.title = "Question of the Day"
        fetchData()
        view.layoutIfNeeded()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupScrollView()
        setupSegmentedControl()
        setupQuestionLabel()
        setupInstructionLabel()
        setupOptionsStackView()
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
        segmentedControl = UISegmentedControl(items: ["QUESTION ID", "Fetching ID..."])
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
    
    private func setupQuestionLabel() {
        questionLabel = UILabel()
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .left
        questionLabel.font = UIFont(name: "Inter-SemiBold", size: 14)
        questionLabel.text = ""
        contentView.addSubview(questionLabel)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 30),
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
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
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
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            optionsStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func fetchData() {
        let db = Firestore.firestore()
        db.collection("PGupload").document("Daily").collection("Quiz")
            .whereField("speciality", isEqualTo: "home")
            .getDocuments { [weak self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    return
                }
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No documents found")
                    return
                }
                let randomDoc = documents.randomElement()!
                let data = randomDoc.data()
                DispatchQueue.main.async {
                    self?.updateUI(with: data)
                    self?.questionID = randomDoc.documentID
                    self?.updateSegmentedControl()
                }
            }
    }
    
    private func updateUI(with data: [String: Any]) {
        let question = data["Question"] as? String ?? "No question available"
        let a = data["A"] as? String ?? ""
        let b = data["B"] as? String ?? ""
        let c = data["C"] as? String ?? ""
        let d = data["D"] as? String ?? ""
        let correct = data["Correct"] as? String ?? ""
        let description = data["Description"] as? String ?? ""

        questionLabel.text = question
        correctAnswer = correct
        currentDescription = description
        options = [a, b, c, d]
        setupOptions()
    }
    
    private func setupOptions() {
        let labels = ["A", "B", "C", "D"]
        
        for view in optionsStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        for (index, option) in options.enumerated() {
            let optionView = createOptionStackView(label: labels[index], description: option)
            optionView.tag = index
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
            optionView.addGestureRecognizer(tapGesture)
            optionsStackView.addArrangedSubview(optionView)
        }
    }
    
    @objc private func optionTapped(_ sender: UITapGestureRecognizer) {
        guard !isAnswerSelected, let viewTapped = sender.view else { return }
        isAnswerSelected = true
        
        let correctIndex = correctAnswerIndex()
        
        for (index, view) in optionsStackView.arrangedSubviews.enumerated() {
            if let stackView = view as? UIStackView, let feedbackLabel = stackView.arrangedSubviews.last as? UILabel {
                stackView.layer.borderWidth = 1.0
                stackView.layer.borderColor = UIColor.clear.cgColor

                if index == correctIndex {
                    stackView.layer.borderColor = UIColor.green.cgColor
                    feedbackLabel.text = "Correct"
                    feedbackLabel.textColor = .green
                }

                if viewTapped == view {
                    if index != correctIndex {
                        stackView.layer.borderColor = UIColor.red.cgColor
                        feedbackLabel.text = "Wrong"
                        feedbackLabel.textColor = .red
                    }
                }
            }
        }

        displayDescription()
    }
    
    private func displayDescription() {
        guard let descriptionHTML = currentDescription else { return }
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.attributedText = convertHTMLToAttributedString(html: descriptionHTML)
        contentView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func correctAnswerIndex() -> Int? {
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
    
    private func updateSegmentedControl() {
        if let id = questionID {
            let shortID = "#DQ" + (id.suffix(4))  // Fetch the last four characters and prepend "PD"
            segmentedControl.setTitle(shortID, forSegmentAt: 1)  // Update the ID in the segmented control
        }
    }
    
    private func addCustomBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        if isAnswerSelected {
            showConfirmationDialog()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func showConfirmationDialog() {
        let alert = UIAlertController(title: "End this Daily?", message: "You'll not be able to see the description related to this once ended.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let endAction = UIAlertAction(title: "End", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(endAction)
        present(alert, animated: true)
    }
}
