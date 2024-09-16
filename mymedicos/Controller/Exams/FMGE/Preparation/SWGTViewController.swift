import UIKit
import Firebase

class SWGTViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ExamQuizLiveTableViewCellDelegate, BottomSheetDelegate, SWGTUpcomingBottomSheetDelegate {
    
    func didSetReminder(forExamID examID: String) {
        scheduleLocalNotification(forExamID: examID)
    }

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
    
    func didChooseOption(examID: String, option: String) {
        print("Option chosen for exam \(examID): \(option)")
    }
    
    
    func didTapSolveButton(examID: String, examTitle: String) {
        let examInfoVC = ExamInfoViewController()
        examInfoVC.examTitle = examTitle
        examInfoVC.hidesBottomBarWhenPushed = true
        examInfoVC.examID = examID
        navigationController?.pushViewController(examInfoVC, animated: true)
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

    var specialtyTitle: String
    var segmentControl: UISegmentedControl!
    var tableView: UITableView!
    var quizData: [(documentID: String, data: String, isBookmarked: Bool, thumbnail: String)] = []
    var quizStartDates: [Date?] = [] // Store start dates for quizzes
    
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
        setupSegmentControl()
        configureTableView()
        fetchLiveQuizzes()  // Fetch live quizzes immediately after setup
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationItem.title = specialtyTitle
        
        let backArrowImage = UIImage(systemName: "chevron.left")
        let backButton = UIBarButtonItem(image: backArrowImage, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupSegmentControl() {
        segmentControl = UISegmentedControl(items: ["Live", "Upcoming", "Past"])
        segmentControl.selectedSegmentIndex = 0  // Default to 'Live'
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentControl)
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
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
        
        // Determine if it's an upcoming or past quiz based on the segment selected
        let isUpcoming = segmentControl.selectedSegmentIndex == 1
        let isPast = segmentControl.selectedSegmentIndex == 2

        let startDate = isUpcoming || segmentControl.selectedSegmentIndex == 0 ? quizStartDates[indexPath.row] : nil
        
        cell.configure(with: quiz.data, examID: quiz.documentID, thumbnailURL: quiz.thumbnail, isUpcoming: isUpcoming, startDate: startDate, isPast: isPast)
        cell.delegate = self
        return cell
    }

    func fetchLiveQuizzes() {
        let db = Firestore.firestore()
        let quizCollection = db.collection("PGupload").document("CWT").collection("Quiz")
        let currentDate = Timestamp(date: Date())
        
        // Step 1: Query to get quizzes that have started
        var query: Query = quizCollection
            .whereField("speciality", isEqualTo: specialtyTitle)
            .whereField("from", isLessThanOrEqualTo: currentDate) // Quizzes that have started
        
        query.getDocuments { (querySnapshot, err) in
            self.quizData = [] // Clear existing data
            self.quizStartDates = [] // Clear existing start dates
            if let err = err {
                print("Error getting documents: \(err)")
                self.showAlert(title: "Error", message: "Failed to fetch quizzes: \(err.localizedDescription)")
            } else if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                for document in querySnapshot.documents {
                    let data = document.data()
                    let toTimestamp = data["to"] as? Timestamp ?? Timestamp(date: Date.distantFuture)
                    
                    // Step 2: Filter on the client side for quizzes that haven't ended
                    if toTimestamp.compare(currentDate) != .orderedAscending { // If 'to' is greater than or equal to currentDate
                        let documentID = document.documentID
                        let title = data["title"] as? String ?? "No Title"
                        let type = data["hyOption"] as? String ?? "Unknown Type"
                        let thumbnail = data["thumbnail"] as? String ?? "No thumbnail"
                        let questionsData = data["Data"] as? [Any] ?? []
                        let numberOfQuestions = questionsData.count
                        let startDate = (data["from"] as? Timestamp)?.dateValue() // Fetch the start date
                        let isBookmarked = false  // Default to false; update in separate fetch if needed
                        let documentInfo = "\(title); \(numberOfQuestions) MCQ's; \(type)"
                        self.quizData.append((documentID: documentID, data: documentInfo, isBookmarked: isBookmarked, thumbnail: thumbnail))
                        self.quizStartDates.append(startDate) // Store the start date
                    }
                }
            } else {
                self.showAlert(title: "No Data", message: "No live quizzes available.")
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }


    func fetchUpcomingQuizzes() {
        let db = Firestore.firestore()
        let quizCollection = db.collection("PGupload").document("CWT").collection("Quiz")
        let currentDate = Timestamp(date: Date())
        var query: Query = quizCollection
            .whereField("speciality", isEqualTo: specialtyTitle)
            .whereField("from", isGreaterThan: currentDate) // Quizzes that start in the future

        query.getDocuments { (querySnapshot, err) in
            self.quizData = [] // Clear existing data
            self.quizStartDates = [] // Clear existing start dates
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
        let quizCollection = db.collection("PGupload").document("CWT").collection("Quiz")
        let currentDate = Timestamp(date: Date())
        var query: Query = quizCollection
            .whereField("speciality", isEqualTo: specialtyTitle)
            .whereField("to", isLessThan: currentDate) // Quizzes that have ended

        query.getDocuments { (querySnapshot, err) in
            self.quizData = [] // Clear existing data
            self.quizStartDates = [] // Clear existing start dates
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
                    let startDate = (data["from"] as? Timestamp)?.dateValue() // Fetch the start date
                    let isBookmarked = false  // Default to false; update in separate fetch if needed
                    let documentInfo = "\(title); \(numberOfQuestions) MCQ's; \(type)"
                    self.quizData.append((documentID: documentID, data: documentInfo, isBookmarked: isBookmarked, thumbnail: thumbnail))
                    self.quizStartDates.append(startDate) // Store the start date
                }
            } else {
                self.showAlert(title: "No Data", message: "No past quizzes available.")
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
