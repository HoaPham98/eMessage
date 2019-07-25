//
//  ChatViewController.swift
//  eMessage
//
//  Created by HoaPQ on 7/25/19.
//  Copyright © 2019 HoaPQ. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseDatabase

class ChatViewController: MessagesViewController {
    
    var currentUser: UserModel = UserModel(uid: AppSettings.uid, username: AppSettings.username)
    var partner: UserModel!
    var childKey1: String!
    var childKey2: String!
    
    var messages = [MessageModel]()
    var ref: DatabaseReference!
    
    init(with partner: UserModel) {
        super.init(nibName: nil, bundle: nil)
        self.partner = partner
        
        self.childKey1 = "\(currentUser.uid)_\(partner.uid)"
        self.childKey2 = "\(partner.uid)_\(currentUser.uid)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.messageInputBar.delegate = self
        self.messagesCollectionView.messagesDataSource = self
        self.messagesCollectionView.messagesLayoutDelegate = self
        self.messagesCollectionView.messagesDisplayDelegate = self
        
        ref = Database.database().reference().child("channels")
        
        ref.child(childKey1).observe(.childAdded) { (snapshot) in
            if let message = MessageModel(snapshot) {
                self.insertNewMessage(message: message)
            }
        }
    }
    
    func save(message: MessageModel) {
        ref.child(childKey1).childByAutoId().setValue(message.representation)
        ref.child(childKey2).childByAutoId().setValue(message.representation)
    }
    
    func insertNewMessage(message: MessageModel) {
        guard !messages.contains(message) else {
            return
        }
        messages.append(message)
        messages.sort()
        
        self.messagesCollectionView.reloadData()
    }
}

extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        return Sender(id: currentUser.uid, displayName: currentUser.username)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return self.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.messages.count
    }
    
    
}

extension ChatViewController: MessagesLayoutDelegate {
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = MessageModel(user: currentUser, content: text)
        
        save(message: message)
        
        inputBar.inputTextView.text = ""
    }
}
