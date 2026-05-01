import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TrainingView()
                .tabItem {
                    Label("Training", systemImage: "waveform.path.ecg")
                }

            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right")
                }

            ModelCardView()
                .tabItem {
                    Label("Model", systemImage: "cpu")
                }
        }
        .tint(.green)
    }
}
