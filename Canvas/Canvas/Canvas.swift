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
public class Canvas : Sequence {
  
  // Representation Invariant:
  //  TODO
  //
  // Abstraction Function:
  //  AF(r) = {curve c} such that
  //   l.start-point = <r.startX, r.startY>
  //   l.end-point = <r.endX, r.endY>
  
  public typealias Point = SCNVector3
  
  /** The collection of curves (ordered points) */
  private var curves : [[Point]]
  
  /**
   Initializes a Canvas.
   
   **Modifies**: self
   **Effects**: sets 
   */
  public init() {
    curves = []
    checkRep()
  }
  
  public init(curves: [[Point]]) {
    // TODO: deep copy
    self.curves = curves
  }
  
  private func checkRep() {
    // TODO: Need to specify RI
  }

  subscript(curve: Int) -> [Point] {
    return curves[curve]
  }
  
  subscript(curve: Int, point: Int) -> Point {
    get {
      return curves[curve][point]
    }
  }
  
  public func add(curve : [Point]) {
    // TODO: deep copy
    curves.append(curve)
    checkRep()
  }
  
  public func remove() {
    curves.removeLast()
  }

  public func makeIterator() -> IndexingIterator<[[Canvas.Point]]> {
    return curves.makeIterator()
  }

}
