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
import FirebaseStorage

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
        
        let userID = Auth.auth().currentUser?.uid
        let storageRef = Storage.storage().reference()
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        
        let ref = storageRef.child("\(userID!).png")
        
        let d: Data = tempImage.pngData()!
        
        ref.putData(d, metadata: metaData) { (metadata, error) in
            if error != nil {
                print("An Error Occured! \(error!)")
            } else {
                ref.downloadURL { url, err in
                    let newImageURL = url
                    let db = Firestore.firestore()
                    db.collection("users").document(userID!).updateData(["img": newImageURL!.absoluteString])
                }
            }
        }
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
                
                // switch to using custom document id to find document (userID was used to add a document)
                db.collection("users").document(userID!).delete()
                self.showToast(message: "User Account and Data Deleted!", seconds: 2.0)
                let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as? ViewController
                self.view.window?.rootViewController = mainViewController
                self.view.window?.makeKeyAndVisible()
                
                
                // find document using wherefield-isequalto
//                db.collection("users").whereField("uid", isEqualTo: userID!).getDocuments { snapshot, error in
//                    if error != nil {
//                        print("An error occured. \(error!)")
//                    } else {
//                        for document in snapshot!.documents {
//                            print("\(document.documentID) => \(document.data())")
//                            db.collection("users").document(document.documentID).delete()
//                        }
//                        self.showToast(message: "User Account and Data Deleted!", seconds: 2.0)
//                        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as? ViewController
//                        self.view.window?.rootViewController = mainViewController
//                        self.view.window?.makeKeyAndVisible()
//
//                    }
//                }
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
    
    
    @IBAction func updateBtn(_ sender: Any) {
        let currentUser = Auth.auth().currentUser
        let userID = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        
//        // using custom id (userid) that was set during registration to find document
//        let document = db.collection("users").document(userID!)
//        var updatedData = false
//        let screenName = self.userNameField.text!
//        let screenEmail = self.userEmailField.text!
//
//        if screenName != document.value(forKey: "name") as? String {
//            document.updateData(["name": screenName])
//            updatedData = true
//        }
//        if screenEmail != document.value(forKey: "email") as? String {
//            document.updateData(["email": screenEmail])
//            currentUser?.updateEmail(to: screenEmail)
//            updatedData = true
//        }
//        if updatedData == true {
//            self.showToast(message: "Data Updated!", seconds: 2.0)
//        } else {
//            self.showToast(message: "No Changes!", seconds: 1.0)
//        }
        
//         find document using wherefield and userid isequalto
        db.collection("users").whereField("uid", isEqualTo: userID!).getDocuments() { (querySnapshot, error) in
            if error != nil {
                print("An Error Occured! \(error!)")
            } else {
                for document in querySnapshot!.documents {
                    let documentID = document.documentID
                    var updatedData = false
                    if self.userNameField.text! != document.data()["name"] as? String {
                        db.collection("users").document(documentID).updateData(["name": self.userNameField.text!])
                        updatedData = true
                    }
                    if self.userEmailField.text! != document.data()["email"] as? String {
                        db.collection("users").document(documentID).updateData(["email": self.userEmailField.text!])
                        currentUser?.updateEmail(to: self.userEmailField.text!)
                        updatedData = true
                    }
                    if updatedData == true {
                        self.showToast(message: "Data Updated!", seconds: 2.0)
                    } else {
                        self.showToast(message: "No Changes!", seconds: 1.0)
                    }
                }
            }
        }
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
