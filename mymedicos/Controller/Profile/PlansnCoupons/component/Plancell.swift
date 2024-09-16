import UIKit

class PlanCell: UITableViewCell {

    static let reuseIdentifier = "PlanCell"
    
    private let planView = PlanView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(planView)
        planView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.backgroundColor = .clear // Make content view background transparent
        backgroundColor = .clear // Make cell background transparent
        
        NSLayoutConstraint.activate([
            planView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            planView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            planView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            planView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    @objc private func cellTapped() {
        didSelectCell?()
    }
    
    var didSelectCell: (() -> Void)?
    
    func configure(with plan: Plan, isSelected: Bool) {
        planView.configure(with: plan, isSelected: isSelected)
    }

    func setRadioButtonAction(_ action: @escaping () -> Void) {
        didSelectCell = action
    }
}
