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
  
  private func makeCurves(_ numcurves: Int, _ numpoints: Int) -> [[Point]] {
    var curves : [[Point]] = []
    for _ in 1...numcurves {
      let curve = Array(1...numpoints).map { Point($0, $0, $0) }
      curves.append(curve)
    }
    return curves
  }
  
  func testInit() {
    let c1 = Canvas()
    let c2 = Canvas()
    XCTAssertEqual(c1, c2)
  }
  
  func testAddCurve() {
    let curves = makeCurves(3, 5)
    let c1 = Canvas(curves: curves)
    let c2 = Canvas()
    for curve in curves {
      c2.add(curve: curve)
    }
    XCTAssertEqual(c1,c2)
  }
  
  func testAddPoint() {
    let curves = makeCurves(3, 5)
    let c1 = Canvas(curves: curves)
    let c2 = Canvas()
    for curve in curves {
      c2.startCurve()
      for point in curve {
        c2.append(point: point)
      }
    }
    XCTAssertEqual(c1, c2)
  }
  
  func testRemove() {
    let curves = makeCurves(3, 5)
    let c1 = Canvas(curves: curves)
    for _ in 1...curves.count {
      c1.remove()
    }
    let c2 = Canvas()
    XCTAssertEqual(c1, c2)
  }
  
  func testSubscriptPoint() {
    let curves = makeCurves(3, 5)
    let c = Canvas(curves: curves)
    for i in 0..<curves.count {
      for j in 0..<curves[0].count {
        XCTAssertEqual(curves[i][j], c[i,j])
      }
    }
  }
  
  func testSubscriptCurve() {
    let curves = makeCurves(3, 5)
    let c = Canvas(curves: curves)
    for i in 0..<curves.count {
      XCTAssertEqual(curves[i], c[i])
    }
  }
}
