import SwiftUI

struct TrainingView: View {
    @StateObject private var api = SentinelAPI.shared
    @State private var realignLog = ""
    @State private var watchdogLog = ""
    @State private var autoRefresh = true

    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var isTrainerLive: Bool {
        api.processes?.processes.first(where: { $0.name.contains("realignment") })?.alive ?? false
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    metricsGrid
                    resourceBars
                    logSection
                }
                .padding()
            }
            .navigationTitle("Training")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await refreshAll() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(api.isLoading)
                }
            }
            .refreshable { await refreshAll() }
            .task { await refreshAll() }
            .onReceive(timer) { _ in
                guard autoRefresh else { return }
                Task { await refreshAll() }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SENTINEL PRIME")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    Text("Frankenstein Edition")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
                StatusBadge(
                    text: isTrainerLive ? "TRAINING LIVE" : "OFFLINE",
                    isLive: isTrainerLive
                )
            }
            if let update = api.lastUpdate {
                Text("Updated \(update, style: .relative) ago")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var metricsGrid: some View {
        let t = api.overview?.training
        let s = api.overview?.shards
        return LazyVGrid(columns: [
            GridItem(.flexible()), GridItem(.flexible())
        ], spacing: 12) {
            MetricCard(
                title: "Step",
                value: t?.currentStep.map { "\($0)" } ?? "\u{2014}",
                subtitle: "Target 5,000"
            )
            MetricCard(
                title: "Loss",
                value: t?.trainLoss.map { String(format: "%.4f", $0) } ?? "\u{2014}",
                subtitle: "Training loss"
            )
            MetricCard(
                title: "Throughput",
                value: t?.tokPerSec.map { String(format: "%.0f tok/s", $0) } ?? "\u{2014}",
                subtitle: "Effective batch 48"
            )
            MetricCard(
                title: "ETA",
                value: t?.etaHrs.map { String(format: "%.1f h", $0) } ?? "\u{2014}",
                subtitle: "Estimated remaining"
            )
            MetricCard(
                title: "Learning Rate",
                value: t?.lr.map { String(format: "%.2e", $0) } ?? "\u{2014}",
                subtitle: "Warmup schedule"
            )
            MetricCard(
                title: "Corpus",
                value: s?.tokensB.map { String(format: "%.1fB", $0) } ?? "\u{2014}",
                subtitle: "\(s?.categories ?? 0) categories"
            )
        }
    }

    private var resourceBars: some View {
        VStack(spacing: 12) {
            if let vram = api.system?.vram {
                UsageBar(
                    label: "VRAM",
                    used: vram.usedGb ?? 0,
                    total: vram.totalGb ?? 0,
                    pct: vram.pct ?? 0
                )
            }
            if let ram = api.system?.ram {
                UsageBar(
                    label: "RAM",
                    used: ram.usedGb ?? 0,
                    total: ram.totalGb ?? 0,
                    pct: ram.pct ?? 0
                )
            }
        }
    }

    private var logSection: some View {
        VStack(spacing: 12) {
            DisclosureGroup("Realignment Log") {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(realignLog.isEmpty ? "Loading..." : String(realignLog.suffix(3000)))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 200)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            DisclosureGroup("Watchdog Log") {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(watchdogLog.isEmpty ? "Loading..." : String(watchdogLog.suffix(2000)))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 150)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func refreshAll() async {
        await api.refresh()
        async let r = api.fetchLog(name: "realign_v2", lines: 80)
        async let w = api.fetchLog(name: "realign_watchdog", lines: 50)
        realignLog = await r
        watchdogLog = await w
    }
}
