//
//  ComponentsLearningViewController.swift
//  COVIDGuide
//
//  Created by William Chen on 2022/11/29.
//

import UIKit

class ComponentsLearningViewController: UIViewController {
    
    //The Rapid Antigen Test the user has scanned
    var scannedTest: Test?
    
    //Indicates which component explanation step we are at
    var componentStepIndex = -1
    
    //Haptic feedback engine
    let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    
    
    //References
    @IBOutlet weak var testTypeLabel: UILabel!
    
    @IBOutlet weak var topButton: UIButton!
    
    @IBOutlet weak var bottomButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let beforeStarting = scannedTest?.beforeStarting else {
            fatalError("Failed to get before starting")
        }
        
        titleLabel.text = "Before you start"
        
        var beforeStartingMessage = ""
        
        var counter = 1
        for message in beforeStarting {
            beforeStartingMessage += counter.description + ". " + message + "\n"
            counter += 1
        }
        
        contentLabel.text = beforeStartingMessage
        
        
        //Setup the buttons
        topButton.setupButton()
        bottomButton.setupButton()
        
        //Update our navigation heading
        navigationItem.title = scannedTest?.name

    }
    
    
    
    
    @IBAction func topButtonPressed(_ sender: Any) {
        
        //Give haptic feedback
        mediumImpact.impactOccurred()
        
        guard let components = scannedTest?.components else {
            fatalError("Failed to get components")
        }
        
        //User wants to learn the components
        if componentStepIndex == -1{
            //Increment our counter
            componentStepIndex += 1
        
            
            //Update the text labels
            titleLabel.text = "Step \(componentStepIndex + 1)"
            contentLabel.text = components[componentStepIndex].stepDescription
            //Update the buttons text
            topButton.setTitle("Next step", for: .normal)
            bottomButton.setTitle("Previous step", for: .normal)
            
            //Update our voiceover focus
            UIAccessibility.post(notification: .screenChanged, argument: titleLabel)
            
            
            navigationItem.title = "Components"
            
        } else {
            //Get the length of the component explanations
            let length = components.count
            //Check which index we are at
            if componentStepIndex == length - 2 { //Second last one, update our button text and move on
                componentStepIndex += 1
                topButton.setTitle("Conduct the test", for: .normal)
                titleLabel.text = "Step \(componentStepIndex + 1)"
                contentLabel.text = components[componentStepIndex].stepDescription
                //Update our voiceover focus
                UIAccessibility.post(notification: .screenChanged, argument: titleLabel)
                
                
            } else if componentStepIndex == length - 1 { //Last one, we go to conduct test page
                self.performSegue(withIdentifier: "componentConductSegue", sender: nil)
                
            } else {//Update our text label
                componentStepIndex += 1
                titleLabel.text = "Step \(componentStepIndex + 1)"
                contentLabel.text = components[componentStepIndex].stepDescription
                
                //Update our voiceover focus
                UIAccessibility.post(notification: .screenChanged, argument: titleLabel)
                
            }
            
        }
        
        
        
        
    }
    
    @IBAction func bottomButtonPressed(_ sender: Any) {
        
        //Give haptic feedback
        mediumImpact.impactOccurred()
        
        guard let components = scannedTest?.components else {
            fatalError("Failed to get components")
        }
        
        
        //User wants to conduct the test
        if componentStepIndex == -1{
            self.performSegue(withIdentifier: "componentConductSegue", sender: nil)
        } else {
            //Check if we are at 0, if so, update our buttons
            if componentStepIndex == 0{
                componentStepIndex -= 1
                topButton.setTitle("Learn the components", for: .normal)
                bottomButton.setTitle("Conduct the test", for: .normal)
                
                guard let beforeStarting = scannedTest?.beforeStarting else {
                    fatalError("Failed to get before starting")
                }
                
                titleLabel.text = "Before you start"
                
                var beforeStartingMessage = ""
                
                var counter = 1
                for message in beforeStarting {
                    beforeStartingMessage += counter.description + ". " + message + "\n"
                    counter += 1
                }
                
                contentLabel.text = beforeStartingMessage
                
                //Update our navigation heading
                navigationItem.title = scannedTest?.name
                
                
            } else {
                
                //Get the length of the component explanations
                let length = components.count
                //Last component, update our button label
                if componentStepIndex == length - 1 {
                    topButton.setTitle("Next step", for: .normal)
                    
                }
                //Update our labels
                componentStepIndex -= 1
                titleLabel.text = "Step \(componentStepIndex + 1)"
                contentLabel.text = components[componentStepIndex].stepDescription
                
                //Update our voiceover focus
                UIAccessibility.post(notification: .screenChanged, argument: titleLabel)
                
                
                
            }
            
        }
        
    }
    
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "backSegue", sender: nil)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "componentConductSegue" {
            //Set the destionation's scanned RAT property
            let destination = segue.destination as! ProcedureOnBoardingViewController
            destination.scannedTest = self.scannedTest
        }
    }

}
