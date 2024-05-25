//
//  LeanrMoreViewController.swift
//  THEIA
//
//  Created by William Chen on 2024/3/17.
//

import UIKit
import Vision

class LearnMoreViewController: UIViewController {

    @IBOutlet weak var resultsBreakDownLabel: UILabel!
    
    var resultsString = ""
    var negative: Int = 0
    var positive: Int = 0
    var weak_positive: Int = 0
    var inconclusiveResult: Int = 0
    var results: [[VNClassificationObservation]] = []
    var counter:Int = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        


            
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        processResults()
        counter = 1
    }
    func processResults(){
        // Do any additional setup after loading the view.
        for result in results {
            if result.isEmpty {
                
                resultsString += "Image \(counter): Our AI Model failed to interpret this image \n"
            } else {
                
                var localPredictionString: String = "Image \(counter): "
                
                for prediction in result {
                    localPredictionString += String(
                        format: "%@ %.1f%%",
                        prediction.identifier,
                        prediction.confidence * 100) + ","
                }
                

                var removedTrailingCommalocalPredictionString = localPredictionString.prefix(localPredictionString.count - 1)
                
                removedTrailingCommalocalPredictionString += " \n"
                
                resultsString += removedTrailingCommalocalPredictionString
                
            }
            counter += 1
        }
        
        resultsBreakDownLabel.text! += "\n\(resultsString)"
        
        
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
