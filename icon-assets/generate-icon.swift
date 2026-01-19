import AppKit
import SwiftUI

let sizes = [16, 32, 64, 128, 256, 512, 1024]

for size in sizes {
    let image = NSImage(systemSymbolName: "eye.fill", accessibilityDescription: nil)!
    let config = NSImage.SymbolConfiguration(pointSize: CGFloat(size), weight: .regular, scale: .large)
    let configuredImage = image.withSymbolConfiguration(config)!
    
    let renderer = NSImage(size: NSSize(width: size, height: size))
    renderer.lockFocus()
    
    // Draw background circle
    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let path = NSBezierPath(ovalIn: rect)
    NSColor.systemBlue.setFill()
    path.fill()
    
    // Draw the eye icon
    configuredImage.draw(
        in: rect.insetBy(dx: size * 0.15, dy: size * 0.15),
        from: NSRect.zero,
        operation: .sourceOver,
        fraction: 1.0
    )
    
    renderer.unlockFocus()
    
    // Save as PNG
    if let tiffData = renderer.tiffRepresentation,
       let bitmapImage = NSBitmapImageRep(data: tiffData),
       let pngData = bitmapImage.representation(using: .png, properties: [:]) {
        let filename = size == 1024 ? "icon_512x512@2x.png" : 
                      size == 512 ? "icon_512x512.png" :
                      size == 256 ? "icon_256x256@2x.png" :
                      size == 128 ? "icon_128x128@2x.png" :
                      size == 64 ? "icon_32x32@2x.png" :
                      size == 32 ? "icon_32x32.png" :
                      "icon_16x16@2x.png"
        try? pngData.write(to: URL(fileURLWithPath: "icon-assets.iconset/\(filename)"))
    }
    
    // Also create @1x versions for smaller sizes
    if size <= 256 {
        let halfSize = size / 2
        let smallImage = NSImage(systemSymbolName: "eye.fill", accessibilityDescription: nil)!
        let smallConfig = NSImage.SymbolConfiguration(pointSize: CGFloat(halfSize), weight: .regular, scale: .large)
        let smallConfiguredImage = smallImage.withSymbolConfiguration(smallConfig)!
        
        let smallRenderer = NSImage(size: NSSize(width: halfSize, height: halfSize))
        smallRenderer.lockFocus()
        
        let smallRect = NSRect(x: 0, y: 0, width: halfSize, height: halfSize)
        let smallPath = NSBezierPath(ovalIn: smallRect)
        NSColor.systemBlue.setFill()
        smallPath.fill()
        
        smallConfiguredImage.draw(
            in: smallRect.insetBy(dx: halfSize * 0.15, dy: halfSize * 0.15),
            from: NSRect.zero,
            operation: .sourceOver,
            fraction: 1.0
        )
        
        smallRenderer.unlockFocus()
        
        if let tiffData = smallRenderer.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapImage.representation(using: .png, properties: [:]) {
            let filename = halfSize == 256 ? "icon_256x256.png" :
                          halfSize == 128 ? "icon_128x128.png" :
                          halfSize == 64 ? "icon_64x64.png" :
                          halfSize == 32 ? "icon_32x32.png" :
                          "icon_16x16.png"
            try? pngData.write(to: URL(fileURLWithPath: "icon-assets.iconset/\(filename)"))
        }
    }
}

print("Icon images generated successfully!")
