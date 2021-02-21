//
//  ColorCodable.swift
//
//
//  Created by neutralradiance on 9/6/20.
//

import SwiftUI
#if os(iOS)
  import UIKit.UIColor
  public typealias NativeColor = UIColor
#elseif os(macOS)
  import AppKit.NSColor
  public typealias NativeColor = NSColor
#endif

public protocol ColorCodable:
  Codable,
  ExpressibleByStringLiteral,
  ExpressibleByArrayLiteral {
  var red: Double { get }
  var green: Double { get }
  var blue: Double { get }
  var alpha: Double { get }
  var hue: Double { get }
  var saturation: Double { get }
  var brightness: Double { get }
  var hex: String { get }
  var components: [Double] { get }
  var rgbComponents: [Double] { get }
  var hsbComponents: [Double] { get }
  var hslComponents: [Double] { get }
  var webComponents: [Int] { get }
  var hexComponents: [String] { get }
  init(
    red: Double,
    green: Double,
    blue: Double,
    alpha: Double
  )
}

enum ColorCodingKeys: CodingKey {
  case red, blue, green, alpha
}

infix operator ~: MultiplicationPrecedence
public extension ColorCodable {
  typealias RGBComponents = (
    red: Double?,
    green: Double?,
    blue: Double?,
    alpha: Double?
  )

  var red: Double { components[0] }
  var green: Double { components[1] }
  var blue: Double { components[2] }
  var alpha: Double { components[3] }
  var hue: Double { hsbComponents[0] }
  var saturation: Double { hsbComponents[1] }
  var brightness: Double { hsbComponents[2] }
  var luminosity: Double { hslComponents[2] }
  var hex: String { hexComponents.joined() }
  var rgbComponents: [Double] { [red, green, blue] }
  var nativeColor: NativeColor {
    NativeColor(
      red: CGFloat(red),
      green: CGFloat(green),
      blue: CGFloat(blue),
      alpha: CGFloat(alpha)
    )
  }

  static func == <C: ColorCodable>(lhs: Self, rhs: C) -> Bool {
    lhs.components == rhs.components
  }

  func compare<C: ColorCodable>(
    _ new: C,
    _ comparison:
    @escaping (_ lhs: Double, _ rhs: Double) -> Double
  ) -> [Double] {
    components.map { lhs -> Double in
      var comp: Double!
      new.components.forEach { rhs in
        comp = comparison(lhs, rhs)
      }
      return comp
    }
  }

  func blendColor<C: ColorCodable>(
    _ color: C,
    _ midpoint: Double = 0.5
  ) -> Self {
    Self(fromComponents:
      compare(color) { lhs, rhs -> Double in
        (1 - midpoint) * pow(lhs, 2) + midpoint * pow(rhs, 2)
      } + [(1 - midpoint) * alpha + midpoint * color.alpha]
    )
  }

  //    /// Color blending
  static func + <C: ColorCodable>(lhs: Self, rhs: C) -> Self {
    Self(fromComponents:
      lhs.compare(rhs) { lhs, rhs -> Double in
        (lhs + rhs) / 2
      } + [(lhs.alpha + rhs.alpha) / 2]
    )
  }

  static func - <C: ColorCodable>(lhs: Self, rhs: C) -> Self {
    Self(fromComponents:
      lhs.compare(rhs) { lhs, rhs -> Double in
        min(lhs + rhs, 1)
      } + [min(lhs.alpha + rhs.alpha, 1)]
    )
  }

  static func * <C: ColorCodable>(lhs: Self, rhs: C) -> Self {
    lhs.blendColor(rhs)
  }

  static func / <C: ColorCodable>(lhs: Self, rhs: C) -> Self {
    lhs.blendColor(rhs.inverted)
  }

  init(stringLiteral value: StaticString) {
    self.init(hex: value.description)!
  }

  init(arrayLiteral elements: Double...) {
    self.init(fromComponents: elements)
  }

  init() {
    self.init(red: 0, green: 0, blue: 0, alpha: 0)
  }

  init(red: Int, green: Int, blue: Int, alpha: Double = 1) {
    self.init(
      red: red.fromWeb,
      green: green.fromWeb,
      blue: blue.fromWeb,
      alpha: alpha
    )
  }

  init(
    hue: Double = 0,
    saturation: Double = 0,
    brightness: Double,
    alpha: Double = 1
  ) {
    var r = brightness.squeezed,
        g = brightness.squeezed,
        b = brightness.squeezed,
        h = hue.squeezed,
        s = saturation.squeezed,
        v = brightness.squeezed,
        i = floor(h * 6),
        f = h * 6 - i,
        p = v * (1 - s),
        q = v * (1 - f * s),
        t = v * (1 - (1 - f) * s)
    switch i.truncatingRemainder(dividingBy: 6) {
    case 0: r = v; g = t; b = p
    case 1: r = q; g = v; b = p
    case 2: r = p; g = v; b = t
    case 3: r = p; g = q; b = v
    case 4: r = t; g = p; b = v
    case 5: r = v; g = p; b = q
    default: break
    }
    self.init(red: r, green: g, blue: b, alpha: alpha)
  }

