//
//  DualCameraViewModel.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/6/25.
//

//
//  DualCameraViewModel.swift
//  Jelly-iOS-App
//
//  Created by You on 2025-06-07.
//

//
//  DualCameraViewModel.swift
//  Jelly-iOS-App
//
//  Created by You on 2025-06-07.
//

//
//  DualCameraViewModel.swift
//  Jelly-iOS-App
//
//  Created by You on 2025-06-07.
//

import Foundation
import AVFoundation

/// Manages a multi-cam session, publishes two live preview–layers.
final class DualCameraViewModel: ObservableObject {
  // MARK: – Published preview layers
  @Published var frontPreviewLayer: AVCaptureVideoPreviewLayer?
  @Published var backPreviewLayer:  AVCaptureVideoPreviewLayer?

  // MARK: – Internals
  private let session = AVCaptureMultiCamSession()

  init() {
    configureSession()
  }

  deinit {
    session.stopRunning()
  }

  private func configureSession() {
    guard AVCaptureMultiCamSession.isMultiCamSupported else {
      debugPrint("⚠️ [DualCam] Multi-cam not supported")
      return
    }

    session.beginConfiguration()
    debugPrint("📷 [DualCam] Begin configuration")

    session.sessionPreset = .inputPriority
    debugPrint("📷 [DualCam] Preset set to \(session.sessionPreset)")

    // — Back camera —
    if let backDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                for: .video,
                                                position: .back),
       let backInput  = try? AVCaptureDeviceInput(device: backDevice),
       session.canAddInput(backInput)
    {
      session.addInput(backInput)
      debugPrint("✅ [DualCam] added back input")

      let backLayer = AVCaptureVideoPreviewLayer(
        sessionWithNoConnection: session
      )
      backLayer.videoGravity = .resizeAspectFill

      if let backPort = backInput.ports.first(where: { $0.mediaType == .video }) {
        let backConn = AVCaptureConnection(
          inputPort: backPort,
          videoPreviewLayer: backLayer
        )
        backConn.videoOrientation = .portrait
        if session.canAddConnection(backConn) {
          session.addConnection(backConn)
          debugPrint("✅ [DualCam] connected back preview layer")
          DispatchQueue.main.async { self.backPreviewLayer = backLayer }
        }
      }
    } else {
      debugPrint("⚠️ [DualCam] couldn’t add back camera")
    }

    // — Front camera —
    if let frontDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                 for: .video,
                                                 position: .front),
       let frontInput  = try? AVCaptureDeviceInput(device: frontDevice),
       session.canAddInput(frontInput)
    {
      session.addInput(frontInput)
      debugPrint("✅ [DualCam] added front input")

      let frontLayer = AVCaptureVideoPreviewLayer(
        sessionWithNoConnection: session
      )
      frontLayer.videoGravity = .resizeAspectFill

      if let frontPort = frontInput.ports.first(where: { $0.mediaType == .video }) {
        let frontConn = AVCaptureConnection(
          inputPort: frontPort,
          videoPreviewLayer: frontLayer
        )
        // use rotation‐angle API on iOS 17+
        frontConn.videoRotationAngle = 0
        frontConn.automaticallyAdjustsVideoMirroring = false
        frontConn.isVideoMirrored = true

        if session.canAddConnection(frontConn) {
          session.addConnection(frontConn)
          debugPrint("✅ [DualCam] connected front preview layer")
          DispatchQueue.main.async { self.frontPreviewLayer = frontLayer }
        }
      }
    } else {
      debugPrint("⚠️ [DualCam] couldn’t add front camera")
    }

    session.commitConfiguration()
    debugPrint("📷 [DualCam] Commit configuration")

    session.startRunning()
    debugPrint("📷 [DualCam] Session isRunning = \(session.isRunning)")
  }
}
