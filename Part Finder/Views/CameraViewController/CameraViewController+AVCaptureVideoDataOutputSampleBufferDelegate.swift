//
//  CameraViewController+PhotoCaptureDelegate.swift
//  Part Finder
//
//  Created by Justin Oakes on 7/29/21.
//

import AVFoundation
import Vision

// This is a delegate to perform operations on a AVCaptureSession's video buffer
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    // This is called when the session is successfully able to send an updated frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Just dealing with the many different weird image formates AVFoundation/Vision/CoreML like
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Where we bring in the model that powered all the heavy lifting in CreateML
        guard let model = try? VNCoreMLModel(for: FerrariObjectDetector(configuration: MLModelConfiguration()).model) else { return }

        let request = VNCoreMLRequest(model: model, completionHandler: requestCompletionHandler)
        
        // Where the magic happens. Passes the buffer we want Vision to analyze and the request we want to Vision to perform on it.
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            .perform([request])
    }

    // Makes sure there are no errors and casts the results to an array of `VNClassificationObservation`
    // before passing them off to be handled
    var requestCompletionHandler: VNRequestCompletionHandler {
        get {
            return { completedRequest, error in
                guard error == nil,
                      let results = completedRequest.results as? [VNClassificationObservation] else { return }
                if !results.isEmpty {
                    print(results)
                }
            }
        }
    }
}
