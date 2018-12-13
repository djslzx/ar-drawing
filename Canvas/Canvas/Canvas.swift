//
//  Canvas.swift
//  Canvas
//
//  Created by David J Lee on 12/7/18.
//  Copyright © 2018 David J Lee. All rights reserved.
//

import Foundation
import SceneKit

/// Manages an ARKit scene; abstracts away scene manipulations
public class Canvas {

  /// Pointer to shared rootNode
  private let root : SCNNode
  
  /// Node storing current line's SCNNode subtree
  private var line : SCNNode

  /// Temporary container for vertex positions
  public private(set) var vertices : [float3]
  
  /// The number of lines in the scene
  public var lineCount : Int {
    return root.childNodes.count
  }
  
  /// Initializes a new Canvas.
  public init(root: SCNNode) {
    self.root = root
    self.line = SCNNode()
    self.vertices = []
  }

  /**
   Starts a new line in the Canvas.  Triggers all behaviors needed
   to get line drawing working.
   
   **Modifies**: root, line, vertices

   **Effects**: Assigns a new SCNNode to line, assigns updated line to root.
    Clears vertices.
   
   */
  public func startLine() {
    line = SCNNode()
    line.name = String(root.childNodes.count)
    //NSLog("Starting line named: \(line.name!)")
    root.addChildNode(line)
    vertices = []
  }
  
  /**
   Ends a line in the Canvas (and triggers all associated behaviors).
   
   **Modifies**: vertices
   
   **Effects**: Clears vertices.
   
   */
  public func endLine() {
    vertices = []
  }
  
  /**
   Adds a new vertex node to the current line being built.
   
   **Modifies**: line, root
   
   **Effects**: Adds a new node to the line's children (implicitly updating self).
   
   */
  public func addNode(_ node: SCNNode) {
    node.name = "\(line.name!), \(line.childNodes.count)"
    //NSLog("Adding node with name: \(node.name!), geometry \(node.geometry)")
    line.addChildNode(node)
  }
  
  /**
   Adds a node directly to the root node (needed for undo/redo).
   
   **Modifies**: root
   
   **Effects**: Adds a node to the root.
   
   - Parameter node: The node to be added to the root.
   
   */
  public func addNodeToRoot(_ node: SCNNode) {
    root.addChildNode(node)
  }

  /**
   Adds a vertex position to be tracked.
   
   **Modifies**: vertices
   
   **Effects**: Adds a vertex to vertices.
   
   - Parameter position: The position of the vertex to be added.
   
   */
  public func addVertex(_ position: float3) {
    vertices.append(position)
    //NSLog("Adding vertex \(position); vertex count: \(vertices.count)")
  }
  
  /**
   Removes and returns the last line in the scene tree, if it exists.
   
   **Modifies**: root, line, vertices
   
   **Effects**: Removes the last child from root, clears line and vertices.
   
   - Returns: The last line in the scene tree, or `nil` if the tree is empty.
   
   */
  public func removeLastLine() -> SCNNode? {
    let name = String(root.childNodes.count - 1)
   // NSLog("Removing last line: \(name)")
    let last = root.childNode(withName: name, recursively: false)
    last?.removeFromParentNode()
    line = SCNNode()
    vertices = []
    return last
  }

  /**
   Clears the Canvas.
   
   **Modifies**: root, line, vertices
   
   **Effects**: Clears root, line, and vertices.
   
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
