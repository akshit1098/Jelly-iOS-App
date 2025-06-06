//
//  VideoRowView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/3/25.
//

import SwiftUI
import AVKit

struct VideoRowView: View {
    let video: Video
    @State private var player: AVPlayer? = nil
    var body: some View {
        VStack(spacing: 0) {
                    if let player = player {
                        VideoPlayer(player: player)
                            .frame(height: 300)
                            .cornerRadius(12)
                            .onAppear {
                                player.isMuted = true
                                player.play()
                            }
                            .onDisappear {
                                player.pause()
                            }
                    } else {
                        // Placeholder rectangle + spinner until we assign the player
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color.gray.opacity(0.3))
                                .frame(height: 300)
                                .cornerRadius(12)
                            ProgressView()
                        }
                        .onAppear {
                            // Create the AVPlayer only once
                            self.player = AVPlayer(url: video.url)
                        }
                    }
                }
                .padding(.vertical, 8)
    }
}

