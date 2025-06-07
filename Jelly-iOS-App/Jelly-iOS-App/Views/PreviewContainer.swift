//
//  PreviewContainer.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/7/25.
//

import SwiftUI
import UIKit
import AVFoundation

/// Hosts a single AVCaptureVideoPreviewLayer and makes sure it
/// always fills its UIView by updating its frame in layoutSubviews.
struct PreviewContainer: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> ContainerView {
        ContainerView(layer: previewLayer)
    }

    func updateUIView(_ uiView: ContainerView, context: Context) {
        // Nothing needed here—ContainerView will resize the layer itself.
    }

    /// A tiny UIView subclass that owns the previewLayer
    /// and stretches it to fill whenever its bounds change.
    final class ContainerView: UIView {
        private let previewLayer: AVCaptureVideoPreviewLayer

        init(layer: AVCaptureVideoPreviewLayer) {
            self.previewLayer = layer
            super.init(frame: .zero)
            // Add the layer once
            self.layer.addSublayer(previewLayer)
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

        override func layoutSubviews() {
            super.layoutSubviews()
            // Stretch the video layer to fill our view
            previewLayer.frame = bounds
        }
    }
}
