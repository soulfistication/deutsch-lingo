import AppKit
import Foundation

let size: CGFloat = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()

let rect = NSRect(x: 0, y: 0, width: size, height: size)
NSColor(srgbRed: 0.345, green: 0.800, blue: 0.008, alpha: 1).setFill()
rect.fill()

func oval(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ color: NSColor) {
    color.setFill()
    NSBezierPath(ovalIn: NSRect(x: x, y: y, width: w, height: h)).fill()
}

// body
oval(170, 90, 684, 780, NSColor(srgbRed: 0.345, green: 0.800, blue: 0.008, alpha: 1))
NSColor(srgbRed: 0.220, green: 0.580, blue: 0.008, alpha: 0.45).setFill()
NSBezierPath(ovalIn: NSRect(x: 210, y: 70, width: 604, height: 160)).fill()

// belly
oval(330, 140, 364, 340, NSColor.white)

// face
oval(220, 390, 584, 390, NSColor.white)

// eyes
oval(300, 500, 170, 170, NSColor(srgbRed: 0.15, green: 0.15, blue: 0.16, alpha: 1))
oval(554, 500, 170, 170, NSColor(srgbRed: 0.15, green: 0.15, blue: 0.16, alpha: 1))
oval(318, 590, 55, 55, NSColor.white)
oval(572, 590, 55, 55, NSColor.white)

// beak
let beak = NSBezierPath()
beak.move(to: NSPoint(x: 512, y: 430))
beak.line(to: NSPoint(x: 572, y: 520))
beak.line(to: NSPoint(x: 452, y: 520))
beak.close()
NSColor(srgbRed: 1.0, green: 0.784, blue: 0.0, alpha: 1).setFill()
beak.fill()

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Failed to encode icon")
}

let out = CommandLine.arguments[1]
try png.write(to: URL(fileURLWithPath: out))
print("Wrote \(out)")
