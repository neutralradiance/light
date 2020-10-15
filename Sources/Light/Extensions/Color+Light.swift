//
//  Color+Light.swift
//  
//
//  Created by neutralradiance on 9/6/20.
//

import SwiftUI

extension NativeColor: ColorRepresentable {
    public var light: Light {
        Light(fromComponents: [red, green, blue, alpha])
    }

    public var components: [CGFloat] {
        var red: CGFloat = 0,
            green: CGFloat = 0,
            blue: CGFloat = 0,
            alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue, alpha]
    }

    public var hsbComponents: [CGFloat] {
        var hue: CGFloat = 0,
            saturation: CGFloat = 0,
            brightness: CGFloat = 0,
            alpha: CGFloat = 0

        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return [hue, saturation, brightness, alpha]
    }
}

extension Color: ColorRepresentable {
    public init(red: CGFloat = 0,
                green: CGFloat = 0,
                blue: CGFloat = 0,
                alpha: CGFloat = 1.0) {
        self.init(.sRGB,
                  red: Double(red),
                  green: Double(green),
                  blue: Double(blue),
                  opacity: Double(alpha))
    }

    public var light: Light {
        self.nativeColor.light
    }

    public var nativeColor: NativeColor {
        return NativeColor(self)
    }

    public var components: [CGFloat] {
        self.nativeColor.components
    }

    public var hsbComponents: [CGFloat] {
        self.nativeColor.hsbComponents
    }
}
