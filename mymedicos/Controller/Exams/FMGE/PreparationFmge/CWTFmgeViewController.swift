import UIKit
import Firebase

class CWTFmgeViewController: UIViewController, UITableViewDataSource, QuizTableViewCellDelegate, BottomSheetDelegate {
    
    var specialtyTitle: String
    var segmentedControl: UISegmentedControl!
    var tableView: UITableView!
    var quizData: [(documentID: String, data: String, isBookmarked: Bool, thumbnail: String, isAttempted: Bool)] = []
    var quizDataGrouped: [String: [(documentID: String, data: String, isBookmarked: Bool, thumbnail: String, isAttempted: Bool)]] = [:]

    var activityIndicator = UIActivityIndicatorView(style: .large)

    init(title: String) {
        self.specialtyTitle = title
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        configureNavigationBar()
        configureSegmentedControl()
        configureTableView()
        setupActivityIndicator()
        fetchQuizData()
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 17, weight: .semibold)]
        navigationItem.title = specialtyTitle

        let backArrowImage = UIImage(systemName: "chevron.left")
        let backButton = UIBarButtonItem(image: backArrowImage, style: .plain, target: self, action: #selector(backButtonTapped))
        let filterImage = UIImage(systemName: "line.horizontal.3.decrease.circle")
        let filterButton = UIBarButtonItem(image: filterImage, style: .plain, target: self, action: #selector(filterButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItems = [filterButton]
    }

    private func configureSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["All", "High yield 🔥", "Bookmark"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }

    private func configureTableView() {
        tableView = UITableView()
        tableView.register(QuizTableViewCell.self, forCellReuseIdentifier: "QuizCell")
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath) as? QuizTableViewCell else {
            return UITableViewCell()
        }
        
        let keys = Array(quizDataGrouped.keys)
        guard indexPath.section < keys.count else {
            print("Section index out of range: \(indexPath.section)")
            return UITableViewCell()
        }
        
        let indexKey = keys[indexPath.section]
        if let quiz = quizDataGrouped[indexKey]?[indexPath.row] {
            cell.delegate = self
            cell.configure(with: quiz.data, examID: quiz.documentID, thumbnailURL: quiz.thumbnail, isAttempted: quiz.isAttempted)
        }
        return cell
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return quizDataGrouped.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let indexKey = Array(quizDataGrouped.keys)[section]
        return quizDataGrouped[indexKey]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let indexKey = Array(quizDataGrouped.keys)[section]
        return indexKey
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 2 {
            fetchBookmarkedQuizzes()
        } else {
            fetchQuizData()
        }
    }

    @objc func backButtonTapped() {
        if let navController = navigationController {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc func filterButtonTapped() {
        let filterVC = FilterSheetViewController()
        filterVC.configureWithIndexes(self.quizDataGrouped.mapValues { $0.count })
        filterVC.modalPresentationStyle = .overFullScreen
        filterVC.modalTransitionStyle = .coverVertical
        filterVC.applyFilter = { [weak self] selectedIndices in
            self?.highlightSelectedIndices(indices: selectedIndices)
        }
        filterVC.completionHandler = {
            NotificationCenter.default.post(name: NSNotification.Name("showTabBar"), object: nil)
        }
        present(filterVC, animated: true)
    }

    
    func highlightSelectedIndices(indices: Set<String>) {
        let sections = Array(quizDataGrouped.keys).sorted()
        print("All Sections: \(sections)")
        
        guard let firstIndex = indices.first else {
            print("No index selected.")
            return
        }

        print("Trying to find section for index: \(firstIndex)")
        
        if let sectionNumber = sections.firstIndex(of: firstIndex) {
            print("Found section \(sectionNumber) for index \(firstIndex)")
            if sectionNumber < tableView.numberOfSections {
                let indexPath = IndexPath(row: 0, section: sectionNumber)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            } else {
                print("Section number \(sectionNumber) is out of bounds.")
            }
        } else {
            print("Section index not found in available sections.")
        }
    }


    func applyFilterSelection(indices: Set<String>) {
        self.quizDataGrouped = self.quizDataGrouped.mapValues { $0.filter { indices.contains($0.documentID) } }
        self.tableView.reloadData()
    }

    func fetchQuizData() {
        guard let currentUser = Auth.auth().currentUser, let phoneNumber = currentUser.phoneNumber else {
            print("User not logged in or phone number not available")
            return
        }
        
        activityIndicator.startAnimating()
        let db = Firestore.firestore()
        let quizCollection = db.collection("Fmge").document("Weekley").collection("Quiz")
        self.quizDataGrouped = [:]

        var query: Query = quizCollection.whereField("speciality", isEqualTo: specialtyTitle)
        if segmentedControl.selectedSegmentIndex == 1 {
            
            query = query.whereField("hyOption", in: ["Premium", "Pro", "Standard"])
        }

        query.getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            if let err = err {
                print("Error getting documents: \(err)")
                return
            }

            if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                let group = DispatchGroup()
                for document in querySnapshot.documents {
                    group.enter()
                    let documentID = document.documentID
                    let title = document.data()["title"] as? String ?? "No Title"
                    let index = document.data()["index"] as? String ?? "No Index"
                    let type = document.data()["hyOption"] as? String ?? "Unknown Type"
                    let thumbnail = document.data()["thumbnail"] as? String ?? "No thumbnail"
                    let questionsData = document.data()["Data"] as? [Any] ?? []
                    let numberOfQuestions = questionsData.count
                    let documentInfo = "\(title); \(numberOfQuestions) MCQ's; \(type)"

                    db.collection("QuizResults").document(phoneNumber).collection("Weekley").document(documentID).getDocument { (resultSnapshot, error) in
                        let isAttempted = resultSnapshot?.exists ?? false
                        let quizData = (documentID: documentID, data: documentInfo, isBookmarked: false, thumbnail: thumbnail, isAttempted: isAttempted)
                        
                        if var sets = self.quizDataGrouped[index] {
                            sets.append(quizData)
                            self.quizDataGrouped[index] = sets
                        } else {
                            self.quizDataGrouped[index] = [quizData]
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    self.tableView.reloadData()
                }
            }
        }
    }


    func fetchBookmarkedQuizzes() {
        guard let currentUser = Auth.auth().currentUser, let phoneNumber = currentUser.phoneNumber else {
            print("User not logged in or phone number not available")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").whereField("Phone Number", isEqualTo: phoneNumber).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching user by phone number: \(error)")
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No user found with the phone number")
                return
            }

            let userDocument = documents.first!
            let bookmarks = userDocument.data()["Bookmarked"] as? [String] ?? []
            self.fetchQuizzesForBookmarks(bookmarkIDs: bookmarks)
        }
    }

    func fetchQuizzesForBookmarks(bookmarkIDs: [String]) {
        let db = Firestore.firestore()
        let quizCollection = db.collection("Fmge").document("Weekley").collection("Quiz")
        self.quizDataGrouped = [:]
        for id in bookmarkIDs {
            quizCollection.document(id).getDocument { (documentSnapshot, error) in
                if let error = error {
                    print("Error fetching quiz data: \(error)")
                    return
                }
                if let document = documentSnapshot, document.exists {
                    let title = document.data()?["title"] as? String ?? "No Title"
                    let index = document.data()?["index"] as? String ?? "No Index"
                    let type = document.data()?["hyOption"] as? String ?? "Unknown Type"
                    let thumbnail = document.data()?["thumbnail"] as? String ?? "No thumbnail"  // Fetch thumbnail URL
                    let questionsData = document.data()?["Data"] as? [Any] ?? []
                    let numberOfQuestions = questionsData.count
                    let documentInfo = "\(title); \(index); \(numberOfQuestions) MCQ's; \(type)"
                    let quizData = (documentID: document.documentID, data: documentInfo, isBookmarked: true, thumbnail: thumbnail, isAttempted: true)
                    if var sets = self.quizDataGrouped[index] {
                        sets.append(quizData)
                        self.quizDataGrouped[index] = sets
                    } else {
                        self.quizDataGrouped[index] = [quizData]
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func didTapSolveButton(examID: String, examTitle: String) {
        let prepInfoVC = PrepInfoFmgeViewController()
        prepInfoVC.examTitle = examTitle
        prepInfoVC.hidesBottomBarWhenPushed = true
        prepInfoVC.examID = examID
        navigationController?.pushViewController(prepInfoVC, animated: true)
    }
    
    func didTapResultButton(examID: String, examTitle: String) {
        guard let currentUser = Auth.auth().currentUser, let phoneNumber = currentUser.phoneNumber else {
            print("User not logged in or phone number not available")
            return
        }

        let db = Firestore.firestore()
        let resultsRef = db.collection("QuizResults").document(phoneNumber).collection("Weekley").document(examID)

        resultsRef.getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching results: \(error)")
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                print("No results available for this quiz.")
                return
            }

            self?.navigateToResultVC(with: data, examTitle: examTitle)
        }
    }

    private func navigateToResultVC(with data: [String: Any], examTitle: String) {
        let resultVC = ResultGTViewController()

        resultVC.examName = examTitle
        resultVC.totalQuestions = data["Total Questions"] as? Int ?? 0
        resultVC.correctAnswers = data["Correct Answers"] as? Int ?? 0
        resultVC.wrongAnswers = data["Wrong Answers"] as? Int ?? 0
        resultVC.averageTimePerQuestion = data["Average Time Per Question (seconds)"] as? Double ?? 0
        resultVC.comment = data["Comment"] as! String
        resultVC.successRate = data["Success Rate (%)"] as? Double ?? 0
        resultVC.totaltimetaken = data["Time Taken (seconds)"] as? Double ?? 0
        resultVC.unansweredCount = data["Unanswered"] as? Int ?? 0
        resultVC.markedCount = data["Marked for Review"] as? Int ?? 0
        resultVC.percentile = data["Success Rate (%)"] as? Double ?? 0.0
        resultVC.submissionDate = (data["Time of Submission"] as? Timestamp)?.dateValue().formatted(date: .abbreviated, time: .shortened) ?? "Date not available"
        resultVC.hidesBottomBarWhenPushed = true
        
        present(resultVC, animated: true, completion: nil)
    }

    
    func didTapLockedQuiz(examID: String) {
        let bottomSheetVC = BottomSheetForPaidSheetViewController()
        bottomSheetVC.delegate = self
        bottomSheetVC.examID = examID
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        bottomSheetVC.modalTransitionStyle = .coverVertical
        present(bottomSheetVC, animated: true)
    }

    func didChooseViewPlans() {
        let plansVC = PlansViewController()
        plansVC.title = "Choose a Plan"
        plansVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(plansVC, animated: true)
    }
}
