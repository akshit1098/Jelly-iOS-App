//
//  FirebaseStorageService.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/6/25.
//

import Foundation
import FirebaseStorage

/// Simple singleton wrapper around Firebase Storage
final class FirebaseStorageService {
    static let shared = FirebaseStorageService()
    private init() {}

    private let storage = Storage.storage()

    /// Upload a single file at `localURL` into "videos/\(UUID).mov"
    func uploadVideo(localURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        let uuid = UUID().uuidString
        let remoteRef = storage.reference()
                              .child("videos")
                              .child("\(uuid).mov")

        let _ = remoteRef.putFile(from: localURL, metadata: nil) { _, err in
            if let err = err {
                completion(.failure(err))
            } else {
                completion(.success(()))
            }
        }
    }

    /// List all files under "videos/" and return their download URLs
    func listAllVideos(completion: @escaping ([URL]) -> Void) {
        let videosRef = storage.reference().child("videos")
        videosRef.listAll { (result, error) in
            guard error == nil else {
                print("⚠️ Failed to list videos:", error!)
                return completion([])
            }

            let items = result!.items
            var urls: [URL] = []
            let group = DispatchGroup()

            for item in items {
                group.enter()
                item.downloadURL { (url, err) in
                    if let url = url {
                        urls.append(url)
                    } else {
                        print("⚠️ couldn’t get downloadURL for \(item.name):", err ?? "")
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                // Sort if you need newest-first, etc.
                completion(urls)
            }
        }
    }
}
