//
//  Canvas.sw.swift
//  Canvas
//
//  Created by 21djl5 on 11/22/18.
//  Copyright © 2018 davidjlee. All rights reserved.
//

import Foundation
import SceneKit

/**
 Represents a collection of curves.
 
 **Specification Properties**:
 - curves: [[Point]] - A set of curves where each curve is a set of points
 
 **Derived Specification Properties**:
 
 **Abstract Invariant**:
 
 */
public class Canvas {
  
  // Representation Invariant:
  //  TODO
  //
  // Abstraction Function:
  //  AF(r) = {curve c} such that
  //   l.start-point = <r.startX, r.startY>
  //   l.end-point = <r.endX, r.endY>
  
  public typealias Point = SCNVector3
  
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
  
  /**
   Initializes a Canvas using `curves`.
   
   **Modifies**: self
   
   **Effects**: Sets up a canvas using data from `curves`.
   
   - Parameter curves: A 2-D array of Points (`SCNVector3`)
   where each constituent 1-D array represents a curve consisting of
   points that are connected in order.
   
   */
  public init(curves: [[Point]]) {
    // TODO: deep copy
    self.curves = curves
  }
  
  /**
   Checks the representation invariant.
   
   TODO: specify rep invariant
   
   */
  private func checkRep() {
    // TODO: Need to specify RI
  }
  
  /**
   Returns the curve at `index`.
   
   **Requires**: 0 <= `index` < `n` where `n` is the number of
   curves in the Canvas
   
   - Parameter index: The index of the curve to be returned.
   */
  subscript(index: Int) -> [Point] {
    assert(0 <= index && index < curves.count)
    return curves[index]
  }
  
  /**
   Returns the j-th point in the i-th curve.

   **Requires**: 0 <= i < `n` && 0 <= j < `m` where `n` is the
   number of curves in the Canvas and `m` is the number of points
   in the i-th curve
   
   - Parameters:
   - i: The index of the curve
   - j: The index of the point in the curve
   
   */
  subscript(i: Int, j: Int) -> Point {
    get {
      assert(0 <= i && i < curves.count)
      assert(0 <= j && j < curves[i].count)
      return curves[i][j]
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
   Removes the last curve in the Canvas (ordered by time of entry).
   
   **Modifies**: self
   
   **Effects**: Removes the most recently added curve from the Canvas.

   */
  public func remove() {
    curves.removeLast()
  }
  
}
