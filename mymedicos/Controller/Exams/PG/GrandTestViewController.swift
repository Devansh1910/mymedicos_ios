import UIKit
import Firebase

class GrandTestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ExamQuizLiveTableViewCellDelegate, BottomSheetDelegate, SWGTUpcomingBottomSheetDelegate {
    
    func didSetReminder(forExamID examID: String) {
        scheduleLocalNotification(forExamID: examID)
    }
    
    var titleLabel = UILabel()
    var detailLabel = UILabel()
    var noDataLabel: UILabel!
    var activityIndicator = UIActivityIndicatorView()


    func scheduleLocalNotification(forExamID examID: String) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Exam Reminder", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Don't forget to review for your upcoming exam!", arguments: nil)
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (60*60*24), repeats: false)

        let request = UNNotificationRequest(identifier: examID, content: content, trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("Error scheduling notification: \(String(describing: error))")
            }
        }
        print("Notification scheduled for examID: \(examID)")
    }
    
    func didTapSolveButton(examID: String, examTitle: String) {
        let examInfoVC = GrandTestInfoViewController()
        examInfoVC.examTitle = examTitle
        examInfoVC.examID = examID
        examInfoVC.hidesBottomBarWhenPushed = true
        present(examInfoVC, animated: true, completion: nil)


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
    
    func didTapComingSoon(examID: String) {
        let bottomSheetVC = SWGTUpcomingBottomSheetViewController()
        bottomSheetVC.examID = examID
        bottomSheetVC.delegate = self
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        bottomSheetVC.modalTransitionStyle = .coverVertical
        present(bottomSheetVC, animated: true)
    }

    

    var segmentControl: UISegmentedControl!
    var tableView: UITableView!
    var quizData: [(documentID: String, data: String, isBookmarked: Bool, thumbnail: String)] = []
    var quizStartDates: [Date?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
        setupLabels()
        setupSegmentControl()
        configureTableView()
        setupNoDataLabel()
        setupActivityIndicator()  // Setup activity indicator
        fetchLiveQuizzes()  // Fetch live quizzes immediately after setup
    }
    
    func setupActivityIndicator() {
        activityIndicator.style = .large
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupNoDataLabel() {
        noDataLabel = UILabel()
        noDataLabel.text = "No data available"
        noDataLabel.textColor = .gray
        noDataLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        noDataLabel.textAlignment = .center
        noDataLabel.isHidden = true  // Hidden by default
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataLabel)
        
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noDataLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noDataLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    
    func setupLabels() {
        titleLabel.text = "Grand Examinations"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        detailLabel.text = "Exams with high quality questions."
        detailLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        detailLabel.textColor = .gray
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }


    private func setupSegmentControl() {
        segmentControl = UISegmentedControl(items: ["Live", "Upcoming", "Past"])
        segmentControl.selectedSegmentIndex = 0  // Default to 'Live'
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentControl)

        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }

    private func configureTableView() {
        tableView = UITableView()
        tableView.register(ExamQuizLiveTableViewCell.self, forCellReuseIdentifier: "ExamQuizLiveCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100 // Set a reasonable estimate
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            fetchLiveQuizzes()
        case 1:
            fetchUpcomingQuizzes()
        case 2:
            fetchPastQuizzes()
        default:
            break
        }
    }

    @objc func backButtonTapped() {
        if let navController = navigationController {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // Implement UITableView DataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExamQuizLiveCell", for: indexPath) as? ExamQuizLiveTableViewCell else {
            return UITableViewCell()
        }
        let quiz = quizData[indexPath.row]
        let isUpcoming = segmentControl.selectedSegmentIndex == 1
        let isPast = segmentControl.selectedSegmentIndex == 2
        let startDate = isUpcoming || segmentControl.selectedSegmentIndex == 0 ? quizStartDates[indexPath.row] : nil

        cell.configure(with: quiz.data, examID: quiz.documentID, thumbnailURL: quiz.thumbnail, isUpcoming: isUpcoming, startDate: startDate, isPast: isPast)
        cell.delegate = self
        return cell
    }
    
    func handleNoData() {
        tableView.isHidden = true
        noDataLabel.isHidden = false
    }
    
    func fetchLiveQuizzes() {
        guard let currentUser = Auth.auth().currentUser, let phoneNumber = currentUser.phoneNumber else {
            print("User not logged in or phone number not available")
            return
        }
        
        activityIndicator.startAnimating()
        let db = Firestore.firestore()
        let quizCollection = db.collection("PGupload").document("Weekley").collection("Quiz")
        let currentDate = Timestamp(date: Date())
        let resultsCollection = db.collection("QuizResults").document(phoneNumber).collection("Exam")

        var query: Query = quizCollection
            .whereField("speciality", isEqualTo: "Exam")
            .whereField("from", isLessThanOrEqualTo: currentDate)
        
        query.getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            self.quizData = []
            self.quizStartDates = []

            if let err = err {
                print("Error getting documents: \(err)")
                self.activityIndicator.stopAnimating()
                self.showAlert(title: "Error", message: "Failed to fetch quizzes: \(err.localizedDescription)")
                return
            }

            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                self.handleNoData()
                self.activityIndicator.stopAnimating()
                return
            }

            let group = DispatchGroup()
            
            for document in documents {
                group.enter()
                let documentID = document.documentID
                resultsCollection.document(documentID).getDocument { (resultSnapshot, error) in
                    defer { group.leave() }
                    
                    if let error = error {
                        print("Error checking results existence: \(error)")
                        return
                    }

                    if resultSnapshot?.exists == false {
                        let data = document.data()
                        let title = data["title"] as? String ?? "No Title"
                        let type = data["hyOption"] as? String ?? "Unknown Type"
                        let thumbnail = data["thumbnail"] as? String ?? "No thumbnail"
                        let questionsData = data["Data"] as? [Any] ?? []
                        let numberOfQuestions = questionsData.count
                        let startDate = (data["from"] as? Timestamp)?.dateValue()
                        let isBookmarked = false
                        let documentInfo = "\(title); \(numberOfQuestions) MCQ's; \(type)"
                        
                        self.quizData.append((documentID: documentID, data: documentInfo, isBookmarked: isBookmarked, thumbnail: thumbnail))
                        self.quizStartDates.append(startDate)
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }



    func fetchUpcomingQuizzes() {
        let db = Firestore.firestore()
        let quizCollection = db.collection("PGupload").document("Weekley").collection("Quiz")
        let currentDate = Timestamp(date: Date())
        var query: Query = quizCollection
            .whereField("speciality", isEqualTo: "Exam")
            .whereField("from", isGreaterThan: currentDate)

        query.getDocuments { (querySnapshot, err) in
            self.quizData = []
            self.quizStartDates = []
            if let err = err {
                print("Error getting documents: \(err)")
                self.showAlert(title: "Error", message: "Failed to fetch quizzes: \(err.localizedDescription)")
            } else if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                for document in querySnapshot.documents {
                    let data = document.data()
                    let documentID = document.documentID
                    let title = data["title"] as? String ?? "No Title"
                    let type = data["hyOption"] as? String ?? "Unknown Type"
                    let thumbnail = data["thumbnail"] as? String ?? "No thumbnail"
                    let questionsData = data["Data"] as? [Any] ?? []
                    let numberOfQuestions = questionsData.count
                    let startDate = (data["from"] as? Timestamp)?.dateValue()
                    let isBookmarked = false
                    let documentInfo = "\(title); \(numberOfQuestions) MCQ's; \(type)"
                    self.quizData.append((documentID: documentID, data: documentInfo, isBookmarked: isBookmarked, thumbnail: thumbnail))
                    self.quizStartDates.append(startDate)
                }
            } else {
                self.showAlert(title: "No Data", message: "No upcoming quizzes available.")
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func fetchPastQuizzes() {
        let db = Firestore.firestore()
        let quizCollection = db.collection("PGupload").document("Weekley").collection("Quiz")
        let currentDate = Timestamp(date: Date())
        var query: Query = quizCollection
            .whereField("speciality", isEqualTo: "Exam")
            .whereField("to", isLessThan: currentDate)

        query.getDocuments { (querySnapshot, err) in
            self.quizData = []
            self.quizStartDates = []
            if let err = err {
                print("Error getting documents: \(err)")
                self.showAlert(title: "Error", message: "Failed to fetch quizzes: \(err.localizedDescription)")
            } else if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                for document in querySnapshot.documents {
                    let data = document.data()
                    let documentID = document.documentID
                    let title = data["title"] as? String ?? "No Title"
                    let type = data["hyOption"] as? String ?? "Unknown Type"
                    let thumbnail = data["thumbnail"] as? String ?? "No thumbnail"
                    let questionsData = data["Data"] as? [Any] ?? []
                    let numberOfQuestions = questionsData.count
                    let startDate = (data["from"] as? Timestamp)?.dateValue()
                    let isBookmarked = false
                    let documentInfo = "\(title); \(numberOfQuestions) MCQ's; \(type)"
                    self.quizData.append((documentID: documentID, data: documentInfo, isBookmarked: isBookmarked, thumbnail: thumbnail))
                    self.quizStartDates.append(startDate)
                }
            } else {
                self.showAlert(title: "No Data", message: "No past quizzes available.")
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func checkResultsExistence(quizID: String, completion: @escaping (Bool) -> Void) {
        guard let userPhone = UserDefaults.standard.string(forKey: "loggedUserPhone") else { return }
        let db = Firestore.firestore()
        let docRef = db.collection("QuizResults").document(userPhone).collection("Exam").document(quizID)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
