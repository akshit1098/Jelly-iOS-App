//
//  CameraRollView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/6/25.
//

import SwiftUI

import SwiftUI
import AVKit

struct CameraRollView: View {
  @StateObject private var vm = CameraRollViewModel()

  var body: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(), GridItem()]) {
        ForEach(vm.videoURLs, id: \.self) { url in
          VideoThumbnailView(videoURL: url)
            .aspectRatio(3/4, contentMode: .fit)
            .onTapGesture {
              // show full‐screen AVPlayer
              AVPlayerViewController.presentVideo(url: url)
            }
        }
      }
      .padding()
    }
    .navigationTitle("My Videos")
    .onAppear {
      vm.loadVideos()
    }
  }
}

/// A thumbnail + play icon overlay
struct VideoThumbnailView: View {
  let videoURL: URL

  var body: some View {
    ZStack {
      // You could generate a thumbnail asynchronously; for simplicity:
      Color.gray.opacity(0.3)
      Image(systemName: "play.circle.fill")
        .font(.largeTitle)
        .foregroundColor(.white)
    }
    .cornerRadius(8)
  }
}

import UIKit
import AVKit

extension AVPlayerViewController {
  static func presentVideo(url: URL) {
    guard let root = UIApplication.shared.windows.first?.rootViewController else {
      return
    }
    let vc = AVPlayerViewController()
    vc.player = AVPlayer(url: url)
    root.present(vc, animated: true) {
      vc.player?.play()
    }
  }
}
