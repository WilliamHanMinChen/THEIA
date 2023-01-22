//
//  TestCapturerViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/1/22.
//

import UIKit
import AVFoundation
import Vision
import Accelerate



class TestCapturerViewController: UIViewController {
    
    //Overlay layer when we detect a test
    private var detectionOverlay: CALayer! = nil

    //Test detection requests
    private var requests = [VNRequest]()
    
    
    //Text recognition request
    lazy var textDetectionRequest: VNRecognizeTextRequest = {
        let textDetectRequest = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        return textDetectRequest
    }()
    
    
    //Saves the currently processed frame's CMSampleBuffer
    var currentFrameData: CMSampleBuffer?
    //Saves our current frame as CIImage
    var currentFrameCIImage: CIImage?
    //Counter for how many images we have taken
    var imageCounter = 0
    
    //Haptic feedback
    let hardImpact = UIImpactFeedbackGenerator(style: .heavy)
    let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    let softImpact = UIImpactFeedbackGenerator(style: .light)
    
    //Records down the time when we last gave haptic feedback
    var lastImapctTime: Date = Date()
    
    //counter used to process every 1,2, or n frame
    var counter = 0
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
