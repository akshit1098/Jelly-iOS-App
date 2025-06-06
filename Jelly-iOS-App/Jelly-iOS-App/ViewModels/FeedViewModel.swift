//
//  FeedViewModel.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/3/25.
//

//import Foundation
//import Combine
//import AVKit
//
///// Simple ViewModel: stores an array of video URLs and creates looping AVPlayers.
//final class FeedViewModel: ObservableObject {
//    @Published var videos: [URL] = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//
//    /// Called once the scraper hands us a full [URL] list.
//    func load(from urls: [URL]) {
//        DispatchQueue.main.async {
//            self.isLoading = false
//            self.errorMessage = nil
//            self.videos = urls
//        }
//    }
//
//    /// Returns an AVPlayer that loops continuously (audio unmuted by default).
//    func makePlayer(for url: URL) -> AVPlayer {
//        let player = AVPlayer(url: url)
//        NotificationCenter.default.addObserver(
//            forName: .AVPlayerItemDidPlayToEndTime,
//            object: player.currentItem,
//            queue: .main
//        ) { _ in
//            player.seek(to: .zero)
//            player.play()
//        }
//        return player
//    }
//}


//import Foundation
//import SwiftUI
//import AVKit
//
///// A simple data model representing one video plus its metadata.
//struct JellyVideo: Identifiable {
//    let id = UUID()
//    let url: URL
//
//    // MARK: – Metadata fields (scrape these if you can; placeholder for now)
//    let profileImage: Image      // e.g. from Assets or loaded via AsyncImage
//    let username: String
//    let titleText: String
//    let descriptionText: String
//    let viewCount: Int
//}
//
//final class FeedViewModel: ObservableObject {
//    // Array of videos (with metadata)
//    @Published var videos: [JellyVideo] = []
//    
//    // If an error occurs during scraping/loading
//    @Published var errorMessage: String? = nil
//
//    /// Called once the hidden WebView gives us an array of URLs to actual .mp4 files.
//    func load(from urls: [URL]) {
//        // Clear any previous error
//        self.errorMessage = nil
//        
//        // If no URLs were found, show error
//        guard !urls.isEmpty else {
//            self.errorMessage = "No video URLs returned from the feed."
//            return
//        }
//
//        // Map each URL into a JellyVideo with placeholder metadata.
//        // In a 'real' version, you should scrape the actual metadata (profile picture URL, username, caption, view count, etc.)
//        self.videos = urls.map { url in
//            JellyVideo(
//                url: url,
//                profileImage: Image(systemName: "person.crop.circle.fill"), // placeholder circle
//                username: "@placeholder",
//                titleText: "Placeholder Title",
//                descriptionText: "This is a placeholder description for the video.",
//                viewCount: Int.random(in: 10...500)
//            )
//        }
//    }
//
//    /// Create an AVPlayer for a given URL. You may choose to reuse players if you want caching.
//    func makePlayer(for url: URL) -> AVPlayer {
//        let playerItem = AVPlayerItem(url: url)
//        return AVPlayer(playerItem: playerItem)
//    }
//}
//


//
//  FeedViewModel.swift
//  Jelly-iOS-App
//
//  Created by Your Name on 6/3/25.
//

import Foundation
import AVKit
import Combine

/// A simple ObservableObject that holds:
///  • videos: the array of fetched video URLs
///  • errorMessage: an optional String if scraping failed
class FeedViewModel: ObservableObject {
    @Published var videos: [URL] = []
    @Published var errorMessage: String? = nil

    /// Load an array of URLs into our view model
    func load(from urls: [URL]) {
        // Optionally, you could shuffle or reorder here.
        DispatchQueue.main.async {
            self.videos = urls
        }
    }

    /// If you need to create AVPlayer per URL (but in our version we build players in JellyFeedView)
    func makePlayer(for url: URL) -> AVPlayer {
        return AVPlayer(url: url)
    }
}
