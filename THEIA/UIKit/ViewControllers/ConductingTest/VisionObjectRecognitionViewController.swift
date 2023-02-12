/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains the object recognition view controller for the Breakfast Finder.
*/

import UIKit
import AVFoundation
import Vision
import Accelerate

class VisionObjectRecognitionViewController: ViewController {
    
    private var detectionOverlay: CALayer! = nil
    
    // Vision parts
    private var requests = [VNRequest]()
    
    //Image classification requests
    var imageClassificationRequests = [VNRequest]()
    
    //Text recognition request
    lazy var textDetectionRequest: VNRecognizeTextRequest = {
        let textDetectRequest = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        return textDetectRequest
    }()
    
    //Saves the currently processed frame's CMSampleBuffer
    var currentFrameData: CMSampleBuffer?
    //Saves our current frame as CIImage
    var currentFrameCIImage: CIImage?
    
    //Counter for how many images we have taken
    var imageCounter = 1
    
    
    
    //Haptic feedback engine
    let hardImpact = UIImpactFeedbackGenerator(style: .heavy)
    
    
    //Records down the time when we last gave haptic feedback
    var lastImapctTime: Date = Date()
    
    //The number of photos of RATs we have taken
    var RATPhotoTaken: Int = 0
    
    //Indicating whether we have already attempted to perform a segue or not
    var performedSegue = false
    
    //Used to calculate sharpness
    let laplacian: [Float] = [-1, -1, -1,
                              -1,  8, -1,
                              -1, -1, -1]
    
    //counter used to process every 1,2, or n frame
    var counter = 0
    
    //Sets up the image classifier
    func setupClassifier() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil
        
