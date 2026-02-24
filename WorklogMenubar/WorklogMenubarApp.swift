import SwiftUI

@main
struct WorklogMenubarApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenubarView()
                .environmentObject(appState)
        } label: {
            Label {
                Text("Worklog")
            } icon: {
                Image(systemName: "clock.arrow.circlepath")
            }
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}
