import UIKit

struct Topic {
    var name: String
    var questionCount: Int
}


class TopicCell: UITableViewCell {
    let numberLabel = UILabel()
    let topicLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        numberLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        topicLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        topicLabel.numberOfLines = 0 // Allow multi-line if needed

        contentView.addSubview(numberLabel)
        contentView.addSubview(topicLabel)
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            numberLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            numberLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            numberLabel.widthAnchor.constraint(equalToConstant: 40),
            
            topicLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 8),
            topicLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            topicLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            topicLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(number: Int, text: String) {
        numberLabel.text = "\(number)"
        topicLabel.text = text
    }
}
