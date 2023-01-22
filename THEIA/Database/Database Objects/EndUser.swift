//
//  User.swift
//  THEIA
//
//  Created by William Chen on 2023/1/10.
//

import UIKit
import FirebaseFirestoreSwift

class EndUser: NSObject, Codable {
    
    //Document ID (Email of the user)
    @DocumentID var id: String?
    //The user's balance
    var balance: Double?

}
