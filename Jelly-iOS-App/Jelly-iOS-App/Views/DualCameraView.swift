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


import SwiftUI

struct DualCameraView: View {
    /// How long to record: 60s or 15s
    enum Duration: Int, CaseIterable, Identifiable {
        case sixty   = 60
        case fifteen = 15

        // Identifiable conformance
        var id: Int { rawValue }

        // Easy-to-display label
        var label: String { "\(rawValue)s" }

        // If you ever need a TimeInterval:
        var timeInterval: TimeInterval { TimeInterval(rawValue) }
    }

    @State private var chosen: Duration = .fifteen

    var body: some View {
        ZStack {
          // ─── Your live preview layer sits behind this… ───
          MultiCamPreview()
            .edgesIgnoringSafeArea(.all)

          // ─── Your overlay UI ───
          VStack {
            HStack {
              Button { /* share link */ }   label: { Image(systemName: "link") }
                .styleOverlayIcon()

              Button { /* swap cameras */ } label: { Image(systemName: "arrow.triangle.2.circlepath.camera") }
                .styleOverlayIcon()

              Spacer()

              Button { /* settings */ }     label: { Image(systemName: "gearshape") }
                .styleOverlayIcon()

              Button { /* flip front/back */ }  label: { Image(systemName: "camera") }
                .styleOverlayIcon()
            }
            .padding(.horizontal)
            .padding(.top, 44)

            Spacer()

            // ─── The only change you needed here ───
            Picker("", selection: $chosen) {
              ForEach(Duration.allCases) { d in
                Text(d.label).tag(d)
              }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 140)
            .padding(.bottom, 20)

            Button {
              // wire these up to your view-model’s start/stop
            } label: {
              ZStack {
                Circle()
                  .strokeBorder(Color.white, lineWidth: 4)
                  .frame(width: 80, height: 80)
                Circle()
                  .fill(Color.red)
                  .frame(width: 56, height: 56)
              }
            }
            .padding(.bottom, 60)
          }
        }
        .navigationBarHidden(true)
    }
}

private extension View {
  /// little translucent round buttons in the top bar
  func styleOverlayIcon() -> some View {
    self
      .font(.system(size: 20))
      .padding(8)
      .background(Color.black.opacity(0.3))
      .clipShape(Circle())
      .foregroundColor(.white)
  }
}

