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
        
        getUserDetails()
    }
    
    
    @IBOutlet weak var userNameField: UITextField!
    
    @IBOutlet weak var userEmailField: UITextField!
    
    @IBOutlet weak var userImage: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    @IBAction func imageChooserBtn(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            print("Button Capture")
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
        func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
            userImage.image = image
        }
    }
    
    
    
    
    @IBAction func deleteAccountBtn(_ sender: UIButton) {
        
    }
    
    
    
    @IBAction func logoutBtn(_ sender: UIButton) {
        try? Auth.auth().signOut()
        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as? MainViewController
        self.view.window?.rootViewController = mainViewController
        self.view.window?.makeKeyAndVisible()
        
    }
    
    func getUserDetails() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: userID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting document. \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    var temp_email = document.data()["email"]
                    var temp_name = document.data()["name"]
                    var temp_img = document.data()["img"] as? String
                    self.userNameField.text = temp_name as? String
                    self.userEmailField.text = temp_email as? String
                    
                    let url = URL(string: temp_img!)
                    self.downloadImage(from: url!)
                    
                    
                }
            }
        }
        
        
    }
    
    func downloadImage(from url: URL) {
        print("Download started")
        getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                print("Download Finished")
                // always update the UI from the main thread
                DispatchQueue.main.async() { [weak self] in
                    self?.userImage.image = UIImage(data: data)
                }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}


