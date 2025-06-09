//
//  ContentView.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/3/25.
//


import SwiftUI

struct ContentView: View {
    @State private var selected = 0

    var body: some View {
        TabView(selection: $selected) {
            
            // ── Feed Tab ──
            NavigationStack {
                JellyFeedView()
                  .navigationTitle("Feed")
            }
            .tabItem { Label("Feed", systemImage: "house") }
            .tag(0)

            // ── Camera Tab ──
            NavigationStack {
                DualCameraView(selectedTab: $selected)
                  .navigationBarHidden(true)
            }
            .tabItem { Label("Camera", systemImage: "camera") }
            .tag(1)

            // ── Roll Tab ──
            NavigationStack {
                CameraRollView()
                  .navigationTitle("Camera Roll")
            }
            .tabItem { Label("Roll", systemImage: "photo.on.rectangle") }
            .tag(2)
        }
    }
}
