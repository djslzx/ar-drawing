# ar-pictionary
An augmented reality drawing-guessing game

David J. Lee

## Vision
Players take turns drawing objects randomly selected from a sub-category (or 'theme') of words.  When it is a player's turn to draw, she uses her phone as a 3D brush, moving it around in space to draw a 3D image.  The other players view this 3D image from their respective phones as an object fixed in 3D space (an overlay on their camera feeds), and must attempt to correctly identify the drawn object within a time limit.  

The idea is to generate a shared server where players may interact with each other through 3D drawings that persist within rounds.  The first game to be implemented will be a 3D version of Pictionary, but the framework should be relatively easily extensible to include drawing competitions, where players agree upon a topic or reference image and compete to draw the most realistic images.  

### Base Version
There are only two players at any given time.  One phone is designated as the drawing device (the 'Drawer') and another is designated as the viewing/guessing device (the 'Guesser').  The Drawer can add strokes to the environment and the Guesser can view the environment but cannot modify it.  There is no guess-checking mechanic--the expectation is that players will confirm their guesses verbally, with the Drawer inputting the name of the winning guesser into the score chart.

### Extensions
- The game is extended to n players, where n >= 2.  Drawing and guessing are randomly assigned roles that vary from round to round.
- Different brush sizes and colors
- Additional game modes (e.g. drawing competition)
  - Symmetry mode: all drawings have a fixed symmetry that can't be turned off and all subjects are asymmetric
- Online multiplayer
  - Players view a simple white room with player stand-ins tracked to iPhone motion
  - Guesses are submitted and checked via text input or voice recognition

## Feature List
#### Drawing
- User can draw strokes in their view
  - Drawing directly on the phone screen adds appropriate strokes to a plane a fixed z away from the user's phone position
  - Holding a finger on the phone screen and moving the phone in 3D space draws 3D strokes where points along the curve correspond to the path of the phone
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
  - Guessers are rewarded 1 point for every correct guess and Drawers are rewarded p points where 0 < p < 1.  Before balancing, let p = 0.25.

## UI Sketches
#### Drawing
![Drawing UI Sketches](https://github.com/deejayessel/ar-pictionary/blob/master/20181114_214855-01-01.jpeg)

#### Game Server
![Game Server UI Sketches](https://github.com/deejayessel/ar-pictionary/blob/master/20181114_214851-01.jpeg)

## Key Use Cases
### Drawing
#### Drawing a stroke
1. User draws a stroke on her phone screen.
 

#### Guessing

## Domain Analysis
- Chisel: Cuts away a local region
- Mallet: Flattens a local region
- Abrade: Smooths the surface of a local region
- Eraser: Removes regions of a surface within a specified distance of the eraser center
- Point-eraser: Removes points of a surface within a specified distance of the eraser center
- Symmetry: Allows symmetrical construction of sculpture model
- Cloning: Allows copying and pasting of local regions of the sculpture model

## Architecture

### Major Frameworks
- ARKit
Describe the major components and data structures for your data model, as well as the top-level controllers and views of your UI. Feel free to use diagrams.
