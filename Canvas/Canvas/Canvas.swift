//
//  Canvas.sw.swift
//  Canvas
//
//  Created by 21djl5 on 11/22/18.
//  Copyright © 2018 davidjlee. All rights reserved.
//

import Foundation
import SceneKit
import CoreGraphics

public class Polyline : CustomDebugStringConvertible {
  
  public private(set) var vertices : [float3]
  
  public var debugDescription: String {
    return String(reflecting: vertices)
  }
  
  public init() {
    vertices = []
  }
  
  public init(vertices : [float3]) {
    self.vertices = vertices
  }
  
  public init(generator : (Float) -> float3, values : [Float]) {
    vertices = values.map(generator)
  }
  
  public func add(vertex : float3) {
    vertices.append(vertex)
  }
  
  public func removeLast() {
    vertices.removeLast()
  }
  
  public func lastSegment() -> (float3, float3)? {
    if vertices.count >= 2 {
      return (vertices[vertices.count - 2], vertices[vertices.count - 1])
    } else {
      return nil
    }
  }
  
  public func segments() -> Zip2Sequence<ArraySlice<float3>, ArraySlice<float3>> {
    return zip(vertices[...], vertices[1...])
  }
  
}

public class PolylineGeometry {
  
  private var line : Polyline
  
  public init(vertices : [float3]) {
    line = Polyline(vertices: vertices)
  }
  
  public convenience init() {
    self.init(vertices: [])
  }
  
  public func geometry(width: CGFloat) -> SCNNode {
    let parent = SCNNode()
    for (u, v) in line.segments() {
      let cylinder = SCNCylinder(radius: width, height: CGFloat(u.distance(to: v)))
      cylinder.heightSegmentCount = 1
      cylinder.radialSegmentCount = 6
      
      let node = SCNNode(geometry: cylinder)
      node.simdPosition = u
      
    }
    return parent
  }
}

//public class Spline : CustomDebugStringConvertible {
//
//  private var vertices : [float3]
//
//  public var debugDescription: String
//
//
//}

extension float3 {
  
  public static func - (lhs : float3, rhs : float3) -> float3 {
    return float3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
  }
  
  public func distance(to dst : float3) -> Float {
    return sqrt(pow(self.x - dst.x, 2) +
      pow(self.y - dst.y, 2) +
      pow(self.z - dst.z, 2))
  }
  
  public func midpoint(with other : float3) -> float3 {
    return float3((self.x + other.x)/2,
                  (self.y + other.y)/2,
                  (self.z + other.z)/2)
  }
}
