//
//  MainMenuViewController.swift
//  Mastermind
//
//  Created by Sébastien Gaya on 20/03/2018.
//  Copyright © 2018 Sébastien Gaya. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainMenuViewController: UIViewController {

    @IBOutlet weak var userBarButton: UIBarButtonItem!
    @IBOutlet weak var historyBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Auth.auth().currentUser != nil {
            userBarButton.tintColor = UIColor(red: 14/255, green: 157/255, blue: 45/255, alpha: 1.0)
            historyBtn.isEnabled = true
        } else {
            userBarButton.tintColor = UIColor.red
            historyBtn.isEnabled = false
        }
    }

    @IBAction func userBtnPressed(_ sender: UIBarButtonItem) {
        if let user = Auth.auth().currentUser {
            // User is signed in.
            let alert = UIAlertController(title: "You are logged in.", message: "You're currently signed in as : \(user.email!)", preferredStyle: .alert)
            let disconnectAction = UIAlertAction(title: "Disconnect", style: .destructive, handler: { (action) in
                do {
                    try Auth.auth().signOut()
                    self.userBarButton.tintColor = UIColor.red
                    self.historyBtn.isEnabled = false
                } catch {
                    print("Error while signing out.")
                }
            })
            let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            
            alert.addAction(disconnectAction)
            alert.addAction(dismissAction)
            
            self.present(alert, animated: true)
        } else {
            // No user is signed in.
            let alert = UIAlertController(title: "You are not logged in.", message: "You can't save old games if you're not authenticated.", preferredStyle: .actionSheet)
            let registerAction = UIAlertAction(title: "Register", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "goToRegister", sender: self)
            })
            let loginAction = UIAlertAction(title: "Login", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "goToLogin", sender: self)
            })
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            
            alert.addAction(registerAction)
            alert.addAction(loginAction)
            alert.addAction(dismissAction)
            
            self.present(alert, animated: true)
        }
    }
    
}

