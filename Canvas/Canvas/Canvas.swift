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

extension float3 {
  
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


/**
 Represents a collection of curves.
 
 **Specification Properties**:
 - curves: [[float3]] - A set of curves where each curve is a set of points
 
 **Derived Specification Properties**:
 
 **Abstract Invariant**:
 
 */
public class Canvas : CustomDebugStringConvertible {
  
  // Representation Invariant:
  //  All curves except the last are non-empty
  //
  // Abstraction Function:
  //  AF(r) = {curve c} such that
  //   l.start-point = <r.startX, r.startY>
  //   l.end-point = <r.endX, r.endY>
  
  /** The collection of curves stored in the Canvas,
   where each inner array represents a curve of points
   connected in order.
   */
  private var curves : [[float3]]
  
  /**
   Initializes a Canvas.
   
   **Modifies**: self
   
   **Effects**: Sets up an empty Canvas.
   
   */
  public init() {
    curves = []
    checkRep()
  }
  
  public var debugDescription: String {
    return String(reflecting: curves)
  }
  
  /**
   Initializes a Canvas using `curves`.
   
   **Modifies**: self
   
   **Effects**: Sets up a canvas using data from `curves`.
   
   - Parameter curves: A 2-D array of `float3`s
   where each constituent 1-D array represents a curve consisting of
   points that are connected in order.
   
   */
  public init(curves: [[float3]]) {
    let copy : [[float3]] = curves.map {
      $0.map { float3($0.x, $0.y, $0.z) }
    }
    self.curves = copy
    checkRep()
  }
  
  /**
   Checks the representation invariant:
   - All curves except the final one should be non-empty
   */
  private func checkRep() {
    for curve in curves {
      assert(!curve.isEmpty)
    }
  }
  
  /**
   Adds a curve to the Canvas.
   
   **Requires**: `curve` is non-empty.
   
   **Modifies**: self
   
   **Effects**: Adds `curve` to the Canvas.
   
   - Parameter curve: The curve to be added to the Canvas.
   
   */
  public func add(curve : [float3]) {
    assert(!curve.isEmpty)
    let copy : [float3] = curve.map { return float3($0.x, $0.y, $0.z) }
    curves.append(copy)
    checkRep()
  }
  
  /**
   Adds a point to the most recently added curve in the canvas.
   If the Canvas is empty, adds a new curve containing the point.
   
   **Modifies**: self
   
   **Effects**: Adds a point to a curve in the Canvas.
   
   - Parameter point: The point to be added.
   
   */
  public func append(point : float3) {
    if var last = curves.popLast() {
      last.append(point)
      curves.append(last)
      assert(curves.last!.last! == point) // confirm that point has been added
    } else {
      curves.append([point])
    }
    checkRep()
  }
  
  /**
   Begins a new empty curve.
   
   **Modifies**: self
   
   **Effects**: Adds an empty curve to the Canvas.  Has no effect if the
   most recently added curve is also empty.
   
   */
  public func startCurve() {
    // Add [] if self.curves is empty or self.curves.last is non-empty
    if !(curves.last?.isEmpty ?? false) {
      curves.append([])
    }
  }
  
  /**
   Removes the last curve in the Canvas (ordered by time of entry).
   
   **Modifies**: self
   
   **Effects**: Removes the most recently added curve from the Canvas.
   
   */
  public func remove() {
    curves.removeLast()
    checkRep()
  }

  /**
   - Returns: A copy of the curves in the Canvas.
   */
  public func getCurves() -> [[float3]] {
    return curves.map {
      curve in curve.map {
        float3(x: $0.x, y: $0.y, z: $0.z)
      }
    }
  }
  
  /**
   - Returns: The last line segment added to the Canvas.
   */
  public func lastSegment() -> (float3, float3)? {
    if let last = curves.last, last.count >= 2 {
      return (last[last.count - 2], last[last.count - 1])
    } else {
      return nil
    }
  }
  
}

// Allows assertion-checking in append(point:)
extension SCNVector3 : Equatable, CustomDebugStringConvertible {
  public var debugDescription: String {
    return "(\(self.x), \(self.y), \(self.z))"
  }
  
  public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
    return lhs.x.isEqual(to: rhs.x) &&
      lhs.y.isEqual(to: rhs.y) &&
      lhs.z.isEqual(to: rhs.z)
  }
}
