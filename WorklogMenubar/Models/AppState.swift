import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var projects: [ProjectLog] = []
    @Published var isLoading = false
    @Published var lastRefresh: Date?

    @AppStorage("scanPath") var scanPath = ""
    @AppStorage("period") var period = "today"
    @AppStorage("refreshInterval") var refreshInterval: TimeInterval = 900 // 15 min

    private var timer: AnyCancellable?

    var totalCommits: Int {
        projects.reduce(0) { $0 + $1.totalCommits }
    }

    var badgeText: String {
        let count = totalCommits
        if count == 0 { return "" }
        if count > 99 { return "99+" }
        return "\(count)"
    }

    func refresh() {
        guard !scanPath.isEmpty else { return }
        isLoading = true
        Task.detached { [scanPath, period] in
            let results = WorklogBridge.scan(path: scanPath, period: period, author: nil)
            await MainActor.run { [weak self] in
                self?.projects = results
                self?.isLoading = false
                self?.lastRefresh = Date()
            }
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

import SwiftUI

extension AppState {
    func initializeIfNeeded() {
        if scanPath.isEmpty {
            scanPath = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Sites")
                .path
        }
        refresh()
        startAutoRefresh()
    }
}