  // https://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion
  init(
    hue: Double = 0,
    saturation: Double = 0,
    luminosity: Double,
    alpha: Double = 1
  ) {
    let h = hue,
        s = saturation,
        l = luminosity
    var r: Double = 0,
        g: Double = 0,
        b: Double = 0
    if s == 0 {
      r = l
      g = l
      b = l
    } else {
      func hue2rgb(
        _ p: Double,
        _ q: Double,
        _ t: Double
      ) -> Double {
        let t = t.squeezed
        switch t {
        case 0 ... (1 / 6): return p + (q - p) * 6 * t
        case 0 ... (1 / 2): return q
        case 0 ... (2 / 3): return p + (q - p) * (2 / 3 - t) * 6
        default: return p
        }
      }
      let q = l < 0.5 ? l * (1 + s) : l + s - l * s
      let p = 2 * l - q
      r = hue2rgb(p, q, h + 1 / 3 - 0.0000000000000003).squeezed
      g = (hue2rgb(p, q, h) + 0.0000000000000003).squeezed
      b = hue2rgb(p, q, h - 1 / 3 + 0.0000000000000003).squeezed
    }
    self.init(
      red: r.rounded,
      green: g.rounded,
      blue: b.rounded,
      alpha: alpha.rounded
    )
  }

  static func white(
    _ value: Double,
    withAlpha alpha: Double = 1
  ) -> Self {
    Self(red: value, green: value, blue: value, alpha: alpha)
  }

  init?(hex: String, alpha: Double = 1) {
    var hexValue = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
    if hexValue.count == 3 {
      for (index, char) in hexValue.enumerated() {
        hexValue.insert(
          char,
          at: hexValue.index(hexValue.startIndex, offsetBy: index * 2)
        )
      }
    }
    guard hexValue.count == 6,
          let intCode = Int(hexValue, radix: 16) else { return nil }
    self.init(red: (intCode >> 16) & 0xFF,
              green: (intCode >> 8) & 0xFF,
              blue: intCode & 0xFF,
              alpha: alpha)
  }

  init(fromComponents components: [Double]) {
    self.init(red: components[0],
              green: components[1],
              blue: components[2],
              alpha: components.count > 3 ? components[3] : 1)
  }

  init(fromComponents components: RGBComponents) {
    self.init(red: components.red ?? 0,
              green: components.green ?? 0,
              blue: components.blue ?? 0,
              alpha: components.alpha ?? 1)
  }

  var hslComponents: [Double] {
    let r = red, g = green, b = blue
    let maximum = max(r, g, b),
        minimum = min(r, g, b),
        avg = (maximum + minimum) / 2
    var h: Double = avg,
        s: Double = avg,
        l: Double = avg

    if minimum != maximum {
      let d = maximum - minimum
      s = l > 0.5 ?
        d / (2 - maximum - minimum) :
        d / (maximum + minimum)
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
    } else {
      h = 0; s = 0
    }
    return [h, s, l, alpha]
  }

  var webComponents: [Int] {
    rgbComponents.map(\.toWeb)
  }

  var hexComponents: [String] {
    webComponents.map {
      String(format: "%2X", $0).replacingOccurrences(of: " ", with: "0")
    }
  }

  func alpha(_ value: Double) -> Self {
    Self(red: red,
         green: green,
         blue: blue,
         alpha: value)
  }

  func transform(_ value: @escaping (Double) -> Double) -> Self {
    Self(
      red: value(red).squeezed,
      green: value(green).squeezed,
      blue: value(blue).squeezed,
      alpha: alpha
    )
  }

  var inverted: Self {
    transform { 1 - $0 }
  }

  func hue(_ value: Double) -> Self {
    Self(
      hue: value,
      saturation: saturation,
      brightness: brightness,
      alpha: alpha
    )
  }

  func saturation(_ value: Double) -> Self {
    Self(
      hue: hue,
      saturation: value,
      brightness: brightness,
      alpha: alpha
    )
  }

  func brightness(_ value: Double) -> Self {
    Self(
      hue: hue,
      saturation: saturation,
      brightness: value,
      alpha: alpha
    )
  }

  func luminosity(_ value: Double) -> Self {
    Self(hue: hue, saturation: saturation, luminosity: value, alpha: alpha)
  }

  func lighten(_ value: Double) -> Self {
    brightness(brightness - (value / 10)).alpha(alpha)
  }

  /// Darkness (0-10)
  func darken(_ value: Double) -> Self {
    brightness(brightness + (value / 10)).alpha(alpha)
  }

  var lightenedToAlpha: Self {
    guard alpha < 1 else { return self }
    return lighten(alpha)
  }

  var darkenedToAlpha: Self {
    guard alpha < 1 else { return self }
    return darken(alpha)
  }

  var isDark: Bool {
    brightness < 0.5
  }

  func isDark<C: ColorCodable>(with background: C) -> Bool {
    guard alpha < 1 else { return isDark }
    let projection =
      (red + green + blue - alpha) + (
        background.red + background.green + background.blue
      )
    return (projection / 2) < 1
  }

  static var black: Self { Self.white(0) }
  static var white: Self { Self.white(1) }
}
