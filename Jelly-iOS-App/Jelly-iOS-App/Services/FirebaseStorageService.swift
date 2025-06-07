//
//  FirebaseStorageService.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/6/25.
//

import Foundation
import FirebaseStorage

/// A simple singleton to upload local video files to Firebase Storage
class FirebaseStorageService {
  static let shared = FirebaseStorageService()
  private let storage = Storage.storage()

  private init() {}

  /// Uploads a single file at localURL, returns a download URL on success
  func uploadVideo(
    localURL: URL,
    completion: @escaping (Result<URL, Error>) -> Void
  ) {
    let filename = "\(UUID().uuidString).mp4"
    let ref = storage.reference().child("videos/\(filename)")
    ref.putFile(from: localURL, metadata: nil) { _, error in
      if let err = error {
        completion(.failure(err)); return
      }
      ref.downloadURL { url, error in
        if let url = url {
          completion(.success(url))
        } else if let err = error {
          completion(.failure(err))
        }
      }
    }
  }
}

