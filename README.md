# ar-drawing
An augmented reality drawing environment

David J. Lee

## Demo (deprecated)
![Demo.gif](https://github.com/deejayessel/ar-drawing/blob/master/flat_brush_test.gif)

## TODOs:
- [ ] **Save and load**: save vertex data and allow user to open saved copies of previous sessions
  - Save vertex data into userdefaults
- [x] **Undo/Redo stacks**: Undo drawing of the last curve (or some fixed k most recent vertices), allow redo
- [x] **Color Picker**: Hue slider
  - [ ] Add preview color box? 
- [ ] **Popups** when tracking quality is bad
- [ ] Plane- and straight-line-drawing
  - [ ] allow user to seed points and display as small SCNSpheres
  - [ ] continually update view during straight-line drawing with a straight line from the start point to the current point
- [x] Polyline SCNCylinder cleaning
   - [x] Remove intermediate points between parallel straight lines (lower angle bound)
   - [x] Insert intermediate points between sharp turns (upper angle bound)
   
## Lower-priority TODOs:
- Splines
  - [x] abstract implementation (Bezier)
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

## Testing
Lots of UI/visual tests

#### Drawing
- place finger on screen (hold down)
- move phone around in 3D space while keeping finger held down
- remove finger from screen
- use the phone as a window into the AR scene
- verify that points have been seeded in the appropriate positions relative to real space
- verify that motion along x, y, and z axes produces expected data (NSLog)

#### Cylinder-drawing
- rotation of cylinders uses quaternion defined by angle phi and rotation axis vector w:
  - ensure w is a unit vector
  - ensure w is oriented in the right direction ('Pokeball' test: seed sphere geometries at the head and tail of w, differentiating the two by using different colors)

####  Mesh-drawing
- Ensure the following:
  - mesh line not invisible
    - try making geometry's `isDoubleSided` property true and test again
  - drawing increases vertex and polygon counts within a reasonable bound (doesn't add nothing or too much)
  - no obvious warping effects
- place nodes with spheres (`pointNode`s) at each vertex and verify that vertices are in the right place ('Atom' test)

#### Pen/Context/Sliders
- try adjusting slider settings and verify that output works appropriately (intuitive outputs)
  - swapping settings doesn't break things
  - try various combinations of swaps

#### Main functionality checks
- drawing line works
  - line segments (cylinders) are oriented in the right direction
  - no obvious gaps
- drawing flat curve works
  - no obvious gaps
- different options don't conflict and behave as expected
  - color and thickness meters harmonize; both harmonize with stroke type
- clearing works without too much delay
- view framerate doesn't drop with a small number of objects in view
- polygon and vertex count stays constant when items in view do not change and no items are added
  (check for addition of invisible geometries)

#### Selection bound-drawing checks
1. hold finger on phone screen
2. move phone to a different location in 3D space
3. lift finger off screen
4. verify that a transparent box has been drawn spanning the starting and ending positions

## Key Use Cases
#### Drawing a stroke
*Main Path*
1. User holds a finger on her phone screen while moving her phone in 3D space.
2. The stroke is drawn in 3D space as a path of points that corresponds to the position of the user's
     iPhone through the duration of the held touch gesture.
3. The user releases her finger from the phone screen.
(Continually) The view overlays all existing strokes onto the live camera feed displayed as the background of the app.  

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
