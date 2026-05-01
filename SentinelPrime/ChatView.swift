import SwiftUI

struct ChatView: View {
    @StateObject private var api = SentinelAPI.shared
    @StateObject private var voiceManager = VoiceInputManager()
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isSending = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messageList
                inputBar
            }
            .navigationTitle("Chat")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        messages.removeAll()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(messages.isEmpty)
                }
            }
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if messages.isEmpty {
                        emptyState
                    }
                    ForEach(messages) { msg in
                        MessageBubble(message: msg)
                            .id(msg.id)
                    }
                    if isSending {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Thinking...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) { _, _ in
                if let last = messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundStyle(.green.opacity(0.5))
            Text("Sentinel Prime")
                .font(.title3)
                .fontWeight(.bold)
            Text("14.4B MoE \u{2014} Frankenstein Edition")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Ask about training status, model architecture, or anything else.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            Button {
                if voiceManager.isRecording {
                    voiceManager.stopRecording()
                    if !voiceManager.transcript.isEmpty {
                        inputText = voiceManager.transcript
                    }
                } else {
                    voiceManager.startRecording()
                }
            } label: {
                Image(systemName: voiceManager.isRecording ? "mic.fill" : "mic")
                    .foregroundStyle(voiceManager.isRecording ? .red : .green)
                    .font(.title3)
            }

            TextField("Message Sentinel...", text: $inputText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .onSubmit { sendMessage() }

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .green)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSending else { return }

        let userMsg = ChatMessage(role: .user, content: text)
        messages.append(userMsg)
        inputText = ""
        isSending = true

        Task {
            let response = await api.sendChat(messages: messages)
            messages.append(ChatMessage(role: .assistant, content: response))
            isSending = false
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 48) }
            Text(message.content)
                .font(.body)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    isUser ? Color.green.opacity(0.2) : Color(.systemGray5),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .foregroundStyle(isUser ? .green : .primary)
                .textSelection(.enabled)
            if !isUser { Spacer(minLength: 48) }
        }
    }
}
