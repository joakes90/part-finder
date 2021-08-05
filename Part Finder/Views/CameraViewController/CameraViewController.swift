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
    private var rootLayer: CALayer!
    private var detectionOverlay: CALayer!
    private var overlayLayers = [CALayer]()
    @IBOutlet weak var previewView: UIView!
    
    var observations = [VNRecognizedObjectObservation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootLayer = previewView.layer
        startCaptureSession()
        detectionOverlay = CALayer()
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: previewView.frame.width,
                                         height: previewView.frame.height)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX,
                                            y: rootLayer.bounds.midY)
        rootLayer.addSublayer(self.detectionOverlay)
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
        layer.bounds = CGRect(x: 0.0,
                              y: 0.0,
                              width: previewView.frame.width,
                              height: previewView.frame.height)
        layer.position = CGPoint(x: previewView.layer.bounds.midX,
                                 y: previewView.layer.bounds.midY)
        rootLayer.addSublayer(layer)

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
        let bounds: [CGRect] = recognizedObjects
            .compactMap({ $0.boundingBox})
            .map({ translateBounds(for: $0) })
        drawRects(for: recognizedObjects)
//        drawRects(at: bounds)
    }

    // This does some coordinate system conversion to set the bounding box in the correct place
    func translateBounds(for rect: CGRect) -> CGRect {
        let largestSide = rect.width > rect.height ? rect.width : rect.height
        let fixedBoundingBox = CGRect(x: rect.origin.x,
                                      y: 1.0 - rect.origin.y - rect.height,
                                      width: largestSide,
                                      height: largestSide)
        
        return VNImageRectForNormalizedRect(fixedBoundingBox,
                                            Int(previewView.frame.width),
                                            Int(previewView.frame.height))
    }

    func drawRects(for observations: [VNRecognizedObjectObservation]) {
        observations.forEach { observation in
            let rect = translateBounds(for: observation.boundingBox)
            let outlineLayer = CALayer()
            outlineLayer.bounds = rect
            outlineLayer.position = CGPoint(x: rect.midX, y: rect.midY)
            outlineLayer.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.5)
            
            guard let text = observation.labels.first?.identifier else { return }
            let attributedString = NSMutableAttributedString(string: "\(text)")
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0),
                              NSAttributedString.Key.foregroundColor: UIColor.white]
            attributedString.addAttributes(attributes,
                                           range: NSRange(location: 0, length: text.count))
            
            let textLayer = CATextLayer()
            textLayer.string = attributedString
            textLayer.bounds = CGRect(x: 0, y: 0, width: rect.size.height, height: rect.size.width)
            textLayer.position = CGPoint(x: rect.midX, y: rect.midY)
            textLayer.shadowOpacity = 0.0
            textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
            textLayer.contentsScale = 2.0 // retina rendering
            
            outlineLayer.addSublayer(textLayer)
            overlayLayers.append(outlineLayer)
            detectionOverlay.addSublayer(outlineLayer)
        }
    }

    func clearRects() {
        overlayLayers.forEach { layer in
            layer.removeFromSuperlayer()
        }
        overlayLayers = []
    }
}
