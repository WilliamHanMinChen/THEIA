//
//  Results.swift
//  THEIA
//
//  Created by William Chen on 2023/1/4.
//

import UIKit

enum LineStrength {
    case NotPresent
    case Weak
    case Strong
}
class Results: NSObject, Identifiable {
    
    var testType: String
    
    var testDate: String
    
    var annotated: Bool
    
    var controlLine : LineStrength
    
    var testLine: LineStrength
    
    init(testType: String, testDate: String, annotated: Bool, controlLine: LineStrength, testLine: LineStrength) {
        self.testType = testType
        self.testDate = testDate
        self.annotated = annotated
        self.controlLine = controlLine
        self.testLine = testLine
    }
    
    

}
