//
//  CameraRollView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/6/25.
//

import SwiftUI
import AVKit

struct CameraRollView: View {
    @StateObject private var vm = CameraRollViewModel()

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(vm.videos, id: \.self) { url in
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 200)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Camera Roll")
        .onAppear { vm.fetchVideos() }
    }
}
