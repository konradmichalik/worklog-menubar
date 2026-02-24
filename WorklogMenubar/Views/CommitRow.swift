import SwiftUI

struct CommitRow: View {
    let commit: Commit

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            commitTypeTag

            VStack(alignment: .leading, spacing: 1) {
                Text(commit.displayMessage)
                    .font(.caption)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Text(commit.hash)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.tertiary)

                    Text(commit.relativeTime)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .padding(.leading, 40)
        .padding(.trailing, 12)
        .padding(.vertical, 3)
    }

    @ViewBuilder
    private var commitTypeTag: some View {
        if let type = commit.commitType {
            Text(type)
                .font(.system(.caption2, design: .monospaced, weight: .medium))
                .foregroundStyle(colorForType(type))
                .frame(width: 44, alignment: .trailing)
        } else {
            Color.clear.frame(width: 44)
        }
    }

    private func colorForType(_ type: String) -> Color {
        switch type {
        case "feat": .green
        case "fix": .red
        case "refactor": .cyan
        case "docs": .blue
        case "test", "style": .yellow
        case "chore", "ci", "perf", "build": .secondary
        default: .primary
        }
    }
}
