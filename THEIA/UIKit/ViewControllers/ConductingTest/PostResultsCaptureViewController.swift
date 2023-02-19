//
//  PostResultsCaptureViewController.swift
//  COVIDGuide
//
//  Created by William Chen on 2022/12/21.
// This view controller will select the best images and upload them to the server

import UIKit
import Accelerate
import UIKit
import Combine
import AVFoundation


import Metal
import MetalPerformanceShaders
import MetalKit

import Firebase
import FirebaseStorage




class PostResultsCaptureViewController: UIViewController {
    
    let laplacian: [Float] = [-1, -1, -1,
                              -1,  8, -1,
                              -1, -1, -1]
    
    
    var mtlDevice : MTLDevice = MTLCreateSystemDefaultDevice()!
    
    var mtlCommandQueue : MTLCommandQueue?
    
    //Stores the filepaths of the images that are the clearest
    var clearImages: [URL] = []
    
    //Buttons reference
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var annotateButton: UIButton!
    
    @IBOutlet weak var aiModelButton: UIButton!
    
    var scannedTest: Test?
    
    var storageReference = Storage.storage()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.setupButton()
        annotateButton.setupButton()
        aiModelButton.setupButton()
        
        annotateButton.isEnabled = false
        aiModelButton.isEnabled = false
        
        findClearestImages(clearest: 5)
        
        //Load each image and stitch them together
        
        var images: [UIImage] = []
        
        for path in clearImages{
            
            let data = try? Data(contentsOf: path)
            var image = UIImage(data: data!)
            
            //If landscape, rotate
            if image!.size.width > image!.size.height {
                image = UIImage(cgImage: (image?.cgImage!)!, scale: 1.0, orientation: .right)
            }
            
            images.append(image!)
        }
        navigationItem.hidesBackButton = true
        
        
        let instructionsImage = getInstructionsImage()
        
        
        //Pass it in
        let stitchedImage = images.stitchImages(isVertical: false)
        
        let combineInstructions = [stitchedImage, instructionsImage].stitchImages(isVertical: false)
        
        //Get the paths
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //Gets the documents directory
        let documentsDirectory = paths[0]
        
        
        let saveURL = documentsDirectory.appendingPathComponent("StitchedFile.png")
        
        guard let data = combineInstructions.pngData() else {
            fatalError("Failed to get png data")
        }
        
