//
//  Color.swift
//
//
//  Created by neutralradiance on 9/6/20.
//

#if os(iOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

public extension NativeColor {
//   convenience init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: ColorCodingKeys.self)
//    let red = try container.decode(CGFloat.self, forKey: .red)
//    let green = try container.decode(CGFloat.self, forKey: .green)
//    let blue = try container.decode(CGFloat.self, forKey: .blue)
//    let alpha = try container.decode(CGFloat.self, forKey: .alpha)
//    self.init(red: red, green: green, blue: blue, alpha: alpha)
//  }
//
//  func encode(to encoder: Encoder) throws {
//    var container = encoder.container(keyedBy: ColorCodingKeys.self)
//    try container.encode(red, forKey: .red)
//    try container.encode(green, forKey: .green)
//    try container.encode(blue, forKey: .blue)
//    try container.encode(alpha, forKey: .alpha)
//  }
  var light: Light {
    #if os(iOS)
      return
        Light(
          red: components[0],
          green: components[1],
          blue: components[2],
          alpha: components[3]
        )
    #elseif os(macOS)
      return
        Light(
          red: Double(redComponent),
          green: Double(greenComponent),
          blue: Double(blueComponent),
          alpha: Double(alphaComponent)
        )
    #endif
  }
}

public extension NativeColor {
  var components: [Double] {
    var red: CGFloat = 0,
        green: CGFloat = 0,
        blue: CGFloat = 0,
        alpha: CGFloat = 0

    #if os(macOS)
      usingColorSpace(.sRGB)
      getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    #elseif os(iOS)
      getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    #endif

    return [
      Double(red),
      Double(green),
      Double(blue),
      Double(alpha)
    ]
  }

  var hsbComponents: [Double] {
    var hue: CGFloat = 0,
        saturation: CGFloat = 0,
        brightness: CGFloat = 0,
        alpha: CGFloat = 0

    #if os(macOS)
      usingColorSpace(.sRGB)?
        .getHue(
          &hue,
          saturation: &saturation,
          brightness: &brightness,
          alpha: &alpha
        )
    #elseif os(iOS)
      getHue(
        &hue,
        saturation: &saturation,
        brightness: &brightness,
        alpha: &alpha
      )
    #endif

    return [
      Double(hue),
      Double(saturation),
      Double(brightness),
      Double(alpha)
    ]
  }
}

#if canImport(SwiftUI)
  import SwiftUI

  @available(macOS 10.15, *, iOS 13.0, *)
  public extension Color {
    init(_ light: Light) {
      self.init(
        .sRGB,
        red: light.red,
        green: light.green,
        blue: light.blue,
        opacity: light.alpha
      )
    }
  }
#endif
