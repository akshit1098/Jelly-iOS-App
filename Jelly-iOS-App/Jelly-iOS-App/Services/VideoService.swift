////
////  VideoService.swift
////  Jelly-iOS-App
////
////  Created by Akshit Saxena on 6/3/25.
////
//
//import Foundation
//
//import Combine
//import SwiftSoup
//
//
//final class VideoService {
//    private let exploreURL = URL(string: "https://jellyjelly.com/feed")!
//    
//    /// Fetches Jelly’s Explore page, parses its HTML, and returns a list of Video objects.
//    /// Each Video has a UUID and the actual video file URL (mp4/webm, etc.).
//    func fetchVideos() -> AnyPublisher<[Video], Error> {
//        URLSession.shared.dataTaskPublisher(for: exploreURL)
//            .tryMap { data, response -> String in
//                // Ensure we got a 200‐299 response
//                guard let http = response as? HTTPURLResponse,
//                      (200..<300).contains(http.statusCode) else {
//                    throw URLError(.badServerResponse)
//                }
//                // Convert data → String (HTML)
//                guard let htmlString = String(data: data, encoding: .utf8) else {
//                    throw URLError(.cannotDecodeRawData)
//                }
//                return htmlString
//            }
//            .flatMap { htmlString -> AnyPublisher<[Video], Error> in
//                // Parse HTML with SwiftSoup on a background thread
//                Future<[Video], Error> { promise in
//                    DispatchQueue.global(qos: .userInitiated).async {
//                        do {
//                            let doc: Document = try SwiftSoup.parse(htmlString)
//                            
//                            // Strategy: find all <video> tags, then inside each, find <source> with src.
//                            // If the <video> tag itself has a "src" attribute, grab that too.
//                            // On Jelly’s Explore page, the videos are often nested like:
//                            //   <video …>
//                            //     <source src="https://cdn.jellyjelly.com/videos/abc123.mp4" type="video/mp4" />
//                            //   </video>
//                            
//                            var foundVideos: [Video] = []
//                            let videoElements: Elements = try doc.select("video")
//                            
//                            for element in videoElements {
//                                // 1) If <video src="…">, grab that
//                                if let videoSrc = try? element.attr("src"), videoSrc.count > 0,
//                                   let videoURL = URL(string: videoSrc) {
//                                    foundVideos.append(Video(id: UUID(), url: videoURL))
//                                }
//                                
//                                // 2) Also look inside <video> for <source> tags
//                                let sourceTags: Elements = try element.select("source[src]")
//                                for sourceTag in sourceTags {
//                                    let srcValue = try sourceTag.attr("src")
//                                    if let videoURL = URL(string: srcValue) {
//                                        foundVideos.append(Video(id: UUID(), url: videoURL))
//                                    }
//                                }
//                            }
//                            
//                            // De-duplicate any duplicate URLs
//                            let uniqueVideos: [Video] = {
//                                var seen = Set<URL>()
//                                var unique: [Video] = []
//                                for v in foundVideos {
//                                    if !seen.contains(v.url) {
//                                        seen.insert(v.url)
//                                        unique.append(v)
//                                    }
//                                }
//                                return unique
//                            }()
//                            
//                            promise(.success(uniqueVideos))
//                        } catch {
//                            promise(.failure(error))
//                        }
//                    }
//                }
//                .eraseToAnyPublisher()
//            }
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//}
