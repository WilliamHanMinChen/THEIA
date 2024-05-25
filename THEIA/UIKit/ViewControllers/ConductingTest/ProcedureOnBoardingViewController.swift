//
//  ProcedureOnBoardingViewController.swift
//  COVIDGuide
//
//  Created by William Chen on 2022/11/28.
//

import UIKit
import SwiftCSVExport


class ProcedureOnBoardingViewController: UIViewController {
    
    //The Rapid Antigen Test the user has scanned
    var scannedTest: Test?
    
    //Step Index, Keeps track of which step we are at
    var stepIndex = 0
    
    
    //Reference to the title label
//    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    
    @IBOutlet weak var nextStepButton: UIButton!
    @IBOutlet weak var previousStepButton: UIButton!
    
    //Haptic feedback engine
    let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    
    var startedTime = Date()
    
    var calendar = Calendar.current
    
    var conductingTime:[Int] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the name
//        titleLabel.text = scannedRAT?.name
        

        guard let steps = scannedTest?.steps else {
            fatalError("Failed to get steps")
        }
        
        
        // Do any additional setup after loading the view.
//        titleLabel.text = "Step \(stepIndex + 1)"
        contentLabel.text = "Step \(stepIndex + 1): " + (steps[stepIndex].stepDescription ?? "")
        
        //Setup the buttons
        nextStepButton.setupButton()
        previousStepButton.setupButton()
        
        //Update our navigation heading
        navigationItem.title = "Conduct the test"
        
        //Check if we have components learning time stored already, if not, instantiate it
        if conductingTime.isEmpty {
            conductingTime = []
            for components in scannedTest?.steps ?? [] {
                conductingTime.append(0)
            }
        }
        
        print("Current components time \(conductingTime)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startedTime = Date()
    }
    

    @IBAction func nextStepPressed(_ sender: Any) {
        
        guard let steps = scannedTest?.steps else {
            fatalError("Failed to get steps")
        }
        
        let stepCount = steps.count
        
        //Give haptic feedback
        mediumImpact.impactOccurred()
        
        updateTime(stepIndex: stepIndex)
        
        print("Current conducting time \(conductingTime)")

        
        
        if stepIndex < stepCount - 1 {
            //Increment our counter
            stepIndex += 1
            //Update our labels
//            titleLabel.text = "Step \(stepIndex + 1)"
            contentLabel.text = "Step \(stepIndex + 1): " + (steps[stepIndex].stepDescription ?? "")
            
            //Update our voiceover focus
            UIAccessibility.post(notification: .screenChanged, argument: contentLabel)
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
    
    
    func updateTime(stepIndex: Int){
        
        //Record time taken and reset the timer
        guard let secondsPassed = calendar.dateComponents([.second], from: startedTime ?? Date(), to: Date()).second else {
            fatalError("Could not calculate seconds passed")
        }
        conductingTime[stepIndex] = (conductingTime[stepIndex]) + secondsPassed
        startedTime = Date()
        
    }
    
    @IBAction func previousStepPressed(_ sender: Any) {
        
        guard let steps = scannedTest?.steps else {
            fatalError("Failed to get steps")
        }
        
        
        let stepCount = steps.count
        
        updateTime(stepIndex: stepIndex)
        print("Current conducting time \(conductingTime)")


        //Give haptic feedback
        mediumImpact.impactOccurred()
        
        if stepIndex > 0 {
            //Decrease our counter
            stepIndex -= 1
            //Update our labels
//            titleLabel.text = "Step \(stepIndex + 1)"
            contentLabel.text = "Step \(stepIndex + 1): " + (steps[stepIndex].stepDescription ?? "")
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
            
            writeData()
        }
    }
    
    func writeData(){
        
        //Getting the time completed
        let date = Date()
        let timeFormatted = date.getFormattedDate(format: "yyyy-MM-dd-HH-mm-ss")
        
        
        var fileName = timeFormatted + "-" + "steps_learning_time" + "-"

        
        
        // Add dictionary into rows of CSV Array
        let data:NSMutableArray  = NSMutableArray()
        //Output to CSV
        for dataPoint in conductingTime {
            
            let dataPointData: NSMutableDictionary = NSMutableDictionary()
            dataPointData.setObject(dataPoint, forKey: "Time spent" as NSCopying);
            data.add(dataPointData);
            
        }
        
        // Add fields into columns of CSV headers
        let header = ["Time spent"]
        
        // Create a object for write CSV
        let writeCSVObj = CSV()
        writeCSVObj.rows = data
        writeCSVObj.delimiter = DividerType.comma.rawValue
        writeCSVObj.fields = header as NSArray
        writeCSVObj.name = fileName
        
        
        // Write File using CSV class object
        let result = CSVExport.export(writeCSVObj)
        
        print("Exported")
    }
    

}
