//
//  Pen.swift
//  Canvas
//
//  Created by cs326 on 12/4/18.
//  Copyright © 2018 davidjlee. All rights reserved.
//

import Foundation
import SceneKit
import CoreGraphics

public class Pen {
  public let count : Int /// The number of point parameters
  private let fn : ([float3], Context) -> SCNNode
  
  public init(count: Int, _ fn: @escaping ([float3], Context) -> SCNNode) {
    self.count = count
    self.fn = fn
  }

  public func apply(vertices: [float3], context : Context) -> SCNNode {
    return fn(vertices, context)
  }
}

public struct Context {
  public var color : UIColor
  public var lineRadius : CGFloat
  public var detail : Int
  
  public init(color: UIColor = UIColor.white,
              lineRadius: CGFloat = CGFloat(powf(10, -3.75)),
              detail: Int = 16) {
    self.color = color
    self.lineRadius = lineRadius
    self.detail = detail
  }
}

/**
 A protocol for context updates.
 */
// TODO: Use protocol?
public class ContextUpdater {
  public init() {}
  
  public func update(context: Context) -> Context {
    return context
  }
}

/**
  A ContextUpdater that changes the context's color every time update() is called.
 
 */
public class RainbowUpdater : ContextUpdater {

  private var hue : CGFloat = 0

  private func incrementHue() {
    hue = (hue + 0.01).truncatingRemainder(dividingBy: 1)
  }

  public override func update(context: Context) -> Context {
    incrementHue()
    var newContext = context
    newContext.color = UIColor(hue: self.hue, saturation: 0.5,
                               brightness: 1, alpha: 1)
    return newContext
  }
}
