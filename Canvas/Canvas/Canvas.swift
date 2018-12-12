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
  
  /// Node storing current line vertex hierarchy
  private var line : SCNNode

  public private(set) var vertices : [float3]
  
  public var lineCount : Int {
    return root.childNodes.count
  }
  
  public var lineVertexCount : Int {
    return line.childNodes.count
  }
  
  public init(root: SCNNode) {
    self.root = root
    self.line = SCNNode()
    self.vertices = []
  }

  /**
   Starts a new line in the Canvas.
   */
  public func startLine() {
    line = SCNNode()
    line.name = String(root.childNodes.count)
    NSLog("Starting line named: \(line.name!)")
    root.addChildNode(line)
    vertices = []
  }
  
  /**
   Ends a line in the Canvas.
   */
  public func endLine() {
    vertices = []
  }
  
  /**
   Adds a new vertex node to the current line being built.
   */
  public func addNode(_ node: SCNNode) {
    node.name = "\(line.name!), \(line.childNodes.count)"
    NSLog("Adding node with name: \(node.name!), geometry \(node.geometry)")
    line.addChildNode(node)
  }
  
  public func addNodeToRoot(_ node: SCNNode) {
    root.addChildNode(node)
  }

  public func addVertex(_ position: float3) {
    vertices.append(position)
    NSLog("Adding vertex \(position); vertex count: \(vertices.count)")
  }
  
  public func removeLastLine() -> SCNNode? {
    let name = String(root.childNodes.count - 1)
    NSLog("Removing last line: \(name)")
    let last = root.childNode(withName: name, recursively: false)
    last?.removeFromParentNode()
    line = SCNNode()
    vertices = []
    return last
  }

  /**
   Clears the Canvas.
   */
  public func clear() {
    NSLog("Clearing canvas")
    for line in root.childNodes {
      line.removeFromParentNode()
    }
    vertices = []
    line = SCNNode()
    NSLog("Canvas cleared")
  }
  
}
