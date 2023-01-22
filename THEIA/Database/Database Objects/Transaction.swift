//
//  Transaction.swift
//  THEIA
//
//  Created by William Chen on 2023/1/11.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class Transaction: NSObject, Codable {
    
    @DocumentID var id: String?
    
    var amount: Double?
    
    var date: Date?
    
    var refunded: Bool?
    
    
    //Test

}
