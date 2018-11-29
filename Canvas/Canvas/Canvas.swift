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
  
  public init() {
    vertices = []
  }
  
  public init(vertices : [float3]) {
    self.vertices = vertices
  }
  
  public init(generator : (Float) -> float3, values : [Float]) {
    vertices = values.map(generator)
  }
  
  public func add(vertex : float3) {
    vertices.append(vertex)
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
  
  public func lineGenerator(radius: CGFloat, segmentCount : Int) -> [float3] -> SCNNode {

    let range = 0..<segmentCount
    let circleVertices : [float3] = range.map {
      let theta  = Float($0)/Float(segmentCount) * 2 * Float.pi
      return float3(x: cos(theta), y: 0, z: sin(theta))
    }

    return {
      (vertices : [float3]) in

      for i in 0...vertices.count-3 {
        let a = vertices[i]
        let b = vertices[i+1]
        let c = vertices[i+2]
        
      }

      // Rotate circleVertices to be perpendicular to vector from u to v
      let (w, phi) = self.rotation(u, v)
      let rotationTransform = simd_float4x4(simd_quatf(angle: phi, axis: w))
      let rotatedVertices : [float3] = circleVertices.map {
        let rotated = float4($0, 1) * rotationTransform
        return float3(rotated)
      }

      // Construct SCNGeometry object
      let source = SCNGeometrySource(vertices: rotatedVertices.map { SCNVector3($0) })
      let element = SCNGeometryElement(indices: Array(0..<rotatedVertices.count),
                                       primitiveType: .triangleStrip)
      let geometry = SCNGeometry(sources: [source], elements: [element])

      let node =  SCNNode(geometry: geometry)
      node.simdPosition = u
      
      // Show vertex positions
      for vertex in rotatedVertices + [float3.zero] {
        node.addChildNode(self.pointNode(at: 0.002 * vertex,
                                         radius: radius/3,
                                         color: UIColor.white))
      }
      return node
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
      node.simdPosition = u //Translate node to position of src node
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


