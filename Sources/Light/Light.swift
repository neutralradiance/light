//
//  Light.swift
//
//
//  Created by neutralradiance on 9/6/20.
//

import Foundation

/// `Codable` color.
public struct Light {
  public var
    redComponent: Double,
    greenComponent: Double,
    blueComponent: Double,
    alphaComponent: Double

  public init(
    red: Double = 0,
    green: Double = 0,
    blue: Double = 0,
    alpha: Double = 1.0
  ) {
    redComponent = red.squeezed
    greenComponent = green.squeezed
    blueComponent = blue.squeezed
    alphaComponent = alpha.squeezed
  }
}

public extension Light {
  // Generic Colors
  static var clear: Self { Self(alpha: 0) }
  static var black: Self { Self() }
  static var white: Self { Self(red: 1, green: 1, blue: 1) }
  static var red: Self { Self(red: 1) }
  static var green: Self { Self(green: 1) }
  static var blue: Self { Self(blue: 1) }

  // Special Colors
  static var graphite: Self { Self(red: 0.56, green: 0.56, blue: 0.55) }
}

extension Light: ColorCodable {
  public var components: [Double] {
    [redComponent, greenComponent, blueComponent, alphaComponent]
  }

  public var hsbComponents: [Double] {
    let r = redComponent, g = greenComponent, b = blueComponent
    let maximum = max(r, g, b), minimum = min(r, g, b)
    var h: Double = 0,
        s: Double = 0,
        v: Double = maximum
    if minimum != maximum {
      let d = maximum - minimum
      s = maximum == 0 ? 0 : d / maximum
      switch maximum {
      case r:
        h = (g - b) / d + (g < b ? 6 : 0)
      case g:
        h = (b - r) / d + 2
      case b:
        h = (r - g) / d + 4
      default: break
      }
      h /= 6
    }
    return [h, s, v, alphaComponent]
  }
}

#if canImport(SwiftUI)
  import SwiftUI

  @available(macOS 10.15, *, iOS 13.0, *)
  public extension Light {
    var token: Color {
      Color(
        red: Double(redComponent),
        green: Double(greenComponent),
        blue: Double(blueComponent),
        opacity: Double(alphaComponent)
      )
    }
  }
#endif
