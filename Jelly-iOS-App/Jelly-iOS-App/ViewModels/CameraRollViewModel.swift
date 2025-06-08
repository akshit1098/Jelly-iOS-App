//
//  CameraRollViewModel.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/6/25.
//

import SwiftUI
import AVKit

final class CameraRollViewModel: ObservableObject {
  @Published var videos: [URL] = []

  init() { loadLocalClips() }

  func loadLocalClips() {
    let tmp = FileManager.default.temporaryDirectory
    videos = (try? FileManager.default
                .contentsOfDirectory(at: tmp,
                                     includingPropertiesForKeys: nil,
                                     options: [.skipsHiddenFiles])
                .filter { $0.pathExtension == "mov" }) ?? []
  }
}
