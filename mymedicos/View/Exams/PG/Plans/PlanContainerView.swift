//import UIKit
//import FirebaseFirestore
//
//
//class PlansContainerView: UIView {
//    private let scrollView = UIScrollView()
//    private var firestore: Firestore!
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setup()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setup() {
//        firestore = Firestore.firestore()
//        setupScrollView()
//        fetchData()
//    }
//    
//    private func setupScrollView() {
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.isPagingEnabled = true
//        addSubview(scrollView)
//        
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: topAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
//        ])
//    }
//    
//    private func fetchData() {
//            let collectionRef = firestore.collection("Plans").document("PG").collection("Subscriptions")
//            collectionRef.getDocuments { [weak self] (querySnapshot, error) in
//                if let self = self, let documents = querySnapshot?.documents {
//                    self.layoutPlanViews(documents: documents)
//                } else {
//                    print("Error fetching documents: \(error?.localizedDescription ?? "No error description")")
//                }
//            }
//        }
//    
//    private func layoutPlanViews(documents: [QueryDocumentSnapshot]) {
//            var offsetX: CGFloat = 0
//            let cardWidth: CGFloat = bounds.width * 0.8
//            let space: CGFloat = 10
//            
//            documents.forEach { document in
//                let planView = PlansNeetPgUIView(frame: CGRect(x: offsetX, y: 0, width: cardWidth, height: bounds.height))
//                planView.configure(with: document.data())
//                scrollView.addSubview(planView)
//                offsetX += cardWidth + space
//            }
//            
//            scrollView.contentSize = CGSize(width: offsetX, height: bounds.height)
//        }
//}
