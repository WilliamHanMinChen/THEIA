//
//  BarcodeScanningViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/1/21.
//

import UIKit
import AVFoundation
import Vision
import FirebaseFirestore
import FirebaseFirestoreSwift

class BarcodeScanningViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    @IBOutlet weak var previewView: UIView!
    
    
    @IBOutlet weak var noBarcodeButton: UIButton!
    
    
    //Boolean indicating whether we have handled the scan or not
    var handledScan = false
    
    //The chosen test type
    var testType: TestType?
    
    //The session that captures Audio Visual input
    let session = AVCaptureSession()
    //The preview layer to be displayed to the user
    var previewLayer: AVCaptureVideoPreviewLayer! = nil
    //Class used to process frames captured from AVCaptureSession
    let videoDataOutput = AVCaptureVideoDataOutput()
    
    //Video capture device reference
    var videoCaptureDevice: AVCaptureDevice?
    
    // Vision parts
    private var requests = [VNRequest]()
    
    //Haptic feedback engine
    let feedback = UINotificationFeedbackGenerator()
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    var bufferSize: CGSize = .zero
    var rootLayer: CALayer! = nil
    
    var database : Firestore?
    
    //Our scanned test
    var scannedTest : Test?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupAVCapture()
        setupBarcodeRequest()
        // start the capture
        startCaptureSession()
        
        noBarcodeButton.setupButton()
        
        //Get our database reference
        database = Firestore.firestore()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session.stopRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        session.startRunning()
        
        //Turn on the flash;ight
        try? videoCaptureDevice!.lockForConfiguration()
        videoCaptureDevice?.torchMode = .on
        videoCaptureDevice!.unlockForConfiguration()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.navigationBar.sizeToFit()
        }
        self.handledScan = false
        
        #if targetEnvironment(simulator)
            return
        #endif
    }
    
    // Clean up capture setup
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }
    
    func startCaptureSession() {
        session.startRunning()
        
        //Turn on the flash;ight
        try? videoCaptureDevice!.lockForConfiguration()
        videoCaptureDevice?.torchMode = .on
        videoCaptureDevice!.unlockForConfiguration()
        
    }
    
    
    
    func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration()
        //session.sessionPreset = .vga640x480 // Model image size is smaller.
        
        // Add a video input
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        let captureConnection = videoDataOutput.connection(with: .video)
        
        // Always process the frames
        captureConnection?.isEnabled = true
        do {
            try  videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
            //Get our reference
            self.videoCaptureDevice = videoDevice
        } catch {
            print(error)
        }
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = previewView.layer
        //Setting the preview dimensions
        previewLayer.frame = CGRect(x: 0, y: 0, width: previewView.frame.width, height: previewView.frame.height)
        rootLayer.addSublayer(previewLayer)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        //This is called every frame
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            //Performs vision requests (images to be processed)
            try imageRequestHandler.perform(self.requests)
            
        } catch {
            print(error)
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        print("frame dropped")
        
    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
    
    
    //Setup Barcode scanning request
    func setupBarcodeRequest(){

        //Initialise the request and give it a callback function
        let barcodeDetectRequest = VNDetectBarcodesRequest(completionHandler: self.detectedBarcode)
        //Only detect certaint types of code
        barcodeDetectRequest.symbologies = [.ean8, .ean13, .pdf417]
        //Append it to the requests
        requests.append(barcodeDetectRequest)
        
    }
    
    //Function that is called when we detect a barcode
    func detectedBarcode(request: VNRequest?, error: Error?){
        
        //Run it on the main thread
        DispatchQueue.main.async {
            
            guard let results = request?.results as? [VNBarcodeObservation] else {
                print("Failed to cast to VNBarcodeObservations")
                return
            }
            
            //Didnt find anything, just return
            if results.count == 0 {
                return
            }
            
            //Ensure we have only one barcode in our field of view
            if results.count == 1 && !self.handledScan{
                //Print out the result
                let barcodeValue = results.first!.payloadStringValue!
                print("Found barcode with value: \(barcodeValue)")
                
                //Check if it is within the same test type
                guard let barcodes = self.testType?.barCodes else {
                    fatalError("Failed to get barcodes")
                }
                
                if barcodes.contains(barcodeValue) {
                    //Set handled scan to true
                    self.handledScan = true
                    print("Found valid bar code")
                    
                    //Get the test information from the database
                    
                    let docRef = self.database?.collection("tests").document(barcodeValue)
                      
                    docRef?.getDocument(as: Test.self) { result in
                        switch result {
                        case .success(let test):
                          // A Test value was successfully initialized from the DocumentSnapshot.
                          self.scannedTest = test
                            print("Test downloaded \(test.name)")
                            self.performSegue(withIdentifier: "barCodeScannedSegue", sender: nil)
                            self.feedback.notificationOccurred(.success)
                        case .failure(let error):
                          //Error message
                          print("Failed to download test")
                        }
                      }
                    
                } else {
                    print("Found invalid barcode")
                }
                
                
                
            } else {
                print("Ignoring the scan!")
                for observation in results{
                    //Print out the result
                    let barcodeValue = observation.payloadStringValue!
                    print("Found barcode with value: \(barcodeValue)")
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "barCodeScannedSegue"{
            
            //Set our next VC's scanned test
            let destination = segue.destination as! ComponentsLearningViewController
            
            destination.scannedTest = self.scannedTest
        }
        
        if segue.identifier == "BarcodeToPackagingSegue"{
            let destination = segue.destination as! ScanTestPackagingViewController
            
            destination.testType = testType
        }
        
    }

    @IBAction func noBarcodeAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: "BarcodeToPackagingSegue", sender: nil)
        
        
    }
    
    
    // MARK: - Navigation

    

}
