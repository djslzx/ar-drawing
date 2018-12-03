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

/**
 Represents a sequence of line segments where each consecutive pair of segments
 shares a point.
 
 */
public class Polyline : CustomDebugStringConvertible {
  
  /// The vertices of the line segments in the Polyline.
  public private(set) var vertices : [float3]
  
  public var debugDescription: String {
    return String(reflecting: vertices)
  }
  
  /**
   Initializes a new Polyline.
   
   - Parameter vertices: The sequence of 3-component vectors to be used
   as the endpoints of the line segments in the Polyline.
   */
  public init(vertices : [float3]) {
    self.vertices = vertices
  }
  
  /** Initializes an empty Polyline. */
  public convenience init() {
    self.init(vertices: [])
  }
  
  /**
   Initializes a Polyline using a generating function.
   
   -**Requires**: the generator is defined on the values provided
   
   - Parameters:
   - generator: The generating function used to compute the values of the vertices
   in the Polyline.
   - values: The values fed into the generator to derive vertex values.
   
   */
  public convenience init(generator : (Float) -> float3, values : [Float]) {
    self.init(vertices: values.map(generator))
  }
  
  /**
   Adds a vertex to the end of the Polyline.
   
   **Modifies**: self
   
   **Effects**: The input vertex is added to self.
   
   - Parameter vertex: The vertex to be added.
   
   */
  public func add(vertex : float3) {
    vertices.append(vertex)
  }
  
  /**
   Removes the last vertex in the Polyline.
   
   **Modifies**: self
   
   **Effects**: Removes the last vertex in self if one exists.
   Exits otherwise.
   
   */
  public func drop() {
    if !vertices.isEmpty {
      vertices.removeLast()
    }
  }
  
  /**
   - Returns: The last line segment in the Polyline.
   
   Useful when converting the Polyline into a viewable format segment by segment.
   */
  public func lastSegment() -> (float3, float3)? {
    if vertices.count >= 2 {
      return (vertices[vertices.count - 2], vertices[vertices.count - 1])
    } else {
      return nil
    }
  }
}

public class Spline {
  // Using cubic Bezier curves
  
  /*
   P(t) = (1-t)³ P1
   + 3t(1-t)² P2
   + 3t²(1-t) P3
   + t³ P4
   */
  
  private let generator : (Float) -> float3
  public let minIndex : Float = 0
  public let maxIndex : Float
  
  private static let bernstein = simd_float4x4(rows:
    [
      float4(1, -3, 3, -1),
      float4(0,3,-6,3),
      float4(0, 0, 3, -3),
      float4(0, 0, 0, 1)
    ])
  
  public init(vertices: [float3]) {

    func basis(t : Float) -> float4 { // needs to be here so generator can use in init
      return float4(1, t, powf(t, 2), powf(t, 3))
    }

    maxIndex = Float(vertices.count-1)
    
    generator = { (t : Float) -> float3 in
      // Can't use instance variables here bc in init
      assert(0 <= t && t <= Float(vertices.count - 1))
      
      // Int : (Float) -> float3
      var subgenerators : [(Float) -> float3] = []
      for i in stride(from: 0, to: vertices.count, by: 4) {
        let geometryMatrix = float4x3(vertices[i],
                                      vertices[i+1],
                                      vertices[i+2],
                                      vertices[i+3])
        subgenerators.append {
          return geometryMatrix * Spline.bernstein * basis(t: $0)
        }
      }
      
      // Deal with remaining; between 0 and 3 leftover points
      if t > Float(vertices.count - (vertices.count % 4)) {
        return vertices[Int(t)]
      }
      
      // Package t and feed into corresponding subgenerator
      // Parametrization: t = 0 at first node, t = n-1 at node n
      return subgenerators[Int(t/4)](t.remainder(dividingBy: 1))
    }
  }
  
  public func eval(at t: Float) -> float3 {
    return generator(t)
  }
  
}


