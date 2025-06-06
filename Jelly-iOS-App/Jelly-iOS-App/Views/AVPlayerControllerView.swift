//
//  AVPlayerControllerView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/4/25.
//

import SwiftUI
import AVKit

/// A simple UIViewControllerRepresentable that hosts AVPlayerViewController.
/// It shows playback controls (including a seek bar) so users can drag to any time.
struct AVPlayerControllerView: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        // Maintain aspect ratio:
        controller.videoGravity = .resizeAspect
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Nothing dynamic to update here (player is already set in makeUIViewController).
    }
}
