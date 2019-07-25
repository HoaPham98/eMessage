//
//  ListViewController.swift
//  eMessage
//
//  Created by HoaPQ on 7/22/19.
//  Copyright © 2019 HoaPQ. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let cellID = "UserCell"
    
    var userRef: DatabaseReference!
    var ref: DatabaseReference!
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.title = AppSettings.username
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(onLogout))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        ref = Database.database().reference().child("users")
        
        loadData()
    }
    
    func loadData() {
        ref.observe(.childAdded) { (snapshot) in
            if let user = UserModel(snapshot) {
                if !self.users.contains(user) {
                    self.users.append(user)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func onLogout() {
        do {
            try Auth.auth().signOut()
            AppSettings.uid = nil
            AppSettings.username = nil
            
            self.present(UINavigationController(rootViewController: LoginViewController()), animated: true, completion: nil)
        } catch {
            print("Error Logout")
        }
    }

}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = users[indexPath.row].username
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let vc = ChatViewController(with: user)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
