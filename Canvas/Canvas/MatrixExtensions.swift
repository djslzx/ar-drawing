//
//  MatrixExtensions.swift
//  Canvas
//
//  Created by 21djl5 on 11/28/18.
//  Copyright © 2018 davidjlee. All rights reserved.
//

import Foundation
import SceneKit

public extension float3 {
  
  public var length : Float {
    return float3(0, 0, 0).distance(to: self)
  }
  
  public func distance(to dst : float3) -> Float {
    return sqrt(pow(self.x - dst.x, 2) +
      pow(self.y - dst.y, 2) +
      pow(self.z - dst.z, 2))
  }
  
  public func midpoint(with other : float3) -> float3 {
    return float3((self.x + other.x)/2,
                  (self.y + other.y)/2,
                  (self.z + other.z)/2)
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
}

public extension float4 {
  func rotated(x : Float, y : Float, z : Float) -> float4 {
    let vector = float3(self.x, self.y, self.z)
    let rotated = vector.rotated(x: x, y: y, z: z)
    return float4(rotated.x, rotated.y, rotated.z, self.w)
  }
}

public extension simd_float4x4 {
  var translation : float3 {
    return float3(columns.3.x, columns.3.y, columns.3.z)
  }
}
