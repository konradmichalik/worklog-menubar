import SwiftUI

// MARK: - Project

struct ProjectSection: View {
    let project: ProjectLog
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            projectHeader
            if isExpanded {
                ForEach(project.branches) { branch in
                    BranchSection(branch: branch)
                }
            }
        }
    }

    private var projectHeader: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tertiary)
                    .frame(width: 8)

                Text(project.project)
                    .font(.system(.body, design: .monospaced, weight: .semibold))

                Spacer()

                CountBadge(count: project.totalCommits)

                if let latest = project.latestActivity {
                    Text(latest)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Branch

private struct BranchSection: View {
    let branch: BranchLog
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            branchHeader
            if isExpanded {
                ForEach(branch.commits) { commit in
                    CommitRow(commit: commit)
                }
            }
        }
    }

    private var branchHeader: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundStyle(.quaternary)
                    .frame(width: 8)

                Image(systemName: "arrow.triangle.branch")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(branch.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                CountBadge(count: branch.commits.count, small: true)

                if let latest = branch.latestActivity {
                    Text(latest)
                        .font(.caption2)
                        .foregroundStyle(.quaternary)
                }
            }
            .padding(.leading, 28)
            .padding(.trailing, 14)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Commit

private struct CommitRow: View {
    let commit: Commit
    @State private var isHovered = false

    var body: some View {
        Button {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(commit.hash, forType: .string)
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                commitTypeTag

                Text(commit.displayMessage)
                    .font(.caption)
                    .lineLimit(2)

                Spacer()

                Text(String(commit.hash.prefix(7)))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.quaternary)

                Text(commit.relativeTime)
                    .font(.caption2)
                    .foregroundStyle(.quaternary)
                    .frame(width: 48, alignment: .trailing)
            }
            .padding(.leading, 44)
            .padding(.trailing, 14)
            .padding(.vertical, 3)
            .background(isHovered ? Color.primary.opacity(0.04) : .clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }

    @ViewBuilder
    private var commitTypeTag: some View {
        if let type = commit.commitType {
            Text(type)
                .font(.system(.caption2, design: .monospaced, weight: .medium))
                .foregroundStyle(colorForType(type))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(colorForType(type).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .frame(minWidth: 48, alignment: .trailing)
        } else {
            Color.clear.frame(width: 48)
        }
    }

    private func colorForType(_ type: String) -> Color {
        switch type {
        case "feat": .green
        case "fix": .red
        case "refactor": .cyan
        case "docs": .blue
        case "test": .orange
        case "style": .purple
        case "chore", "ci", "perf", "build": .secondary
        default: .primary
        }
    }
}

// MARK: - Count Badge

struct CountBadge: View {
    let count: Int
    var small: Bool = false

    var body: some View {
        Text("\(count)")
            .font(small
                ? .system(.caption2, design: .rounded)
                : .system(.caption, design: .rounded, weight: .medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, small ? 4 : 6)
            .padding(.vertical, small ? 1 : 2)
            .background(.fill.quaternary)
            .clipShape(Capsule())
    }
}
