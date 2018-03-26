//
//  RegisterViewController.swift
//  Mastermind
//
//  Created by Sébastien Gaya on 26/03/2018.
//  Copyright © 2018 Sébastien Gaya. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        SVProgressHUD.show()
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                SVProgressHUD.dismiss()
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: "Error while signing up. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                self.navigationController?.popToRootViewController(animated: true)
            })
        }
    }
    
    // MARK: - UITextField Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
