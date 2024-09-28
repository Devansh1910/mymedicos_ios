//import UIKit
//
//class SlideTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//
//    private var collectionView: UICollectionView!
//    private var slides: [Slide] = []
//
//    var specialtyLabel = UILabel()
//    var typeLabel = UILabel()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupViews()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupViews() {
//        // Set up collection view layout
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 1
//        layout.itemSize = CGSize(width: 50, height: 100) // Adjust the width and height based on design
//
//        // Set up collection view
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.backgroundColor = .clear
//        collectionView.register(SlideCollectionViewCell.self, forCellWithReuseIdentifier: "SlideCollectionViewCell")
//
//        // Add collection view to content view
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(collectionView)
//
//        // Set up labels
//        specialtyLabel.translatesAutoresizingMaskIntoConstraints = false
//        specialtyLabel.font = UIFont.systemFont(ofSize: 14)
//        contentView.addSubview(specialtyLabel)
//
//        typeLabel.translatesAutoresizingMaskIntoConstraints = false
//        typeLabel.font = UIFont.systemFont(ofSize: 12)
//        typeLabel.textAlignment = .right
//        contentView.addSubview(typeLabel)
//
//        // Add constraints to collection view and labels
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
//            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            collectionView.heightAnchor.constraint(equalToConstant: 100), // Adjust height as needed
//
//            specialtyLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 5),
//            specialtyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
//
//            typeLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 5),
//            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
//        ])
//    }
//
//    func configure(with slides: [Slide], speciality: String, type: String) {
//        self.slides = slides
//        self.specialtyLabel.text = speciality
//        self.typeLabel.text = type
//        collectionView.reloadData()
//    }
//
//    // MARK: - Collection View Data Source Methods
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return slides.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlideCollectionViewCell", for: indexPath) as? SlideCollectionViewCell else {
//            return UICollectionViewCell()
//        }
//        let slide = slides[indexPath.item]
//        cell.configure(with: slide)
//        return cell
//    }
//}
//
//class SlideCollectionViewCell: UICollectionViewCell {
//    var slideImageView = UIImageView()
//    var titleLabel = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupViews() {
//        // Image setup
//        slideImageView.translatesAutoresizingMaskIntoConstraints = false
//        slideImageView.contentMode = .scaleAspectFit
//        slideImageView.clipsToBounds = true // Ensures that the image fits well within the view
//        contentView.addSubview(slideImageView)
//
//        // Title setup
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
//        titleLabel.textAlignment = .center
//        titleLabel.numberOfLines = 1
//        titleLabel.lineBreakMode = .byTruncatingTail // Truncate long titles
//        contentView.addSubview(titleLabel)
//
//        // Constraints
//        NSLayoutConstraint.activate([
//            slideImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            slideImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            slideImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            slideImageView.heightAnchor.constraint(equalToConstant: 40), // Adjust as needed
//
//            titleLabel.topAnchor.constraint(equalTo: slideImageView.bottomAnchor, constant: 5),
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//        ])
//    }
//
//    func configure(with slide: Slide) {
//        titleLabel.text = slide.title
//        loadImage(from: slide.images.first?.url)
//    }
//
//    private func loadImage(from urlString: String?) {
//        guard let urlString = urlString, let url = URL(string: urlString) else {
//            slideImageView.image = UIImage(named: "placeholder") // Set a placeholder image if URL is not valid
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let data = data, let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self.slideImageView.image = image
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.slideImageView.image = UIImage(named: "placeholder")
//                }
//            }
//        }.resume()
//    }
//}
