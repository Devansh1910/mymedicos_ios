import UIKit

protocol GrandTestNavigatorDelegate: AnyObject {
    func didSelectQuestion(at index: Int)
    func didDismissQuestionNavigator()
}

class GrandTestNavigatorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    private var questions: [QuestionCome]
    private var collectionView: UICollectionView!
    weak var delegate: GrandTestNavigatorDelegate?

    private var answeredLabel: UILabel!
    private var markedLabel: UILabel!
    private var unansweredLabel: UILabel!
    private var answeredCountLabel: UILabel!
    private var markedCountLabel: UILabel!
    private var unansweredCountLabel: UILabel!

    private var selectedIndex: Int? // To track the currently selected question

    init(questions: [QuestionCome], delegate: GrandTestNavigatorDelegate) {
        self.questions = questions
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateCounts()
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Setup top border view
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor.lightGray
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBorderView)

        // Setup labels and counters
        answeredLabel = createLabel(text: "Answered")
        markedLabel = createLabel(text: "In Review")
        unansweredLabel = createLabel(text: "Unanswered")

        answeredCountLabel = createCountLabel()
        markedCountLabel = createCountLabel()
        unansweredCountLabel = createCountLabel()

        // StackViews for labels and counters
        let answeredStackView = createVerticalStackView(arrangedSubviews: [answeredLabel, answeredCountLabel])
        let markedStackView = createVerticalStackView(arrangedSubviews: [markedLabel, markedCountLabel])
        let unansweredStackView = createVerticalStackView(arrangedSubviews: [unansweredLabel, unansweredCountLabel])

        // Horizontal stack view to hold all three vertical stack views
        let countsStackView = UIStackView(arrangedSubviews: [answeredStackView, markedStackView, unansweredStackView])
        countsStackView.axis = .horizontal
        countsStackView.distribution = .fillEqually
        countsStackView.spacing = 20
        countsStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(countsStackView)

        // Setup collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "QuestionCell")
        view.addSubview(collectionView)

        // Setup close button at the bottom
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = .darkGray
        closeButton.layer.cornerRadius = 10
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        // Layout constraints for top border, count labels, collection view, and close button
        NSLayoutConstraint.activate([
            topBorderView.topAnchor.constraint(equalTo: view.topAnchor),
            topBorderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBorderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBorderView.heightAnchor.constraint(equalToConstant: 0.5),

            countsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            countsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            countsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            collectionView.topAnchor.constraint(equalTo: countsStackView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20),

            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            closeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.text = text
        return label
    }

    private func createCountLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }

    private func createVerticalStackView(arrangedSubviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func updateCounts() {
        let answeredCount = questions.filter { $0.isAnswered }.count
        let markedCount = questions.filter { $0.isMarkedForReview }.count
        let unansweredCount = questions.count - answeredCount

        answeredCountLabel.text = "\(answeredCount)"
        markedCountLabel.text = "\(markedCount)"
        unansweredCountLabel.text = "\(unansweredCount)"
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuestionCell", for: indexPath)

        // Set border radius
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true

        let question = questions[indexPath.row]

        // Determine the background color based on question status
        if question.isAnswered {
            cell.backgroundColor = .lightGray // Light Gray if answered
            cell.layer.borderWidth = 0 // No border if answered
        } else if question.isMarkedForReview {
            cell.backgroundColor = .white // White if marked for review (border color will show)
            cell.layer.borderColor = UIColor.orange.cgColor
            cell.layer.borderWidth = 1.0 // Orange border if marked for review
        } else {
            cell.backgroundColor = .white // White if neither
            cell.layer.borderColor = UIColor.gray.cgColor
            cell.layer.borderWidth = 1.0 // Gray border if neither
        }

        // Add dotted border for the currently selected question
        if selectedIndex == indexPath.row {
            cell.layer.borderColor = UIColor.blue.cgColor
            cell.layer.borderWidth = 2.0
            let dottedBorder = CAShapeLayer()
            dottedBorder.strokeColor = UIColor.blue.cgColor
            dottedBorder.lineDashPattern = [4, 2]
            dottedBorder.frame = cell.bounds
            dottedBorder.fillColor = nil
            dottedBorder.path = UIBezierPath(rect: cell.bounds).cgPath
            cell.layer.addSublayer(dottedBorder)
        }

        let questionNumberLabel = UILabel()
        questionNumberLabel.text = String(format: "%d", indexPath.row + 1) // Adjust to start from 1
        questionNumberLabel.textAlignment = .center
        questionNumberLabel.font = UIFont.boldSystemFont(ofSize: 16)
        questionNumberLabel.textColor = .darkGray // Set text color to dark grey
        questionNumberLabel.translatesAutoresizingMaskIntoConstraints = false

        let statusView = UIView()
        statusView.backgroundColor = question.isMarkedForReview ? .orange : .clear
        statusView.layer.cornerRadius = 5
        statusView.translatesAutoresizingMaskIntoConstraints = false

        // Clear previous subviews (to avoid duplicate views when reusing cells)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        cell.contentView.addSubview(questionNumberLabel)
        cell.contentView.addSubview(statusView)

        NSLayoutConstraint.activate([
            questionNumberLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            questionNumberLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            statusView.heightAnchor.constraint(equalToConstant: 10),
            statusView.widthAnchor.constraint(equalToConstant: 10),
            statusView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5),
            statusView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -5)
        ])

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.reloadData() // Reload to update the border of the cells
        delegate?.didSelectQuestion(at: indexPath.row)
        dismiss(animated: true, completion: nil)
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isBeingDismissed {
            delegate?.didDismissQuestionNavigator()
        }
    }
}
