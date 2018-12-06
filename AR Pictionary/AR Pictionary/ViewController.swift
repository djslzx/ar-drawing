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

/// Controls the AR view and updates the model.
class ViewController: UIViewController, ARSCNViewDelegate {
  
  /// AR view
  @IBOutlet var sceneView: ARSCNView!
  
  /// Computed property to make the AR view's root node more accessible
  private var rootNode : SCNNode {
    return sceneView.scene.rootNode
  }
  
  /// Dictionary of available Pens
  private let pens : [String : Pen] = [
    "Curve" : Pen(count: 2, Geometry.cylinderGenerator()),
    "Flat" : Pen(count: 3, Geometry.flatBrushGenerator()),
    "Bezier" : Pen(count: 4, Geometry.bezierCurveGenerator()),
  ]

  /// Dictionary of available ContextUpdaters
  private let contextUpdaters : [String: ContextUpdater] = [
    "Vanilla" : ContextUpdater(),
    "Rainbow" : RainbowUpdater()
  ]
  
  /// Current pen and context
  private var pen : Pen = Pen(count: 2, Geometry.cylinderGenerator())
  private var context : Context = Context(color: UIColor.white,
                                          lineRadius: CGFloat(powf(10, -3.75)),
                                          detail: 9)

  /// Stores current contextUpdater
  private var updater : ContextUpdater = ContextUpdater()

  /// Responds to user context changes
  @IBAction func contextUpdaterChanged(_ sender: UISegmentedControl) {
    updater = contextUpdaters[sender.titleForSegment(at: sender.selectedSegmentIndex)!] ??
      contextUpdaters["Vanilla"]!
  }

  /// Responds to user brush type changes
  @IBAction func brushChanged(_ sender: UISegmentedControl) {
    pen = pens[sender.titleForSegment(at: sender.selectedSegmentIndex)!] ??
      pens["Curve"]!
  }
  
  /// Responds to user brush hue changes
  @IBAction func hueSliderChanged(_ sender: UISlider) {
    context.color = UIColor(hue: CGFloat(sender.value),
                            saturation: 0.5,
                            brightness: 1,
                            alpha: 1)
    sender.tintColor = context.color
  }
  
  /// Updates the lineRadius when the user moves the slider
  @IBAction func thicknessSliderChanged(_ sender: UISlider) {
    context.lineRadius = CGFloat(powf(10, sender.value))
  }
  
  /// Model: collection of Polylines
  private var lines : [Polyline] = []
  
  /// Tracks whether user currently has their finger on the phone screen
  /// (i.e. whether in active drawing state)
  private var touched : Bool = false
  
  /**
   Coordinates response to user screen presses.
   
   **Modifies**: lines, touched, sceneView
   
   **Effects**:
   - When user starts pressing the screen, adds a new line to
      model and draws a point in sceneView.  Sets touched true.
   - While user is still pressing the screen, draws a point in sceneView
      and adds to model.
   - When user is done pressing the screen, sets touched false,
      ending point-draw queueing.
   
   */
  @IBAction func pressed(_ sender: UILongPressGestureRecognizer) {
    switch sender.state {
    case .began:
      touched = true
      NSLog("Began pressed")
      drawPoint()
    case .ended:
      NSLog("Ended pressed")
      touched = false
      lines.append(Polyline())
    //TODO:
    default:
      break
    }
  }
  
  /// Slider for adjusting hue
  @IBOutlet weak var hueSlider: UISlider!
  
  /// Resets color to white upon button press
  @IBAction func resetColorSlider(_ sender: UIButton) {
    context.color = UIColor.white
    hueSlider.tintColor = context.color
    hueSlider.setValue((hueSlider.maximumValue + hueSlider.minimumValue)/2,
                       animated: true)
  }

  /**
   Matrix for camera transform that gives the position at which new points
   should be drawn.
  */
  private let deviceToDrawpointTranslation : matrix_float4x4 =
    matrix_float4x4(rows:
      [
        float4([1, 0, 0, 0.0025 * 0.6]), // compensate for x offset
        float4([0, 1, 0, 0]),
        float4([0, 0, 1, -0.06]), // z-offset draws objects a fixed distance away from device
        float4([0, 0, 0, 1])
      ])
  
  /**
   - Returns: The position of the device, offset by deviceToDrawpointTranslation,
      given as a 4x4 matrix.
   */
  private var deviceLocationTransform : simd_float4x4? {
    if let cameraTransform = sceneView.session.currentFrame?.camera.transform {
      return cameraTransform * deviceToDrawpointTranslation
    } else {
      return nil
    }
  }
  
  /// The current position of the device, given as a 3-component vector
  private var currentPos : float3? {
    return deviceLocationTransform?.translation
  }
  
  /**
    Draws a new point in the sceneView, extending the currently drawn line
    if one exists.
   
   **Modifies**: previous, lines, sceneView
   
   **Effects**:
   - If the user is not actively drawing (touched is false), sets previous to nil
      and quits.
   - If this is the first vertex in the line being drawn (previous is nil),
      sets previous to the current position and recurses.
   - Otherwise, if the new point is far enough away from the last drawn point
      (distance > lineRadius/2), then adds a point to the model and view.  Recurses.
   
   */
  private func drawPoint() {
    DispatchQueue.global().async {
      [weak self] in
      DispatchQueue.main.async {

        // Ensure that draw method should still be active and current position
        // is capturing correctly
        guard self?.touched ?? false, let currentPos = self?.currentPos else {
          return
        }

        // Handle case where line is just starting to be drawn
        guard let previous = self?.lines.last?.vertices.last else {
          self?.lines.last?.add(vertex: currentPos)
          self?.drawPoint()
          return
        }
        
        // Ensure that points aren't too close together
        if previous.distance(to: currentPos) >= Float(self!.context.lineRadius) {
          self?.lines.last?.add(vertex: currentPos)
          self?.context = self!.updater.update(context: self!.context)

          if let vertices = self?.lines.last?.vertices,
            let pen = self?.pen,
            vertices.count >= pen.count,
            let context = self?.context
          {
            let node = pen.apply(vertices: vertices, context: context)
            self?.rootNode.addChildNode(node)
          }
        }
        // Repeat
        self?.drawPoint()
      }
    }
  }
  
  /// Tracks whether the scene is currently being cleared (in case the user presses
  /// the clear button multiple times in s                           uccession).
  private var inMiddleOfClearing : Bool = false
  
  /**
   Responds to the user's 'clear' button press.
   
   **Modifies**: inMiddleOfClearing, sceneView
   
   **Effects**: sets inMiddleOfClearing to reflect clearing state
    and clears the scene.
   
   */
  @IBAction func clearPressed() {
    // Only clear if program isn't already in the middle of clearing
    // and there are lines to be cleared
    if !inMiddleOfClearing, lines.count != 0 {
      DispatchQueue.global().async {
        [weak self] in
        self?.inMiddleOfClearing = true
        self?.clearScene()
        self?.inMiddleOfClearing = false
      }
    }
  }
  
  /// Clears the scene and model.
  public func clearScene() {
    NSLog("Clearing scene")
    sceneView.scene = SCNScene()
    lines = [Polyline()]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true
    
    lines.append(Polyline())
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
