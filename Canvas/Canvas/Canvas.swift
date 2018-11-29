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
  
  public func generator(width: CGFloat) -> (float3, float3) -> SCNNode {
    return { (u : float3, v : float3) -> SCNNode in
      let cylinder = SCNCylinder(radius: width, height: CGFloat(u.distance(to: v)))
      cylinder.heightSegmentCount = 1

      // Vector from u to v
      let n = v - u
      let (x,y,z) = (n.x, n.y, n.z)

      // Rotating cylinder
      let d = sqrt(pow(x, 2) + pow(y,2))
      let phi = atan(d/z)
      let w = float3(y/d, -x/d, 0)

      let printphi = ((phi / Float.pi * 180) + 360).truncatingRemainder(dividingBy: 360)
      NSLog("phi: \(printphi)")
      NSLog("w: \(w.length)")
      
      func getNode(position : float3, color: UIColor) -> SCNNode{
        let geometry = SCNSphere(radius: width)
        let node = SCNNode(geometry: geometry)
        node.simdPosition = position
        node.geometry?.firstMaterial?.diffuse.contents = color
        return node
      }
      
//      let u_node = getNode(position: u, color: UIColor.white)
//      let w_node = getNode(position: u + 0.001 * w, color: UIColor.red)
//      let z_axis = getNode(position: u + 0.002 * float3(0,0,z), color: UIColor.green)
//
//      let parent = SCNNode()
//      parent.addChildNode(u_node)
//      parent.addChildNode(w_node)
//      parent.addChildNode(z_axis)
//
//      return parent

      // Rotating and translating by n
      let node = SCNNode(geometry: cylinder)
      node.simdPosition = u
      
      let newnode = SCNNode(geometry: cylinder)
      newnode.simdLocalRotate(by: simd_quatf(angle: phi, axis: w))
      newnode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
      //node.simdLocalRotate(by: simd_quatf(angle: phi, axis: w))
      node.simdLocalTranslate(by: simd_float3(SCNVector3(n)))
      
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


