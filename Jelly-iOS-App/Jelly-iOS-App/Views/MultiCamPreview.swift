//
//  MultiCamPreview.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/7/25.
//

import SwiftUI
import AVFoundation

/// Wraps the DualCameraViewModel and draws its two preview layers (or colored placeholders + debug text).
struct MultiCamPreview: View {
    @StateObject private var vm = DualCameraViewModel()

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // ── Top half: front camera or red
                Group {
                    if let frontLayer = vm.frontPreviewLayer {
                        PreviewContainer(previewLayer: frontLayer)
                            .overlay(Text("Front OK")
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(4)
                                        .padding(8),
                                     alignment: .topLeading)
                    } else {
                        Color.red
                            .overlay(Text("NO FRONT LAYER")
                                        .foregroundColor(.white)
                                        .bold())
                    }
                }
                .frame(height: geo.size.height / 2)

                // ── Bottom half: back camera or blue
                Group {
                    if let backLayer = vm.backPreviewLayer {
                        PreviewContainer(previewLayer: backLayer)
                            .overlay(Text("Back OK")
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(4)
                                        .padding(8),
                                     alignment: .topLeading)
                    } else {
                        Color.blue
                            .overlay(Text("NO BACK LAYER")
                                        .foregroundColor(.white)
                                        .bold())
                    }
                }
                .frame(height: geo.size.height / 2)
            }
        }
        // log when these published properties change:
        .onReceive(vm.$frontPreviewLayer) { layer in
            print("[MultiCamPreview] frontPreviewLayer →", layer as Any)
        }
        .onReceive(vm.$backPreviewLayer) { layer in
            print("[MultiCamPreview] backPreviewLayer  →", layer as Any)
        }
    }
}
