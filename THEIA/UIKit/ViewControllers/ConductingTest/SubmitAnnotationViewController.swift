//
//  SubmitAnnotationViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/12/31.
//

import UIKit
import FirebaseStorage
import FirebaseAuth

class SubmitAnnotationViewController: UIViewController {
    
    //Stores the filepaths of the images that are the clearest
    var clearImages: [URL] = []
    
    //Stores a referene to the database
    weak var dataBaseController: DatabaseProtocol?
    

    @IBOutlet weak var loadingView: UIView! {
      didSet {
        loadingView.layer.cornerRadius = 6
      }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    

    @IBOutlet weak var sendForAnnotationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendForAnnotationButton.setupButton()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        dataBaseController = appDelegate?.databaseController
        
        loadingView.isHidden = true
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func sendForAnnotationAction(_ sender: Any) {
        
        
        //Get reference to the storage bucket
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        //Create a new job within Firestore for this annotation job
        let userEmail = Auth.auth().currentUser?.email
        //Get the new job ID
        let newJobID = dataBaseController?.addNewAnnotationJob(userEmail: userEmail!)
        
        print("Document added with \(newJobID ?? "INVALID") as ID")
        //Using the return document ID, create a folder to store this job's images
        
        guard let newJobID = newJobID else {
            fatalError("Could not create a new job")
        }
        
        activityIndicator.startAnimating()
        loadingView.isHidden = false
        
        //Array to store the path of the uploaded files
        var uploadedLinksArray : [String] = []
        
        var finishedCount = 0
        
        var updatedDocument = false
        
        for path in clearImages {
            // Create a reference to the file you want to upload: Annotations/DocID/ImageName.jpg
            let fileReference = storageRef.child("Annotations/\(newJobID)/\(path.lastPathComponent)")
            
            // Upload the file to the path
            let uploadTask = fileReference.putFile(from: path, metadata: nil) { metadata, error in
              guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
              }
              // Metadata contains file metadata such as size, content-type.
              let size = metadata.size
              // You can also access to download URL after upload.
                fileReference.downloadURL { (url, error) in
                guard let downloadURL = url else {
                  fatalError("Could not get download URL")
                }
                    uploadedLinksArray.append(downloadURL.absoluteString)
                    //If all images finished uploading
                    if finishedCount == self.clearImages.count  && !updatedDocument{
                        //Finished uploading, remove the spinner
                        self.activityIndicator.stopAnimating()
                        self.loadingView.isHidden = true
                        
                        //Update the Annotation job to contain the links
                        self.dataBaseController?.updateAnnotationJobLinks(annotationID: newJobID, links: uploadedLinksArray)
                        
                        print("Called this function")
                        //Finished uploading, go to the next screen
                    
                    }
                    
//                print("Finished uploading, download it at: \(downloadURL)")
              }
            }
            
            let observer = uploadTask.observe(.success) {snapshot in
                finishedCount += 1
                
                if finishedCount == self.clearImages.count {
                    self.performSegue(withIdentifier: "uploadToSucessSegue", sender: nil)
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
