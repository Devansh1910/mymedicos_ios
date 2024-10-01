import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, _ in
            if success {
                print("Success in APN's register")
            }
        }
        
        application.registerForRemoteNotifications()
        
        // Setup notification handler for logout
        setupLogoutNotification()

        if #available(iOS 13.0, *) {
            // Handle iOS 13+ scene delegate settings
        } else {
            // Setup the initial view controller for iOS 12 and below
            window = UIWindow(frame: UIScreen.main.bounds)
            let navigationController = UINavigationController(rootViewController: GetStartedViewController())
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
            
            window?.overrideUserInterfaceStyle = .light
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Implement if needed
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
    }
    
    private func subscribeToTopics() {
        Messaging.messaging().subscribe(toTopic: "NEWS_UPDATES") { error in
            print("Subscribed to NEWS_UPDATES topic successfully")
        }
        Messaging.messaging().subscribe(toTopic: "PUBLICATIONS") { error in
            print("Subscribed to PUBLICATIONS topic successfully")
        }
    }

    private func setupLogoutNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogoutNotification), name: NSNotification.Name("UserDidLogout"), object: nil)
    }

    @objc func handleLogoutNotification() {
        DispatchQueue.main.async {
            self.window?.rootViewController?.dismiss(animated: true) {
                let navigationController = UINavigationController(rootViewController: GetStartedViewController())
                self.window?.rootViewController = navigationController
            }
        }
    }
}

