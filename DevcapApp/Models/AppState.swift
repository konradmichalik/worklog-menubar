import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var projects: [ProjectLog] = []
    @Published var isLoading = false
    @Published var lastRefresh: Date?
    @Published var allExpanded = true
    @Published var expansionID = UUID()

    @AppStorage("scanPath") var scanPath = ""
    @AppStorage("period") var period = "today"
    @AppStorage("refreshInterval") var refreshInterval: TimeInterval = 900 // 15 min
    @AppStorage("menubarBadge") var menubarBadge = "none"
    @AppStorage("coloredCommitTypes") var coloredCommitTypes = true
    @AppStorage("showOriginIcons") var showOriginIcons = true
    @AppStorage("showDiffStats") var showDiffStats = true
    @AppStorage("sortOrder") var sortOrder = "time"

    /// Bridged from @Environment(\.openSettings) via MenubarView.onAppear,
    /// because the AppDelegate has no access to SwiftUI scene environments.
    var openSettingsAction: (() -> Void)?

    private var timer: AnyCancellable?

    var totalCommits: Int {
        projects.reduce(0) { $0 + $1.totalCommits }
    }

    var totalBranches: Int {
        projects.reduce(0) { $0 + $1.branches.count }
    }

    var badgeCount: Int? {
        switch menubarBadge {
        case "projects": return projects.isEmpty ? nil : projects.count
        case "branches": return totalBranches == 0 ? nil : totalBranches
        case "commits": return totalCommits == 0 ? nil : totalCommits
        default: return nil
        }
    }

    func toggleExpansion() {
        allExpanded.toggle()
        expansionID = UUID()
    }

    init() {
        if scanPath.isEmpty {
            scanPath = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Sites")
                .path
        }
        Task { [weak self] in
            self?.refresh()
            self?.startAutoRefresh()
        }
    }

    func refresh() {
        guard !scanPath.isEmpty else { return }
        isLoading = true
        Task.detached { [scanPath, period] in
            let results = DevcapBridge.scan(path: scanPath, period: period, author: nil)
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.projects = self.sorted(results)
                self.isLoading = false
                self.lastRefresh = Date()
            }
        }
    }

    func applySort() {
        projects = sorted(projects)
    }

    private func sorted(_ items: [ProjectLog]) -> [ProjectLog] {
        switch sortOrder {
        case "name":
            return items.sorted { $0.project.localizedCaseInsensitiveCompare($1.project) == .orderedAscending }
        case "commits":
            return items.sorted { $0.totalCommits > $1.totalCommits }
        default:
            return items.sorted { ($0.latestTimestamp ?? "") > ($1.latestTimestamp ?? "") }
        }
    }

    func startAutoRefresh() {
        stopAutoRefresh()
        guard refreshInterval > 0 else { return }
        timer = Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refresh()
            }
    }

    func stopAutoRefresh() {
        timer?.cancel()
        timer = nil
    }
}
