//
//  CameraRollViewModel.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/6/25.
//

import Foundation

final class CameraRollViewModel: ObservableObject {
    @Published var videos: [URL] = []

    /// Ask your Firebase service for all merged-POV clips.
    func fetchVideos() {
        FirebaseStorageService.shared.listAllVideos { urls in
            DispatchQueue.main.async {
                // sort by whatever makes sense
                self.videos = urls
            }
        }
    }
}
