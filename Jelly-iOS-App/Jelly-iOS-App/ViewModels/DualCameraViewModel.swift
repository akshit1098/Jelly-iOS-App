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
import SwiftUI

final class DualCameraViewModel: NSObject, ObservableObject {
  // MARK: – Published for your SwiftUI
  @Published var backPreviewLayer:  AVCaptureVideoPreviewLayer?
  @Published var frontPreviewLayer: AVCaptureVideoPreviewLayer?
  @Published var isRecording = false
  @Published var recordedURLs: (front: URL, back: URL)?
  @Published var showSavePrompt = false

  // MARK: – Private
  private let session = AVCaptureMultiCamSession()
  private var backOutput:  AVCaptureMovieFileOutput?
  private var frontOutput: AVCaptureMovieFileOutput?
  private var group = DispatchGroup()
  private var tmpBackURL:  URL!
  private var tmpFrontURL: URL!

  override init() {
    super.init()
    configureSession()
  }

  deinit {
    session.stopRunning()
  }

  private func configureSession() {
    guard AVCaptureMultiCamSession.isMultiCamSupported else {
      debugPrint("⚠️ Multi-cam not supported")
      return
    }

    session.beginConfiguration()
    session.sessionPreset = .inputPriority

    // — Back camera input + preview layer —
    if let backDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                for: .video,
                                                position: .back),
       let backIn = try? AVCaptureDeviceInput(device: backDevice),
       session.canAddInput(backIn)
    {
      session.addInput(backIn)
      let backLayer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session)
      backLayer.videoGravity = .resizeAspectFill
      if let port = backIn.ports.first(where: { $0.mediaType == .video }) {
        let conn = AVCaptureConnection(inputPort: port, videoPreviewLayer: backLayer)
        conn.videoRotationAngle = 0
        session.addConnection(conn)
      }
      backPreviewLayer = backLayer
    }

    // — Front camera input + preview layer —
    if let frontDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                 for: .video,
                                                 position: .front),
       let frontIn = try? AVCaptureDeviceInput(device: frontDevice),
       session.canAddInput(frontIn)
    {
      session.addInput(frontIn)
      let frontLayer = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session)
      frontLayer.videoGravity = .resizeAspectFill
      if let port = frontIn.ports.first(where: { $0.mediaType == .video }) {
        let conn = AVCaptureConnection(inputPort: port, videoPreviewLayer: frontLayer)
        conn.automaticallyAdjustsVideoMirroring = false
        conn.isVideoMirrored = true
        conn.videoRotationAngle = 0
        session.addConnection(conn)
      }
      frontPreviewLayer = frontLayer
    }

    session.commitConfiguration()
    session.startRunning()
  }

  // MARK: – Recording

  func startRecording() {
    guard !isRecording else { return }
    isRecording = true

    // Prepare temp URLs
    let tmpDir = FileManager.default.temporaryDirectory
    tmpBackURL  = tmpDir.appendingPathComponent("back-\(UUID()).mov")
    tmpFrontURL = tmpDir.appendingPathComponent("front-\(UUID()).mov")

    // Create outputs
    let backMovie  = AVCaptureMovieFileOutput()
    let frontMovie = AVCaptureMovieFileOutput()

    session.beginConfiguration()
    if session.canAddOutput(backMovie)  { session.addOutput(backMovie) }
    if session.canAddOutput(frontMovie) { session.addOutput(frontMovie) }
    session.commitConfiguration()

    backOutput  = backMovie
    frontOutput = frontMovie

    // We’ll wait for both delegates
    group = DispatchGroup()
    group.enter(); group.enter()

    backMovie.startRecording(to: tmpBackURL, recordingDelegate: self)
    frontMovie.startRecording(to: tmpFrontURL, recordingDelegate: self)
  }

  func stopRecording() {
    guard isRecording else { return }
    isRecording = false
    backOutput?.stopRecording()
    frontOutput?.stopRecording()

    // When both didFinishRecording fire:
    group.notify(queue: .main) {
      self.recordedURLs  = (front: self.tmpFrontURL, back: self.tmpBackURL)
      self.showSavePrompt = true
      // clean up outputs so preview continues uninterrupted
      self.session.beginConfiguration()
      if let o = self.backOutput  { self.session.removeOutput(o) }
      if let o = self.frontOutput { self.session.removeOutput(o) }
      self.session.commitConfiguration()
    }
  }
}

// MARK: – Delegate

extension DualCameraViewModel: AVCaptureFileOutputRecordingDelegate {
  func fileOutput(_ output: AVCaptureFileOutput,
                  didFinishRecordingTo outputFileURL: URL,
                  from connections: [AVCaptureConnection],
                  error: Error?)
  {
    group.leave()
  }
}
