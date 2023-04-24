//
//  LoginViewController.swift
//  recipes
//
//  Created by Sohail Ahmed Mohammed on 2023-04-23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var loginEmail: UITextField!
    
    @IBOutlet weak var loginPassword: UITextField!
    
    
    @IBOutlet weak var loginErrorLabel: UILabel!
    
    @IBAction func loginButton(_ sender: UIButton) {
        let email = loginEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = loginPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                self.loginErrorLabel.text = error!.localizedDescription
                self.loginErrorLabel.alpha = 1
            } else {
                let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
                self.view.window?.rootViewController = homeViewController
                self.view.window?.makeKeyAndVisible()
            }
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
