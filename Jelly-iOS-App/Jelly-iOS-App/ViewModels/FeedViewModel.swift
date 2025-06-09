//
//  FeedViewModel.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/3/25.
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
