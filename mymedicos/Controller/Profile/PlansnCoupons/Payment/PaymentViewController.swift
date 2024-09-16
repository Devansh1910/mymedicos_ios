import UIKit
import Razorpay

class PaymentViewController: UIViewController, RazorpayPaymentCompletionProtocol {

    var selectedPlan: Plan!
    var razorpay: RazorpayCheckout!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        razorpay = RazorpayCheckout.initWithKey("rzp_live_mgbdzdpY69jVbV", andDelegate: self)

        // Directly start the payment process
        startPayment()
    }

    @objc private func startPayment() {
        let amountInPaise = (Double(selectedPlan.price.replacingOccurrences(of: "₹", with: "")) ?? 0.0) * 100 // Convert rupees to paise
        
        let options: [String: Any] = [
            "amount": String(format: "%.0f", amountInPaise), // Amount in paise, converted to string
            "currency": "INR",
            "description": selectedPlan.plan,
            "order_id": "order_OtsVhjmHElEyHL", // Ensure to generate this order ID from your backend
            "name": "mymedicos",
            "prefill": [
                "contact": "+919305506538",
                "email": "devanshsaxena1019@gmail.com"
            ],
            "theme": [
                "color": "#2BD0BF"
            ]
        ]
        razorpay.open(options)
    }

    // RazorpayPaymentCompletionProtocol methods
    func onPaymentSuccess(_ payment_id: String) {
        print("Payment Success: \(payment_id)")
        // Handle success - navigate to a success screen or show an alert
    }

    func onPaymentError(_ code: Int32, description str: String) {
        print("Payment Failed: \(str)")
        // Handle error - show an alert or message
    }
}
