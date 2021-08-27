//
//  CameraViewController+PhotoCaptureDelegate.swift
//  Part Finder
//
//  Created by Justin Oakes on 7/29/21.
//

import AVFoundation
import CoreImage
import UIKit
import Vision

// This is a delegate to perform operations on a AVCaptureSession's video buffer
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    // This is called when the session is successfully able to send an updated frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Just dealing with the many different weird image formats AVFoundation/Vision/CoreML like
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
                      let results = completedRequest.results as? [VNRecognizedObjectObservation],
                      self.frameFinishedUpdating(observations: results) else { return }
                // You may want to do more filtering here.
                // ie check for over lap, change in objects since the last frame,
                // or set iou and confidence thresholds by setting a featureProvider on your VNCoreMLModel
                if !results.isEmpty {
                    // Remember we are running on the video queue
                    // switch back to main for updating UI
                    DispatchQueue.main.async {
                        self.updateLayers(for: results)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.clearRects()
                    }
                }
            }
        }
    }
}

private extension CameraViewController {

    func frameFinishedUpdating(observations: [VNRecognizedObjectObservation]) -> Bool {
        guard self.observations.count == observations.count else {
            self.observations = observations
            return false
        }
        var matches = 0
        for new in observations {
            for old in self.observations {
                if new.labels.first?.identifier == old.labels.first?.identifier &&
                    intersectionOverUnion(old.boundingBox, new.boundingBox) > 0.75 {
                    matches += 1
                }
            }
        }
        self.observations = observations
        return matches == observations.count
    }
}
