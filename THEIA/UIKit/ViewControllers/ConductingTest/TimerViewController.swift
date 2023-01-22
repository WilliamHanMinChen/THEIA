//
//  TimerViewController.swift
//  COVIDGuide
//
//  Created by William Chen on 2022/11/28.
//

import UIKit

class TimerViewController: UIViewController {
    
    
    var scannedTest: Test?
    
    //References
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var readResultsButton: UIButton!
    
    @IBOutlet weak var progressView: UIView!
    
    
    @IBOutlet weak var progressBar: UIView!
    

    @IBOutlet weak var progressBarConstraint: NSLayoutConstraint!
    
    
    
    //Keeps track of the first time the user click the next button
    var firstButtonClickTime: Date?
    
    
    //Keeping track of the amount of time left
    var minutes = 15
    var seconds = 0
    
    var totalSeconds = 900


    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        readResultsButton.tintColor = .systemBlue
        readResultsButton.backgroundColor = .systemBlue
        readResultsButton.layer.cornerRadius = 10
        
        //Initialise the timer
        var timer = Timer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { Timer in
            
            
            //Update our values
            if self.seconds == 0 {
                self.minutes -= 1
                self.seconds = 59
            } else {
                self.seconds -= 1
            }
            
            //Update the label
            self.timeLabel.text = String(format: "%02i:%02i", self.minutes, self.seconds)
            
            //Update our background progress view
            let heightRatio = ((Float(self.minutes * 60)) + Float(self.seconds)) / Float(self.totalSeconds)
            
            //Calculate our new height
            let newHeight = CGFloat(heightRatio) * UIScreen.main.bounds.height
            
        
            
            UIView.animate(withDuration: 1, animations: { () -> Void in
                self.progressBarConstraint.constant = newHeight
                self.progressBar.layoutIfNeeded()
                self.progressView.layoutIfNeeded()
            })
            
            
        })
        
        readResultsButton.isAccessibilityElement = true
        
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        progressBarConstraint.constant = UIScreen.main.bounds.height
        progressBar.layoutIfNeeded()
        
        if let time = scannedTest?.timer {
            self.minutes = time
            self.totalSeconds = time * 60
        }
        
        self.timeLabel.text = String(format: "%02i:%02i", self.minutes, self.seconds)
        
        readResultsButton.setupButton()
        
        
        
    }
    
    
    
    
    
    
    @IBAction func readResultsPressed(_ sender: Any) {
        
        //Check the amount of time left, if not safe to proceed, warn the user
        
        
        
        //timerResultsSegue
        //If ten minutes has passed
        if totalSeconds - ((minutes * 60) + seconds) >= 600 {
            //Move onto the next screen to read the results
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if UIAccessibility.isVoiceOverRunning {
                    UIAccessibility.post(notification: .announcement, argument: "Launching results capture screen")
                }
            }
            
            self.performSegue(withIdentifier: "CaptureToPrepareSegue", sender: nil)
            
        } else {
            //Warn the user before proceeding
            if let firstButtonClickTime = firstButtonClickTime { //If there was already a tap on the button
                if Date().timeIntervalSince(firstButtonClickTime) < 8.0 { //If the last swipe was within 8 seconds
                    print("Moving screens")
                    if UIAccessibility.isVoiceOverRunning {
                        UIAccessibility.post(notification: .screenChanged, argument: "Launching results capture screen")
                    }
                    
                    self.performSegue(withIdentifier: "CaptureToPrepareSegue", sender: nil)
                    
                } else { //Update the last swipe time and announce something to the user
                    print("Updating double click time")
                    self.firstButtonClickTime = Date()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if UIAccessibility.isVoiceOverRunning {
                            UIAccessibility.post(notification: .announcement, argument: "Warning not enough time has passed, Double tap again to capture results")
                        }
                    }
                }
                
            } else {
                //First time double tap
                self.firstButtonClickTime = Date()
                print("Updating double click time")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if UIAccessibility.isVoiceOverRunning {
                        UIAccessibility.post(notification: .announcement, argument: "Warning not enough time has passed, Double tap again to capture results")
                    }
                }
            }
            
            
        }
        
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
