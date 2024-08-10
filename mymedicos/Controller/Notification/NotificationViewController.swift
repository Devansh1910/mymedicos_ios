//
//  NotificationViewController.swift
//  mymedicos
//
//  Created by Devansh Saxena on 03/08/24.
//

import UIKit

class NotificationViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white // Set background color to white
        title = "Notifications" // Set the title for the navigation bar
        
        // Optionally ensure the navigation bar uses the correct tint color
        navigationController?.navigationBar.tintColor = .black
    }

}

