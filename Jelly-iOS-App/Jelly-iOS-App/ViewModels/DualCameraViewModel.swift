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

// DualCameraViewModel.swift
// Jelly-iOS-App

// DualCameraViewModel.swift
// Jelly-iOS-App

import Foundation
import AVFoundation
import Combine

final class DualCameraViewModel: NSObject, ObservableObject {
  // MARK: Published
  @Published var backPreviewLayer:  AVCaptureVideoPreviewLayer?
  @Published var frontPreviewLayer: AVCaptureVideoPreviewLayer?
  @Published var isRecording = false
  @Published var recordingURL: URL?
    /// true while exporting/uploading
  @Published var isSaving = false

      /// flips to true once the final file is safely on disk (and/or uploaded)
  @Published var didFinishSaving = false

  // MARK: Private
  private let session = AVCaptureMultiCamSession()
  private var backOutput:  AVCaptureMovieFileOutput?
  private var frontOutput: AVCaptureMovieFileOutput?
  private var backFinished:  URL?
  private var frontFinished: URL?

  override init() {
    super.init()
    configureSession()
  }

  deinit {
    session.stopRunning()
  }

  // MARK: Public API

  func startRecording() {
    guard !isRecording else { return }
    isRecording = true

    let tmp  = FileManager.default.temporaryDirectory
    let uuid = UUID().uuidString

    if let out = backOutput {
      let url = tmp.appendingPathComponent("back-\(uuid).mov")
      out.startRecording(to: url, recordingDelegate: self)
    }
    if let out = frontOutput {
      let url = tmp.appendingPathComponent("front-\(uuid).mov")
      out.startRecording(to: url, recordingDelegate: self)
    }
  }

  func stopRecording() {
    guard isRecording else { return }
    isRecording = false
    backOutput?.stopRecording()
    frontOutput?.stopRecording()
  }

  // MARK: Session setup

  private func configureSession() {
    guard AVCaptureMultiCamSession.isMultiCamSupported else {
      print("⚠️ multicam not supported")
      return
    }

    session.beginConfiguration()
    session.sessionPreset = .inputPriority

    // ─── BACK CAMERA ───
    if let dev = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
       let inp = try? AVCaptureDeviceInput(device: dev),
       session.canAddInput(inp)
    {
      session.addInput(inp)

      // preview layer
      let preview = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session)
      preview.videoGravity = .resizeAspectFill
      if let port = inp.ports.first(where:{ $0.mediaType == .video }) {
        let conn = AVCaptureConnection(inputPort: port, videoPreviewLayer: preview)
        conn.videoRotationAngle = 0
        if session.canAddConnection(conn) {
          session.addConnection(conn)
          backPreviewLayer = preview
        } else {
          print("⚠️ cannot add back preview-connection; skipping")
        }
      }

      // movie output
      let out = AVCaptureMovieFileOutput()
      if session.canAddOutput(out) {
        session.addOutput(out)
        backOutput = out

        if let port = inp.ports.first(where:{ $0.mediaType == .video }) {
          let fileConn = AVCaptureConnection(inputPorts: [port], output: out)
          if session.canAddConnection(fileConn) {
            session.addConnection(fileConn)
          } else {
            print("⚠️ cannot add back file-connection; skipping")
          }
        }
      }
    }

    // ─── FRONT CAMERA ───
    if let dev = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
       let inp = try? AVCaptureDeviceInput(device: dev),
       session.canAddInput(inp)
    {
      session.addInput(inp)

      // preview layer
      let preview = AVCaptureVideoPreviewLayer(sessionWithNoConnection: session)
      preview.videoGravity = .resizeAspectFill
      if let port = inp.ports.first(where:{ $0.mediaType == .video }) {
        let conn = AVCaptureConnection(inputPort: port, videoPreviewLayer: preview)
        conn.videoRotationAngle = 0
        conn.automaticallyAdjustsVideoMirroring = false
        conn.isVideoMirrored = true
        if session.canAddConnection(conn) {
          session.addConnection(conn)
          frontPreviewLayer = preview
        } else {
          print("⚠️ cannot add front preview-connection; skipping")
        }
      }

      // movie output
      let out = AVCaptureMovieFileOutput()
      if session.canAddOutput(out) {
        session.addOutput(out)
        frontOutput = out

        if let port = inp.ports.first(where:{ $0.mediaType == .video }) {
          let fileConn = AVCaptureConnection(inputPorts: [port], output: out)
          if session.canAddConnection(fileConn) {
            session.addConnection(fileConn)
          } else {
            print("⚠️ cannot add front file-connection; skipping")
          }
        }
      }
    }

