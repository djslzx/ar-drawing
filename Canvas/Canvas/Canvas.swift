//
//  Canvas.swift
//  Canvas
//
//  Created by David J Lee on 12/7/18.
//  Copyright © 2018 David J Lee. All rights reserved.
//

import Foundation
import SceneKit

/// Manages an ARKit scene
public class Canvas {

  /// Pointer to shared rootNode
  private let root : SCNNode
  
  private var child : SCNNode
  
  public init(rootNode: SCNNode) {
    root = rootNode
    child = SCNNode()
  }

  public func startLine() {
    child = SCNNode()
  }
  
  public func endLine() {
    
  }

  public func addVertexNode(node: SCNNode) {
    child.addChildNode(node)
  }
}
