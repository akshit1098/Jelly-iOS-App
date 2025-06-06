////
////  FeedView.swift
////  Jelly-iOS-App
////
////  Created by Akshit Saxena on 6/3/25.
////
//
//import SwiftUI
//
//struct FeedView: View {
//    
//    @StateObject private var viewModel = FeedViewModel()
//    
//    var body: some View {
//        NavigationView {
//                    Group {
//                        if viewModel.isLoading {
//                            // Show a loading spinner
//                            VStack {
//                                Spacer()
//                                ProgressView("Loading Feed…")
//                                    .progressViewStyle(CircularProgressViewStyle())
//                                Spacer()
//                            }
//                        }
//                        else if let error = viewModel.errorMessage {
//                            // Show error state + Retry button
//                            VStack(spacing: 16) {
//                                Spacer()
//                                Text("❌ \(error)")
//                                    .multilineTextAlignment(.center)
//                                    .foregroundColor(.red)
//                                    .padding(.horizontal, 32)
//                                Button("Retry") {
//                                    viewModel.fetchFeed()
//                                }
//                                Spacer()
//                            }
//                        }
//                        else {
//                            // Main scrollable feed
//                            ScrollView {
//                                LazyVStack {
//                                    ForEach(viewModel.videos) { video in
//                                        VideoRowView(video: video)
//                                            .padding(.horizontal)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .navigationTitle("Jelly Feed")
//                    .toolbar {
//                        ToolbarItem(placement: .navigationBarTrailing) {
//                            Button {
//                                viewModel.fetchFeed()
//                            } label: {
//                                Image(systemName: "arrow.clockwise")
//                            }
//                            .help("Refresh Feed")
//                        }
//                    }
//                }
//    }
//}
//
