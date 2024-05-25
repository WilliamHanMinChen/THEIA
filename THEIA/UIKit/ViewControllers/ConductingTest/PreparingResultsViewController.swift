//
//  PreparingResultsViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/1/21.
//

import UIKit

class PreparingResultsViewController: UIViewController {
    
    
    
    
    
    @IBOutlet weak var nextStepButton: UIButton!
    
    
    @IBOutlet weak var testDetectedButton: UIButton!
    
    @IBOutlet weak var capturingImageButton: UIButton!
    
    @IBOutlet weak var resultsTitleLabel: UILabel!
    
    var scannedTest: Test?
    
    //Haptic feedback engine
    let hardImpact = UIImpactFeedbackGenerator(style: .heavy)

    let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    let softImpact = UIImpactFeedbackGenerator(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextStepButton.setupButton()
        testDetectedButton.setupButton()
        capturingImageButton.setupButton()
        testDetectedButton.accessibilityLabel = "Feel the weak haptic."
        capturingImageButton.accessibilityLabel = "Feel the strong haptic."

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func nextStepAction(_ sender: Any) {
        
        //Give haptic feedback
        mediumImpact.impactOccurred()
        
        performSegue(withIdentifier: "preparingToCaptureSegue", sender: nil)
    }
    

    @IBAction func testDetectedHapticButtonPressed(_ sender: Any) {
        
        //Give 5 haptic feedback
        for i in 1 ... 10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.2 * Double(i))) {
                // your code here
                self.softImpact.impactOccurred()
            }
        }
        
        
    }
    
    @IBAction func capturingImageHapticButtonPressed(_ sender: Any) {
        //Give 5 haptic feedback
        for i in 1 ... 10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.2 * Double(i))) {
                // your code here
                self.hardImpact.impactOccurred()
            }
        }
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
