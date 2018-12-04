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
  let count : Int /// The number of point parameters
  private let fn : ([float3], Context) -> SCNNode
  
  public init(count: Int, _ fn: @escaping ([float3], Context) -> SCNNode) {
    self.count = count
    self.fn = fn
  }

  public func apply(vertices: [float3], context : Context) -> SCNNode {
    return fn(vertices, context)
  }
}

public class Context {
  private let color : UIColor
  private let lineThickness : CGFloat
  private let lineDetail : Int

  public init(color: UIColor, lineThickness: CGFloat, lineDetail: Int) {
    self.color = color
    self.lineThickness = lineThickness
    self.lineDetail = lineDetail
  }
}

public class ContextUpdater {
  
}