    session.commitConfiguration()
    session.startRunning()
    print("📷 multicam running = \(session.isRunning)")
  }

  // MARK: Merge

    private func mergeClips(front frontURL: URL, back backURL: URL) {
      // 1) Load assets
      let frontAsset = AVURLAsset(url: frontURL)
      let backAsset  = AVURLAsset(url: backURL)

      guard
        let frontTrack = frontAsset.tracks(withMediaType: .video).first,
        let backTrack  = backAsset.tracks(withMediaType: .video).first
      else {
        print("❌ couldn’t load video tracks")
        return
      }

      // 2) Create a mutable composition and add two video tracks
      let mix = AVMutableComposition()
      guard
        let compBack  = mix.addMutableTrack(
                         withMediaType: .video,
                         preferredTrackID: kCMPersistentTrackID_Invalid),
        let compFront = mix.addMutableTrack(
                         withMediaType: .video,
                         preferredTrackID: kCMPersistentTrackID_Invalid)
      else {
        print("❌ couldn’t create composition tracks")
        return
      }

      do {
        // insert entire back & front clips at time zero
        try compBack.insertTimeRange(
          CMTimeRange(start: .zero, duration: backAsset.duration),
          of: backTrack,
          at: .zero
        )
        try compFront.insertTimeRange(
          CMTimeRange(start: .zero, duration: frontAsset.duration),
          of: frontTrack,
          at: .zero
        )
      } catch {
        print("❌ inserting tracks failed:", error)
        return
      }

      // 3) Figure out the render size: we’ll stack vertically,
      //    so width = max(width₁, width₂), height = h₁ + h₂
      let backSize  = backTrack.naturalSize.applying(backTrack.preferredTransform)
      let frontSize = frontTrack.naturalSize.applying(frontTrack.preferredTransform)

      let w = max(abs(backSize.width), abs(frontSize.width))
      let h = abs(backSize.height) + abs(frontSize.height)
      let renderSize = CGSize(width: w, height: h)

      // 4) Build two layer-instructions, each with the transform to position
      //    its clip in the top or bottom half of the full canvas.
      let instruction = AVMutableVideoCompositionInstruction()
      instruction.timeRange = CMTimeRange(start: .zero,
                                          duration: CMTimeMaximum(backAsset.duration, frontAsset.duration))

      // back = top half
      let backLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compBack)
      // Scale to fit width if needed, then translate so it's at y=frontHeight
      var backTransform = backTrack.preferredTransform
      let backScaleW = w / abs(backSize.width)
      backTransform = backTransform.concatenating(CGAffineTransform(scaleX: backScaleW, y: backScaleW))
      backTransform = backTransform.concatenating(CGAffineTransform(translationX: 0,
                                                                     y: abs(frontSize.height)))
      backLayerInstruction.setTransform(backTransform, at: .zero)

      // front = bottom half
      let frontLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compFront)
      var frontTransform = frontTrack.preferredTransform
      let frontScaleW = w / abs(frontSize.width)
      frontTransform = frontTransform.concatenating(CGAffineTransform(scaleX: frontScaleW, y: frontScaleW))
      // no additional Y translation: sits at y=0
      frontLayerInstruction.setTransform(frontTransform, at: .zero)

      instruction.layerInstructions = [
        backLayerInstruction,
        frontLayerInstruction
      ]

      // 5) Wrap that in a videoComposition
      let videoComposition = AVMutableVideoComposition()
      videoComposition.instructions = [instruction]
      videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
      videoComposition.renderSize    = renderSize

      // 6) Export with the custom videoComposition
      let outputURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("stacked-\(UUID()).mov")

      guard let exporter = AVAssetExportSession(
        asset: mix,
        presetName: AVAssetExportPresetHighestQuality
      ) else {
        print("❌ export session init failed")
        return
      }

      exporter.outputURL        = outputURL
      exporter.outputFileType   = .mov
      exporter.videoComposition = videoComposition

      self.isSaving = true             // start spinner
      exporter.exportAsynchronously {
        DispatchQueue.main.async {
          switch exporter.status {
          case .completed:
            self.didFinishSaving = true
            print("✅ stack export done:", outputURL)
            // hand it back to your view‐model so your UI can redirect
            self.recordingURL = outputURL

          case .failed, .cancelled:
            print("❌ stack export failed:", exporter.error ?? "unknown")

          default:
            break
          }
        }
      }
    }

}

// MARK: File-output delegate

extension DualCameraViewModel: AVCaptureFileOutputRecordingDelegate {
  func fileOutput(_ output: AVCaptureFileOutput,
                  didFinishRecordingTo url: URL,
                  from connections: [AVCaptureConnection],
                  error: Error?)
  {
    if output === backOutput  { backFinished  = url }
    if output === frontOutput { frontFinished = url }

    if let b = backFinished, let f = frontFinished {
      backFinished = nil
      frontFinished = nil
      mergeClips(front: f, back: b)
    }
  }
}
