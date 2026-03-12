import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var eventMonitor: Any?
    weak var appState: AppState?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Detect right-clicks on the MenuBarExtra status item.
        // Uses private window class name — no public API exists for this.
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.rightMouseUp]) { [weak self] event in
            guard let window = event.window,
                  String(describing: type(of: window)).contains("StatusBar") else {
                return event
            }
            self?.showContextMenu(with: event)
            return nil
        }
    }

    private func showContextMenu(with event: NSEvent) {
        let menu = NSMenu()

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit devcap", action: #selector(quitApp), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)

        if let contentView = event.window?.contentView {
            NSMenu.popUpContextMenu(menu, with: event, for: contentView)
        }
    }

    @objc private func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        appState?.openSettingsAction?()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}

@main
struct DevcapApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenubarView()
                .environmentObject(appState)
                .task { appDelegate.appState = appState }
        } label: {
            Image("MenubarIcon")
            if let count = appState.badgeCount {
                Text("\(count)")
            }
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}
