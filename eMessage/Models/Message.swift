//
//  Message.swift
//  eMessage
//
//  Created by HoaPQ on 7/29/19.
//  Copyright © 2019 HoaPQ. All rights reserved.
//

import Foundation
import MessageKit
import FirebaseDatabase

struct MessageModel: MessageType {
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var content: String = ""
    
    var kind: MessageKind {
        return .text(content)
    }
    
    // Hàm init để khởi tạo MessageModel khi người dùng ấn nút send
    init(content: String, user: UserModel) {
        self.content = content
        self.sender = Sender(id: user.uid, displayName: user.username)
        self.messageId = ""
        self.sentDate = Date()
    }
    
    // Hàm init để tạo MessageModel từ firebase xuống
    init?(snapshot: DataSnapshot) {
        // Lấy dữ liệu từ snapshot thành dictionary
        let dict = snapshot.value as! [String: Any?]
        // Lấy senderID và senderName từ dictionary
        let senderID = dict["senderID"] as! String
        let senderName = dict["senderName"] as! String
        
        self.sender = Sender(id: senderID, displayName: senderName)
        
        self.messageId = snapshot.key
        
        // Lấy senderDate từ dictionary
        let dateFommater = DateFormatter()
        dateFommater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateString = dict["senderDate"] as! String
        self.sentDate = dateFommater.date(from: dateString) ?? Date()
        
        self.content = dict["content"] as! String
    }
    
}