        //Load the Corresponding ML file
        guard let modelURL = Bundle.main.url(forResource: "RATClassificationV1", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            //This is the model that is being ran and the call back method once the results have been processed
            let imageClassification = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {

                    // perform all the UI updates on the main queue
                    if let observations = request.results as? [VNClassificationObservation] {
//                        print("Request processed, got the results")
//                        print("RAT Result: \(observations.first?.identifier)")
                        //self.resultLabel.text = "Result: \(observations.first!.identifier)"
                    }
                })
            })
            self.imageClassificationRequests = [imageClassification]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    
    @discardableResult
    func setupVision() -> NSError? {
        // Setup Vision parts
        let error: NSError! = nil
        
        //Load the Corresponding ML file
        guard let modelURL = Bundle.main.url(forResource: "detectRATV2", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            //This is the model that is being ran and the call back method once the results have been processed
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    // perform all the UI updates on the main queue
                    if let results = request.results {
                        if results.isEmpty{
                            //self.resultLabel.text = "Result: Detecting"
                        }
//                        self.resultLabel.text = "Result: Detecting"
//                        print("Request processed, got the results")
                        self.drawVisionRequestResults(results)
                    }
                    
                })
            })
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    func handleDetectedText(request: VNRequest?, error: Error?) {
        
        // Check what was found
        guard let results = request?.results as? [VNRecognizedTextObservation] else {
                return
        }
        //Output this frame
        //Get file manager
        //Get the paths
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //Gets the documents directory
        let documentsDirectory = paths[0]
        //Gets our image file's path
        let fileURL = documentsDirectory.appendingPathComponent(imageCounter.description + ".png")
        
        //Loop through the results, only save those that have the "2019-nCov" string
        for result in results {
            if result.topCandidates(1).first?.string == "2019-nCoV" || result.topCandidates(1).first?.string == "COVID-19"{
                //Save the image
                //Print the confidence
                print("Image saved, confidence: \(result.topCandidates(1).first?.confidence)")
                currentFrameCIImage?.saveImage(self.imageCounter.description + ".png", inDirectoryURL: documentsDirectory)
                self.imageCounter += 1
            }
            
        }
    }
    
    
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            //Object bounds is a tuple with the boundaries of the object
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
//            print("Found RAT with bounds: \(objectBounds)")

            //If there is only one result
            if results.count == 1 {
                
                //Output this frame
                //Get file manager
                //Get the paths
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                //Gets the documents directory
                let documentsDirectory = paths[0]
                //Gets our image file's path
                let fileURL = documentsDirectory.appendingPathComponent(imageCounter.description + ".png")
                
//                imageCounter += 1
                
                //Convert it to UI Image
                guard let currentFrameData = currentFrameData else {
                    fatalError("Tried processing data before current frame is set!")
                }
                let imageBuffer = CMSampleBufferGetImageBuffer(currentFrameData)!
                
                let ciimage = CIImage(cvPixelBuffer: imageBuffer)
                
                
    //            let image = self.convert(cmage: ciimage)
                
                let croppedImage = ciimage.cropped(to: objectBounds)
                
                //Assign our image to be saved
                self.currentFrameCIImage =
                croppedImage
                
                //Check how blurry it is
//                //Get the PixelBuffer
//                guard let pixelBuffer = buffer(from: croppedImage) else{
//                    print("Failed to cast to pixel buffer")
//                    return
//                }
//
                
//                var pixelBuffer: CVPixelBuffer?
//                let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
//                             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
//                let width:Int = Int(croppedImage.extent.width)
//                let height:Int = Int(croppedImage.extent.height)
//                CVPixelBufferCreate(kCFAllocatorDefault,
//                                    width,
//                                    height,
//                                    kCVPixelFormatType_32BGRA,
//                                    attrs,
//                                    &pixelBuffer)
//
//                let pixelContext = CIContext()
//
//                pixelContext.render(croppedImage, to: pixelBuffer!)

                
                //Get the sharpness
                //getSharpness(croppedImage: croppedImage, pixelBuffer: imageBuffer)
                
                
                
                
                //croppedImage.saveJPEG(imageCounter.description + ".jpeg", inDirectoryURL: documentsDirectory)
                
                let exifOrientation = exifOrientationFromDeviceOrientation()
                
                
                
                let context = CIContext(options: nil)
                    if let cgImage = context.createCGImage(croppedImage, from: croppedImage.extent) {
                        //This is called every frame
                        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: exifOrientation)
                        
                        do {
                            //Performs vision requests (images to be processed)
                            try handler.perform(self.imageClassificationRequests)
                            
                            //Do the text recognition requests
                            try handler.perform([self.textDetectionRequest])
                            
                        } catch {
                            print(error)
                        }
                    }
                
                //Depending on the distance, we give intervaled feedback
                if Date().timeIntervalSince(lastImapctTime) > (0.5){
                    hardImpact.impactOccurred()
                    lastImapctTime = Date()
                }
                
                
                
            }
            
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            identifier: topLabelObservation.identifier,
                                                            confidence: topLabelObservation.confidence)
            shapeLayer.addSublayer(textLayer)
            detectionOverlay.addSublayer(shapeLayer)
            
        }
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        
        //getSharpness(pixelBuffer: pixelBuffer)
        
        //This is called every frame

        counter += 1
        //Only process every 3rd frame
        if counter % 3 != 0{
            return
        }
        //print("Processing requests")
        //If we have captured less than 50 images
        if imageCounter <= 50{
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
            do {
                //Performs vision requests (images to be processed)
                try imageRequestHandler.perform(self.requests)
                
                self.currentFrameData = sampleBuffer
                
                
            } catch {
                print(error)
            }
        } else {
            //If we have not performed a segue
            if !performedSegue{
                //We have captured enough, go to the post capture screen
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "CaptureToPostCaptureSegue", sender: nil)
                }
                performedSegue = true
            } else {
            }

        }
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
        
        // setup Vision parts
        setupLayers()
        updateLayerGeometry()
        setupVision()
        //Setup classifier
        setupClassifier()
        
        // start the capture
        startCaptureSession()
    }
    
    func setupLayers() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX, y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
    }
    
    func updateLayerGeometry() {
        let bounds = rootLayer.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
        
    }
    
    //Calculate sharpness score
    
    func getSharpness(croppedImage: CIImage, pixelBuffer: CVPixelBuffer) -> Float{
        
//        //Cast this to UIImage then to PixelBuffer
//        let cropepdUIImage = UIImage(ciImage: croppedImage)
//
//        //Cast this to CVPixelBuffer
//        let pixelBuffer = cropepdUIImage.convertToBuffer()!

        CVPixelBufferLockBaseAddress(pixelBuffer,
                                     CVPixelBufferLockFlags.readOnly)
        
        let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
        let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        let count = width * height
        
        let lumaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
        let lumaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
        
        let lumaCopy = UnsafeMutableRawPointer.allocate(byteCount: count,
                                                        alignment: MemoryLayout<Pixel_8>.alignment)
        lumaCopy.copyMemory(from: lumaBaseAddress!,
                            byteCount: count)
        
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer,
                                       CVPixelBufferLockFlags.readOnly)
        
        DispatchQueue.global(qos: .utility).async {
            var sourceBuffer = vImage_Buffer(data: lumaCopy,
                                             height: vImagePixelCount(height),
                                             width: vImagePixelCount(width),
                                             rowBytes: lumaRowBytes)
            
            var floatPixels: [Float]
            let count = width * height
            
            if sourceBuffer.rowBytes == width * MemoryLayout<Pixel_8>.stride {
                let start = sourceBuffer.data.assumingMemoryBound(to: Pixel_8.self)
                floatPixels = vDSP.integerToFloatingPoint(
                    UnsafeMutableBufferPointer(start: start,
                                               count: count),
                    floatingPointType: Float.self)
            } else {
                floatPixels = [Float](unsafeUninitializedCapacity: count) {
                    buffer, initializedCount in
                    
                    var floatBuffer = vImage_Buffer(data: buffer.baseAddress,
                                                    height: sourceBuffer.height,
                                                    width: sourceBuffer.width,
                                                    rowBytes: width * MemoryLayout<Float>.size)
                    vImageConvert_Planar8toPlanarF(&sourceBuffer,
                                                       &floatBuffer,
                                                       0, 255,
                                                       vImage_Flags(kvImageNoFlags))
                    
                    initializedCount = count
                }
                
            }
            
            // Convolve with Laplacian.
            vDSP.convolve(floatPixels,
                          rowCount: height,
                          columnCount: width,
                          with3x3Kernel: self.laplacian,
                          result: &floatPixels)
            
            // Calculate standard deviation.
            var mean = Float.nan
            var stdDev = Float.nan
            
            vDSP_normalize(floatPixels, 1,
                           nil, 1,
                           &mean, &stdDev,
                           vDSP_Length(count))
            
            // Create display version of laplacian convolution.
            let clippedPixels = vDSP.clip(floatPixels, to: 0 ... 255)
            var pixel8Pixels = vDSP.floatingPointToInteger(clippedPixels,
                                                           integerType: UInt8.self,
                                                           rounding: .towardNearestInteger)
            
            print("score \(stdDev * stdDev)")
            //Create the CIImage
//            let ciimage = CIImage(cvPixelBuffer: pixelBuffer)
            //Save the image
            
            //Get the paths
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            //Gets the documents directory
            let documentsDirectory = paths[0]
            
            self.imageCounter += 1
            
            //Save the image
            
            croppedImage.saveImage(self.imageCounter.description + "_\((stdDev * stdDev).description)" + ".jpeg", inDirectoryURL: documentsDirectory)
            
           
            
            
//            // Create display images.
//            if
//                let orientation = orientation,
//                let imagePropertyOrientation = CGImagePropertyOrientation(rawValue: orientation),
//                let laplacianImage = BlurDetector.makeImage(fromPixels: &pixel8Pixels,
//                                                            width: width, height: height,
//                                                            gamma: 1 / 2.2,
//                                                            orientation: imagePropertyOrientation),
//                let monoImage = BlurDetector.makeImage(fromPlanarBuffer: sourceBuffer,
//                                                       orientation: imagePropertyOrientation) {
//                let result = BlurDetectionResult(index: sequenceCount,
//                                                 image: monoImage,
//                                                 laplacianImage: laplacianImage,
//                                                 score: stdDev * stdDev)
//
//                print("index \(sequenceCount) : score \(stdDev * stdDev)")
//
//                DispatchQueue.main.async {
//                    self.processedCount += 1
//                    self.resultsDelegate?.itemProcessed(result)
//
//                    if self.processedCount == expectedCount {
//                        self.resultsDelegate?.finishedProcessing()
//                    }
//                }
//            }
//        }
            
            lumaCopy.deallocate()
            
        }
        
        
        return 0
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
    
    
    // Convert CIImage to UIImage
    func convert(cmage: CIImage) -> UIImage {
         let context = CIContext(options: nil)
         let cgImage = context.createCGImage(cmage, from: cmage.extent)!
         let image = UIImage(cgImage: cgImage)
         return image
    }
    
    
    //Converts to PixelBuffer, https://stackoverflow.com/questions/54354138/how-can-you-make-a-cvpixelbuffer-directly-from-a-ciimage-instead-of-a-uiimage-in
    func buffer(from image: CIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.extent.width), Int(image.extent.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)

        guard (status == kCVReturnSuccess) else {
            return nil
        }

        return pixelBuffer
    }
    
    
    
}


