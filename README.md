# ar-sculpt
An AR Sculpting/Drawing Toolkit

David J. Lee

## Vision
**To develop a general-purpose augmented-reality sculpting application that allows users to easily sculpt or draw 3D objects using intuitive gestures.**  Users will be able to move their phones in intuitive motions to simulate the use of carving or drawing tools, and the augmented reality display will modify and display sculptures situated in the real world.  

## Feature List

- A basic view for displaying and editing sculptures
- A suite of tools to work with simple 3D models

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
