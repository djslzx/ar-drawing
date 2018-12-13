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

/// A wrapper for Geometry generators
public class Pen {
  public let count : Int /// The number of point parameters
  private let fn : ([float3], Context) -> SCNNode /// Geometry generator
  
  /// Initializes a new Pen
  public init(count: Int, _ fn: @escaping ([float3], Context) -> SCNNode) {
    self.count = count
    self.fn = fn
  }

  /// - Returns: A SCNNode containing the result of the pen's application
  public func apply(vertices: [float3], context : Context) -> SCNNode {
    return fn(vertices, context)
  }
}

/// A wrapper for drawn properties
public struct Context {
  public var color : UIColor /// The color of a brush/geometry
  public var lineRadius : CGFloat /// The radius of a stroke geometry
  public var detail : Int /// The level of detail (i.e. for Bezier, the number of discretization ˜ƒpoints)
  
  /// Initializes a new Context
  public init(color: UIColor = UIColor.white,
              lineRadius: CGFloat = CGFloat(powf(10, -3.75)),
              detail: Int = 16) {
    self.color = color
    self.lineRadius = lineRadius
    self.detail = detail
  }
}

/**
 A superclass for context updates.
 */
public class ContextUpdater {
  public init() {}
  
  /// - Returns: An updated version of the context.
  /// - Parameter context: The context to be updated.
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
