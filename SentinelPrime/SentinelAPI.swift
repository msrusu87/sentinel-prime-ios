import Foundation

struct TrainingOverview: Codable {
    let training: TrainingMetrics?
    let shards: ShardInfo?
}

struct TrainingMetrics: Codable {
    let currentStep: Int?
    let trainLoss: Double?
    let lr: Double?
    let tokPerSec: Double?
    let etaHrs: Double?

    enum CodingKeys: String, CodingKey {
        case currentStep = "current_step"
        case trainLoss = "train_loss"
        case lr
        case tokPerSec = "tok_per_sec"
        case etaHrs = "eta_hrs"
    }
}

struct ShardInfo: Codable {
    let tokensB: Double?
    let categories: Int?

    enum CodingKeys: String, CodingKey {
        case tokensB = "tokens_b"
        case categories
    }
}

struct SystemInfo: Codable {
    let vram: ResourceUsage?
    let ram: ResourceUsage?
}

struct ResourceUsage: Codable {
    let usedGb: Double?
    let totalGb: Double?
    let pct: Double?

    enum CodingKeys: String, CodingKey {
        case usedGb = "used_gb"
        case totalGb = "total_gb"
        case pct
    }
}

struct ProcessEntry: Codable, Identifiable {
    var id: String { name }
    let name: String
    let alive: Bool
    let pids: [Int]
}

struct ProcessList: Codable {
    let processes: [ProcessEntry]
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: Role
    let content: String

    enum Role { case user, assistant }
}

struct ChatResponse: Codable {
    let response: String?
    let error: String?
}

@MainActor
final class SentinelAPI: ObservableObject {
    static let shared = SentinelAPI()

    private let baseURL = "https://sentinel.qubitpage.com"
    private let session: URLSession

    @Published var overview: TrainingOverview?
    @Published var system: SystemInfo?
    @Published var processes: ProcessList?
    @Published var isLoading = false
    @Published var lastError: String?
    @Published var lastUpdate: Date?

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        lastError = nil

        async let ov = fetchJSON(TrainingOverview.self, path: "/api/overview")
        async let sys = fetchJSON(SystemInfo.self, path: "/api/system")
        async let proc = fetchJSON(ProcessList.self, path: "/api/processes")

        let (ovResult, sysResult, procResult) = await (ov, sys, proc)

        overview = ovResult
        system = sysResult
        processes = procResult
        lastUpdate = Date()

        if overview == nil && system == nil {
            lastError = "API unreachable"
        }
    }

    func fetchLog(name: String, lines: Int = 100) async -> String {
        guard let url = URL(string: "\(baseURL)/api/logs/\(name)?n=\(lines)") else { return "" }
        do {
            let (data, _) = try await session.data(from: url)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }

    func sendChat(messages: [ChatMessage]) async -> String {
        guard let url = URL(string: "\(baseURL)/api/chat") else { return "Invalid URL" }

        let payload: [[String: String]] = messages.map { msg in
            ["role": msg.role == .user ? "user" : "assistant", "content": msg.content]
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["messages": payload])

        do {
            let (data, _) = try await session.data(for: request)
            if let resp = try? JSONDecoder().decode(ChatResponse.self, from: data) {
                return resp.response ?? resp.error ?? "No response"
            }
            return String(data: data, encoding: .utf8) ?? "Unknown response"
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }

    private func fetchJSON<T: Codable>(_ type: T.Type, path: String) async -> T? {
        guard let url = URL(string: "\(baseURL)\(path)") else { return nil }
        do {
            let (data, _) = try await session.data(from: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}
