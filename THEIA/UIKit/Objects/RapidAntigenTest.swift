//
//  RapidAntigenTest.swift
//  COVIDGuide
//
//  Created by William Chen on 2022/11/28.
//

import UIKit



class RapidAntigenTest: NSObject {
    
    var name: String
    var imageNames: [String]
    var type: TestType
    var steps: [Step]
    var components: [Step]
    
    init(name: String, imageNames: [String],type: TestType, steps: [Step], components: [Step]) {
        self.name = name
        self.imageNames = imageNames
        self.type = type
        self.steps = steps
        self.components = components
    }
    

}
