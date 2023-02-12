//
//  ScanTestPackagingViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/2/9.
//

import UIKit
import ARKit
import RealityKit

import Firebase
import FirebaseAuth
import CryptoKit

class ScanTestPackagingViewController: UIViewController, ARSessionDelegate, DatabaseListener {
    
    
    @IBOutlet weak var arView: ARView!
    
    
    @IBOutlet weak var searchButton: UIButton!
    
    //Stores a referene to the database
    weak var dataBaseController: DatabaseProtocol?
    
    //Sets the listener type
    var listenerType: ListenerType = ListenerType.test
    
    //List of tests we are scanning for
    var tests: [Test] = []
    
    var filteredTests: [Test] = []
    
    //The chosen test type
    var testType: TestType?
    
    //The list of image paths we are recognising for
    var imagePaths: [String?] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Session configuration for images
        let configuration = ARImageTrackingConfiguration()
        //Loads all the images its going to look for
        let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
        
        //Tells the configuration to look for these reference images
        configuration.trackingImages = referenceImages
        
        // Both trackingImages and maximumNumberOfTrackedImages are required
        // This example assumes there is only one reference image named "target"
        configuration.maximumNumberOfTrackedImages = 10
        configuration.trackingImages = referenceImages
        
        // Set ARView delegate so we can define delegate methods in this controller
        arView.session.delegate = self
        
        // Forgo automatic configuration to do it manually instead
        arView.automaticallyConfigureSession = false
        
        // Disable any unneeded rendering options
        arView.renderOptions = [.disableCameraGrain, .disableHDR, .disableMotionBlur, .disableDepthOfField, .disableFaceOcclusions, .disablePersonOcclusion, .disableGroundingShadows, .disableAREnvironmentLighting]
        
        // Run an ARView session with the defined configuration object
        //arView.session.run(configuration)
        
        arView.session.run(configuration)
        
        searchButton.setupButton()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        dataBaseController = appDelegate?.databaseController
        
        
    }
    
    //This registers this class to receive updates from the database
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataBaseController?.addListener(listener: self)
    }
    
    //This unregisters this class to receive updates from the database
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataBaseController?.removeListener(listener: self)
    }
    

    func updateARImages(){
        
        //Get our directory
        //Get the paths
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //Gets the documents directory
        let documentsDirectory = paths[0].appendingPathComponent((testType?.testTypeName!)!.replacingOccurrences(of: " ", with: "-") + "-PackagingImages", conformingTo: .folder)
        
        print(documentsDirectory)
        
        //Check if the folder exists, if not, create one
        
        var isDir:ObjCBool = true
        if !FileManager.default.fileExists(atPath: documentsDirectory.description, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
            }
            catch {
                
            }
        }


        
        
        //Loop through the tests
        for test in tests{
            //Loop through the image links
            for imageLink in test.packagingImages{

                //Calculate the URL's hash value
                let inputString = imageLink
                let inputData = Data(inputString!.utf8)
                let hashed = SHA256.hash(data: inputData)
                
                //Set the file name
                let filename = imageLink

                //Get the iamge URL
                let imageURL = documentsDirectory.appendingPathComponent(hashed.description + ".png")
                
                let image = UIImage(contentsOfFile: imageURL.path)


                if let image = image {
                    print("Image exists")
                } else {
                    //Download it
                    let url = URL(string: imageLink!)!
                    
                    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                       if let error = error {

                          // handle error
                          return
                       }
                       guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                          // handle error
                          return
                       }
                       if let data = data {
                           do {
                               // process data
                                try data.write(to: imageURL)
                           } catch {
                               print(error)
                           }
                           
                           //Try loading it
                           let image = UIImage(contentsOfFile: imageURL.path)
                           if let image = image {
                               print("Got the image")
                           } else {
                               print("Failed to get image")
                           }
                           
                       }
                    }.resume()


                }

            }
        }
    }
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        
        for anchor in anchors{
            
            if let imageAnchor = anchor as? ARImageAnchor {
                
                
                print("Anchor found")
            }
        }
    }
    
    
    
    @IBAction func searchButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "PackagingToSearchingSegue", sender: nil)
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PackagingToSearchingSegue" {
            let destination = segue.destination as! SearchTestsTableViewController
            
            destination.testType = testType
        }
    }
    
    
    
    func onAuthStateChange(user: User) {
        
        
    }
    
    func onAuthError(error: NSError) {
        
        
    }
    
    func onEndUserChange(change: DataBaseChange, user: EndUser) {
        
        
    }
    
    func onTestTypesChange(change: DataBaseChange, testTypes: [TestType]) {
        
        
    }
    
    func onTestChange(change: DataBaseChange, tests: [Test]) {
        
        var newTests:[Test] = []
        //If it is within the test barcodes
        for test in tests {
            if ((testType?.barCodes?.contains(test.id ?? "")) != nil){
                newTests.append(test)
            }
        }
        self.tests = newTests
        //Update our AR Images set
        updateARImages()
    }
    

}
