//
//  ViewController.swift
//  COVIDGuide
//
//  Created by William Chen on 2022/11/25.
//

import UIKit
import RealityKit
import ARKit

class RATScannerViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    
    //Rapid Antigen Tests
    var RATs: [RapidAntigenTest] = []
    
    //The scanned RAT test
    var scannedRat: RapidAntigenTest?
    
    //Haptic feedback engine
    let feedback = UINotificationFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configuration for tracking images and objects
        let configuration = ARWorldTrackingConfiguration()
        
        
        //Loads all the images its going to look for
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
        
        
        //Provide it to the configuration
        configuration.detectionImages = referenceImages
        
        //Give it a maximum number it can track at the same time
        configuration.maximumNumberOfTrackedImages = 10
        
        // Set ARView delegate so we can define delegate methods in this controller
        arView.session.delegate = self
        
        // Forgo automatic configuration to do it manually instead
        arView.automaticallyConfigureSession = false
        
        // Disable any unneeded rendering options
        arView.renderOptions = [.disableCameraGrain, .disableHDR, .disableMotionBlur, .disableDepthOfField, .disableFaceMesh, .disablePersonOcclusion, .disableGroundingShadows, .disableAREnvironmentLighting]
        
        //Run the session
        arView.session.run(configuration)
        
//        //Setup the RATs
//        setup()
        
        
    }
    
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
       //Loop through the anchors added
        for anchor in anchors {
            //If it is an image anchor
            if let imageAnchor = anchor as? ARImageAnchor{
                
                //Get the name of the anchor
                guard let name = imageAnchor.name else {
                    fatalError("No name set for the image! Check the AR Resources folder")
                }
                
                //Loop through the RATs and see which type it picked up
                for RAT in RATs{
                    //If our name is one of the image names
                    if RAT.imageNames.contains(name) {
                        //Update our scanned RAT
                        scannedRat = RAT
                        //Move onto the next screen
                        self.performSegue(withIdentifier: "scannerScannedSegue", sender: nil)
                        
                        feedback.notificationOccurred(.success)
                        
                    }
                }
                
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        //Loop through the updated anchors
        for anchor in anchors {
            //If it is an image anchor
            if let imageAnchor = anchor as? ARImageAnchor{
                
                print(imageAnchor.name)
                
                
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Check which segue we are going for
        if segue.identifier == "scannerScannedSegue"{
            //Cast our destination
            let destination = segue.destination as! ComponentsLearningViewController
            guard let scannedRat = scannedRat else{
                fatalError("The user did not scan a RAT")
            }
            //destination.scannedRAT = scannedRat
        }
    }
    
}



