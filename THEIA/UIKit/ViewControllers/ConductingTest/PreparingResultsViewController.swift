//
//  PreparingResultsViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/1/21.
//

import UIKit

class PreparingResultsViewController: UIViewController {
    
    
    
    
    
    @IBOutlet weak var nextStepButton: UIButton!
    
    
    @IBOutlet weak var resultsTitleLabel: UILabel!
    
    var scannedTest: Test?
    
    //Haptic feedback engine
    let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextStepButton.setupButton()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func nextStepAction(_ sender: Any) {
        
        //Give haptic feedback
        mediumImpact.impactOccurred()
        
        performSegue(withIdentifier: "preparingToCaptureSegue", sender: nil)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Set our Next VC's Test
        if segue.identifier == "preparingToCaptureSegue" {
            let destination = segue.destination as! TestCapturerViewController
            
            destination.scannedTest = self.scannedTest
        }
    }
    

}
