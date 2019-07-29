//
//  ViewController.swift
//  eMessage
//
//  Created by HoaPQ on 7/22/19.
//  Copyright © 2019 HoaPQ. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var buttonStart: UIButton!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkLogined()
        setUpView()
    }
    
    func setUpView() {
        viewContainer.layer.cornerRadius = 10
        buttonStart.layer.cornerRadius = buttonStart.frame.size.height / 2
        ref = Database.database().reference()
    }
    
    // Kiểm tra nếu login rồi thì chuyển luôn sang màn list
    func checkLogined() {
        if Auth.auth().currentUser != nil {
            let vc = UINavigationController(rootViewController: ListViewController())
            DispatchQueue.main.async {
                self.present(vc, animated: false, completion: nil)
            }
        }
    }
    
    
    @IBAction func onStart(_ sender: Any) {
        if let name = textFieldName.text, !name.isEmpty {
            buttonStart.titleLabel?.text = "Loading..."
            buttonStart.isEnabled = false
            Auth.auth().signInAnonymously { (result, error) in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.showMessage(title: "Error", message: "Something wrong, please try again")
                        self.buttonStart.titleLabel?.text = "Start"
                        self.buttonStart.isEnabled = true
                    }
                    return
                }
                if let user = Auth.auth().currentUser {
                    self.saveUser(user: user)
                
                    let vc = UINavigationController(rootViewController: ListViewController())
                    self.present(vc, animated: true, completion: nil)
                
                }
            }
        } else {
            self.showMessage(title: "Error", message: "Please choose a display name")
        }
    }
    
    func saveUser(user: User) {
        AppSettings.username = self.textFieldName.text!
        AppSettings.uid = user.uid
        self.ref.child("users").child("\((AppSettings.uid)!)").child("username").setValue(AppSettings.username)
    }
}

