//
//  ReticleView.swift
//  AR Pictionary
//
//  Created by 21djl5 on 11/25/18.
//  Copyright © 2018 davidjlee. All rights reserved.
//

import UIKit

/// Reticle overlay
@IBDesignable class ReticleView: UIView {

  /// Cross reticle properties
  @IBInspectable public var lineThickness : CGFloat = 1
  @IBInspectable public var crossLineColor : UIColor = UIColor.lightGray
  @IBInspectable public var crossRadius : CGFloat = 15

  // Draws a reticle
  override func draw(_ rect: CGRect) {
    stroke(from: CGPoint(x: self.center.x, y: self.center.y - crossRadius),
           to: CGPoint(x: self.center.x, y: self.center.y + crossRadius))
    stroke(from: CGPoint(x: self.center.x - crossRadius, y: self.center.y),
           to: CGPoint(x: self.center.x + crossRadius, y: self.center.y))
  }
  
  /// Draws a stroke from `src` to `dst`
  private func stroke(from src : CGPoint, to dst : CGPoint) {
    let path = UIBezierPath()
    path.move(to: src)
    path.addLine(to: dst)
    path.lineWidth = lineThickness
    crossLineColor.setStroke()
    path.stroke()
  }
  
  /// Updates predictive circle reticle using given circle radius
  public func updateReticle(color: UIColor, radius: CGFloat) {
    crossLineColor = color
    crossRadius = radius
    setNeedsDisplay()
  }
}
