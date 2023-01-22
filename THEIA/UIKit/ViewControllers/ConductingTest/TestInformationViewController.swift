//
//  PreConductTestScreenViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/1/20.
//

import UIKit

class TestInformationViewController: UIViewController {
    
    //The selected Test Type
    var selectedTestType: TestType?

    
    @IBOutlet weak var informationLabel: UILabel!
    
    @IBOutlet weak var capturingInformationLabel: UILabel!
    
    
    @IBOutlet weak var nextStepButtonReference: UIButton!
    
    @IBOutlet weak var ImportantInfo: UILabel!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var resultsCapturingLabel: UILabel!
    
    //Haptic feedback engine
    let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize.width = UIScreen.screenWidth
        // Do any additional setup after loading the view.
        
        ImportantInfo.attributedText = "Important Information:".underLined
        
        resultsCapturingLabel.attributedText = "Results Capturing:".underLined
        
        
        guard let importantInformation = selectedTestType?.importantInformation else {
            fatalError("Failed to get important information")
        }
        
        //Get the display information string
        var displayInformation = ""
        
        
        //Loop through the instructions
        for information in importantInformation{
            displayInformation += "\u{2022} " + information + "\n"
        }
        
        informationLabel.text = displayInformation
        
        
        //Get the results capturing information string
        var resultsCapturingInformation = ""
        
        guard let captureInformation = selectedTestType?.resultsCapturing else {
            fatalError("Failed to get results capturing string")
        }
        
        //Loop through the information
        for information in captureInformation{
            resultsCapturingInformation += "\u{2022} " + information + "\n"
        }
        
        capturingInformationLabel.text = displayInformation
        
        nextStepButtonReference.setupButton()
        
        
    }
    

    
    //MARK: Button Actions
    
    @IBAction func nextStepAction(_ sender: Any) {
        
        //Give haptic feedback
        mediumImpact.impactOccurred()
        
        performSegue(withIdentifier: "ConductingBarScanningSegue", sender: selectedTestType!)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Set our next VC's test type
        if segue.identifier == "ConductingBarScanningSegue" {
            
            let destination = segue.destination as! BarcodeScanningViewController
            
            destination.testType = sender as! TestType
        }
    }

}


extension String {

    var underLined: NSAttributedString {
        NSMutableAttributedString(string: self, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
    }

}
