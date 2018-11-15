# ar-pictionary
An AR implementation of a drawing guessing game

David J. Lee

## Vision


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
