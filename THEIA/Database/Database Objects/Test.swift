//
//  Test.swift
//  THEIA
//
//  Created by William Chen on 2023/1/11.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class Test: NSObject, Codable {

    @DocumentID var id: String?
    
    var name: String?
    var components : [Step]?
    var steps : [Step]?
    var beforeStarting : [String]?
    var timer : Int?
    
    
}
