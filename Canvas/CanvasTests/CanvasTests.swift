//
//  CanvasTests.swift
//  CanvasTests
//
//  Created by 21djl5 on 11/22/18.
//  Copyright © 2018 davidjlee. All rights reserved.
//

import XCTest
import SceneKit
@testable import Canvas

class CanvasTests: XCTestCase {
  
  func testInit() {
    var curves : [[Point]] = []
    for _ in 1...3 {
      let curve = Array(1...3).map { Point($0, $0, $0) }
      curves.append(curve)
    }
    let c1 = Canvas(curves: curves)
    
    let c2 = Canvas()
    for curve in curves {
      c2.add(curve: curve)
    }
    
    let c3 = Canvas()
    for curve in curves {
      c3.startCurve()
      for point in curve {
        c3.append(point: point)
      }
    }
    
    XCTAssertEqual(c1, c2)
    XCTAssertEqual(c2, c3)
    XCTAssertEqual(c3, c1)
  }
  
  
  
}
