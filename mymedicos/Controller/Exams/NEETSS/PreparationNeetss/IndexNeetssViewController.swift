import UIKit
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth

class IndexNeetssViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate {
    var specialtyTitle: String
    var segmentedControl: UISegmentedControl!
    var topicsTableView: UITableView!
    var topics: [String] = []
    var notes: [Note] = []

    var activityIndicator = UIActivityIndicatorView(style: .large)

    private let noDataView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "No data available"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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
        setupTopicsTableView()
        setupNoDataView()
        setupActivityIndicator()
        fetchCategoryAndData()
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

        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]

        navigationItem.title = specialtyTitle

        let backArrowImage = UIImage(systemName: "chevron.left")
        let backButton = UIBarButtonItem(image: backArrowImage, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }

    private func configureSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["Index", "Notes"])
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

    private func setupTopicsTableView() {
        topicsTableView = UITableView(frame: CGRect.zero, style: .plain)
        topicsTableView.register(TopicCell.self, forCellReuseIdentifier: "TopicCell")
        topicsTableView.register(NoteCell.self, forCellReuseIdentifier: "NoteCell")
        topicsTableView.dataSource = self
        topicsTableView.delegate = self
        topicsTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topicsTableView)

        NSLayoutConstraint.activate([
            topicsTableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            topicsTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            topicsTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            topicsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNoDataView() {
        view.addSubview(noDataView)
        noDataView.addSubview(noDataLabel)

        NSLayoutConstraint.activate([
            noDataView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noDataView.widthAnchor.constraint(equalTo: view.widthAnchor),
            noDataView.heightAnchor.constraint(equalToConstant: 200),

            noDataLabel.centerXAnchor.constraint(equalTo: noDataView.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: noDataView.centerYAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = segmentedControl.selectedSegmentIndex == 0 ? topics.count : notes.count
        noDataView.isHidden = count > 0
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as? TopicCell else {
                return UITableViewCell()
            }
            cell.configure(number: indexPath.row + 1, text: topics[indexPath.row])
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as? NoteCell else {
                return UITableViewCell()
            }
            let note = notes[indexPath.row]
            cell.configure(with: note)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentedControl.selectedSegmentIndex == 1 { // Notes segment
            let note = notes[indexPath.row]
            let detailVC = NoteDetailPopupViewController(note: note)
            let navController = UINavigationController(rootViewController: detailVC)
            present(navController, animated: true, completion: nil)
        }
    }

    private func fetchCategoryAndData() {
        guard let userPhoneNumber = Auth.auth().currentUser?.phoneNumber else {
            print("No logged in user found")
            return
        }

        let ref = Database.database().reference()
        ref.child("profiles").child(userPhoneNumber).child("Neetss").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let category = snapshot.value as? String else {
                print("No category found for user")
                return
            }
            self?.fetchIndexData(category: category)
        }
    }

    private func fetchIndexData(category: String) {
        activityIndicator.startAnimating()
        let db = Firestore.firestore()
        let documentPath = "Neetss/\(category)/Index/\(specialtyTitle)"

        db.document(documentPath).getDocument { [weak self] (documentSnapshot, error) in
            self?.activityIndicator.stopAnimating()
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                guard let data = documentSnapshot.data(), let topicsArray = data["Data"] as? [String] else {
                    print("Failed to retrieve data or 'Data' field is not an array")
                    self?.topics = []
                    self?.updateUIWithTopics()
                    return
                }
                self?.topics = topicsArray
                self?.updateUIWithTopics()
            } else {
                print("Document does not exist at the path: \(documentPath)")
                self?.topics = []
                self?.updateUIWithTopics()
            }
        }
    }

    private func updateUIWithTopics() {
        DispatchQueue.main.async {
            self.topicsTableView.reloadData()
            self.animateNoDataView()
        }
    }

    private func updateUIWithNotes() {
        DispatchQueue.main.async {
            self.topicsTableView.reloadData()
            self.animateNoDataView()
        }
    }

    private func animateNoDataView() {
        if self.noDataView.isHidden == false {
            UIView.animate(withDuration: 0.3) {
                self.noDataView.alpha = 1.0
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.noDataView.alpha = 0.0
            }
        }
    }
    
    private func fetchNotesAndData() {
        guard let userPhoneNumber = Auth.auth().currentUser?.phoneNumber else {
            print("No logged in user found")
            return
        }

        let ref = Database.database().reference()
        ref.child("profiles").child(userPhoneNumber).child("Neetss").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let category = snapshot.value as? String else {
                print("No category found for user")
                return
            }
            self?.fetchNotesData(category: category)
        }
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            fetchCategoryAndData()
        } else {
            fetchNotesAndData()
        }
    }
    
    private func fetchNotesData(category: String) {
            let db = Firestore.firestore()
            db.collection("Neetss/\(category)/Notes")
                .whereField("speciality", isEqualTo: specialtyTitle)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching documents: \(error.localizedDescription)")
                        self.notes = []
                        self.updateUIWithNotes()
                        return
                    }
                    guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                        print("No notes found")
                        self.notes = []
                        self.updateUIWithNotes()
                        return
                    }
                    self.notes = documents.compactMap { doc in
                        guard let title = doc.data()["Title"] as? String,
                              let description = doc.data()["Description"] as? String,
                              let time = doc.data()["Time"] as? String,
                              let previewURL = doc.data()["pdf"] as? String,
                              let type = doc.data()["type"] as? String,
                              let fileURL = doc.data()["file"] as? String else {
                            return nil
                        }
                        return Note(title: title, description: description, time: time, previewURL: previewURL, type: type, fileURL: fileURL)
                    }
                    self.updateUIWithNotes()
                }
        }


    @objc func backButtonTapped() {
        if let navController = navigationController {
            if navController.viewControllers.first == self {
                dismiss(animated: true)
            } else {
                navController.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - UIViewControllerTransitioningDelegate

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController2(presentedViewController: presented, presenting: presenting)
    }
}
