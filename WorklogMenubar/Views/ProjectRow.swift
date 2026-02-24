import SwiftUI

struct ProjectRow: View {
    let project: ProjectLog
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .frame(width: 10)

                    Text(project.project)
                        .font(.system(.body, design: .monospaced, weight: .semibold))

                    Spacer()

                    Text("\(project.totalCommits)")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary)
                        .clipShape(Capsule())

                    if let latest = project.latestActivity {
                        Text(latest)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                ForEach(project.branches) { branch in
                    BranchSection(branch: branch)
                }
            }
        }
    }
}

struct BranchSection: View {
    let branch: BranchLog

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(branch.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 32)
            .padding(.vertical, 3)

            ForEach(branch.commits) { commit in
                CommitRow(commit: commit)
            }
        }
    }
}
