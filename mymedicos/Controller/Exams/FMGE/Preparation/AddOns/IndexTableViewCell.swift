import UIKit

class IndexTableViewCell: UITableViewCell {
    let indexLabel = UILabel()
    let countLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        indexLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        indexLabel.textColor = UIColor.darkGray
        countLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        countLabel.textColor = UIColor.gray

        contentView.addSubview(indexLabel)
        contentView.addSubview(countLabel)

        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indexLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            indexLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            indexLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            countLabel.topAnchor.constraint(equalTo: indexLabel.bottomAnchor, constant: 2),
            countLabel.leadingAnchor.constraint(equalTo: indexLabel.leadingAnchor),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}
