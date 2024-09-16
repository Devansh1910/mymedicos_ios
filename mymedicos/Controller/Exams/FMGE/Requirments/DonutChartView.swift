import UIKit

class DonutChartView: UIView {
    // Define colors for each segment of the donut chart
    let segmentColors: [UIColor] = [
        .yellow, .gray, .orange, .blue, .red, .green, .systemCyan, .purple, .brown
    ]
    
    // Values for each segment, dynamically updateable
    var segmentValues: [CGFloat] = [10, 10, 10, 10, 10, 10, 10, 10, 20] {
        didSet {
            self.setNeedsDisplay()  // Redraw view when values change
        }
    }
    
    // Text to be displayed in the middle of the donut
    // In DonutChartView
    var segmentLabels: [String] = ["Answered", "Marked", "Unanswered", "Correct Answers", "Wrong Answers", "Others", "Others", "Others", "Others"]
    private var centerTextLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCenterText()
        backgroundColor = .white  // Set background color to white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCenterText()
        backgroundColor = .white  // Set background color to white
    }
    
    private func setupCenterText() {
        centerTextLabel = UILabel()
        centerTextLabel.text = "Results"
        centerTextLabel.textAlignment = .center
        centerTextLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold) // Adjusted font size
        centerTextLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerTextLabel)
        
        NSLayoutConstraint.activate([
            centerTextLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func draw(_ rect: CGRect) {
        let radius: CGFloat = min(bounds.width, bounds.height) / 2  // Further adjust the radius for an even larger view
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let lineWidth: CGFloat = 40.0  // Further increased line width for a thicker donut

        let total = segmentValues.reduce(0, +)
        var startAngle: CGFloat = -.pi / 2
        
        segmentValues.enumerated().forEach { (index, value) in
            let endAngle = startAngle + .pi * 2 * (value / total)
            let path = UIBezierPath(arcCenter: center, radius: radius - lineWidth / 2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.lineWidth = lineWidth
            segmentColors[index % segmentColors.count].setStroke()
            path.stroke()
            startAngle = endAngle
        }
    }
}
