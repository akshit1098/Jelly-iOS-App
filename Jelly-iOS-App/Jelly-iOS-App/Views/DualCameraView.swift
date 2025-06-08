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


//
//  DualCameraView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/7/25.
//


import SwiftUI

struct DualCameraView: View {
  @StateObject private var vm = DualCameraViewModel()
  @State private var navigateToRoll = false

  var body: some View {
    ZStack {
      // your two-pane live preview
      MultiCamPreview(vm: vm)
        .edgesIgnoringSafeArea(.all)

      // overlay record button
      VStack {
        Spacer()
        Button(action: {
          vm.isRecording ? vm.stopRecording() : vm.startRecording()
        }) {
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
    }
    // when delegate sets recordedURLs, show “Save?” prompt
    .alert(isPresented: $vm.showSavePrompt) {
      Alert(
        title: Text("Save recording?"),
        message: Text("Would you like to save this clip to your camera roll?"),
        primaryButton: .default(Text("Save")) {
          // upload both then go to roll
          guard let urls = vm.recordedURLs else { return }
          FirebaseStorageService.shared.uploadVideo(localURL: urls.front) { _ in }
          FirebaseStorageService.shared.uploadVideo(localURL: urls.back) { _ in
            navigateToRoll = true
          }
        },
        secondaryButton: .cancel {
          // discard temp files
        }
      )
    }
    .background(
      NavigationLink(destination: CameraRollView(),
                     isActive: $navigateToRoll) {
        EmptyView()
      }
    )
    .navigationBarHidden(true)
  }
}