        do {
            try data.write(to: saveURL)
        } catch{
            print(error.localizedDescription)
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
            return image
        }
        print("No image found")
        return UIImage()
        
    }

    
    
    func loadImageData(filename: String) -> UIImage? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }
        
    func findClearestImages(clearest: Int){
            
            //Get the paths
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            //Gets the documents directory
            let documentsDirectory = paths[0]
            
            var results: [(Int , Int8)] = []
            
            for i in 1...50 {
                
                //Code from https://betterprogramming.pub/blur-detection-via-metal-on-ios-16dd02cb1558
                
                self.mtlCommandQueue = mtlDevice.makeCommandQueue()!
                // Do any additional setup after loading the view.
                
                // Create a command buffer for the transformation pipeline
                let commandBuffer = self.mtlCommandQueue!.makeCommandBuffer()!
                // These are the two built-in shaders we will use
                let laplacian = MPSImageLaplacian(device: self.mtlDevice)
                let meanAndVariance = MPSImageStatisticsMeanAndVariance(device: self.mtlDevice)
                // Load the captured pixel buffer as a texture
                let textureLoader = MTKTextureLoader(device: self.mtlDevice)
                
                
                //Get the paths to the images
                let imagePath = documentsDirectory.appendingPathComponent(i.description + ".png")
                
                let image = CIImage(contentsOf: imagePath)!
                
                let context = CIContext(options: nil)
                guard let cgiImage = context.createCGImage(image, from: image.extent) else {
                    fatalError("Failed to get CGIImage")
                }
                
                
                let sourceTexture = try! textureLoader.newTexture(cgImage: cgiImage, options: nil)
                // Create the destination texture for the laplacian transformation
                let lapDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: sourceTexture.pixelFormat, width: sourceTexture.width, height: sourceTexture.height, mipmapped: false)
                lapDesc.usage = [.shaderWrite, .shaderRead]
                let lapTex = self.mtlDevice.makeTexture(descriptor: lapDesc)!
                // Encode this as the first transformation to perform
                laplacian.encode(commandBuffer: commandBuffer, sourceTexture: sourceTexture, destinationTexture: lapTex)
                // Create the destination texture for storing the variance.
                let varianceTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: sourceTexture.pixelFormat, width: 2, height: 1, mipmapped: false)
                varianceTextureDescriptor.usage = [.shaderWrite, .shaderRead]
                let varianceTexture = self.mtlDevice.makeTexture(descriptor: varianceTextureDescriptor)!
                // Encode this as the second transformation
                meanAndVariance.encode(commandBuffer: commandBuffer, sourceTexture: lapTex, destinationTexture: varianceTexture)
                // Run the command buffer on the GPU and wait for the results
                commandBuffer.commit()
                commandBuffer.waitUntilCompleted()
                // The output will be just 2 pixels, one with the mean, the other the variance.
                var result = [Int8](repeatElement(0, count: 2))
                let region = MTLRegionMake2D(0, 0, 2, 1)
                varianceTexture.getBytes(&result, bytesPerRow: 1 * 2 * 4, from: region, mipmapLevel: 0)
                let variance = result.last!
                
                results.append((i, variance))
                
                
            
        }
        
        
        //Sort the results
        results = results.sorted(by: {$0.1 > $1.1})
        
        print("Here are the clearest images: ")
        //Keep the top x images
        for i in 0...(clearest - 1) {
            clearImages.append(documentsDirectory.appendingPathComponent(results[i].0.description + ".png"))
            print("Image: \(results[i].0.description), Clearness factor: \(results[i].1.description)")
        }
    

        
    }
    
    
    
    @IBAction func shareAction(_ sender: Any) {
        
        //Get the paths
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //Gets the documents directory
        let documentsDirectory = paths[0]
        
        
        let fileURL = documentsDirectory.appendingPathComponent("StitchedFile.png")
        
    

        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()

        // Add the path of the file to the Array
        filesToShare.append(fileURL)

        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)

        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func annotatedAction(_ sender: Any) {
    }
    
    @IBAction func aiAction(_ sender: Any) {
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
    
    @IBAction func doneAction(_ sender: Any) {
        performSegue(withIdentifier: "backToHomeSegue", sender: nil)
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

//Stitching images, https://stackoverflow.com/questions/42890154/stitch-multiple-images-together-horizontally-swift-3
extension Array where Element: UIImage {
    func stitchImages(isVertical: Bool) -> UIImage {

        let maxWidth = self.compactMap { $0.size.width }.max()
        let maxHeight = self.compactMap { $0.size.height }.max()

        let maxSize = CGSize(width: maxWidth ?? 0, height: maxHeight ?? 0)
        let totalSize = isVertical ?
            CGSize(width: maxSize.width, height: maxSize.height * (CGFloat)(self.count))
            : CGSize(width: maxSize.width  * (CGFloat)(self.count), height:  maxSize.height)
        let renderer = UIGraphicsImageRenderer(size: totalSize)

        return renderer.image { (context) in
            for (index, image) in self.enumerated() {
                let rect = AVMakeRect(aspectRatio: image.size, insideRect: isVertical ?
                    CGRect(x: 0, y: maxSize.height * CGFloat(index), width: maxSize.width, height: maxSize.height) :
                    CGRect(x: maxSize.width * CGFloat(index), y: 0, width: maxSize.width, height: maxSize.height))
                image.draw(in: rect)
            }
        }
    }
}
