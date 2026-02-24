import AppKit

enum GitIcon {
    static func menubarImage() -> NSImage {
        guard let image = NSImage(named: "MenubarIcon") else {
            return NSImage()
        }
        image.isTemplate = true
        return image
    }
}
