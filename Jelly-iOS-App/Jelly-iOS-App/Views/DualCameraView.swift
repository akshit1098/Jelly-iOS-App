//
//  DualCameraView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/6/25.
//

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
          
        Text(vm.isRecording ? "Press red button to stop recording" : "Press white button to start recording")
            .font(.headline)
            .foregroundColor(.white)
            .padding(.bottom, 8)

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
        ProgressView("Saving your video. Please wait…")
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
