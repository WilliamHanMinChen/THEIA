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


import Metal
import MetalPerformanceShaders
import MetalKit



class PostResultsCaptureViewController: UIViewController {
    
    let laplacian: [Float] = [-1, -1, -1,
                              -1,  8, -1,
                              -1, -1, -1]
    
    
    var mtlDevice : MTLDevice = MTLCreateSystemDefaultDevice()!
    
    var mtlCommandQueue : MTLCommandQueue?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //findSharpest(numberOfImages: 5)

        
        
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
        
        //Upload the top 5
        
        
        for result in results {
            print("\(result.0), Variance: \(result.1)")
        }

        
    }
    
    
//    ///
//    ///This function loops through the images taken and returns a string containing the sharpest N number of images
//    func findSharpest(numberOfImages: Int) -> [String]{
//
//        //Get the paths
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        //Gets the documents directory
//        let documentsDirectory = paths[0]
//
//        //Array holding our sharpness values
//        var sharpnessArray = [0]
//
//        for i in 1...51{
//            //Get the paths to the images
//            let imagePath = documentsDirectory.appendingPathComponent(i.description + ".png")
//
//
//            let image = CIImage(contentsOf: imagePath)!
//
//            guard let pixelBuffer = buffer(from: image) else {
//                print("Failed to get pixel buffer for image \(i).png")
//                return []
//            }
//
//
//            CVPixelBufferLockBaseAddress(pixelBuffer,
//                                         CVPixelBufferLockFlags.readOnly)
//
//            let width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
//            let height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
//            let count = width * height
//
//            let lumaBaseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
//            let lumaRowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
//
//            let lumaCopy = UnsafeMutableRawPointer.allocate(byteCount: count,
//                                                            alignment: MemoryLayout<Pixel_8>.alignment)
//            lumaCopy.copyMemory(from: lumaBaseAddress!,
//                                byteCount: count)
//
//
//            CVPixelBufferUnlockBaseAddress(pixelBuffer,
//                                           CVPixelBufferLockFlags.readOnly)
//
//            DispatchQueue.global(qos: .utility).async {
//
//                var sourceBuffer = vImage_Buffer(data: lumaCopy,
//                                                 height: vImagePixelCount(height),
//                                                 width: vImagePixelCount(width),
//                                                 rowBytes: lumaRowBytes)
//
//                var floatPixels: [Float]
//                let count = width * height
//
//                if sourceBuffer.rowBytes == width * MemoryLayout<Pixel_8>.stride {
//                    let start = sourceBuffer.data.assumingMemoryBound(to: Pixel_8.self)
//                    floatPixels = vDSP.integerToFloatingPoint(
//                        UnsafeMutableBufferPointer(start: start,
//                                                   count: count),
//                        floatingPointType: Float.self)
//                } else {
//                    floatPixels = [Float](unsafeUninitializedCapacity: count) {
//                        buffer, initializedCount in
//
//                        var floatBuffer = vImage_Buffer(data: buffer.baseAddress,
//                                                        height: sourceBuffer.height,
//                                                        width: sourceBuffer.width,
//                                                        rowBytes: width * MemoryLayout<Float>.size)
//
//                        vImageConvert_Planar8toPlanarF(&sourceBuffer,
//                                                       &floatBuffer,
//                                                       0, 255,
//                                                       vImage_Flags(kvImageNoFlags))
//
//                        initializedCount = count
//                    }
//                }
//
//                // Convolve with Laplacian.
//                vDSP.convolve(floatPixels,
//                              rowCount: height,
//                              columnCount: width,
//                              with3x3Kernel: self.laplacian,
//                              result: &floatPixels)
//
//                // Calculate standard deviation.
//                var mean = Float.nan
//                var stdDev = Float.nan
//
//                vDSP_normalize(floatPixels, 1,
//                               nil, 1,
//                               &mean, &stdDev,
//                               vDSP_Length(count))
//
//                // Create display version of laplacian convolution.
//                let clippedPixels = vDSP.clip(floatPixels, to: 0 ... 255)
//                var pixel8Pixels = vDSP.floatingPointToInteger(clippedPixels,
//                                                               integerType: UInt8.self,
//                                                               rounding: .towardNearestInteger)
//
//                print("index \(i) : score \(stdDev * stdDev)")
//
//                lumaCopy.deallocate()
//            }
//
//
//
//        }
//
//
//        return []
//    }
    
    
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
