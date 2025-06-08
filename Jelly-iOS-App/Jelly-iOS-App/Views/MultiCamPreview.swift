//
//  MultiCamPreview.swift
//  Jelly-iOS-App
//
//  Created by Akshit Saxena on 6/7/25.
//

// MultiCamPreview.swift

import SwiftUI
import AVFoundation

/// A UIView that knows how to lay out two video-preview layers,
/// one on its top half (back camera) and one on its bottom half (front camera).
class PreviewContainerView: UIView {
  /// Back camera preview
  var backLayer: AVCaptureVideoPreviewLayer? {
    willSet { backLayer?.removeFromSuperlayer() }
    didSet {
      guard let layer = backLayer else { return }
      layer.videoGravity = .resizeAspectFill
      // Insert below frontLayer if both exist
      let idx = frontLayer != nil ? 0 : self.layer.sublayers?.count ?? 0
      self.layer.insertSublayer(layer, at: UInt32(idx))
      setNeedsLayout()
    }
  }
  /// Front camera preview
  var frontLayer: AVCaptureVideoPreviewLayer? {
    willSet { frontLayer?.removeFromSuperlayer() }
    didSet {
      guard let layer = frontLayer else { return }
      layer.videoGravity = .resizeAspectFill
      self.layer.addSublayer(layer)
      setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let halfH = bounds.height / 2
    backLayer?.frame  = CGRect(x: 0, y: 0,           width: bounds.width, height: halfH)
    frontLayer?.frame = CGRect(x: 0, y: halfH,       width: bounds.width, height: halfH)
  }
}

/// SwiftUI wrapper around the above container.
struct MultiCamPreview: UIViewRepresentable {
  @ObservedObject var vm: DualCameraViewModel

  func makeUIView(context: Context) -> PreviewContainerView {
    let view = PreviewContainerView()
    // as soon as the VM has its layers, assign them
    view.backLayer  = vm.backPreviewLayer
    view.frontLayer = vm.frontPreviewLayer
    return view
  }

  func updateUIView(_ uiView: PreviewContainerView, context: Context) {
    // re-assign whenever VM publishes new layers
    uiView.backLayer  = vm.backPreviewLayer
    uiView.frontLayer = vm.frontPreviewLayer
  }
}