extension CIImage {

    //https://stackoverflow.com/questions/27896410/given-a-ciimage-what-is-the-fastest-way-to-write-image-data-to-disk
    //Save to file path
    @objc func saveImage(_ name:String, inDirectoryURL:URL? = nil, quality:CGFloat = 1.0) -> String? {
        
        var destinationURL = inDirectoryURL
        
        if destinationURL == nil {
            destinationURL = try? FileManager.default.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }
        
        if var destinationURL = destinationURL {
            
            destinationURL = destinationURL.appendingPathComponent(name)
            
            if let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) {
                
                do {

                    let context = CIContext()

                    try context.writeJPEGRepresentation(of: self, to: destinationURL, colorSpace: colorSpace, options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption : quality])
                    
                    let format = CIFormat.RGBA8
                    try context.writePNGRepresentation(of: self, to: destinationURL, format: format, colorSpace: colorSpace)
                    
                    
//                    try context.writePNGRepresentation(of: self, to: destinationURL, format: colorSpace, colorSpace: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption : quality])
                    
                    return destinationURL.path
                    
                } catch {
                    return nil
                }
            }
        }
        
        return nil
    }
}




extension UIImage {
        
    func convertToBuffer() -> CVPixelBuffer? {
        
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, Int(self.size.width),
            Int(self.size.height),
            kCVPixelFormatType_32ARGB,
            attributes,
            &pixelBuffer)
        
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: pixelData,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
