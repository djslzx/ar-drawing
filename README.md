# ar-pictionary
An augmented reality drawing-guessing game

David J. Lee

## TODOs:
- Polylines
  - [x] SCNCylinder line drawing
    - [x] Get cylinders to line up correctly
    - NOTE: too pixellated --> move on to manual mesh specification
  - [ ] Cylinder mesh line drawing (all points have corresponding circular interfaces; all cylinders are directly connected)
    - [ ] mathematical model for getting vertices of circle faces
    - [ ] use SCNGeometryElement and SCNGeometrySource to construct
- Splines
  - [ ] abstract implementation (Bezier)
  - [ ] conversion from polylines to splines and back
- Shared environment

(Way down the line...)
- Plane-drawing
  - [ ] allow user to seed points and display as small SCNSpheres
  - [ ] allow user to close a face path --> trigger plane generation

## Vision
Players take turns drawing objects randomly selected from a sub-category (or 'theme') of words.  
When it is a player's turn to draw, she uses her phone as a 3D brush, moving it around in space 
to draw a 3D image.  The other players view this 3D image from their respective phones as an 
object fixed in 3D space (an overlay on their camera feeds), and must attempt to correctly 
identify the drawn object within a time limit.  

The idea is to generate a shared server where players may interact with each other through 
3D drawings that persist within rounds.  The first game to be implemented will be a 3D version
of Pictionary, but the framework should be relatively easily extensible to include drawing 
competitions, where players agree upon a topic or reference image and compete to draw the 
most realistic images.  

### Base Version
There are only two players at any given time.  One phone is designated as the drawing device
(the 'Drawer') and another is designated as the viewing/guessing device (the 'Guesser').  
The Drawer can add strokes to the environment and the Guesser can view the environment but 
cannot modify it.  There is no guess-checking mechanic--the expectation is that players will 
confirm their guesses verbally, with the Drawer inputting the name of the winning guesser into 
the score chart.

### Extensions
- The game is extended to n players, where n >= 2.  Drawing and guessing are randomly assigned 
  roles that vary from round to round.
- Different brush sizes and colors
- Undo/Redo options (History stack)
- Additional game modes (e.g. drawing competition)
  - Symmetry mode: all drawings have a fixed symmetry that can't be turned off and all subjects are asymmetric
  - Chaos mode: brush size and color randomly change as the Drawer draws
- Online multiplayer
  - Players view a simple white room with player stand-ins tracked to iPhone motion
  - Guesses are submitted and checked via text input or voice recognition

## Feature List
#### Drawing
- User can draw strokes in their view
  - Drawing directly on the phone screen adds appropriate strokes to a plane a fixed z away
    from the user's phone position
  - Holding a finger on the phone screen and moving the phone in 3D space draws 3D strokes 
    where points along the curve correspond to the path of the phone
- User can erase strokes in their view (same motion mechanic as the drawing case)
- [Extension] User can see markers that show where the Guessers are viewing the scene from
- [Extension] User can customize their stroke color, thickness, and brush type

#### Guessing
- User can view strokes drawn by Drawer
  - All strokes are fixed in 3D space
- [Extension] User can use text input to guess the identity of the drawn object

#### Game Facilitation
- [Extension] Drawer and Guesser roles are assigned randomly at the start of each round
- Drawer is given an object to draw
  - [?] Allow Drawer to discard and request a new object?
- Score tracking
  - Guessers are rewarded 1 point for every correct guess and Drawers are rewarded p 
    points where 0 < p < 1.  Before balancing, let p = 0.25.

## UI Sketches
#### Drawing
![Drawing UI Sketches](https://github.com/deejayessel/ar-pictionary/blob/master/20181114_214855-01-01.jpeg)

#### Game Server
![Game Server UI Sketches](https://github.com/deejayessel/ar-pictionary/blob/master/20181114_214851-01.jpeg)

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
No expert features involved.

## Architecture
[//]: # (Describe the major components and data structures for your data model, as well as the top-level controllers and views of your UI. Feel free to use diagrams.)

#### Data model
* Drawing canvas: ordered list of ordered list of `SCNVector3`s: `[[SCNVector3]]`
  * Each array (`[SCNVector3]`) represents a set of 3D points ordered by time of creation; the ordering 
    implicitly stores edge data
  * Arrays are ordered by entry time to allow for history tracking
  * Fed into view to make 3D cylinders only upon creation/deletion, so arrays are good enough 
    (don't need quick look-up, just some notion of ordering)
* Game mechanics: 
  * Player class - name/id, phone position/id, role designation; dictionary of names/ids to Player objects `[String:Player]`
  * Word generation: database of mappings from topics/themes to string collections, implemented using an 
    external, persistent database (potentially with web updating)

#### Controllers and Views
- ARSCNView as generic view, split off into DrawerView (drawing-enabled) and GuesserView (drawing-disabled) with respective
  view controllers
- `SCNVector3`s rendered as `SCNCylinder`s stored in the view; singleton class for `SCNCylinder` container (Canvas class)
