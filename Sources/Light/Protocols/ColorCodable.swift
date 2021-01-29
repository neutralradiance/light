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

internal var floatRange: ClosedRange<CGFloat> { 0 ... 1 }
internal var webRange: ClosedRange<Int> { 0 ... 255 }
internal var roundValue: Int { 16 }

public protocol ColorCodable: Codable,
	Identifiable,
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
	init(fromComponents: [CGFloat])
	init(fromComponents: RGBComponents)
}

enum ColorCodingKeys: CodingKey {
	case red, blue, green, alpha
}

infix operator ~: MultiplicationPrecedence
public extension ColorCodable {
	typealias RGBComponents = (
		red: CGFloat?, green: CGFloat?,
		blue: CGFloat?,
		alpha: CGFloat?
	)
	var id: UUID {
		UUID() // Int(components.map{ $0.toWeb }.map{ String(Int($0)) }.joined())!
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: ColorCodingKeys.self)
		let red = try container.decode(CGFloat.self, forKey: .red)
		let green = try container.decode(CGFloat.self, forKey: .green)
		let blue = try container.decode(CGFloat.self, forKey: .blue)
		let alpha = try container.decode(CGFloat.self, forKey: .alpha)
		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: ColorCodingKeys.self)
		try container.encode(red, forKey: .red)
		try container.encode(green, forKey: .green)
		try container.encode(blue, forKey: .blue)
		try container.encode(alpha, forKey: .alpha)
	}

	var red: CGFloat { components[0] }
	var green: CGFloat { components[1] }
	var blue: CGFloat { components[2] }
	var alpha: CGFloat { components[3] }
	var hue: CGFloat { hsbComponents[0] }
	var saturation: CGFloat { hsbComponents[1] }
	var brightness: CGFloat { hsbComponents[2] }
	var luminosity: CGFloat { hslComponents[2] }
	var hex: String { hexComponents.joined() }
	var rgbComponents: [CGFloat] { [red, green, blue] }
	var nativeColor: NativeColor {
		NativeColor(red: red,
		            green: green,
		            blue: blue,
		            alpha: alpha)
	}

	static func == <C: ColorCodable>(lhs: Self, rhs: C) -> Bool {
		lhs.components == rhs.components
	}

	func compare<C: ColorCodable>(
		_ new: C,
		_ comparison:
		@escaping (_ lhs: CGFloat, _ rhs: CGFloat) -> CGFloat
	) -> [CGFloat] {
		components.map { lhs -> CGFloat in
			var comp: CGFloat!
			new.components.forEach { rhs in
				comp = comparison(lhs, rhs)
			}
			return comp
		}
	}

	func blendColor<C: ColorCodable>(
		_ color: C,
		_ midpoint: CGFloat = 0.5
	) -> Self {
		Self(fromComponents:
			compare(color) { lhs, rhs -> CGFloat in
				(1 - midpoint) * pow(lhs, 2) + midpoint * pow(rhs, 2)
			} + [(1 - midpoint) * alpha + midpoint * color.alpha]
		)
	}

	//    /// Color blending
	static func + <C: ColorCodable>(lhs: Self, rhs: C) -> Self {
		Self(fromComponents:
			lhs.compare(rhs) { lhs, rhs -> CGFloat in
				(lhs + rhs) / 2
			} + [(lhs.alpha + rhs.alpha) / 2]
		)
	}

	static func - <C: ColorCodable>(lhs: Self, rhs: C) -> Self {
		Self(fromComponents:
			lhs.compare(rhs) { lhs, rhs -> CGFloat in
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

	init(arrayLiteral elements: CGFloat...) {
		self.init(fromComponents: elements)
	}

	init() {
		self.init(red: 0, green: 0, blue: 0, alpha: 0)
	}

	init(
		hue: CGFloat = 0,
		saturation: CGFloat = 0,
		brightness: CGFloat,
		alpha: CGFloat = 1
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
		hue: CGFloat = 0,
		saturation: CGFloat = 0,
		luminosity: CGFloat,
		alpha: CGFloat = 1
	) {
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

	init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
		self.init(red: red.fromWeb,
		          green: green.fromWeb,
		          blue: blue.fromWeb,
		          alpha: alpha)
	}

	static func white(
		_ value: CGFloat,
		withAlpha alpha: CGFloat = 1
	) -> Self {
		Self(red: value, green: value, blue: value, alpha: alpha)
	}

	init?(hex: String, alpha: CGFloat = 1) {
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

	init(fromComponents components: [CGFloat]) {
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

	var hslComponents: [CGFloat] {
		let r = red, g = green, b = blue
		let maximum = max(r, g, b),
		    minimum = min(r, g, b),
		    avg = (maximum + minimum) / 2
		var h: CGFloat = avg,
		    s: CGFloat = avg,
		    l: CGFloat = avg

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

	func alpha(_ value: CGFloat) -> Self {
		Self(red: red,
		     green: green,
		     blue: blue,
		     alpha: value)
	}

	func transform(_ value: @escaping (CGFloat) -> CGFloat) -> Self {
		Self(red: value(red).squeezed,
		     green: value(green).squeezed,
		     blue: value(blue).squeezed,
		     alpha: alpha)
	}

	var inverted: Self {
		transform { 1 - $0 }
	}

	func hue(_ value: CGFloat) -> Self {
		Self(hue: value, saturation: saturation, brightness: brightness, alpha: alpha)
	}

	func saturation(_ value: CGFloat) -> Self {
		Self(hue: hue, saturation: value, brightness: brightness, alpha: alpha)
	}

	func brightness(_ value: CGFloat) -> Self {
		Self(hue: hue, saturation: saturation, brightness: value, alpha: alpha)
	}

	func luminosity(_ value: CGFloat) -> Self {
		Self(hue: hue, saturation: saturation, luminosity: value, alpha: alpha)
	}

	func lighten(_ value: CGFloat) -> Self {
		brightness(brightness - (value / 10)).alpha(alpha)
	}

	/// Darkness (0-10)
	func darken(_ value: CGFloat) -> Self {
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

internal extension ClosedRange {
	func squeeze(_ value: Bound) -> Bound {
		contains(value) ?
			value : value > upperBound ?
			upperBound :
			lowerBound
	}
}

internal extension CGFloat {
	func roundTo(to decimals: Int) -> Self {
		let divisor = pow(10.0, Self(decimals))
		return (self * divisor).rounded() / divisor
	}

	var rounded: Self { roundTo(to: roundValue) }
	var squeezed: Self { floatRange.squeeze(self) }
	var toWeb: Int { Int(self * 255) }
}

internal extension Int {
	var squeezed: Int { webRange.squeeze(self) }
	var fromWeb: CGFloat { (CGFloat(squeezed) / 255).rounded }
}

extension Comparable {
	func clamp(_ lhs: Self, _ rhs: Self) -> Self {
		min(max(self, lhs), rhs)
	}
}
