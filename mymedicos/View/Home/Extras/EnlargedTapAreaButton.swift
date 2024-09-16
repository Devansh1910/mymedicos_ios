import UIKit

class EnlargedTapAreaButton: UIButton {

    var horizontalPadding: CGFloat = 20
    var verticalPadding: CGFloat = 20

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let largerArea = bounds.insetBy(dx: -horizontalPadding, dy: -verticalPadding)
        return largerArea.contains(point)
    }
}
