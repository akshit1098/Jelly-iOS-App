//
//  VideoPlayerView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/3/25.
//

//import SwiftUI
//import AVKit
//import Combine
//
//struct VideoPlayerView: View {
//    let video: URL
//    let player: AVPlayer
//
//    /// Tracks whether the AVPlayer’s first frame is ready to display
//    @State private var isReady: Bool = false
//
//    /// Current playback time (in seconds) — drives the slider thumb
//    @State private var currentTime: Double = 0
//
//    /// Total video duration (in seconds). Zero until we pull it from the AVPlayerItem.
//    @State private var totalDuration: Double = 0
//
//    /// A Combine publisher for periodically polling the player’s current time
//    @State private var timeObserverCancellable: AnyCancellable?
//
//    /// Whether the user is currently dragging the slider (we’ll pause updating currentTime while they drag)
//    @State private var isDraggingSlider: Bool = false
//
//    var body: some View {
//        ZStack {
//            // 1) Black background, full‐screen
//            Color.black
//                .ignoresSafeArea()
//
//            if isReady {
//                // 2) Once the player is ready, show the VideoPlayer + progress bar
//                VStack(spacing: 0) {
//                    // ─────────────────────────────────────────────────────────────────
//                    // A) The VideoPlayer itself
//                    // ─────────────────────────────────────────────────────────────────
//                    VideoPlayer(player: player)
//                        .ignoresSafeArea()
//                        .onAppear {
//                            // When this view appears, start playback and start our time‐poller
//                            player.play()
//                            startPeriodicTimeObserver()
//                        }
//                        .onDisappear {
//                            // Pause and cancel the time‐poller
//                            player.pause()
//                            timeObserverCancellable?.cancel()
//                        }
//
//                    // ─────────────────────────────────────────────────────────────────
//                    // B) A thin slider at the bottom that shows/controls progress
//                    // ─────────────────────────────────────────────────────────────────
//                    VStack {
//                        // Current time / Duration labels (optional)
//                        HStack {
//                            Text(formatTime(currentTime))
//                                .font(.caption)
//                                .foregroundColor(.white)
//                            Spacer()
//                            Text(formatTime(totalDuration))
//                                .font(.caption)
//                                .foregroundColor(.white)
//                        }
//                        .padding(.horizontal, 16)
//
//                        // The Slider itself
//                        Slider(
//                            value: Binding(
//                                get: {
//                                    currentTime
//                                },
//                                set: { newValue in
//                                    currentTime = newValue
//                                }
//                            ),
//                            in: 0...max(totalDuration, 0.1),
//                            onEditingChanged: { dragging in
//                                isDraggingSlider = dragging
//                                if !dragging {
//                                    // When the user finishes dragging, seek to that time
//                                    let targetTime = CMTime(seconds: currentTime, preferredTimescale: 600)
//                                    player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
//                                }
//                            }
//                        )
//                        .accentColor(.green)   // green track & thumb
//                        .padding(.horizontal, 16)
//                        .padding(.bottom, 8)
//                    }
//                    .background(Color.black.opacity(0.5))
//                }
//                .onAppear {
//                    // Immediately fetch duration from the AVPlayerItem (if available)
//                    if let item = player.currentItem {
//                        let durationSec = item.asset.duration.seconds
//                        if durationSec.isFinite && durationSec > 0 {
//                            totalDuration = durationSec
//                        }
//                        else {
//                            // If it’s not valid yet (metadata not loaded), observe until it becomes valid:
//                            item.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
//                                var error: NSError?
//                                let status = item.asset.statusOfValue(forKey: "duration", error: &error)
//                                if status == .loaded {
//                                    let d = item.asset.duration.seconds
//                                    if d.isFinite && d > 0 {
//                                        DispatchQueue.main.async {
//                                            totalDuration = d
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            else {
//                // 3) Show a spinner until we have at least one rendered video frame
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                    .scaleEffect(1.5)
//                    .onAppear {
//                        // Give AVPlayer a moment to prepare. After 0.3s, we'll assume it's “ready.”
//                        // In a production app, you could KVO‐observe AVPlayerItem.status instead.
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            isReady = true
//                        }
//                    }
//            }
//        }
//    }
//
//    // ───────────────────────────────────────────────────────────────────────────
//    // MARK: - Helper Methods
//    // ───────────────────────────────────────────────────────────────────────────
//
//    /// Format a Double (seconds) into mm:ss
//    private func formatTime(_ secs: Double) -> String {
//        guard secs.isFinite && secs >= 0 else { return "00:00" }
//        let totalSeconds = Int(secs)
//        let minutes = totalSeconds / 60
//        let seconds = totalSeconds % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//
//    /// Install a Combine timer that polls the player's currentTime every 0.5s,
//    /// updating `currentTime` so the slider thumb moves as the video plays.
//    private func startPeriodicTimeObserver() {
//        // If already running, do nothing
//        if timeObserverCancellable != nil { return }
//
//        // Create a Timer publisher on the main runloop, firing every 0.5s
//        timeObserverCancellable = Timer.publish(every: 0.5, on: .main, in: .common)
//            .autoconnect()
//            .sink { _ in
//                // If the user isn't actively dragging, update the thumb to match the player's time
//                guard !isDraggingSlider else { return }
//                let currentCMTime = player.currentTime()
//                let seconds = currentCMTime.seconds
//                if seconds.isFinite {
//                    currentTime = seconds
//                }
//            }
//    }
//}
//
//
//
//


//
//  VideoPlayerView.swift
//  Jelly-iOS-App
//
//  Created by Your Name on 6/3/25.
//

import SwiftUI
import AVKit
import UIKit

struct VideoPlayerView: View {
    let video: URL
    let player: AVPlayer

    // MARK: – Playback State
    @State private var isPlaying: Bool = true
    @State private var iconOpacity: Double = 0
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var timeObserverToken: Any?

    // MARK: – Like / Share / Mute State
    @State private var isLiked: Bool = false
    @State private var isMuted: Bool = false
    @State private var showingShareSheet: Bool = false

    var body: some View {
        ZStack {
            // 1) Black background
            Color.black.ignoresSafeArea()

            // 2) The AVPlayer-backed VideoPlayer
            VideoPlayer(player: player)
                .ignoresSafeArea()
                .onAppear {
                    setupTimeObserver()
                    player.play()
                    isPlaying = true
                }
                .onDisappear {
                    cleanupTimeObserver()
                    player.pause()
                    isPlaying = false
                }
                // Tapping anywhere on the video toggles play/pause
                .contentShape(Rectangle())
                .onTapGesture {
                    togglePlayPause()
                }

            // 3) Large center icon for play/pause feedback (fades out)
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.white)
                .opacity(iconOpacity)

            // 4) Bottom overlay: small play/pause + time slider + time labels
            VStack {
                Spacer()

                if duration > 0 {
                    HStack(spacing: 12) {
                        // 4.1) Small play/pause button
                        Button(action: {
                            togglePlayPause()
                        }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: iconSize, height: iconSize)
                                .foregroundColor(.white)
                        }

                        // 4.2) Current time label
                        Text(timeString(from: currentTime))
                            .font(.caption2)
                            .foregroundColor(.white)
                            .frame(width: timeLabelWidth, alignment: .leading)

                        // 4.3) Scrubber slider
                        Slider(
                            value: Binding(
                                get: { currentTime },
                                set: { newValue in
                                    seek(to: newValue)
                                }
                            ),
                            in: 0...duration
                        )
                        .accentColor(.green)

                        // 4.4) Duration label
                        Text(timeString(from: duration))
                            .font(.caption2)
                            .foregroundColor(.white)
                            .frame(width: timeLabelWidth, alignment: .trailing)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
            }

            // 5) Right-side vertical stack: profile, heart, X (Share), speaker
            VStack(spacing: 24) {
                // 5.1) Dummy profile picture
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .onTapGesture {
                        print("Profile tapped (stub).")
                    }

                // 5.2) Like (heart) button
                Button(action: {
                    isLiked.toggle()
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                        .foregroundColor(isLiked ? .red : .white)
                }

                // 5.3) “X” share button
                Button(action: {
                    showingShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                        .foregroundColor(.white)
                }
                .sheet(isPresented: $showingShareSheet) {
                    ShareSheet(activityItems: [video])
                }

                // 5.4) Speaker (mute/unmute) button
                Button(action: {
                    toggleMute()
                }) {
                    Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                        .foregroundColor(.white)
                }

                Spacer()
            }
            .padding(.top, eighty)          // push down from top a bit
            .padding(.trailing, twelve)     // right inset
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    // MARK: – Play/Pause Toggle & Overlay Animation

    private func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()

        // Show the large overlay icon, then fade it out after a brief delay
        iconOpacity = 1.0
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            iconOpacity = 0.0
        }
    }

    // MARK: – Mute/Unmute Toggle

    private func toggleMute() {
        isMuted.toggle()
        player.isMuted = isMuted
    }

    // MARK: – Seek Logic

    private func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: cmTime) { _ in
            // If it was playing before scrubbing, resume
            if isPlaying {
                player.play()
            }
        }
    }

    // MARK: – Periodic Time Observer

    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.2, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let secs = time.seconds
            currentTime = secs

            // Read duration once, as soon as it's nonzero
            if duration == 0, let item = player.currentItem {
                let dur = item.duration.seconds
                if dur.isFinite && dur > 0 {
                    duration = dur
                }
            }
        }
    }

    private func cleanupTimeObserver() {
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    // MARK: – Time Formatting

    private func timeString(from seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "0:00" }
        let interval = Int(seconds.rounded())
        let s = interval % 60
        let m = (interval / 60) % 60
        let h = interval / 3600

        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%d:%02d", m, s)
        }
    }

    // MARK: – Sizing Constants (inlined)

    private let iconSize: CGFloat = 36           // small play/pause, heart, X size
    private let timeLabelWidth: CGFloat = 40     // width for “0:00” labels
    private let fiftySix: CGFloat = 56           // profile picture size
    private let eighty: CGFloat = 80             // top padding for right‐stack
    private let twelve: CGFloat = 12             // right padding
}

// MARK: – UIKit Share Sheet Wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        // Optional: if you want to exclude certain share options, add:
        // controller.excludedActivityTypes = [.assignToContact, .saveToCameraRoll, .addToReadingList, .postToFacebook]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nothing to update; we simply show it modally
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(
            video: URL(string: "https://www.example.com/video.mp4")!,
            player: AVPlayer(url: URL(string: "https://www.example.com/video.mp4")!)
        )
    }
}
