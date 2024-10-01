import UIKit
import Razorpay
import FirebaseAuth
import FirebaseFirestore

class PaymentViewController: UIViewController, RazorpayPaymentCompletionProtocolWithData {

    var selectedPlan: Plan!
    var razorpay: RazorpayCheckout!
    var currentOrderId: String?

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
    
    func onPaymentSuccess(_ payment_id: String, andData data: [AnyHashable: Any]?) {
        let signature = data?["razorpay_signature"] as? String ?? "No Signature"
        let orderId = currentOrderId ?? "No Order ID"
        print("Payment Success: \(payment_id)")
        DispatchQueue.main.async {
            let message = "Payment ID: \(payment_id)\nOrder ID: \(orderId)\nSignature: \(signature)"
            let alert = UIAlertController(title: "Payment Success", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func onPaymentError(_ code: Int32, description str: String, andData data: [AnyHashable: Any]?) {
        print("Payment Failed: \(str)")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Payment Failed", message: str, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
