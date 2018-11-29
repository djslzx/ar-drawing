//
//  Canvas.sw.swift
//  Canvas
//
//  Created by 21djl5 on 11/22/18.
//  Copyright © 2018 davidjlee. All rights reserved.
//

import Foundation
import SceneKit
import CoreGraphics

public class Polyline : CustomDebugStringConvertible {
  
  public private(set) var vertices : [float3]
  
  public var debugDescription: String {
    return String(reflecting: vertices)
  }
  
  public init(vertices : [float3]) {
    self.vertices = vertices
    NSLog("Created new PolyLine")
  }
  
  public convenience init() {
    self.init(vertices: [])
  }
  
  public convenience init(generator : (Float) -> float3, values : [Float]) {
    self.init(vertices: values.map(generator))
  }
  
  public func add(vertex : float3) {
    vertices.append(vertex)
    NSLog("Added new vertex: \(vertex)")
  }
  
  public func removeLast() {
    vertices.removeLast()
  }
  
  public func lastSegment() -> (float3, float3)? {
    if vertices.count >= 2 {
      return (vertices[vertices.count - 2], vertices[vertices.count - 1])
    } else {
      return nil
    }
  }
  
  public func segments() -> Zip2Sequence<ArraySlice<float3>, ArraySlice<float3>> {
    return zip(vertices[...], vertices[1...])
  }
  
}

public class PolylineGeometry {
  
  public init() {
    // Make Swift compiler happy
  }
  
  private func rotation(_ u : float3, _ v : float3) -> (axis : float3, angle : Float) {
    // Vector from u to v
    let n = v - u
    let (x,y,z) = (n.x, n.y, n.z)
    
    // Rotating cylinder
    let d = sqrt(pow(x, 2) + pow(z, 2))
    let phi = atan(d/y)
    let w = float3(-z/d, 0, x/d)
    
    return (w, phi)
  }
  
  public func pointNode(at center: float3, radius : CGFloat, color : UIColor) -> SCNNode {
    let sphere = SCNSphere(radius: radius)
    sphere.firstMaterial?.diffuse.contents = color
    let node = SCNNode(geometry: sphere)
    node.simdPosition = center
    return node
  }
  
  public func lineGenerator(radius: CGFloat, segmentCount : Int) -> ([float3]) -> SCNNode {

    let range = 0..<segmentCount
    let circleVertices : [float3] = range.map {
      let theta  = Float($0)/Float(segmentCount) * 2 * Float.pi
      return float3(x: cos(theta), y: 0, z: sin(theta)) * Float(radius)
    }

    // Rotate circleVertices to be perpendicular to vector from u to v
    func rotatedVertices(_ u : float3, _ v : float3) -> [float3] {
      let (w,phi) = self.rotation(u, v)
      let rotationTransform = simd_float4x4(simd_quatf(angle: phi, axis: w))
      return circleVertices.map {
        let rotated = float4($0, 1) * rotationTransform
        return float3(rotated)
      }
    }
    
    return {
      (vertices : [float3]) in

      guard vertices.count >= 2 else {
        return SCNNode()
      }
      
      // The parent node of all nodes generated in the loop; to be returned
      let parent = SCNNode()

      // Construct a set of tubes (uncapped cylinders) and add caps at end
      
      // Initialize first circle using vector from first to second vertex
      var firstCircle : [float3] = rotatedVertices(vertices[0], vertices[1])
      for i in 1..<vertices.count-1 {
        let u = vertices[i]
        let v = vertices[i+1]

        // Interleave circle vertices to get cylinder vertices
        let secondCircle : [float3] = rotatedVertices(u, v)
        assert(firstCircle.count == secondCircle.count)
        let cylinderVertices : [float3] = zip(firstCircle, secondCircle).flatMap { [$0,$1] }

        NSLog("First circle: \(firstCircle)")
        NSLog("Second circle: \(secondCircle)")
        NSLog("Interleaved: \(cylinderVertices)")
        
//        for vertex in firstCircle[0...1] {
//          let node = self.pointNode(at: u + vertex,
//                                    radius: radius/3,
//                                    color: UIColor.red)
//          parent.addChildNode(node)
//        }
//        for vertex in secondCircle[0...1] {
//          let node = self.pointNode(at: v + vertex,
//                                    radius: radius/3,
//                                    color: UIColor.blue)
//          parent.addChildNode(node)
//        }
        
        // Update firstCircle
        firstCircle = secondCircle
        
        // Construct a cylinder
        let source = SCNGeometrySource(vertices: cylinderVertices.map { SCNVector3($0) })
        let indices = (0...cylinderVertices.count-3).map { UInt8($0) }
        let element = SCNGeometryElement(indices: indices,
                                         primitiveType: .triangleStrip)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.firstMaterial?.isDoubleSided = true

        // FOR TESTING: set line color red
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        
        // Add to SCNNode
        let node = SCNNode(geometry: geometry)
        node.simdPosition = u.midpoint(with: v)
        
        parent.addChildNode(node)
      }
      
      return parent
    }
  }
  
  public func cylinderGenerator(radius: CGFloat) -> (float3, float3) -> SCNNode {
    return { (u : float3, v : float3) -> SCNNode in
      let cylinder = SCNCylinder(radius: radius, height: CGFloat(u.distance(to: v)))
      cylinder.heightSegmentCount = 1

      // Get rotation axis and angle for the vector from u to v
      let (w, phi) = self.rotation(u, v)
      let theta = Float.pi - phi
    
      // Rotate cylinder by phi about w
      let node = SCNNode(geometry: cylinder)
      node.simdPosition = u.midpoint(with: v) //Translate node to position of src node
      node.simdLocalRotate(by: simd_quatf(angle: theta, axis: w))

      return node
    }
  }
}

//public class Spline : CustomDebugStringConvertible {
//
//  private var vertices : [float3]
//
//  public var debugDescription: String
//
//
//}


