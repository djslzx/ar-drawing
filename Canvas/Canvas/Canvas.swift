//
//  Canvas.sw.swift
//  Canvas
//
//  Created by 21djl5 on 11/22/18.
//  Copyright © 2018 davidjlee. All rights reserved.
//

import Foundation
import SceneKit

public struct Point : Equatable, CustomDebugStringConvertible {
  let x : Double
  let y : Double
  let z : Double
  
  public init(_ x : Double, _ y : Double, _ z : Double) {
    self.x = x
    self.y = y
    self.z = z
  }
  
  public init(_ x : Int, _ y : Int, _ z : Int) {
    self.x = Double(x)
    self.y = Double(y)
    self.z = Double(z)
  }
  
  public var debugDescription: String {
    return "(\(self.x), \(self.y), \(self.z))"
  }
  
  public func copy() -> Point {
    return Point(self.x, self.y, self.z)
  }
}

/**
 Represents a collection of curves.
 
 **Specification Properties**:
 - curves: [[Point]] - A set of curves where each curve is a set of points
 
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
  private var curves : [[Point]]
  
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
   
   - Parameter curves: A 2-D array of Points (`SCNVector3`)
   where each constituent 1-D array represents a curve consisting of
   points that are connected in order.
   
   */
  public init(curves: [[Point]]) {
    let copy : [[Point]] = curves.map {
      $0.map { Point($0.x, $0.y, $0.z) }
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
  public func add(curve : [Point]) {
    assert(!curve.isEmpty)
    let copy : [Point] = curve.map { return Point($0.x, $0.y, $0.z) }
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
  public func append(point : Point) {
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
   Removes the last curve in the Canvas (ordered by time of entry).
   
   **Modifies**: self
   
   **Effects**: Removes the most recently added curve from the Canvas.
   
   */
  public func remove() {
    curves.removeLast()
    checkRep()
  }

  /**
   */
  public func getCurves() -> [[Point]] {
    return curves.map { $0.map { point in point.copy() } }
  }
  
}

// Allows assertion-checking in add(point:)
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
