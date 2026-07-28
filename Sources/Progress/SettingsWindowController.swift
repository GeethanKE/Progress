import AppKit
import SwiftUI

final class SettingsWindowController: NSWindowController {
    convenience init(store: ProgressStore) {
        let hosting = NSHostingController(rootView: SettingsView().environmentObject(store))
        let window = NSWindow(contentViewController: hosting)
        window.title = "Progress Settings"
        window.styleMask = [.titled, .closable]
        window.setContentSize(NSSize(width: 300, height: 240))
        window.center()
        window.isReleasedWhenClosed = false
        self.init(window: window)
    }
}
