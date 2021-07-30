//
//  ViewController.swift
//  Part Finder
//
//  Created by Justin Oakes on 7/29/21.
//

import AVFoundation
import CoreML
import UIKit

class CameraViewController: UIViewController {

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        startCaptureSession()
    }
}

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
