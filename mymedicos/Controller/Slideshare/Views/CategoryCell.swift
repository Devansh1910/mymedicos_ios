import UIKit

class CategoryCell: UICollectionViewCell {
    private var label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        backgroundColor = UIColor(hex: "#EFEFF0") // Regular background color
        layer.cornerRadius = 10
        
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }

    func configure(with title: String, isActive: Bool) {
        label.text = title
        if isActive {
            backgroundColor = .darkGray // Active category color
            label.textColor = .white
        } else {
            backgroundColor = UIColor(hex: "#EFEFF0") // Regular background color
            label.textColor = .black
        }
    }
}
