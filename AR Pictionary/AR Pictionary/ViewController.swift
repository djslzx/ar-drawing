//
//  ViewController.swift
//  AR Pictionary
//
//  Created by David J Lee on 11/19/18.
//  Copyright © 2018 David J Lee. All rights reserved.
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
  
  // - MARK: Reticle View
  @IBOutlet weak var reticleView: ReticleView!

  // - MARK: Pens and contexts
  
  /// Dictionary of available Pens
  private let pens : [String : Pen] = [
    "Pen" : Pen(count: 2, Geometry.cylinderGenerator()),
    "Chisel" : Pen(count: 3, Geometry.flatBrushGenerator()),
    "Bezier" : Pen(count: 4, Geometry.bezierCurveGenerator()),
  ]

  /// Dictionary of available ContextUpdaters
  private let contextUpdaters : [String: ContextUpdater] = [
    "Vanilla" : ContextUpdater(),
    "Rainbow" : RainbowUpdater()
  ]
  
  /// Pen defaults
  private let defaultColor = UIColor.white
  private let defaultLineRadius = CGFloat(powf(10, -3.75))
  private let defaultDetail = 9
  
  /// Current pen and context
  private var pen : Pen = Pen(count: 2, Geometry.cylinderGenerator())
  private var context : Context = Context(color: UIColor.white,
                                          lineRadius: CGFloat(powf(10, -3.75)),
                                          detail: 9) {
    didSet {
      updateReticle()
    }
  }
  
  private func updateReticle() {
    reticleView.updateReticle(color: context.color.darker(by: 10)!,
                                    radius: context.lineRadius * 1.4
                                      / defaultLineRadius)
  }

  /// Stores current contextUpdater
  private var updater : ContextUpdater = ContextUpdater()

  /// Responds to user context changes
  @IBAction func contextUpdaterChanged(_ sender: UISegmentedControl) {
    updater = contextUpdaters[sender.titleForSegment(at: sender.selectedSegmentIndex)!] ??
      contextUpdaters["Vanilla"]!
  }

  /// Responds to user pen type changes
  @IBAction func penChanged(_ sender: UIButton) {
    NSLog(sender.titleLabel?.text ?? "")
    pen = pens[sender.titleLabel?.text ?? "Pen"] ?? pens["Pen"]!
  }
  
  /// Responds to user brush hue changes
  @IBAction func hueSliderChanged(_ sender: UISlider) {
    context.color = UIColor(hue: CGFloat(sender.value),
                            saturation: 0.5,
                            brightness: 1,
                            alpha: 1)
    sender.minimumTrackTintColor = context.color
    sender.maximumTrackTintColor = context.color
  }
  
  /// Updates the lineRadius when the user moves the slider
  @IBAction func thicknessSliderChanged(_ sender: UISlider) {
    context.lineRadius = CGFloat(powf(10, sender.value))
  }
  
  /// MARK: Model
  private var canvas : Canvas!

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
      canvas.startLine()
      drawPoint()
    case .ended:
      NSLog("Ended pressed")
      touched = false
      canvas.endLine()
    default:
      break
    }
  }
  
  /// Slider outlets
  @IBOutlet weak var hueSlider: UISlider!
  @IBOutlet weak var thicknessSlider: UISlider!
  
  /// Resets color to white upon button press
  @IBAction func resetSliders(_ sender: UIButton) {
    context.color = defaultColor
    context.lineRadius = defaultLineRadius
    hueSlider.minimumTrackTintColor = defaultColor
    hueSlider.maximumTrackTintColor = defaultColor
    hueSlider.setValue((hueSlider.maximumValue + hueSlider.minimumValue)/2,
                       animated: true)
    thicknessSlider.setValue((thicknessSlider.maximumValue + thicknessSlider.minimumValue)/2,
                             animated: true)
  }

  // - MARK: Camera/stroke positioning
  
  /**
   Matrix for camera transform that gives the position at which new points
   should be drawn.
  */
  private let deviceToDrawpointTranslation : matrix_float4x4 =
    matrix_float4x4(rows:
      [
        float4([1, 0, 0, 0.001]), // compensate for x offset
        float4([0, 1, 0, -0.00015]),
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
  
  // - MARK: Drawing
  
  /// The current position of the device, given as a 3-component vector
  private var currentPos : float3? {
    return deviceLocationTransform?.translation
  }
  
  /**
    Draws a new point in the sceneView, extending the currently drawn line
    if one exists.
   
   **Modifies**: lines, sceneView, context
   
   **Effects**:
   - If the user is not actively drawing (touched is false), quits.
   - If this is the first vertex in the line being drawn, adds a new point to
      the model and recurses.
   - Otherwise, if the new point is far enough away from the last drawn point,
      and there are enough points such that a geometry can be generated by the pen,
      then adds a point to the model and view.  Recurses.
   
   */
  private func drawPoint() {
    DispatchQueue.global().async {
      [weak self] in
      DispatchQueue.main.async {
        
        // Ensure that draw method should still be active and current position
        // is capturing correctly
        guard self?.touched ?? false, let currentPos = self?.currentPos else {
          NSLog("[drawPoint] Failed basic check, exiting")
          return
        }
        
        // If no points yet seeded, seed a point
        guard self!.canvas.vertices.count > 0 else {
          NSLog("[drawPoint] Seeding first point")
          self!.canvas.addVertex(currentPos)
          self!.drawPoint()
          return
        }

        // Distance check
        let prev = self!.canvas.vertices.last!
        let dist = prev.distance(to: self!.currentPos!)
        if dist >= 0.001 { // TODO: swap to variable
          self!.canvas.addVertex(currentPos)

          // Check that enough points are seeded for pen to be used
          if self!.canvas.vertices.count >= self!.pen.count { // Use pen
            self!.drawNode()
          }
        }

        // Repeat
        self?.drawPoint()
      }
    }
  }
  
  private func drawNode() {
    context = updater.update(context: context)
    let node = pen.apply(vertices: canvas.vertices,
                         context: context)
    canvas.addNode(node)
    redos = []
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
    if !inMiddleOfClearing {
      inMiddleOfClearing = true
      clearScene()
      inMiddleOfClearing = false
    }
  }
  
  /// Clears the scene and model.
  public func clearScene() {
    NSLog("Clearing scene")
    self.canvas.clear()
    redos = []
  }
  
  // - MARK: Undo/Redo Stack
  
  /// Stores all undone curves
  private var redos : [SCNNode] = [] {
    didSet {
      // Only enable redos if the redo stack has items in it
      NSLog("redos updated: \(redos.count)")
      redoButton.isEnabled = !redos.isEmpty
    }
  }
  
  /// Redo button outlet (used to toggle enabling)
  @IBOutlet weak var redoButton: UIButton!
  
  /// Undoes a little bit
  @IBAction func undoPressed(_ sender: UIButton) {
    NSLog("Undo press registered")
    if let undoneNode = canvas.removeLastLine() {
      redos.append(undoneNode)
      NSLog("Added to redo stack")
    }
  }
  
  @IBAction func redoPressed(_ sender: UIButton) {
    NSLog("Redo press registered")
    if !redos.isEmpty {
      let redoneNode = redos.removeLast()
      canvas.addNodeToRoot(redoneNode)
      NSLog("Redo performed")
    }
  }
  
  
  // - MARK: Save/Load functionality

  private var saves : [SceneSave] = []

  @IBAction func savePressed(_ sender: UIButton) {
    save()
  }

  /// Save current scene
  private func save() {
    /// - TODO: use camera frustrums to define capture window
    saves.append(SceneSave(root: self.rootNode, center: currentPos!))
  }
  
  @IBAction func loadPressed(_ sender: UIButton) {
    load()
  }

  /// Load previously saved scene
  private func load() {
    if let poppedSave = saves.popLast() {
      let poppedNode = poppedSave.load(center: currentPos!)
      canvas.addNode(poppedNode)
    }
  }
  
  // MARK: Utilities
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Show statistics such as fps and timing information
    sceneView.showsStatistics = false
    
    updateReticle()
    
    // Set up Canvas
    canvas = Canvas(root: rootNode)
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
  
  // MARK: Unwind segue
  
  @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {}
  
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
