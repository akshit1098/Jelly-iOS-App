//
//  CameraRollViewModel.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/6/25.
//

import Foundation
import FirebaseStorage

/// Fetches all video URLs from the "videos/" folder
class CameraRollViewModel: ObservableObject {
  @Published var videoURLs: [URL] = []

  private let storage = Storage.storage().reference().child("videos")

  func loadVideos() {
    storage.listAll { result, error in
      if let items = result?.items {
        items.forEach { item in
          item.downloadURL { url, _ in
            if let url = url {
              DispatchQueue.main.async {
                self.videoURLs.append(url)
              }
            }
          }
        }
      }
    }
  }
}

