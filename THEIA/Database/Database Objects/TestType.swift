//
//  TestType.swift
//  THEIA
//
//  Created by William Chen on 2023/1/11.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class TestType: NSObject, Codable {
    
    @DocumentID var id: String?
    
    var importantInformation: [String]?
    
    var NextSteps: String?
    
    var testTypeName: String?
    
    var resultsCapturing: [String]?
    
    var regulations: String?
    
    var barCodes: [String]?

}
