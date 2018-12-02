//
//  Geometry.swift
//  AR Pictionary
//
//  Created by cs326 on 12/1/18.
//  Copyright © 2018 davidjlee. All rights reserved.
//

import Foundation
import SceneKit
import CoreGraphics

/**
 A factory class comprised of static functions that generate different geometries.
 */
public class Geometry {
  
  // - MARK: Utility methods
  
  /**
   - Returns: (w, phi) where w is the axis of rotation and phi is the angle of rotation.
   
   - Parameters:
   - u: The vector's tail coordinate.
   - v: The vector's head coordinate.
   */
  private static func rotation(_ u : float3, _ v : float3) -> (axis : float3, angle : Float) {
    // Vector from u to v
    let n = v - u
    let (x,y,z) = (n.x, n.y, n.z)
    
    // Rotating cylinder
    let d = sqrt(pow(x, 2) + pow(z, 2))
    let phi = atan(d/y)
    let w = float3(-z/d, 0, x/d)
    
    return (w, Float.pi - phi) //TODO: see if Float.pi - phi works better
  }
  
  /**
   - Returns: The vertices of a circle given its radius and segmentCount.
   
   - Parameters:
   - radius: The radius of the circle to be generated.
   - segmentCount: The number of segments used in the perimeter of the circle. 48 by default.
   */
  private static func circleVertices(radius : Float, segmentCount : Int = 48) -> [float3] {
    return (0...segmentCount).map {
      let theta  = Float($0)/Float(segmentCount) * 2 * Float.pi
      return float3(x: cos(theta), y: 0, z: sin(theta)) * radius
    }
  }
  
  /**
   - Returns: The vertices of a face rotated to be perpendicular to the vector v.
   
   - Parameters:
   - face: The collection of vertices describing the face in the x-z plane.
   - v: The vector rooted at the origin to which the face will be made perpendicular.
   */
  
  // Rotate face to be perpendicular to vector v
  private static func rotatedFace(face : [float3], _ v : float3) -> [float3] {
    let (w,phi) = rotation(float3(), v)
    let rotationTransform = simd_float4x4(simd_quatf(angle: phi, axis: w))
    return face.map {
      let rotated = float4($0, 1) * rotationTransform
      return float3(rotated)
    }
  }
  
  /**
   - Returns: A SCNNode with a SCNSphere at its center.
   
   - Parameters:
   - center: The center of the SCNNode.
   - radius: The radius of the SCNSphere.
   - color: The color of the SCNSphere.
   */
  private static func pointNode(at center: float3, radius : CGFloat, color : UIColor) -> SCNNode {
    let sphere = SCNSphere(radius: radius)
    sphere.firstMaterial?.diffuse.contents = color
    let node = SCNNode(geometry: sphere)
    node.simdPosition = center
    return node
  }
  
  // - MARK: Generators
  
  public static func tubeLineGenerator(radius: CGFloat, segmentCount : Int) -> ([float3]) -> SCNNode {
    
    let range = 0..<segmentCount
    let circleVertices : [float3] = range.map {
      let theta  = Float($0)/Float(segmentCount) * 2 * Float.pi
      return float3(x: cos(theta), y: 0, z: sin(theta)) * Float(radius)
    }
    
    // Rotate circleVertices to be perpendicular to vector from u to v
    func rotatedVertices(_ u : float3, _ v : float3) -> [float3] {
      let (w,phi) = rotation(u, v)
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
      //var firstCircle : [float3] = rotatedVertices(vertices[0], vertices[1])
      for i in 1..<vertices.count-1 {
        let u = vertices[i-1]
        let v = vertices[i]
        let w = vertices[i+1]
        
        let firstCircle : [float3] = rotatedVertices(u, v)
        let secondCircle : [float3] = rotatedVertices(v, w).map {
          $0 + (v - u)
        }
        
        // Interleave circle vertices to get cylinder vertices
        let interleaved : [float3] = zip(firstCircle + Array(firstCircle[0...1]),
                                         secondCircle + Array(secondCircle[0...1])).flatMap { [$0,$1] }
        
        // Construct a cylinder
        let source = SCNGeometrySource(vertices: interleaved.map { SCNVector3($0) })
        let indices = (0...interleaved.count-3).map { UInt8($0) }
        let element = SCNGeometryElement(indices: indices,
                                         primitiveType: .triangleStrip)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        //geometry.firstMaterial?.isDoubleSided = true
        
        // FOR TESTING: set line color red
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        
        // Add to SCNNode
        let node = SCNNode(geometry: geometry)
        node.simdPosition = u
        parent.addChildNode(node)
      }
      return parent
    }
  }
  
