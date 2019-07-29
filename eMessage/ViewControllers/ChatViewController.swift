//
//  ChatViewController.swift
//  eMessage
//
//  Created by HoaPQ on 7/29/19.
//  Copyright © 2019 HoaPQ. All rights reserved.
//

import Foundation
import MessageKit
import FirebaseDatabase
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    var messages: [MessageModel] = []
    
    var currentUser = UserModel(uid: AppSettings.uid, username: AppSettings.username)
    
    var partner: UserModel!
    var channelID1: String!
    var channelID2: String!
    
    var channelDB: DatabaseReference!
    
    init(with partner: UserModel) {
        super.init(nibName: nil, bundle: nil)
        self.partner = partner
        
        // Cần 2 channels vì channels của mình và partner đều cần save thêm message mới khi currentUser và partner send message lên firebase
        self.channelID1 = "\(currentUser.uid)_\(partner.uid)"
        self.channelID2 = "\(partner.uid)_\(currentUser.uid)"
        
        channelDB = Database.database().reference().child("channels")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messagesCollectionView.messagesDataSource = self
        self.messagesCollectionView.messagesLayoutDelegate = self
        self.messagesCollectionView.messagesDisplayDelegate = self
        
        // Chỉ listen sự kiện thêm child ở channel ID1
        channelDB.child(channelID1).observe(.childAdded) { (snapshot) in
            if let message = MessageModel(snapshot: snapshot) {
                self.messages.append(message)
                self.messagesCollectionView.reloadData()
            }
        }
        
        // Thêm delegate cho thanh input để bắt sự kiện ấn nút send
        messageInputBar.delegate = self
    }
}

// Cái này tương tự parse dữ liệu cho UITableViewController
extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        return Sender(id: AppSettings.uid, displayName: AppSettings.username)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}

// Bắt sự kiện ấn nút send
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = MessageModel(content: text, user: currentUser)
        inputBar.inputTextView.text = ""
        
        let dateFommater = DateFormatter()
        dateFommater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Firebase không cho lưu kiểu dữ liệu MessageModel nên cần chuyển MessageModel sang dạng dictionary
        let dict: [String: Any] = [
            "senderID": currentUser.uid,
            "senderName": currentUser.username,
            "senderDate": dateFommater.string(from: message.sentDate),
            "content": message.content
        ]
        
        // Save message mới ở cả 2 channel. childById dùng để tự sinh id cho message
        channelDB.child(channelID1).childByAutoId().setValue(dict)
        channelDB.child(channelID2).childByAutoId().setValue(dict)
    }
}
