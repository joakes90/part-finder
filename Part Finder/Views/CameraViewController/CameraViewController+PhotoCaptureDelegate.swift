//
//  CameraViewController+PhotoCaptureDelegate.swift
//  Part Finder
//
//  Created by Justin Oakes on 7/29/21.
//

import AVFoundation

extension CameraViewController {

    class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {

        // MARK: Monitoring Capture Progress

        func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
            print("willBeginCaptureFor resolvedSettings")
        }

        func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
            print("willCapturePhotoFor resolvedSettings")
        }

        func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
            print("didCapturePhotoFor resolvedSettings")
        }

        func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
            print("didFinishCaptureFor resolvedSettings")
        }

        // MARK: Receiving Capture Results

        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            print("didFinishProcessingPhoto")
        }

    }

}
