import UIKit

class PieChartView: UIView {
    var score: Int = 0 {
        didSet {
            setNeedsDisplay() // Redraw the view when the score changes
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .white // Set the background color to white
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let lineWidth: CGFloat = 20.0
        let radius: CGFloat = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        // Background path
        let backgroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        backgroundPath.lineWidth = lineWidth
        UIColor.lightGray.setStroke()
        backgroundPath.stroke()

        // Foreground path
        let endAngle = CGFloat(score) / 100 * 2 * .pi - .pi / 2
        let foregroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: endAngle, clockwise: true)
        foregroundPath.lineWidth = lineWidth
        UIColor.red.setStroke()
        foregroundPath.stroke()
        
        // Draw the score in the center
        let scoreText = "\(score)"
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        let scoreAttributedString = NSAttributedString(string: scoreText, attributes: scoreAttributes)
        let scoreTextSize = scoreAttributedString.size()

        // Draw the label "Score" under the numeric score
        let labelText = "score"
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ]
        let labelAttributedString = NSAttributedString(string: labelText, attributes: labelAttributes)
        let labelTextSize = labelAttributedString.size()

        // Calculate combined height and position both texts
        let totalHeight = scoreTextSize.height + labelTextSize.height + 5 // 5 points space between texts
        let scoreTextRect = CGRect(
            x: center.x - scoreTextSize.width / 2,
            y: center.y - totalHeight / 2,
            width: scoreTextSize.width,
            height: scoreTextSize.height
        )
        scoreAttributedString.draw(in: scoreTextRect)

        let labelTextRect = CGRect(
            x: center.x - labelTextSize.width / 2,
            y: scoreTextRect.maxY + 5, // Start 5 points below the score text
            width: labelTextSize.width,
            height: labelTextSize.height
        )
        labelAttributedString.draw(in: labelTextRect)
    }
}
