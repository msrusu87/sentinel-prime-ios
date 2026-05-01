import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    var color: Color = .green

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct UsageBar: View {
    let label: String
    let used: Double
    let total: Double
    let pct: Double

    var barColor: Color {
        if pct >= 97 { return .red }
        if pct >= 90 { return .orange }
        return .green
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.1f / %.1f GB (%.0f%%)", used, total, pct))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.quaternary)
                    Capsule()
                        .fill(barColor.gradient)
                        .frame(width: geo.size.width * min(pct / 100, 1))
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct StatusBadge: View {
    let text: String
    let isLive: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isLive ? .green : .red)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.caption)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            (isLive ? Color.green : Color.red).opacity(0.15),
            in: Capsule()
        )
    }
}
