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
        
        self.ref = Database.database().reference().child("users")
        
        
        ref.observe(.childAdded) { (snapshot) in
            if let user = UserModel.init(snapshot: snapshot) {
            
                // Chỉ cho những user có uid khác với uid của mình
                if user.uid == AppSettings.uid {
                    return
                }
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
        
        loadData()
    }
    
    func loadData() {

    }
    
    @objc func onLogout() {

    }

}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = self.users[indexPath.row].username
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Tapped item \(indexPath.row)")
        
        let vc = ChatViewController(with: self.users[indexPath.row])
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
