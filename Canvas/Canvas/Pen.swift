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
    let node = fn(vertices, context)
    // Set color and style
    node.enumerateChildNodes { (child, _) in
      child.geometry?.firstMaterial?.diffuse.contents = context.color
    }
  }
}

public struct Context {
  let color : UIColor
  let lineThickness : CGFloat
  let lineDetail : Int
}

public class ContextUpdater {
  
}
