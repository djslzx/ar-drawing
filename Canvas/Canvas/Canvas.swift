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
 
 */
public class Canvas {
  // Representation Invariant:
  //  ! (startX == endX && startY == endY)
  //
  // Abstraction Function:
  //  AF(r) = a line, l, such that
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
  
  public func add(curve : [Point]) {
    // TODO: deep copy
    curves.append(curve)
    checkRep()
  }
  
  public func remove() {
    curves.removeLast()
  }
}
