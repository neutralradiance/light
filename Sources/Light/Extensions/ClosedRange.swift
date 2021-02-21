//
//  ClosedRange.swift
//  
//
//  Created by neutralradiance on 2/21/21.
//

import Foundation

internal extension ClosedRange {
  func squeeze(_ value: Bound) -> Bound {
    contains(value) ?
      value : value > upperBound ?
      upperBound :
      lowerBound
  }
}
