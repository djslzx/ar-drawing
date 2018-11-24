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
  
  private let lineRadius : CGFloat = 0.005
  private let lineColor : UIColor = UIColor.white
  
  /** Model */
  private let canvas = Canvas()
  
  private var touched : Bool = false
  
  @IBAction func pressed(_ sender: UILongPressGestureRecognizer) {
    switch sender.state {
    case .began:
      assert(touched == false)
      touched = true
      drawPoint()
    case .ended:
      assert(touched == true)
      touched = false
    default:
      break
    }
  }
  
  private func drawPoint() {
    DispatchQueue.global().async {
      [weak self] in
      DispatchQueue.main.async {
        if self?.touched ?? false,
          let cameraTransform = self?.sceneView.session.currentFrame?.camera.transform
        {
          let pointGeometry = SCNSphere(radius: self!.lineRadius)
          let pointNode = SCNNode(geometry: pointGeometry)
          pointGeometry.firstMaterial?.diffuse.contents = self?.lineColor
          
          // Translate point to position in front of camera
          var translation = matrix_identity_float4x4
          translation.columns.3.z = -0.2
          pointNode.simdTransform = matrix_multiply(cameraTransform, translation)

          // Add to view
          self?.sceneView.scene.rootNode.addChildNode(pointNode)
          self?.drawPoint()
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
    
    let pointNode = SCNNode(geometry: SCNSphere(radius: 0.01))
    pointNode.position = SCNVector3(0, 0, -0.2) // SceneKit/AR coordinates are in meters
    //sceneView.scene.rootNode.addChildNode(pointNode)
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

extension simd_float4x4 {
  func position() -> SCNVector3 {
    return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
  }
}
