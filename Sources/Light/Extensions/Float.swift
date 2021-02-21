//
//  Float.swift
//  
//
//  Created by neutralradiance on 2/21/21.
//

import Foundation

var doubleRange: ClosedRange<Double> { 0 ... 1 }
var webRange: ClosedRange<Int> { 0 ... 255 }
var roundValue: Int { 16 }

extension Double {
  func roundTo(to decimals: Int) -> Self {
    let divisor = pow(10.0, Self(decimals))
    return (self * divisor).rounded() / divisor
  }

  var rounded: Self { roundTo(to: roundValue) }
  var squeezed: Self { doubleRange.squeeze(self) }
  var toWeb: Int { Int(self * 255) }
}

extension Int {
  var squeezed: Int { webRange.squeeze(self) }
  var fromWeb: Double { (Double(squeezed) / 255).rounded }
}

extension Comparable {
  func clamp(_ lhs: Self, _ rhs: Self) -> Self {
    min(max(self, lhs), rhs)
  }
}
