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
    var curves : [[SCNVector3]] = []
    for _ in 0...10 {
      let curve = Array(0...10).map { SCNVector3($0, $0, $0) }
      curves.append(curve)
    }
    let canvas = Canvas(curves: curves)
    for point in canvas {
      NSLog(point)
    }
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
