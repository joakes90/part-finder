//
//  ViewController.swift
//  Part Finder
//
//  Created by Justin Oakes on 7/29/21.
//

import AVFoundation
import UIKit
import Vision

class CameraViewController: UIViewController {

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var identificationLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startCaptureSession()
    }
}

// Preview session set up
extension CameraViewController {
    func startCaptureSession() {
        // Create capture session with rear camera input
        let session = AVCaptureSession()
        session.beginConfiguration()
        captureSession = session
        guard let device = AVCaptureDevice.default(for: .video),
              let captureDevice = try? AVCaptureDeviceInput(device: device) else {
                fatalError("this phone sucks")
        }
        session.addInput(captureDevice)
        
        // Create preview layer
        let layer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer = layer
        layer.videoGravity = .resizeAspectFill
        layer.connection?.videoOrientation = .portrait
        layer.frame = previewView.bounds
        previewView.layer.addSublayer(layer)

        // Start capture session
        session.commitConfiguration()
        session.startRunning()

        // Create Output
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(output)
    }
}

// Overlay layer
// Largely stolen from apple example code
extension CameraViewController {

    func updateLayers(for recognizedObjects: [VNRecognizedObjectObservation]) {
        let names = recognizedObjects
            .compactMap({ $0.labels.first?.identifier })
            .joined(separator: "\n")
        identificationLabel.text = names
    }

    // This does some coordinate system conversion to set the bounding box in the correct place
    func bounds(for observation: VNRecognizedObjectObservation) -> CGRect {
        let boundingBox = observation.boundingBox
        let fixedBoundingBox = CGRect(x: boundingBox.origin.x,
                                      y: 1.0 - boundingBox.origin.y - boundingBox.height,
                                      width: boundingBox.width,
                                      height: boundingBox.height)
        return VNImageRectForNormalizedRect(fixedBoundingBox, Int(view.frame.width), Int(view.frame.height))
    }
}
