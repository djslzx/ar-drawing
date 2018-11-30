# ar-drawing
An augmented reality drawing environment

David J. Lee

## TODOs:
- Polylines
  - [x] SCNCylinder line drawing
    - [x] Get cylinders to line up correctly
    - NOTE: too pixellated --> move on to manual mesh specification
  - [ ] Cylinder mesh line drawing (all points have corresponding circular interfaces; all cylinders are directly connected)
    - [x] mathematical model for getting vertices of circle faces
    - [x] use SCNGeometryElement and SCNGeometrySource to construct
    - [ ] get everything working
- Splines
  - [ ] abstract implementation (Bezier)
  - [ ] conversion from polylines to splines and back
  - [ ] allow vector-drawing using Bezier in 3D
- General drawing
  - [ ] User can erase strokes in their view (same motion mechanic as the drawing case)
  - [ ] User can customize their stroke color, thickness, and brush type
- [ ] Shared environment
- [ ] Export and import data
  - [ ] export into appropriate format (JSON?)
  - [ ] import from same format

(Way down the line...)
- Plane-drawing
  - [ ] allow user to seed points and display as small SCNSpheres
  - [ ] allow user to close a face path --> trigger plane generation

## Vision
Users select a brush stroke and move their phones around in 3D space to draw 3D brush strokes.
The resulting strokes are suspended in 3D space at a fixed location determined at the time of drawing,
although the world space may be translated if the user desires.

### Base Version
The user can draw smooth lines in 3D space, adjusting simple characteristics like 
- [ ] Color
- [ ] Opacity
- [ ] Stroke detail (polygon count)

### Extensions
#### Drawing
- Sculpting features
  - User specifies points, algorithm run to get smallest prism containing points
  - Vertices distorted with vertex-editing tools
- Different brush sizes and colors
- Undo/Redo options (History stack)

#### Pictionary
- The game is extended to n players, where n >= 2.  Drawing and guessing are randomly assigned 
  roles that vary from round to round.
- Additional game modes (e.g. drawing competition)
  - Symmetry mode: all drawings have a fixed symmetry that can't be turned off and all subjects are asymmetric
  - Chaos mode: brush size and color randomly change as the Drawer draws
- **Online multiplayer**
  - Players view a simple white room with player stand-ins tracked to iPhone motion
  - Guesses are submitted and checked via text input or voice recognition

## Feature List
#### Drawing
- User can draw strokes in their view
  - [x] Drawing directly on the phone screen adds strokes at a fixed translation away from the user's current phone position
  - [x] Holding a finger on the phone screen and moving the phone in 3D space draws 3D strokes 
        where points along the curve correspond to the path of the phone
- [ ] User can erase strokes in their view (same motion mechanic as the drawing case)
- [ ] User can customize their stroke color, thickness, and brush type
- [Extension] User can see markers that show where the Guessers are viewing the scene from

## UI Sketches
#### Drawing
![Drawing UI Sketches](https://github.com/deejayessel/ar-drawing/blob/master/20181114_214855-01-01.jpeg)

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
- `SCNVector3`s rendered as `SCNCylinder`s stored in the view; singleton class for `SCNCylinder` container (Canvas class)
