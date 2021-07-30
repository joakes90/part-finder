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
    private var annotations = Set<CALayer>()
    
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
        layer.frame = view.bounds
        view.layer.addSublayer(layer)

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
        for object in recognizedObjects {
            guard let name = object.labels.first?.identifier else { continue }
            let bounds = bounds(for: object)
            let shapeLayer = createRoundedRectLayer(with: bounds)
            let textLayer = createTextLayer(in: bounds, with: name)
            shapeLayer.addSublayer(textLayer)
            annotations.insert(shapeLayer)
            previewLayer?.addSublayer(shapeLayer)
        }
    }

    func removeAnnotations() {
        annotations.forEach { layer in
            layer.removeFromSuperlayer()
            annotations.remove(layer)
        }
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

    func createRoundedRectLayer(with bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.backgroundColor = #colorLiteral(red: 0.9404104806, green: 0, blue: 0, alpha: 0.6644581905)
        shapeLayer.borderColor = #colorLiteral(red: 0.9404104806, green: 0, blue: 0, alpha: 1)
        shapeLayer.cornerRadius = 14
        return shapeLayer
    }

    func createTextLayer(in bounds: CGRect, with name: String) -> CATextLayer {
        let textLayer = CATextLayer()
        let attributedString = NSMutableAttributedString(string: "\(name)")
        let largeFont = UIFont.systemFont(ofSize: 12)
        let attributes = [NSAttributedString.Key.font: largeFont,
                          NSAttributedString.Key.foregroundColor: UIColor.white]
        attributedString.addAttributes(attributes,
                                       range: NSRange(location: 0, length: name.count))
        textLayer.string = attributedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height, height: bounds.size.width)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.0
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        return textLayer
    }
}
