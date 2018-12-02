//
//  MatrixExtensions.swift
//  Canvas
//
//  Created by 21djl5 on 11/28/18.
//  Copyright © 2018 davidjlee. All rights reserved.
//
//  A collection of extensions to a few matrix operation classes.
//

import Foundation
import SceneKit

public extension float3 {
  
  public var length : Float {
    return sqrtf(self.reduce(0) { $0 + powf($1, 2) })
  }
  
  public func distance(to dst : float3) -> Float {
    return (dst - self).length
  }
  
  public func midpoint(with other : float3) -> float3 {
    return (self + other)/2
  }
  
  public var flattened : CGPoint {
    return CGPoint(x: CGFloat(self.x), y: CGFloat(self.y))
  }
  
  func rotated(x : Float, y : Float, z : Float) -> float3 {
    let matrices : [simd_float3x3] =
      [
        simd_float3x3(rows:
          [
            float3([1, 0 , 0]),
            float3([0, cos(x), -sin(x)]),
            float3([0, sin(x), cos(x)])
          ]),
        simd_float3x3(rows:
          [
            float3([cos(y), 0, sin(y)]),
            float3([0, 1, 0]),
            float3([-sin(y), 0, cos(y)])
          ]),
        simd_float3x3(rows:
          [
            float3([cos(z), -sin(z), 0]),
            float3([sin(z), cos(z), 0]),
            float3([0, 0, 1])
          ]
        )
    ]
    return matrices.reduce(self, *)
  }
  
  public init(_ v : float4) {
    self.init(x: v.x, y: v.y, z: v.z)
  }
}

public extension float4 {
  public func rotated(x : Float, y : Float, z : Float) -> float4 {
    let rotated = float3(self).rotated(x: x, y: y, z: z)
    return float4(rotated, self.w)
  }
  
  public var length : Float {
    return sqrtf(self.reduce(0) { $0 + powf($1, 2) })
  }
  
  public init(_ v : float3, _ i : Float) {
    self.init(v.x, v.y, v.z, i)
  }
}

public extension simd_float4x4 {
  public var translation : float3 {
    return float3(columns.3.x, columns.3.y, columns.3.z)
  }
}
