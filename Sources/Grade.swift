//
//  Grade.swift
//  Grade
//
//  Created by Yannick Heinrich on 04.09.18.
//  Copyright © 2018 Yannick Heinrich. All rights reserved.
//

import CoreGraphics

#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit
    public typealias Color = UIColor
#elseif os(macOS)
    import Cocoa
    public typealias Color = NSColor
#endif


fileprivate struct RGBA: Equatable, Hashable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    let alpha: UInt8

    func toColor() -> Color {
        return Color(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
    }
}

fileprivate struct Brightness: Equatable, Hashable {
    let rgba: RGBA
    let brightness: CGFloat
    init(rgba: RGBA) {
        self.rgba = rgba
        self.brightness = (CGFloat(rgba.red) * 299.0 + CGFloat(rgba.green) * 587.0 + CGFloat(rgba.blue) * 114.0) / 1000;
    }
}

#if os(iOS) || os(watchOS) || os(tvOS)
/// Get the gradients colors from the provided image
///
/// - Parameter img: The image to get the colors from
/// - Returns: Both start and end colors to use for the gradients
public func GradeColors(forImage img: UIImage) -> (Color, Color) {
    return GradeColors(forCGImage: img.cgImage!)
}
#endif

/// Get the gradients colors from the provided image
///
/// - Parameter img: The image to get the colors from
/// - Returns: Both start and end colors to use for the gradients
public func GradeColors(forCGImage img: CGImage) -> (Color, Color)  {

    let bytesPerPixels = 4
    let bytesPerRow = img.width*bytesPerPixels
    let bufSize = img.width*img.height
    var buff = calloc(bufSize, bytesPerPixels)!
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let callback: CGBitmapContextReleaseDataCallback = { (data, _) in
        free(data)
    }

    let ctx = CGContext(data: buff, width: img.width, height: img.height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue, releaseCallback:callback, releaseInfo: nil)!
    ctx.draw(img, in: CGRect(origin: .zero, size: CGSize(width: img.width, height: img.height)))

    var pixelsValues: [Int: [UInt8]] = [:]
    for index in 0..<bufSize {
        let val = buff.load(as: UInt8.self)
        let ix = Int(floor(CGFloat(index)/CGFloat(bytesPerPixels)))
        if pixelsValues[ix] == nil {
            pixelsValues[ix] = [UInt8]()
        }
        pixelsValues[ix]?.append(val)
        buff += 1
    }
    let colors = pixelsValues.filter { validatePixel($0.value) }.map { RGBA(red: $0.value[0], green: $0.value[1], blue: $0.value[2], alpha: $0.value[3]) }

    var uniqValues: [RGBA: UInt] = [:]
    for color in colors {
        if let iter: UInt = uniqValues[color] {
            uniqValues[color] = iter + 1
        } else {
            uniqValues[color] = 1
        }
    }

    let sortedValues = uniqValues.sorted { $0.value > $1.value }[0..<10]
    let brightness = sortedValues.map { Brightness(rgba: $0.key) }
    let sorted = brightness.sorted { $0.brightness > $1.brightness }

    let begin = sorted[0]
    let last = sorted[sorted.count - 1]
    return (begin.rgba.toColor(), last.rgba.toColor())
}

private func validatePixel(_ pixel: [UInt8]) -> Bool {
    return pixel[0] > 0 && pixel[0] < 250 && pixel[1] > 0 && pixel[1] < 250
}

