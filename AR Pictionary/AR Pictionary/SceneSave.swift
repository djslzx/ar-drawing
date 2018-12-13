//
//  SceneSave.swift
//  AR Pictionary
//
//  Created by cs326 on 12/6/18.
//  Copyright © 2018 davidjlee. All rights reserved.
//

import Foundation
import SceneKit

/// Represents a saved scene; a convenient wrapper class
public class SceneSave {
  private let root : SCNNode

  /**
   - TODO:
   Takes the bounding box of dimensions specified by the bound
   centered at the input origin and extracts and saves all
   nodes within the bound.
   
   */
  public init(root: SCNNode, boundMin: float3, boundMax: float3) {
    self.root = SCNNode()
    let boundMid = boundMin.midpoint(with: boundMax)

    root.enumerateChildNodes { (child, _) in
      if child.inBound(boundMin, boundMax) {
        let clone = child.clone()
        clone.simdPosition -= boundMid //center at midpoint between bound extremes
        self.root.addChildNode(clone)
      }
    }
  }
  
  /// Initialize a SavedScene given a center point and the root of the
  /// scene to save.
  public init(root: SCNNode, center: float3) {
    self.root = SCNNode()
    root.enumerateChildNodes { (child, _) in
      let clone = child.clone()
      clone.simdPosition -= center //center at midpoint between bound extremes
      self.root.addChildNode(clone)
    }
  }
  
  /// - Returns: A SCNNode containing the data in the save.
  public func load(center: float3) -> SCNNode {
    let parent = SCNNode()
    self.root.enumerateHierarchy { (child, _) in
      let clone = child.clone()
      clone.simdPosition += center
      parent.addChildNode(clone)
    }
    return parent
  }
  
}

public extension SCNNode {

  /// Checks whether node is contained in the box spanning
  /// from boundMin to boundMax
  public func inBound(_ min: float3, _ max: float3) -> Bool {
    return isIncreasing(a: min.x, b: self.position.x, c: max.x) &&
      isIncreasing(a: min.y, b: self.position.y, c: max.y) &&
      isIncreasing(a: min.z, b: self.position.z, c: max.z)
  }
  
  private func isIncreasing(a: Float, b: Float, c: Float) -> Bool {
    return a <= b && b <= c
  }
}
