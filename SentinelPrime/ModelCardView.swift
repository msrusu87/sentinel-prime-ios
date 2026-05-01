import SwiftUI

struct ModelCardView: View {
    private let facts: [(String, String)] = [
        ("Model", "Sentinel Prime (Frankenstein Edition)"),
        ("Parameters", "14.4B (Mixture-of-Experts)"),
        ("Architecture", "24 layers, 4096 hidden, 32 Q heads, 8 KV heads"),
        ("Experts", "4 FFN experts, top-2 routing"),
        ("Tokenizer", "cl100k_base, vocab 100,277"),
        ("Hardware", "AMD Instinct MI300X, 205.8 GB VRAM"),
        ("Phase", "Text coherence repair / realignment"),
        ("Seq Length", "4096 tokens"),
        ("Batch", "8 \u{00d7} grad_accum 6 = effective 48"),
    ]

    private let fusionSources: [(String, String, String)] = [
        ("Embeddings, LM head, routers", "SentinelBrain-14B-MoE-v0.1", "Identity & tokenizer"),
        ("Attention & norms", "Hermes-3-Llama-3.1-8B", "General reasoning"),
        ("Experts 0 & 2", "xLAM-7b-fc-r", "Tool/function calling"),
        ("Experts 1 & 3", "DeepSeek-Coder-6.7B", "Coding & repair"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    factsSection
                    fusionSection
                    datasetsSection
                    linksSection
                }
                .padding()
            }
            .navigationTitle("Model Card")
        }
    }

    private var factsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("MODEL FACTS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.green)
                .padding(.bottom, 8)

            ForEach(Array(facts.enumerated()), id: \.offset) { _, fact in
                HStack(alignment: .top) {
                    Text(fact.0)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 100, alignment: .leading)
                    Text(fact.1)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 6)
                Divider()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var fusionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FUSION SOURCES")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.green)

            ForEach(Array(fusionSources.enumerated()), id: \.offset) { _, src in
                VStack(alignment: .leading, spacing: 4) {
                    Text(src.0)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    HStack {
                        Text(src.1)
                            .font(.caption)
                            .foregroundStyle(.blue)
                        Text("\u{2014} \(src.2)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var datasetsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DATASET EXPANSION (MAY 2026)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.green)

            DatasetRow(name: "Medical Expanded", rows: "168,848", tokens: "43.6M")
            DatasetRow(name: "ECG & Health Text", rows: "9,494", tokens: "2.1M")
            DatasetRow(name: "Voice Expanded", rows: "20,000", tokens: "3.5M")
            Divider()
            DatasetRow(name: "Total New", rows: "198,342", tokens: "49.2M")
                .fontWeight(.bold)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var linksSection: some View {
        VStack(spacing: 12) {
            Link(destination: URL(string: "https://sentinel.qubitpage.com/")!) {
                Label("Mission Control Dashboard", systemImage: "globe")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.green)

            Link(destination: URL(string: "https://huggingface.co/spaces/lablab-ai-amd-developer-hackathon/sentinel-prime-frankenstein-edition")!) {
                Label("HuggingFace Space", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
    }
}

struct DatasetRow: View {
    let name: String
    let rows: String
    let tokens: String

    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
            Spacer()
            Text(rows)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(tokens)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 60, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }
}
