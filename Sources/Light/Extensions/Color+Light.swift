//
//  Color+Light.swift
//  
//
//  Created by neutralradiance on 9/6/20.
//

import SwiftUI

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
            .getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        #elseif os(iOS)
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        #endif
        
        return [hue, saturation, brightness, alpha]
    }
}

extension CGColorSpace {
    fileprivate var swiftUIColorSpace: Color.RGBColorSpace {
        guard let name = name else { return .sRGB }
        switch name as String {
            case "displayP3": return .displayP3
            case "sRGB": return .sRGB
            case "sRGBLinear": return .sRGBLinear
            default:
                return .sRGB
        }
    }
}
extension Color {
    public init(_ light: Light) {
        self.init(.sRGB,
                  red: Double(light.red),
                  green: Double(light.green),
                  blue: Double(light.blue),
                  opacity: Double(light.alpha))
    }
}
@available(iOS 13.0, macOS 10.15, *)
extension Color {
//        public init(_ nativeColor: NativeColor) {
//            self.init(.sRGB,
//                      red: Double(nativeColor.red),
//                      green: Double(nativeColor.green),
//                      blue: Double(nativeColor.blue),
//                      opacity: Double(nativeColor.alpha))
//        }
    public init(_ cgColor: CGColor) {
        self = {
            switch cgColor.numberOfComponents {
                case 2:
                    return Color(.sRGB, white: Double(cgColor.components?[0] ?? 0), opacity: Double(cgColor.alpha))
                case 3:
                    return Color(cgColor.colorSpace?.swiftUIColorSpace ?? .sRGB,
                                     red: Double(cgColor.components?[0] ?? 0),
                                     green: Double(cgColor.components?[1] ?? 0),
                                     blue: Double(cgColor.components?[2] ?? 0),
                                     opacity: 0)
                default:
                    return Color(cgColor.colorSpace?.swiftUIColorSpace ?? .sRGB,
                                     red: Double(cgColor.components?[0] ?? 0),
                                     green: Double(cgColor.components?[1] ?? 0),
                                     blue: Double(cgColor.components?[2] ?? 0),
                                     opacity: Double(cgColor.components?[3] ?? 0))

            }

        }()
    }
}
//@available(iOS 14.0, *)
//extension Color: ColorCodable {
//    @available(iOS 14.0, *)
//    public init(red: CGFloat = 0,
//                green: CGFloat = 0,
//                blue: CGFloat = 0,
//                alpha: CGFloat = 1.0) {
//        self.init(.sRGB,
//                  red: Double(red),
//                  green: Double(green),
//                  blue: Double(blue),
//                  opacity: Double(alpha))
//    }
//
//    public var light: Light {
//        self.nativeColor.light
//    }
//
//    public var nativeColor: NativeColor {
//        return NativeColor(self)
//    }
//    @available(iOS 14.0, *)
//    public var components: [CGFloat] {
//        self.nativeColor.components
//    }
//    @available(iOS 14.0, *)
//    public var hsbComponents: [CGFloat] {
//        self.nativeColor.hsbComponents
//    }
//}
