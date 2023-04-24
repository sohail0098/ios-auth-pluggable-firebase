//
//  HomeViewController.swift
//  recipes
//
//  Created by Sohail Ahmed Mohammed on 2023-04-24.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: userID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting document. \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let temp_email = document.data()["email"]
                    let temp_name = document.data()["name"]
                    let temp_img = document.data()["img"] as? String
                    self.userNameField.text = temp_name as? String
                    self.userEmailField.text = temp_email as? String
                    let url = URL(string: temp_img!)
                    self.downloadImage(from: url!)
                    self.showToast(message: "Hello, \(temp_name!)!", seconds: 1.5)
                }
            }
        }
    }
    
    
    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var userEmailField: UITextField!
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBAction func imageChooserBtn(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
            imagePickerController.allowsEditing = false //If you want edit option set "true"
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        userImage.image  = tempImage
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountBtn(_ sender: UIButton) {
        let user = Auth.auth().currentUser
        let userID = user?.uid
        user?.delete {error in
            if let error = error {
                print("An error occured! \(error)")
            } else {
                let db = Firestore.firestore()
                db.collection("users").whereField("uid", isEqualTo: userID!).getDocuments { snapshot, error in
                    if error != nil {
                        print("An error occured. \(error!)")
                    } else {
                        for document in snapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            db.collection("users").document(document.documentID).delete()
                        }
                        self.showToast(message: "User Account and Data Deleted!", seconds: 2.0)
                        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as? ViewController
                        self.view.window?.rootViewController = mainViewController
                        self.view.window?.makeKeyAndVisible()
                        
                    }
                }
            }
        }
        
    }
    
    @IBAction func logoutBtn(_ sender: UIButton) {
        try? Auth.auth().signOut()
        self.showToast(message: "Logged-out Successfully!", seconds: 1.5)
        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as? ViewController
        self.view.window?.rootViewController = mainViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() { [weak self] in
                    self?.userImage.image = UIImage(data: data)
                }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

extension UIViewController{

func showToast(message : String, seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
 }
