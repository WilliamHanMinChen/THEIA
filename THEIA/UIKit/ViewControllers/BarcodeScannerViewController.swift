/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains the view controller for the Breakfast Finder.
*/

import UIKit
import AVFoundation
import Vision
import SwiftUI


//Delegate methods

protocol BarcodeScanningViewControllerDelegate {
    func finishedScanning(readRAT: RapidAntigenTest)
}

class BarcodeScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var bufferSize: CGSize = .zero
    var rootLayer: CALayer! = nil
    
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var previewView: UIView!
    
    
    //Spacing ratio to the side of the screen with respect to the width of the screen
    var horizontalSideSpacingRatio : Double = 14.2666666667
    
    
    // Vision parts
    private var requests = [VNRequest]()
    
    //Medical Barcode dictionary
    var medicalBarCodeLookUp: [String: RapidAntigenTest] = [:]
    //Item Batcode dictionary
    var itemBarCodeLookUp: [String: Item] = [:]
    //The scanned RAT test
    var scannedRat: RapidAntigenTest?
    
    //Haptic feedback engine
    let feedback = UINotificationFeedbackGenerator()

    //Boolean indicating whether we have handled the scan or not
    var handledScan = false
    
    //The session that captures Audio Visual input
    let session = AVCaptureSession()
    //The preview layer to be displayed to the user
    var previewLayer: AVCaptureVideoPreviewLayer! = nil
    //Class used to process frames captured from AVCaptureSession
    let videoDataOutput = AVCaptureVideoDataOutput()
    
    //Video capture device reference
    var videoCaptureDevice: AVCaptureDevice?
    
    //Call back delegate (SwiftUI)
    var delegate : BarcodeScanningViewControllerDelegate?
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    //Delegate to call when we finish scanning
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVCapture()
        setupBarcodeRequest()
        // start the capture
        startCaptureSession()
        
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session.stopRunning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        previewLayer.frame = CGRect(x: UIScreen.screenWidth / horizontalSideSpacingRatio, y: 0, width: UIScreen.screenWidth - 2 * (UIScreen.screenWidth / horizontalSideSpacingRatio), height: UIScreen.screenHeight / 2.2259615385)
        rootLayer.addSublayer(previewLayer)
    }
    
    func startCaptureSession() {
        
        session.startRunning()
        
        //Turn on the flashlight
        try? videoCaptureDevice!.lockForConfiguration()
        videoCaptureDevice?.torchMode = .on
        videoCaptureDevice!.unlockForConfiguration()
        
    }
    
    // Clean up capture setup
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
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
            if results.count == 1{
                //Print out the result
                let barcodeValue = results.first!.payloadStringValue!
                print("Found barcode with value: \(barcodeValue)")
                //Check if it is a logged barcode
                if let scannedRAT = self.medicalBarCodeLookUp[barcodeValue]{
                    
                    if !self.handledScan {
                        //Handle the scan
                        self.handledScan = true
                        //Update our scanned RAT
                        self.scannedRat = scannedRAT
                        //Move onto the next screen
                        //self.performSegue(withIdentifier: "scannerScannedSegue", sender: nil)
                        //Call delegate
                        print("Calling delegate")
                        self.delegate?.finishedScanning(readRAT: scannedRAT)
                    } else {
                        //Ignore
                    }
                }
                
            } else {
                print("Scanned multiple barcodes!")
                for observation in results{
                    //Print out the result
                    let barcodeValue = observation.payloadStringValue!
                    print("Found barcode with value: \(barcodeValue)")
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Check which segue we are going for
        if segue.identifier == "scannerScannedSegue"{
            self.feedback.notificationOccurred(.success)
            //Cast our destination
            let destination = segue.destination as! ComponentsLearningViewController
            guard let scannedRat = scannedRat else{
                fatalError("The user did not scan a RAT")
            }
            //destination.scannedRAT = scannedRat
        }
    }
    
    
}

