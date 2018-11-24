//
//  ViewController.swift
//  AR Pictionary
//
//  Created by 21djl5 on 11/19/18.
//  Copyright © 2018 davidjlee. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Canvas

class ViewController: UIViewController, ARSCNViewDelegate {
  
  @IBOutlet var sceneView: ARSCNView!
  
  private let lineRadius : CGFloat = 5.0
  
  /** Model */
  private let canvas = Canvas()
  
  @IBAction func pressed(_ sender: UILongPressGestureRecognizer) {
    switch sender.state {
    case .began:
      canvas.startCurve()
      NSLog("Started curve")
      fallthrough
    case .changed:
      NSLog("Adding to curve")
      canvas.append(point: Point(0, 0, 0))
    case .ended:
      NSLog("Ended curve")
    default:
      break
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Show statistics such as fps and timing information
    sceneView.showsStatistics = false
    
    let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
    cubeNode.position = SCNVector3(0, 0, -0.2) // SceneKit/AR coordinates are in meters
    sceneView.scene.rootNode.addChildNode(cubeNode)
  }
  
  private func renderLines() {
    for curve in canvas.getCurves() {
      let curveNode = SCNNode()
      for i in 0..<curve.count-1 {
        let start = curve[i]
        let end = curve[i+1]

        let cylinder = SCNCylinder(radius: lineRadius, height: CGFloat(Point.distance(start, end)))
        cylinder.radialSegmentCount = 5
        cylinder.heightSegmentCount = 1
        let segmentNode = SCNNode(geometry: cylinder)
        segmentNode.position = Point.midpoint(start, end).vector
        // segmentNode.rotation =
        curveNode.addChildNode(segmentNode)
      }
      sceneView.scene.rootNode.addChildNode(curveNode)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    
    // Run the view's session
    sceneView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    sceneView.session.pause()
  }
  
  // MARK: - ARSCNViewDelegate
  
  /*
   // Override to create and configure nodes for anchors added to the view's session.
   func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
   let node = SCNNode()
   
   return node
   }
   */
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user
    
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
  }
}
