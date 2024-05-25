//
//  ComponentsLearningViewController.swift
//  COVIDGuide
//
//  Created by William Chen on 2022/11/29.
//

import UIKit

import Firebase
import FirebaseStorage
import SwiftCSVExport


class ComponentsLearningViewController: UIViewController {
    
    //The Rapid Antigen Test the user has scanned
    var scannedTest: Test?
    
    //Indicates which component explanation step we are at
    var componentStepIndex = -1
    
    //Haptic feedback engine
    let mediumImpact = UIImpactFeedbackGenerator(style: .medium)

    var storageReference = Storage.storage()
    
    var componentsLearningTime:[Int] = []
    
    var startedTime: Date?
    
    var calendar = Calendar.current
    
    //References
    @IBOutlet weak var testTypeLabel: UILabel!
    
    @IBOutlet weak var topButton: UIButton!
    
    @IBOutlet weak var bottomButton: UIButton!
        
    @IBOutlet weak var contentLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let beforeStarting = scannedTest?.beforeStarting else {
            fatalError("Failed to get before starting")
        }
        
//        titleLabel.text = "Before you start"
        
        var beforeStartingMessage = "Before you start\n"
        
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
        
        getInstructionsImage()
        
        //Check if we have components learning time stored already, if not, instantiate it
        if componentsLearningTime.isEmpty {
            componentsLearningTime = []
            for components in scannedTest?.components ?? [] {
                componentsLearningTime.append(0)
            }
        }
        
        print("Current components time \(componentsLearningTime)")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Called this")
        //If we are at the last step and there is no time (user pressed back from conducting screen)
        if componentStepIndex == scannedTest!.components!.count - 1 && startedTime == nil {
            startedTime = Date()
        }
    }
    
    func getInstructionsImage() -> UIImage{
        
        //Ensures we have one, if not, set a default picture
        guard let imageURL = scannedTest?.interpretationImageURL else {
            return UIImage()
        }
        
        let filename = imageURL
        
        //If it exists then we down need to download it again
        if let image = self.loadImageData(filename: filename) {
            print("Image already downloaded")
            return image
        } else {
            // Next Step
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            let downloadTask = storageReference.reference(forURL: imageURL).write(toFile:fileURL)
            downloadTask.observe(.success) { snapshot in
                print("Successfully downloaded image")}
                downloadTask.observe(.failure){ snapshot in print("\(String(describing: snapshot.error))")
                }
        }
        
        return UIImage()
        
    }
    
    //Write the image file locally
    func saveImageData(filename: String, imageData: Data) {
        let paths = FileManager.default.urls(for: .documentDirectory,
            in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("Error writing file: \(error.localizedDescription)")
        }
        
    }
    
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
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
//            titleLabel.text = "Step \(componentStepIndex + 1)"
            contentLabel.text = "Step \(componentStepIndex + 1): " + (components[componentStepIndex].stepDescription ?? "")
            //Update the buttons text
            topButton.setTitle("Next step", for: .normal)
            bottomButton.setTitle("Previous step", for: .normal)
            
            //Update our voiceover focus
            UIAccessibility.post(notification: .screenChanged, argument: contentLabel)
            
            //Start the counter
            startedTime = Date()
            
            navigationItem.title = "Components"
            
        } else {
            updateTime(componentStepIndex: componentStepIndex)

            //Get the length of the component explanations
            let length = components.count
            //Check which index we are at
            if componentStepIndex == length - 2 { //Second last one, update our button text and move on
                componentStepIndex += 1
                topButton.setTitle("Conduct the test", for: .normal)
//                titleLabel.text = "Step \(componentStepIndex + 1)"
                contentLabel.text = "Step \(componentStepIndex + 1): " + (components[componentStepIndex].stepDescription ?? "")
                //Update our voiceover focus
                UIAccessibility.post(notification: .screenChanged, argument: contentLabel)
                
                
            } else if componentStepIndex == length - 1 { //Last one, we go to conduct test page
                self.performSegue(withIdentifier: "componentConductSegue", sender: nil)
            } else {//Update our text label

                
                componentStepIndex += 1
//                titleLabel.text = "Step \(componentStepIndex + 1)"
                contentLabel.text = "Step \(componentStepIndex + 1): " + (components[componentStepIndex].stepDescription ?? "")
                
                //Update our voiceover focus
                UIAccessibility.post(notification: .screenChanged, argument: contentLabel)
                
            }
            
            print("Time taken updated: \(componentsLearningTime)")

            
        }
        
        
        
        
    }
    
    func updateTime(componentStepIndex: Int){
        
        //Record time taken and reset the timer
        guard let secondsPassed = calendar.dateComponents([.second], from: startedTime ?? Date(), to: Date()).second else {
            fatalError("Could not calculate seconds passed")
        }
        componentsLearningTime[componentStepIndex] = (componentsLearningTime[componentStepIndex]) + secondsPassed
        startedTime = Date()
        
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
            
            updateTime(componentStepIndex: componentStepIndex)

            //Check if we are at 0, if so, update our buttons
            if componentStepIndex == 0{
                componentStepIndex -= 1
                topButton.setTitle("Learn the components", for: .normal)
                bottomButton.setTitle("Conduct the test", for: .normal)
                
                guard let beforeStarting = scannedTest?.beforeStarting else {
                    fatalError("Failed to get before starting")
                }
                
//                titleLabel.text = "Before you start"
                
                var beforeStartingMessage = "Before you start\n"
                
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
//                titleLabel.text = "Step \(componentStepIndex + 1)"
                contentLabel.text = "Step \(componentStepIndex + 1): " + (components[componentStepIndex].stepDescription ?? "")
                
                //Update our voiceover focus
                UIAccessibility.post(notification: .screenChanged, argument: contentLabel)

            }
            print("Time taken updated: \(componentsLearningTime)")

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
            
            //Reset the start time so when the user comes, back we do not add the time spent in the other VC
            startedTime = nil
            //Set the destionation's scanned RAT property
            let destination = segue.destination as! ProcedureOnBoardingViewController
            destination.scannedTest = self.scannedTest
            
            
            //Write the results into a CSV
            writeData()
        }
    }
    
    func writeData(){
        
        //Getting the time completed
        let date = Date()
        let timeFormatted = date.getFormattedDate(format: "yyyy-MM-dd-HH-mm-ss")
        
        
        var fileName = timeFormatted + "-" + "components_learning_time" + "-"

        
        
        // Add dictionary into rows of CSV Array
        let data:NSMutableArray  = NSMutableArray()
        //Output to CSV
        for dataPoint in componentsLearningTime {
            
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


extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

