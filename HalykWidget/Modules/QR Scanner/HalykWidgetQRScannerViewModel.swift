//
//  HalykWidgetQRScannerViewModel.swift
//  HalykWidget
//
//  Created by Zhanibek Lukpanov on 16.10.2024.
//

import Foundation
import UIKit.UIImpactFeedbackGenerator
import AVFoundation
import Combine
internal import HalykCore

class HalykWidgetQRScannerViewModel: NSObject, ObservableObject {

    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var scanResult: String?
    private let captureSession = AVCaptureSession()

    override init() {
        super.init()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }

        if captureSession.canAddInput(captureDeviceInput) {
            captureSession.addInput(captureDeviceInput)
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr]
        }
    }

    func startCaptureSession() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.connection?.videoOrientation = .portrait

        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInteractive).async {
                self.captureSession.startRunning()
            }
        }
    }

    func stopCaptureSession() {
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInteractive).async {
                self.captureSession.stopRunning()
            }
        }
    }

    private func didScan(qr: String) {
        scanResult = qr
    }
}

extension HalykWidgetQRScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        stopCaptureSession()

        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }

        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        didScan(qr: stringValue)
    }
}
