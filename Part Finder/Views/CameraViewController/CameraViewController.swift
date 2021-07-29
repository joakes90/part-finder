//
//  ViewController.swift
//  Part Finder
//
//  Created by Justin Oakes on 7/29/21.
//

import UIKit
import AVKit

class CameraViewController: UIViewController {

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    private var photoSettings: AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        settings.flashMode = .auto
        return settings
    }

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
    }
}
