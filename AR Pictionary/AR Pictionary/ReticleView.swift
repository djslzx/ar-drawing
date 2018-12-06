//
//  ReticleView.swift
//  AR Pictionary
//
//  Created by 21djl5 on 11/25/18.
//  Copyright © 2018 davidjlee. All rights reserved.
//

import UIKit

@IBDesignable
class ReticleView: UIView {

  /// Cross reticle properties
  @IBInspectable public var lineThickness : CGFloat = 1
  @IBInspectable public var crossLineColor : UIColor = UIColor.lightGray
  @IBInspectable public var crossRadius : CGFloat = 15

  // Draws a reticle
  override func draw(_ rect: CGRect) {
//    stroke(from: CGPoint(x: self.center.x, y: self.center.y - crossRadius),
//           to: CGPoint(x: self.center.x, y: self.center.y + crossRadius))
//    stroke(from: CGPoint(x: self.center.x - crossRadius, y: self.center.y),
//           to: CGPoint(x: self.center.x + crossRadius, y: self.center.y))
    circularReticle()
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

  /// Circle line prediction redicle
  @IBInspectable public var circleLineColor : UIColor = UIColor.white
  @IBInspectable public var circleRadius : CGFloat = 14
  
  /// Draws a circular path
  private func circularReticle()  {
    let path = UIBezierPath(arcCenter: self.center,
                            radius: circleRadius,
                            startAngle: 0,
                            endAngle: CGFloat.pi * 2,
                            clockwise: true)
    path.lineWidth = lineThickness
    circleLineColor.setStroke()
    path.stroke()
  }
  
  /// Updates predictive circle reticle using given circle radius
  public func updateCircleReticle(color: UIColor, radius: CGFloat) {
    circleLineColor = color
    circleRadius = radius
    setNeedsDisplay()
  }
}
