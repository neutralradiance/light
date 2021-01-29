//
//  Color+Light.swift
//
//
//  Created by neutralradiance on 9/6/20.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension NativeColor: ColorCodable {
	public var light: Light {
		Light(fromComponents: [red, green, blue, alpha])
	}

	public var components: [CGFloat] {
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

		return [red, green, blue, alpha]
	}

	public var hsbComponents: [CGFloat] {
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

		return [hue, saturation, brightness, alpha]
	}
}

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, *, iOS 13.0, *)
public extension Color {
	init(_ light: Light) {
		self.init(.sRGB,
		          red: Double(light.red),
		          green: Double(light.green),
		          blue: Double(light.blue),
		          opacity: Double(light.alpha))
	}
}
#endif
