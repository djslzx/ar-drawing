//
//  UIColorExtension.swift
//  AR Pictionary
//
//  Created by cs326 on 12/5/18.
//  By Steven (https://stackoverflow.com/users/1616074/stephen)
//

import Foundation
import UIKit

extension UIColor {
  
  func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
    return self.adjust(by: abs(percentage) )
  }
  
  func darker(by percentage: CGFloat = 30.0) -> UIColor? {
    return self.adjust(by: -1 * abs(percentage) )
  }
  
  func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      return UIColor(red: min(red + percentage/100, 1.0),
                     green: min(green + percentage/100, 1.0),
                     blue: min(blue + percentage/100, 1.0),
                     alpha: alpha)
    } else {
      return nil
    }
  }
  
  func changeAlpha(by percentage: CGFloat = 30) -> UIColor? {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      return UIColor(red: red, green: green, blue: blue,
                     alpha: min(alpha + percentage/100, 1.0))
    } else {
      return nil
    }
  }
}
