//
//  JellyFeedView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/3/25.
//


import SwiftUI
import AVKit
import Combine

struct JellyFeedView: View {
    @StateObject private var viewModel = FeedViewModel()

    /// Becomes true once we receive the full [URL] from the hidden WebView
    @State private var urlsFetched = false

    /// Which video index is currently shown in the TabView
    @State private var selectedIndex: Int = 0

    /// A UUID to force-recreate ScrapingWebViewHorizontal on “reload”
    @State private var reloadKey = UUID()

    /// One AVPlayer per video URL
    @State private var players: [AVPlayer] = []

    var body: some View {
        ZStack {
            if !urlsFetched {
                // HIDDEN SCRAPER WEBVIEW
                ScrapingWebView { urls in
                    if urls.isEmpty {
                        // If no URLs were found, show an error in the viewModel
                        viewModel.errorMessage = "No videos found."
                        urlsFetched = true
                    } else {
                        viewModel.load(from: urls)
                        urlsFetched = true
                    }
                }
                .frame(width: 1, height: 1)
                .opacity(0)
                .id(reloadKey)

            } else {
                // 2) AFTER URLs ARRIVE
                if let error = viewModel.errorMessage {
                    // Show an error + Retry
                    VStack(spacing: 16) {
                        Spacer()
                        Text("❌ \(error)")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.red)
                            .padding(.horizontal, 32)
                        Button("Retry") {
                            reload()
                        }
                        Spacer()
                    }
                }
                else if viewModel.videos.isEmpty {
                    // (Should not normally happen, but a safeguard)
                    VStack {
                        Spacer()
                        Text("No videos available.")
                            .foregroundColor(.gray)
                        Button("Retry") {
                            reload()
                        }
                        Spacer()
                    }
                }
                else if players.count != viewModel.videos.count {
                    // We have URLs in viewModel.videos, but haven't built `players` yet.
                    // Show a black placeholder while we create AVPlayers.
                    Color.black
                        .ignoresSafeArea()
                        .onAppear {
                            // Build one AVPlayer per URL, then start first video
                            setupPlayers()
                        }
                }
                else {
                    // 3) ALL PLAYERS READY → SHOW CAROUSEL
                    TabView(selection: $selectedIndex) {
                        ForEach(Array(viewModel.videos.enumerated()), id: \.offset) { idx, url in
                            VideoPlayerView(
                                video: url,
                                player: players[idx]
                            )
                            .tag(idx)
                            .ignoresSafeArea()
                            // When this player's item finishes, advance index:
                            .onReceive(
                                NotificationCenter.default
                                    .publisher(
                                        for: .AVPlayerItemDidPlayToEndTime,
                                        object: players[idx].currentItem
                                    )
                            ) { _ in
                                advanceIndex()
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    // Whenever selectedIndex changes (swipe or programmatic), pause all but that index, then play it
                    .onChange(of: selectedIndex) { newIndex in
                        playVideo(at: newIndex)
                    }
                    .overlay(
                        // Overlay left/right arrow buttons
                        HStack {
                            // Left arrow
                            Button {
                                rewindIndex()
                            } label: {
                                Image(systemName: "chevron.left.circle.fill")
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                    .opacity(0.7)
                            }
                            .padding(.leading, 16)

                            Spacer()

                            // Right arrow
                            Button {
                                advanceIndex()
                            } label: {
                                Image(systemName: "chevron.right.circle.fill")
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                    .opacity(0.7)
                            }
                            .padding(.trailing, 16)
                        }
                        .foregroundColor(.white),
                        alignment: .center
                    )
                }
            }
        }
        .navigationBarTitle("Jelly Feed", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    reload()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Reload feed")
            }
        }
    }

    
    /// Create one AVPlayer for each URL, then start the first video.
    private func setupPlayers() {
        // Clear any old players
        players.removeAll()

        // Build exactly one AVPlayer per video URL
        players = viewModel.videos.map { AVPlayer(url: $0) }

        // Start playing index 0
        playVideo(at: 0)
    }

    /// Pause all players except the one at `index`, then play that one from start.
    private func playVideo(at index: Int) {
        for (i, player) in players.enumerated() {
            if i == index {
                player.seek(to: .zero)
                player.play()
            } else {
                player.pause()
            }
        }
    }

   

    /// Advance to the next video (wrap around to zero)
    private func advanceIndex() {
        guard !viewModel.videos.isEmpty else { return }
        let next = (selectedIndex + 1) % viewModel.videos.count
        withAnimation {
            selectedIndex = next
        }
    }

    /// Go back to the previous video (wrap around to last index)
    private func rewindIndex() {
        guard !viewModel.videos.isEmpty else { return }
        let prev = (selectedIndex - 1 + viewModel.videos.count) % viewModel.videos.count
        withAnimation {
            selectedIndex = prev
        }
    }

    

    /// Reset everything so that ScrapingWebViewHorizontal will run again
    private func reload() {
        urlsFetched = false
        viewModel.videos = []
        viewModel.errorMessage = nil
        selectedIndex = 0
        players = []
        reloadKey = UUID()
    }
}

struct JellyFeedView_Previews: PreviewProvider {
    static var previews: some View {
        JellyFeedView()
    }
}
