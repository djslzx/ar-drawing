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

extension CGPoint {
  public init(_ x : Float, _ y : Float) {
    self.init(x: Double(x), y: Double(y))
  }
}

class ViewController: UIViewController, ARSCNViewDelegate {
  
  @IBOutlet var sceneView: ARSCNView!
  
  private var rootNode : SCNNode {
    return sceneView.scene.rootNode
  }
  
  private let lineRadius : CGFloat = 0.001
  private let lineColor : UIColor = UIColor.white
  private let lineDetail : Int = 9
  
  /** Model */
  private var lines : [Polyline] = []
  
  private var touched : Bool = false
  
  @IBAction func pressed(_ sender: UILongPressGestureRecognizer) {
    switch sender.state {
    case .began:
      touched = true
      lines.append(Polyline())
      fallthrough
    case .changed:
      drawPoint()
    case .ended:
      touched = false
    default:
      break
    }
  }
  
  // Calibrate camera transform with center reticle
  private let translation : matrix_float4x4 =
    matrix_float4x4(rows:
      [
        float4([1, 0, 0, 0.0025 * 0.6]),
        float4([0, 1, 0, 0]),
        float4([0, 0, 1, -0.06]),
        float4([0, 0, 0, 1])
      ])
  
  private func cameraTransform() -> simd_float4x4? {
    if let cameraTransform = sceneView.session.currentFrame?.camera.transform {
      return cameraTransform * translation
    } else {
      return nil
    }
  }
  
  private func drawLine() {
    let factory = Geometry.tubeLineGenerator(radius: lineRadius, segmentCount: lineDetail)
    if let line = lines.last {
      let lineNode = factory(line.vertices)
      self.rootNode.addChildNode(lineNode)
    }
  }
  
  private var currentPos : float3? {
    return cameraTransform()?.translation
  }
  
  private var previous : float3?
  
  private func drawPoint() {
    // TODO: clean up using guard
    
    DispatchQueue.global().async {
      [weak self] in
      DispatchQueue.main.async {
        guard self?.touched ?? false, let currentPos = self?.currentPos else {
          self?.previous = nil
          return
        }
        guard let previousPos = self?.previous else {
          self?.previous = currentPos
          self?.drawPoint()
          return
        }
        
        // Check that new points are far enough away to be worth drawing
        if currentPos.distance(to: previousPos) > Float(self!.lineRadius)/2 {
          self?.lines.last?.add(vertex: currentPos)
          
          let factory = Geometry.cylinderGenerator(radius: self!.lineRadius * 0.5)
          let node = factory(previousPos, currentPos)
          self?.rootNode.addChildNode(node)
          self?.previous = currentPos
        }

        // Repeat
        self?.drawPoint()
      }
    }
  }
  
  private var inMiddleOfClearing : Bool = false
  
  @IBAction func clearPressed() {
    // Only clear if program isn't already in the middle of clearing
    // and there are lines to be cleared
    if !inMiddleOfClearing, lines.count != 0 {
      DispatchQueue.global().async {
        [weak self] in
        self?.inMiddleOfClearing = true
        self?.clear()
        self?.inMiddleOfClearing = false
      }
    }
  }
  
  public func clear() {
    sceneView.scene = SCNScene()
    lines = []
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
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
