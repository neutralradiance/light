//
//  File.swift
//  
//
//  Created by neutralradiance on 9/6/20.
//

import SwiftUI
#if canImport(UIKit)
import UIKit.UIColor
public typealias NativeColor = UIColor
#elseif canImport(AppKit)
import AppKit.NSColor
public typealias NativeColor = NSColor
#endif

internal var floatRange: ClosedRange<CGFloat> { 0...1 }
internal var webRange: ClosedRange<Int> { 0...255 }
internal var roundValue: Int { 16 }

public protocol ColorRepresentable: Hashable,
                        ExpressibleByStringLiteral,
                        ExpressibleByArrayLiteral {
    var red: CGFloat { get }
    var green: CGFloat { get }
    var blue: CGFloat { get }
    var alpha: CGFloat { get }
    var hue: CGFloat { get }
    var saturation: CGFloat { get }
    var brightness: CGFloat { get }
    var hex: String { get }
    var components: [CGFloat] { get }
    var rgbComponents: [CGFloat] { get }
    var hsbComponents: [CGFloat] { get }
    var hslComponents: [CGFloat] { get }
    var webComponents: [Int] { get }
    var hexComponents: [String] { get }
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)
    init(hue: CGFloat, saturation: CGFloat, luminosity: CGFloat, alpha: CGFloat)
    init(red: Int, green: Int, blue: Int, alpha: CGFloat)
    init?(hex: String, alpha: CGFloat)
    init(fromComponents: [CGFloat?])
    init(fromComponents: RGBComponents)
}

extension ColorRepresentable {
    public typealias RGBComponents = (red: CGFloat?, green: CGFloat?, blue: CGFloat?, alpha: CGFloat?)

    public var red: CGFloat { components[0] }
    public var green: CGFloat { components[1] }
    public var blue: CGFloat { components[2] }
    public var alpha: CGFloat { components[3] }
    public var hue: CGFloat { hsbComponents[0] }
    public var saturation: CGFloat { hsbComponents[1] }
    public var brightness: CGFloat { hsbComponents[2] }
    public var luminosity: CGFloat { hslComponents[2] }
    public var hex: String { hexComponents.joined() }
    public var rgbComponents: [CGFloat] { [red, green, blue] }

    public static func ==<C: ColorRepresentable>(lhs: Self, rhs: C) -> Bool {
        lhs.components == rhs.components
    }

    public init(stringLiteral value: StaticString) {
        self.init(hex: value.description)!
    }

    public init(arrayLiteral elements: CGFloat...) {
        self.init(fromComponents: elements)
    }

    public init() {
        self.init(red: 0, green: 0, blue: 0, alpha: 0)
    }

    public init(hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat, alpha: CGFloat = 1) {
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
    public init(hue: CGFloat = 0, saturation: CGFloat = 0, luminosity: CGFloat, alpha: CGFloat = 1) {
        let h = hue,
        s = saturation,
        l = luminosity
        var r: CGFloat = 0,
            g: CGFloat = 0,
            b: CGFloat = 0
        if s == 0 {
            r = l
            g = l
            b = l
        } else {
            func hue2rgb(_ p: CGFloat, _ q: CGFloat, _ t: CGFloat) -> CGFloat {
                let t = t.squeezed
                switch t {
                case 0...(1/6): return p + (q - p) * 6 * t
                case 0...(1/2): return q
                case 0...(2/3): return p + (q - p) * (2 / 3 - t) * 6
                default: return p
                }
            }
            let q = l < 0.5 ? l * (1 + s) : l + s - l * s
            let p = 2 * l - q
            r = hue2rgb(p, q, h + 1 / 3 - 0.0000000000000003).squeezed
            g = (hue2rgb(p, q, h) + 0.0000000000000003).squeezed
            b = hue2rgb(p, q, h - 1 / 3 + 0.0000000000000003).squeezed
        }
        self.init(red: r.rounded, green: g.rounded, blue: b.rounded, alpha: alpha.rounded)
    }

    public init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
        self.init(red: red.fromWeb,
                  green: green.fromWeb,
                  blue: blue.fromWeb,
                  alpha: alpha)
    }

    public init?(hex: String, alpha: CGFloat = 1) {
        var hexValue = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        if hexValue.count == 3 {
            for (index, char) in hexValue.enumerated() {
              hexValue.insert(char, at: hexValue.index(hexValue.startIndex, offsetBy: index * 2))
            }
        }
        guard hexValue.count == 6, let intCode = Int(hexValue, radix: 16) else { return nil }
        self.init(red: (intCode >> 16) & 0xFF,
                  green: (intCode >> 8) & 0xFF,
                  blue: intCode & 0xFF,
                  alpha: alpha)
    }

    public init(fromComponents components: [CGFloat?]) {
        self.init(red: components[0] ?? 0,
                  green: components[1] ?? 0,
                  blue: components[2] ?? 0,
                  alpha: components[3] ?? 1)
    }

    public init(fromComponents components: RGBComponents) {
        self.init(red: components.red ?? 0,
                  green: components.green ?? 0,
                  blue: components.blue ?? 0,
                  alpha: components.alpha ?? 1)
    }

    // Calculate hue separately?
    public var hslComponents: [CGFloat] {
        let r = red, g = green, b = blue
        let maximum = max(r, g, b), minimum = min(r, g, b), avg = (maximum + minimum) / 2
        var h: CGFloat = avg,
            s: CGFloat = avg,
            l: CGFloat = avg

        if minimum != maximum {
            let d = maximum - minimum
            s = l > 0.5 ? d / (2 - maximum - minimum) : d / (maximum + minimum)
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

    public var webComponents: [Int] {
        rgbComponents.map { $0.toWeb }
    }

    public var hexComponents: [String] {
        webComponents.map {
            String(format: "%2X", $0).replacingOccurrences(of: " ", with: "0")
        }
    }

    public func opacity(_ value: CGFloat) -> Self {
         Self(red: red,
              green: green,
              blue: blue,
              alpha: value)
    }

    public func transform(_ value: @escaping (CGFloat) -> CGFloat) -> Self {
        Self(red: value(red).squeezed,
             green: value(green).squeezed,
             blue: value(blue).squeezed,
             alpha: alpha)
    }

//    public func saturation(_ value: CGFloat) -> Self {
//        transform(alpha: alpha) { $0 * value }
//    }

    public func lighten(_ value: CGFloat) -> Self {
        transform { ($0*(value+1)).squeezed }
    }
    public func darken(_ value: CGFloat) -> Self {
        transform { (($0/10)/value).squeezed }
    }
    public var lightenedToAlpha: Self {
        lighten((1-alpha)).opacity(1)
    }
    public var darkenedToAlpha: Self {
        darken((1-alpha)).opacity(1)
    }
}

internal extension ClosedRange {
    func squeeze(_ value: Bound) -> Bound {
        self.contains(value) ? value :
            value > upperBound ? upperBound : lowerBound
    }
}

internal extension CGFloat {
    func roundTo(to decimals: Int) -> Self {
        let divisor = pow(10.0, Self(decimals))
        return (self * divisor).rounded() / divisor
    }
    var rounded: Self { self.roundTo(to: roundValue) }
    var squeezed: Self { floatRange.squeeze(self) }
    var toWeb: Int { Int(self * 255) }
}

internal extension Int {
    var squeezed: Int { webRange.squeeze(self) }
    var fromWeb: CGFloat { (CGFloat(self.squeezed) / 255).rounded }
}
