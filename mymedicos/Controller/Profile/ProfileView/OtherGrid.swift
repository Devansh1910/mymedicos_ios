import UIKit

protocol OtherGridDelegate: AnyObject {
    func navigateToTermsAndConditions()
    func navigateToReportIssue()
    func navigateToaboutus()
}

class OtherGrid: UIView {
    
    weak var delegate: OtherGridDelegate?
        
    private let learnmoreButton = createButton(title: "Learn more", iconName: "docs")
    private let aboutusButton = createButton(title: "About us", iconName: "aboutus")
    private let rateusButton = createButton(title: "Rate us", iconName: "rate")
    private let tncButton = createButton(title: "T&C", iconName: "tnc")
    private let reportprivacyissueButton = createButton(title: "Report privacy issue", iconName: "reportprivacy")
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGrid()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGrid()
        setupActions()
    }
    
    private static func createButton(title: String, iconName: String) -> UIButton {
        let button = UIButton(type: .system)
        
        let icon = UIImage(named: iconName)
        let imageView = UIImageView(image: icon)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.font = UIFont(name: "Poppins-SemiBold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(imageView)
        button.addSubview(label)
        
        button.backgroundColor = UIColor(hexString: "#EAEAEA")
        button.layer.cornerRadius = 8
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        return button
    }
    
    private func setupGrid() {
        let topRow = UIStackView(arrangedSubviews: [learnmoreButton, aboutusButton])
        let middleRow = UIStackView(arrangedSubviews: [rateusButton, tncButton])
        let bottomRow = UIStackView(arrangedSubviews: [reportprivacyissueButton])
        
        topRow.distribution = .fillEqually
        topRow.axis = .horizontal
        topRow.spacing = 10
        
        middleRow.distribution = .fillEqually
        middleRow.axis = .horizontal
        middleRow.spacing = 10
        
        bottomRow.distribution = .fillEqually
        bottomRow.axis = .horizontal
        bottomRow.spacing = 10
        
        let gridStackView = UIStackView(arrangedSubviews: [topRow, middleRow, bottomRow])
        gridStackView.axis = .vertical
        gridStackView.distribution = .fillEqually
        gridStackView.spacing = 10
        
        gridStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gridStackView)
        
        NSLayoutConstraint.activate([
            gridStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            gridStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15),
            gridStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            gridStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15)
        ])
    }
    
    private func setupActions() {
        learnmoreButton.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        aboutusButton.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        rateusButton.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        tncButton.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
        reportprivacyissueButton.addTarget(self, action: #selector(handleButtonClick(_:)), for: .touchUpInside)
    }
    
    @objc func handleButtonClick(_ sender: UIButton) {
        if sender == learnmoreButton {
            print("Learn more button tapped")
        } else if sender == aboutusButton {
            delegate?.navigateToaboutus()
        } else if sender == rateusButton {
            print("Rate us button tapped")
        } else if sender == tncButton {
            print("Tnc us button tapped")
            delegate?.navigateToTermsAndConditions()
        } else if (sender == reportprivacyissueButton){
            delegate?.navigateToReportIssue()
        }
    }
}
