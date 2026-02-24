import SwiftUI

struct MenubarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()

            if appState.isLoading && appState.projects.isEmpty {
                loadingView
            } else if appState.projects.isEmpty {
                emptyView
            } else {
                projectList
            }

            Divider()
            footer
        }
        .frame(width: 380)
        .onAppear {
            appState.initializeIfNeeded()
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Worklog")
                    .font(.headline)
                if let lastRefresh = appState.lastRefresh {
                    Text("Updated \(lastRefresh, style: .relative) ago")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            PeriodPicker(selection: $appState.period)
                .onChange(of: appState.period) {
                    appState.refresh()
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var projectList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(appState.projects) { project in
                    ProjectRow(project: project)
                }
            }
        }
        .frame(maxHeight: 400)
    }

    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .controlSize(.small)
            Text("Scanning...")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(height: 80)
    }

    private var emptyView: some View {
        VStack(spacing: 6) {
            Image(systemName: "tray")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No commits found")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
    }

    private var footer: some View {
        HStack {
            Button {
                appState.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
            .disabled(appState.isLoading)

            Spacer()

            Text("\(appState.totalCommits) commits")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            SettingsLink {
                Image(systemName: "gear")
            }
            .buttonStyle(.borderless)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct PeriodPicker: View {
    @Binding var selection: String

    private let options = [
        ("today", "Today"),
        ("yesterday", "Yesterday"),
        ("week", "Week"),
        ("7d", "7 days"),
    ]

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(options, id: \.0) { value, label in
                Text(label).tag(value)
            }
        }
        .pickerStyle(.menu)
        .frame(width: 100)
    }
}
