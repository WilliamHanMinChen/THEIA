//
//  AnnotationJob.swift
//  THEIA
//
//  Created by William Chen on 2023/12/31.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class AnnotationJob: NSObject {
    
    //ID of the document
    @DocumentID var id: String?
    
    //Array containing the links to files store in Firebase Storage bucket
    var imageLinks: [String]?
    
    //The user's email who initiated this job
    var userID: String?

}
