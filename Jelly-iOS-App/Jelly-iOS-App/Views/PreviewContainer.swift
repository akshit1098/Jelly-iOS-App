//
//  PreviewContainer.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/7/25.
//

import SwiftUI
import AVFoundation

struct PreviewContainer: UIViewRepresentable {
  let layer: AVCaptureVideoPreviewLayer

  func makeUIView(context: Context) -> UIView {
    let v = UIView(frame: .zero)
    layer.frame = v.bounds
    layer.needsDisplayOnBoundsChange = true
    v.layer.addSublayer(layer)
    return v
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    layer.frame = uiView.bounds
  }
}
