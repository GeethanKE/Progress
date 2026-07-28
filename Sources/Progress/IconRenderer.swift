import AppKit

/// Renders a small pie-chart or progress-bar NSImage for the status item.
/// The image is marked as a *template* image, matching the native look of
/// system menu bar icons (like the battery or clock glyph): macOS auto-tints
/// it black/white/inverted depending on light mode, dark mode, and menu-open
/// state, using only the image's alpha channel.
enum IconRenderer {
    static func image(fraction: Double, style: ProgressStyle, size: CGFloat = 18) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()
        defer { image.unlockFocus() }

        let rect = NSRect(x: 1, y: 1, width: size - 2, height: size - 2)

        switch style {
        case .pie:
            // Faint full-circle track.
            let track = NSBezierPath(ovalIn: rect)
            NSColor.black.withAlphaComponent(0.35).setStroke()
            track.lineWidth = 1.2
            track.stroke()

            // Solid pie slice for the elapsed fraction, starting at 12 o'clock.
            let center = NSPoint(x: rect.midX, y: rect.midY)
            let radius = rect.width / 2
            let slice = NSBezierPath()
            slice.move(to: center)
            let startAngle: CGFloat = 90
            let endAngle = startAngle - CGFloat(fraction) * 360
            slice.appendArc(withCenter: center, radius: radius,
                             startAngle: startAngle, endAngle: endAngle, clockwise: true)
            slice.close()
            NSColor.black.setFill()
            slice.fill()

        case .bar:
            let barRect = NSRect(x: 0, y: size / 2 - 4, width: size, height: 8)
            let track = NSBezierPath(roundedRect: barRect, xRadius: 2, yRadius: 2)
            NSColor.black.withAlphaComponent(0.25).setFill()
            track.fill()

            let fillWidth = max(2, barRect.width * CGFloat(fraction))
            let fgRect = NSRect(x: barRect.minX, y: barRect.minY, width: fillWidth, height: barRect.height)
            let fg = NSBezierPath(roundedRect: fgRect, xRadius: 2, yRadius: 2)
            NSColor.black.setFill()
            fg.fill()
        }

        image.isTemplate = true
        return image
    }
}
