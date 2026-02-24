import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    private let refreshOptions: [(String, TimeInterval)] = [
        ("Off", 0),
        ("5 minutes", 300),
        ("15 minutes", 900),
        ("30 minutes", 1800),
    ]

    var body: some View {
        Form {
            Section("Scan Path") {
                HStack {
                    TextField("Path to scan", text: $appState.scanPath)
                        .textFieldStyle(.roundedBorder)

                    Button("Browse...") {
                        selectFolder()
                    }
                }
            }

            Section("Refresh") {
                Picker("Auto-refresh", selection: $appState.refreshInterval) {
                    ForEach(refreshOptions, id: \.1) { label, value in
                        Text(label).tag(value)
                    }
                }
                .onChange(of: appState.refreshInterval) {
                    appState.startAutoRefresh()
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 200)
    }

    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            appState.scanPath = url.path
            appState.refresh()
        }
    }
}
