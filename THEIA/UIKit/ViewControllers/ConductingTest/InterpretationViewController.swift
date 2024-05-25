//
//  InterpretationViewController.swift
//  THEIA
//
//  Created by William Chen on 2024/3/2.
//

import UIKit
import CoreML
import Vision
import SwiftCSVExport


class InterpretationViewController: UIViewController {
    
    
    @IBOutlet weak var resultsLabel: UILabel!
    
    @IBOutlet weak var learnMoreButton: UIButton!
    
    @IBOutlet weak var chooseAnotherOptionButton: UIButton!
    
    @IBOutlet weak var finishButton: UIButton!
    
    @IBOutlet weak var actualResultsLabel: UILabel!
    
    @IBOutlet weak var breakDownLabel: UILabel!
    
    
    var resultsString = ""
    var negative: Int = 0
    var positive: Int = 0
    var weak_positive: Int = 0
    var inconclusiveResult: Int = 0
    var counter: Int = 0
    var results: [[VNClassificationObservation]] = []
    
    var classificationRequests: [VNCoreMLRequest] = []
    lazy var classificationRequest: VNCoreMLRequest = {
      do {
        // 1
          let resultsInterpreter = try ResultsInterpreter_V7()
        // 2
        let visionModel = try VNCoreMLModel(
          for: resultsInterpreter.model)
        // 3
        let request = VNCoreMLRequest(model: visionModel,
                                      completionHandler: {
          [weak self] request, error in
            self?.processObservations(for: request, error: error)
        })
        // 4
        request.imageCropAndScaleOption = .centerCrop
        return request
      } catch {
        fatalError("Failed to create VNCoreMLModel: \(error)")
      }
    }()


    //Stores the filepaths of the images that are the clearest
    var clearImages: [URL] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for clearImage in clearImages {
            let data = try? Data(contentsOf: clearImage) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            classify(image: UIImage(data: data!)!)
        }

        
        learnMoreButton.setupButton()
        chooseAnotherOptionButton.setupButton()
        finishButton.setupButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        negative = 0
        positive = 0
        weak_positive = 0
        inconclusiveResult = 0
        counter = 0
        
    }
    
    func processObservations(
      for request: VNRequest,
      error: Error?) {
      // 1
      DispatchQueue.main.async {
        // 2
        if let results = request.results
          as? [VNClassificationObservation] {
          // 3
            //Save our results
            self.results.append(results)
            
            //Process our results
          if results.isEmpty {
              self.inconclusiveResult += 1
          } else {
              
              //If our confidence is larger thna 70%
              if (results[0].confidence * 100 ) > 70 {
                  if results[0].identifier == "Positive" {
                      self.positive += 1
                  } else if results[0].identifier == "Negative" {
                      self.negative += 1
                  } else {
                      self.weak_positive += 1
                  }
                  
                  
              } else {
                  self.inconclusiveResult += 1
              }
              self.counter += 1
              self.resultsString += "Image \(self.counter): " + String(
                format: "%@ %.1f%%",
                results[0].identifier,
                results[0].confidence * 100) + "\n"
              
              //If we have processed all results, print it
              if self.inconclusiveResult + self.positive + self.negative + self.weak_positive == 5 {
                  print( self.resultsString)
                  //Show it to the user
                  self.displayResults()
              }

          }
        // 4
        } else if let error = error {
          print("Error while retrievingdata")
        }

      }
    }
    
    func displayResults(){
        
        self.breakDownLabel.text = "Here is the break down of each image: " + self.resultsString
        //<=1 inconclusive result will mean the user should recapture
        if inconclusiveResult >= 1 {
            actualResultsLabel.text = "Our AI Model has mixed answers about your results based off the 5 images we had chosen. Please either capture your results again or choose another interpretation method."
        } else if negative >= 1 && weak_positive >= 1 && positive >= 1 { //All three results, mark as inconclusive
            actualResultsLabel.text = "Our AI Model could not accurately predict what your results are based off the 5 images we had chosen. Please either capture your results again or choose another interpretation method."
            
        } else if negative >= 1 && positive >= 1 { // Both positive and negative, mark as inconclusive
            actualResultsLabel.text = "Our AI Model has mixed answers about your results based off the 5 images we had chosen. Please either capture your results again or choose another interpretation method."
            
        } else if negative >= 1 && weak_positive >= 1 { //Both weak positive and negative
            
            if negative > weak_positive { //More negative
                actualResultsLabel.text = "Our AI Model thinks that your results are mostly negative but there exists a really faint line within your test window."
            } else {
                actualResultsLabel.text = "Our AI Model thinks that your results are mostly weak positive and there exists a really faint line within your test window."
            }
            
        } else if positive >= 1 && weak_positive >= 1 {
            
            actualResultsLabel.text = "Our AI Model thinks that your results are mostly positive but the T line within your test window is not as strong as the C line."
            
        } else if positive >= 1 { //All positive
            actualResultsLabel.text = "Our AI Model thinks that your results are positive."
        } else if negative >= 1 { //All negative
            actualResultsLabel.text = "Our AI Model thinks that your results are negative."
        } else if weak_positive >= 1 { //All weak positive
            actualResultsLabel.text = "Our AI Model thinks that your results are mostly positive but the T line within your test window is not as strong as the C line."
        }
    }
    
    func classify(image: UIImage) {
      // 1
      guard let ciImage = CIImage(image: image) else {
        print("Unable to create CIImage")
        return
      }
//      // 2
//      let orientation = CGImagePropertyOrientation(
//        rawValue: UInt32(image.imageOrientation.rawValue))
      // 3
      DispatchQueue.global(qos: .userInitiated).async {
        // 4
        let handler = VNImageRequestHandler(
          ciImage: ciImage,
          orientation: .up)
        do {
          try handler.perform([self.classificationRequest])
        } catch {
          print("Failed to perform classification: \(error)")
        }
      }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "AIToLearnMoreSegue" {
            let destination = segue.destination as! LearnMoreViewController
            
            destination.negative = negative
            destination.positive = positive
            destination.weak_positive = weak_positive
            destination.inconclusiveResult = inconclusiveResult
            destination.results = results

        }
    }
    
    
    //MARK: UIBUTTON ACTIONS
    @IBAction func finishButtonAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)

    }
    
    @IBAction func chooseAnotherOptionButtonAction(_ sender: Any) {
        //Pop the last two view controllers
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
    }
    
    @IBAction func learnMoreButtonAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: "AIToLearnMoreSegue", sender: nil)
    }
    
    
}