  public static func cylinderGenerator(radius: CGFloat) -> (float3, float3) -> SCNNode {
    return { (u : float3, v : float3) -> SCNNode in
      let cylinder = SCNCylinder(radius: radius, height: CGFloat(u.distance(to: v)))
      cylinder.heightSegmentCount = 1
      
      // Get rotation axis and angle for the vector from u to v
      let (w, phi) = self.rotation(u, v)
      
      // Rotate cylinder by phi about w
      let node = SCNNode(geometry: cylinder)
      node.simdPosition = u.midpoint(with: v) //Translate node to position of src node
      node.simdLocalRotate(by: simd_quatf(angle: phi, axis: w))
      
      return node
    }
  }
  
  //  public static func jointedcylinderGenerator(radius: CGFloat) -> (float3, float3, float3) -> SCNNode {
  //    assertionFailure("Not implemented")
  //    return { (u: float3, v: float3, w: float3) -> SCNNode in
  //      let cylinders : [SCNNode] = [(u,v), (v,w)].map(cylinderGenerator(radius: radius))
  //
  //      //firstTerminal, secondInitial faces
  //      let firstTerminal : [float3] = rotatedFace(face: circleVertices(radius: Float(radius)), v - u)
  //      let secondInitial : [float3] = rotatedFace(face: circleVertices(radius: Float(radius)), w - v)
  //
  //      // call bridge() method
  //      return SCNNode()
  //    }
  //  }
  
  public static func rectangleBrushGenerator(width: CGFloat,
                                             height: CGFloat,
                                             color: UIColor) -> (float3, float3) -> SCNNode {
    let w = Float(width), h = Float(height)
    let wideBrush : [float3] = [
      float3(-w, 0, -h),
      float3(w, 0, -h),
      float3(-w, 0, h),
      float3(w, 0, h)
    ]
    return faceTubeGenerator(face: wideBrush, color: color)
  }
  
  /**
   - Parameter face: the x-z plane version of the face to be used in each prism
   */
  private static func faceTubeGenerator(face : [float3], color : UIColor) -> (float3, float3) -> SCNNode {
    return {
      (u: float3, v: float3) -> SCNNode in
      
      /** TODO: Use SCNShape */
      //let geometry = SCNShape
      
      let firstFace : [float3] = rotatedFace(face: face, v - u)
      let secondFace : [float3] = rotatedFace(face: face, v - u).map { $0 + (v - u) }
      
      // Interleave circle vertices to get cylinder vertices
      let interleaved : [float3] = zip(firstFace + Array(firstFace[0...1]),
                                       secondFace + Array(secondFace[0...1])).flatMap { [$0,$1] }
      
      // Construct a cylinder
      let source = SCNGeometrySource(vertices: interleaved.map { SCNVector3($0) })
      let indices = (0...interleaved.count-3).map { UInt8($0) }
      // TODO: BRIDGE METHOD
      let element = SCNGeometryElement(indices: indices,
                                       primitiveType: .triangleStrip)
      let geometry = SCNGeometry(sources: [source], elements: [element])
      geometry.firstMaterial?.diffuse.contents = color
      
      // Add to SCNNode
      let node = SCNNode(geometry: geometry)
      node.simdPosition = u
      return node
    }
  }
  
}
