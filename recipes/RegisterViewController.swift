//
//  RegisterViewController.swift
//  recipes
//
//  Created by Sohail Ahmed Mohammed on 2023-04-23.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var registerFullName: UITextField!
    @IBOutlet weak var registerEmailAddress: UITextField!
    @IBOutlet weak var registerPassword: UITextField!
    @IBOutlet weak var registerPasswordConfirm: UITextField!
    
    @IBAction func registerButton(_ sender: UIButton) {
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
