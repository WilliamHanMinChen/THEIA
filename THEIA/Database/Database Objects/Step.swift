//
//  Step.swift
//  COVIDGuide
//
//  Created by William Chen on 2022/11/28.
//

import UIKit

class Step: NSObject, Codable {
    
    var stepDescription: String
    var audioURL: String
    
    init(stepDescription: String, audioURL: String) {
        self.stepDescription = stepDescription
        self.audioURL = audioURL
    }

}
