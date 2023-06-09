//
//  RegisterViewController.swift
//  recipes
//
//  Created by Sohail Ahmed Mohammed on 2023-04-23.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var registerFullName: UITextField!
    @IBOutlet weak var registerEmailAddress: UITextField!
    @IBOutlet weak var registerPassword: UITextField!
    @IBOutlet weak var registerPasswordConfirm: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    let defaultImg = "https://firebasestorage.googleapis.com/v0/b/recipes-cfad1.appspot.com/o/defaultImg.png?alt=media&token=3bfe9a47-10b0-4314-9c9e-b1eaa3164947"
    
    @IBAction func registerButton(_ sender: UIButton) {
        if registerFullName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            registerEmailAddress.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            registerPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            registerPasswordConfirm.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            errorLabel.text = "Please fill all the fields properly"
            errorLabel.alpha = 1
        } else if (registerPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) != registerPasswordConfirm.text?.trimmingCharacters(in: .whitespacesAndNewlines)) {
            errorLabel.text = "Passwords Do Not Match!"
            errorLabel.alpha = 1
        } else {
            let name = registerFullName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = registerEmailAddress.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = registerPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                if err != nil {
                    self.errorLabel.text = "Error Creating User Account!\n" + err!.localizedDescription
                    self.errorLabel.alpha = 1
                } else {
                    let db = Firestore.firestore()
                    // Custom document ID in a collection (using uid itself in this case)
                    db.collection("users").document(result!.user.uid).setData(["name": name, "email": email, "img": self.defaultImg, "uid": result!.user.uid]) { (error) in
                        if error != nil {
                            self.errorLabel.text = "Error saving user data"
                            self.errorLabel.alpha = 1
                        }
                    }
                    // Creates Auto-ID for document in a collection
//                    db.collection("users").addDocument(data: ["name": name, "email": email, "img": self.defaultImg, "uid": result!.user.uid]) { (error) in
//                        if error != nil {
//                            self.errorLabel.text = "Error saving user data"
//                            self.errorLabel.alpha = 1
//                        }
//                    }
                    let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
                    self.view.window?.rootViewController = homeViewController
                    self.view.window?.makeKeyAndVisible()
                }
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
