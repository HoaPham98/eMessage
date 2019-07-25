//
//  User.swift
//  eMessage
//
//  Created by HoaPQ on 7/22/19.
//  Copyright © 2019 HoaPQ. All rights reserved.
//

import Foundation
import FirebaseDatabase

// Struct lưu thông tin các user
struct UserModel {
    var uid: String
    var username: String
    
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
    }
    
    init?(_ snapshot: DataSnapshot) {
        self.uid = snapshot.key
        let dict = snapshot.value as! [String: Any?]
        self.username = dict["username"] as! String
    }
    
}

extension UserModel: DatabaseRepresentation {
    
    var representation: [String : Any] {
        let rep = ["uid": uid, "username": username]
        
        return rep
    }
    
}

extension UserModel: Comparable {
    
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    static func < (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.username < rhs.username
    }
    
}

