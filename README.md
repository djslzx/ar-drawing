# ar-pictionary
An augmented reality drawing-guessing game

David J. Lee

## Vision
A game played in a shared environment where players take turns drawing objects randomly selected from a sub-category (or 'theme') of words.  When it is a player's turn to draw, she uses her phone as a 3D brush, moving it around in space to draw a 3D image.  The other players view this 3D image from their respective phones as an object fixed in 3D space (an overlay on their camera feeds), and must attempt to correctly identify the drawn object within a time limit.  

The idea is to generate a shared server where players may interact with each other through 3D drawings that persist within rounds.  The first game to be implemented will be a 3D version of Pictionary, but the framework should be relatively easily extensible to include drawing competitions, where players agree upon a topic or reference image and compete to draw the most realistic images.  

### Base Version
There are only two players at any given time.  One phone is designated as the drawing device and another is designated as the viewing/guessing device.  The drawing device can add strokes to the environment and the guessing device can view the environment but cannot modify it.  There is no guess-checking mechanic--the expectation is that players will confirm their guesses verbally, with the drawing player inputting the name of the winning guesser into the score chart.

### Extensions
- The game is extended to n players, where n >= 2.  
- Additional game modes (e.g. drawing competition)
- 

## Feature List

-

### Tools
- Prototyping
  - Cube
  - Prism (set of points -> shape)

- Stone-working
  - Chisel 
  - Mallet
  - Abrade

- Drawing
  - Brush
  - Eraser
  - Point-eraser

- Derived
  - Symmetry
  - Cloning

## UI Sketches

## Key Use Cases
1. Sculpting
2. Viewing
3. Sharing

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
