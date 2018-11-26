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

  @IBInspectable public var lineColor : UIColor = UIColor.red
  @IBInspectable public var lineWidth : CGFloat = 1
  @IBInspectable public var radius : CGFloat = 10

  // Draws a reticle
  override func draw(_ rect: CGRect) {
    stroke(from: CGPoint(x: self.center.x, y: self.center.y - radius/2),
           to: CGPoint(x: self.center.x, y: self.center.y + radius/2))
    stroke(from: CGPoint(x: self.center.x - radius/2, y: self.center.y),
           to: CGPoint(x: self.center.x + radius/2, y: self.center.y))
  }
  
  private func stroke(from src : CGPoint, to dst : CGPoint) {
    let path = UIBezierPath()
    path.move(to: src)
    path.addLine(to: dst)
    path.lineWidth = lineWidth
    lineColor.setStroke()
    path.stroke()
  }
  
}
