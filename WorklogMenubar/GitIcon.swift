import AppKit

enum GitIcon {
    static func menubarImage() -> NSImage {
        let size = NSSize(width: 16, height: 16)
        let image = NSImage(size: size, flipped: false) { _ in
            NSColor.black.setStroke()
            NSColor.black.setFill()

            // Main vertical line (trunk)
            let trunk = NSBezierPath()
            trunk.lineWidth = 1.5
            trunk.lineCapStyle = .round
            trunk.move(to: NSPoint(x: 5.5, y: 2))
            trunk.line(to: NSPoint(x: 5.5, y: 14))
            trunk.stroke()

            // Branch curve
            let branch = NSBezierPath()
            branch.lineWidth = 1.5
            branch.lineCapStyle = .round
            branch.move(to: NSPoint(x: 5.5, y: 7))
            branch.curve(
                to: NSPoint(x: 12, y: 11.5),
                controlPoint1: NSPoint(x: 8, y: 7),
                controlPoint2: NSPoint(x: 12, y: 9)
            )
            branch.stroke()

            // Node circles
            let r: CGFloat = 1.8
            for center in [
                NSPoint(x: 5.5, y: 2),
                NSPoint(x: 5.5, y: 14),
                NSPoint(x: 12, y: 11.5),
            ] {
                NSBezierPath(ovalIn: NSRect(
                    x: center.x - r, y: center.y - r,
                    width: r * 2, height: r * 2
                )).fill()
            }

            return true
        }
        image.isTemplate = true
        return image
    }
}
