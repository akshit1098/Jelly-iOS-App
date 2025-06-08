//
//  DualCameraView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/6/25.
//

//import SwiftUI
//import AVFoundation
//
//struct DualCameraView: View {
//  @StateObject private var vm = DualCameraViewModel()
//  @State private var navigateToTab3 = false
//
//  var body: some View {
//    ZStack {
//      // Two preview layers, top + bottom halves
//      VStack(spacing: 0) {
//        CameraPreview(session: vm.session, position: .back)
//        CameraPreview(session: vm.session, position: .front)
//      }
//      .ignoresSafeArea()
//
//      // Record button
//      VStack {
//        Spacer()
//        Button(action: vm.startRecording) {
//          Circle()
//            .fill(vm.isRecording ? Color.red : Color.white.opacity(0.8))
//            .frame(width: 70, height: 70)
//            .overlay(
//              Circle()
//                .stroke(Color.white, lineWidth: 4)
//            )
//        }
//        .padding(.bottom, 40)
//      }
//    }
//    // When recordingURLs appear, upload then switch to Tab 3
//    .onReceive(vm.$recordingURLs.compactMap { $0 }.first()) { urls in
//      // Upload both, then switch:
//      FirebaseStorageService.shared.uploadVideo(localURL: urls.front) { _ in }
//      FirebaseStorageService.shared.uploadVideo(localURL: urls.back)  { _ in
//        // After uploads finish (or immediately), navigate:
//        navigateToTab3 = true
//      }
//    }
//    .background(
//      NavigationLink(destination: CameraRollView(),
//                     isActive: $navigateToTab3) { EmptyView() }
//    )
//  }
//}
//
///// Renders just the preview for one camera position.
//struct CameraPreview: UIViewRepresentable {
//  let session: AVCaptureMultiCamSession
//  let position: AVCaptureDevice.Position
//
//  func makeUIView(context: Context) -> UIView {
//    let view = UIView()
//    let layer = AVCaptureVideoPreviewLayer(session: session)
//    layer.videoGravity = .resizeAspectFill
//    // choose the correct input port
//    if let connection = layer.connection,
//       connection.isVideoOrientationSupported {
//      connection.videoOrientation = .portrait
//    }
//    view.layer.addSublayer(layer)
//    return view
//  }
//
//  func updateUIView(_ uiView: UIView, context: Context) {
//    uiView.layer.sublayers?.first?.frame = uiView.bounds
//  }
//}


// DualCameraView.swift
import SwiftUI

struct DualCameraView: View {
  @Binding var selectedTab: Int
  @StateObject private var vm = DualCameraViewModel()

  /// Which segment (15s vs 60s)
  enum Duration: Int, CaseIterable, Identifiable {
    case fifteen = 15, sixty = 60
    var id: Int { rawValue }
    var label: String { "\(rawValue)s" }
  }
  @State private var chosen: Duration = .fifteen

  /// Tracks upload/spinner & navigation
  @State private var isSaving = false
  @State private var goToRoll = false

  var body: some View {
    ZStack {
      // ─── Live multicam preview ───
      MultiCamPreview(vm: vm)
        .edgesIgnoringSafeArea(.all)

      // ─── UI overlay ───
      VStack {
        // … your top bar + picker …

        Spacer()

        // Record / Stop button
        Button {
          if vm.isRecording {
            vm.stopRecording()
          } else {
            vm.startRecording()
          }
        } label: {
          ZStack {
            Circle()
              .strokeBorder(Color.white, lineWidth: 4)
              .frame(width: 80, height: 80)
            Circle()
              .fill(vm.isRecording ? Color.red : Color.white.opacity(0.8))
              .frame(width: 56, height: 56)
          }
        }
        .padding(.bottom, 60)
      }

      // ─── Full-screen saving spinner ───
      if isSaving {
        Color.black.opacity(0.4)
          .ignoresSafeArea()
        ProgressView("Saving…")
          .progressViewStyle(CircularProgressViewStyle(tint: .white))
          .scaleEffect(1.5)
      }
    }
    .onReceive(vm.$recordingURL.compactMap { $0 }) { url in
      isSaving = true
      
      // upload then navigate
      FirebaseStorageService.shared.uploadVideo(localURL: url) { _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
          isSaving = false
          selectedTab = 2
          goToRoll = true
        }
      }
    }
    // Hidden link to Tab 3
    .background(
      NavigationLink(
        destination: CameraRollView(),
        isActive: $goToRoll
      ) { EmptyView() }
    )
    .navigationBarHidden(true)
  }
}
