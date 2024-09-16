import UIKit

class InstructionsUIView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Create and configure labels for each instruction
        let instructionsLabel = createLabel(withText: "Instructions", fontSize: 24, weight: .bold)
        let instruction1Label = createLabel(withText: "1. The Question Palette will show the status of each question using the following symbols:", fontSize: 16, weight: .regular)
        let instruction2Label = createLabel(withText: "2. The test has 5 sections. The total duration of the test is 210 minutes.", fontSize: 16, weight: .regular)
        let instruction3Label = createLabel(withText: "3. You have the option to view and answer 40 questions within the current section of the test...", fontSize: 16, weight: .regular)
        let instruction4Label = createLabel(withText: "4. The countdown timer at the top centre of the screen will show the remaining time left to complete the exam.", fontSize: 16, weight: .regular)
        let instruction5Label = createLabel(withText: "5. Once the timer reaches zero, the exam will end automatically without any permission to end or submit the exam.", fontSize: 16, weight: .regular)

        
        // Add labels to the view
        let stackView = UIStackView(arrangedSubviews: [
            instructionsLabel,
            instruction1Label,
            instruction2Label,
            instruction3Label,
            instruction4Label,
            instruction5Label
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        
        // Setup constraints for stackView
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
        ])
    }
    
    private func createLabel(withText text: String, fontSize: CGFloat, weight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }
}
