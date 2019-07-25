//
//  MessageModel.swift
//  eMessage
//
//  Created by HoaPQ on 7/25/19.
//  Copyright © 2019 HoaPQ. All rights reserved.
//

import Foundation
import MessageKit
import FirebaseDatabase

class MessageModel: MessageType {
    
    var id: String?
    var sender: SenderType
    var messageId: String {
        return id ?? UUID().uuidString
    }
    var sentDate: Date
    var content: String
    var kind: MessageKind {
        return .text(content)
    }
    
    var dateFomatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter
    }()
    
    init(user: UserModel, content: String) {
        self.sender = Sender(id: user.uid, displayName: user.username)
        self.content = content
        self.sentDate = Date()
        self.id = nil
    }
    
    init?(_ snapshot: DataSnapshot) {
        let dict = snapshot.value as! [String: Any?]
//        dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let senderID = dict["senderID"] as? String,
            let senderName = dict["senderName"] as? String,
            let content = dict["content"] as? String,
            let created = dict["created"] as? String
        else {
            return nil
        }
        self.id = snapshot.key
        self.sender = Sender(id: senderID, displayName: senderName)
        self.sentDate = dateFomatter.date(from: created)!
        self.content = content
    }
}

extension MessageModel: DatabaseRepresentation {
    var representation: [String : Any] {
//        dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let rep = [
            "created": dateFomatter.string(from: self.sentDate),
            "content": self.content,
            "senderID": self.sender.senderId,
            "senderName": self.sender.displayName
        ]
        
        return rep
    }
}

extension MessageModel: Comparable {
    static func < (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    
}
