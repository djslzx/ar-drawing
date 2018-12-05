# ar-drawing
An augmented reality drawing environment

David J. Lee

## Demo
![Demo.gif](https://github.com/deejayessel/ar-drawing/blob/master/flat_brush_test.gif)

## TODOs:
- [ ] **Save and load**: save vertex data and allow user to open saved copies of previous sessions
  - Save vertex data into userdefaults
- [ ] **Undo/Redo stacks**: Undo drawing of the last curve (or some fixed k most recent vertices), allow redo
- [ ] **Color Picker**: Provide good swatches
- [ ] **UI Changes**: master/detail layout of more detailed controls
- [ ] **depth of field blur**: Better z-sensing
- [ ] **Popups** when tracking quality is bad
- [ ] Plane- and straight-line-drawing
  - [ ] allow user to seed points and display as small SCNSpheres
  - [ ] continually update view during straight-line drawing with a straight line from the start point to the current point
- [ ] Polyline SCNCylinder cleaning
   - [ ] Remove intermediate points between parallel straight lines (lower angle bound)
   - [ ] Insert intermediate points between sharp turns (upper angle bound)
   
## Lower-priority TODOs:
- [ ] Branching-geometry factories (trees, lightning)
- Splines
  - [ ] abstract implementation (Bezier)
  - [ ] conversion from polylines to splines and back
  - [ ] allow vector-drawing using Bezier in 3D
- [ ] Shared environment

## Vision
Users select a brush stroke and move their phones around in 3D space to draw 3D brush strokes.
The resulting strokes are suspended in 3D space at a fixed location determined at the time of drawing,
although the world space may be translated if the user desires.

### Extensions
#### Drawing
- Sculpting features
  - Allow user to warp existing vertices with vertex-editing tools (bulge and contract)
- Symmetry mode: symmetry across a given fixed plane (fixed relative to phone or some arbitrary start point)
- Chaos/Jackson-Pollock mode: brush size and color randomly change
#### Online multiplayer
  - Players view a simple white room with player stand-ins tracked to iPhone motion
  - Guesses are submitted and checked via text input or voice recognition

## Feature List
#### Drawing
- User can draw strokes in their view
  - [x] Holding a finger on the phone screen and moving the phone in 3D space draws 3D strokes 
        where points along the curve correspond to the path of the phone
- [x] User can customize their stroke color, thickness, and brush type

## UI Sketches (Deprecated)
#### Drawing
![Drawing UI Sketches](https://github.com/deejayessel/ar-drawing/blob/master/20181114_214855-01-01.jpeg)

## Test Plan
Lots of UI/visual tests
1.
2.
3.
4.

## Key Use Cases
#### Drawing a stroke
*Main Path*
1. User draws a stroke on her phone screen while keeping her phone stable.
2. The stroke is drawn onto a plane parallel to the user's phone orientation but at a short distance away. 
3. The view overlays all existing strokes onto the live camera feed displayed as the background of the app.  

*Alternate Path*
1.1. User holds a finger on her phone screen while moving her phone in 3D space.
2.1. The stroke is drawn in 3D space as a path of points that corresponds to the position of the user's
     iPhone through the duration of the held touch gesture.
3.1. The user releases her finger from the phone screen.
4.1. Return to Main Path at Step 3.

#### Viewing the scene
*Main Path*
1. User moves her iPhone around in space.
2. iPhone tracks motion and keeps 3D objects in the scene fixed in absolute space.

## Domain Analysis
- Spline and Polylines
- Bezier curves
- Basic computer graphics (quaternion rotation)

## Architecture
[//]: # (Describe the major components and data structures for your data model, as well as the top-level controllers and views of your UI. Feel free to use diagrams.)

#### Data model
* `Spline`s and `Polyline`s
 * Polyline: collection of straight line segments
 * Spline: Bezier curves
  * Input a Polyline
  * Smooth line, define parametrization
* `PolylineGeometry` (factory)
* Drawing canvas: ordered list of lines `[Polyline]`
 * Lines are ordered by entry time to allow for history tracking
 * Fed into view to make 3D cylinders only upon creation/deletion, so arrays are good enough 
   (don't need quick look-up, just some notion of ordering)

#### Controllers and Views
- ARSCNView
- `SCNVector3`s rendered as `SCNCylinder`s stored in the view
