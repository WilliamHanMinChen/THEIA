//
//  ProcedureOnBoardingViewController.swift
//  COVIDGuide
//
//  Created by William Chen on 2022/11/28.
//

import UIKit

class ProcedureOnBoardingViewController: UIViewController {
    
    //The Rapid Antigen Test the user has scanned
    var scannedTest: Test?
    
    //Step Index, Keeps track of which step we are at
    var stepIndex = 0
    
    
    //Reference to the title label
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    
    @IBOutlet weak var nextStepButton: UIButton!
    @IBOutlet weak var previousStepButton: UIButton!
    
    //Haptic feedback engine
    let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the name
//        titleLabel.text = scannedRAT?.name
        

        guard let steps = scannedTest?.steps else {
            fatalError("Failed to get steps")
        }
        
        
        // Do any additional setup after loading the view.
        titleLabel.text = "Step \(stepIndex + 1)"
        contentLabel.text = steps[stepIndex].stepDescription
        
        //Setup the buttons
        nextStepButton.setupButton()
        previousStepButton.setupButton()
        
        //Update our navigation heading
        navigationItem.title = "Conduct the test"
        
    }
    

    @IBAction func nextStepPressed(_ sender: Any) {
        
        guard let steps = scannedTest?.steps else {
            fatalError("Failed to get steps")
        }
        
        let stepCount = steps.count
        
        //Give haptic feedback
        mediumImpact.impactOccurred()
        
        
        if stepIndex < stepCount - 1 {
            //Increment our counter
            stepIndex += 1
            //Update our labels
            titleLabel.text = "Step \(stepIndex + 1)"
            contentLabel.text = steps[stepIndex].stepDescription
            
            //Update our voiceover focus
            UIAccessibility.post(notification: .screenChanged, argument: titleLabel)
        }
        //If it is the last step
        if stepIndex == stepCount - 1 {
            
            //If we have already updated the timer and the user pressed it again, go to the timer screen
            if nextStepButton.titleLabel?.text == "Start Timer"{
                performSegue(withIdentifier: "procedureTimerSegue", sender: nil)
                
            }
            
            nextStepButton.setTitle("Start Timer", for: .normal)
        }
        
        
    }
    
    @IBAction func previousStepPressed(_ sender: Any) {
        
        guard let steps = scannedTest?.steps else {
            fatalError("Failed to get steps")
        }
        
        
        let stepCount = steps.count
        
        //Give haptic feedback
        mediumImpact.impactOccurred()
        
        if stepIndex > 0 {
            //Decrease our counter
            stepIndex -= 1
            //Update our labels
            titleLabel.text = "Step \(stepIndex + 1)"
            contentLabel.text = steps[stepIndex].stepDescription
        }
        if stepIndex == stepCount - 2 {
            nextStepButton.setTitle("Next Step", for: .normal)
        }
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "procedureTimerSegue" {
            
            let destination = segue.destination as! TimerViewController
            
            destination.scannedTest = self.scannedTest
        }
    }
    

}
