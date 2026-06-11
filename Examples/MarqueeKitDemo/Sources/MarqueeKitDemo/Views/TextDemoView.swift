import SwiftUI
import MarqueeKit

struct TextDemoView: View {

    @State private var customText = "Type something long enough to scroll…"
    @State private var selectedSpeed = 1

    private let speedOptions: [(String, MarqueeSpeed)] = [
        ("Adaptive", .adaptive),
        ("Slow", .slow),
        ("Medium", .medium),
        ("Fast", .fast),
        ("Fixed 100px/s", .fixed(100)),
    ]

    var body: some View {
        List {
            Section("Basic") {
                cell("Default") {
                    MarqueeText("Breaking News: Apple introduces new SwiftUI APIs at WWDC 2025")
                }

                cell("Fade edges") {
                    MarqueeText("Fade edges enabled — clean gradient at both ends of the view")
                        .fadeEdges(true)
                }

                cell("Pause on touch") {
                    MarqueeText("Touch and hold to pause the scrolling animation")
                        .pauseOnTouch(true)
                }
            }

            Section("Speed") {
                Picker("Speed", selection: $selectedSpeed) {
                    ForEach(0 ..< speedOptions.count, id: \.self) {
                        Text(speedOptions[$0].0).tag($0)
                    }
                }
                .pickerStyle(.segmented)

                cell("Preview") {
                    MarqueeText("The quick brown fox jumps over the lazy dog")
                        .speed(speedOptions[selectedSpeed].1)
                }
            }

            Section("Directions") {
                cell("Left (default)") {
                    MarqueeText("← Scrolling left")
                        .direction(.left)
                }
                cell("Right") {
                    MarqueeText("Scrolling right →")
                        .direction(.right)
                }
            }

            Section("Custom text") {
                TextField("Enter long text", text: $customText)
                cell("Live preview") {
                    MarqueeText(customText)
                        .speed(.adaptive)
                        .fadeEdges(true)
                }
            }

            Section("Reading mode") {
                cell("Smart pause") {
                    MarqueeText("Smart reading mode pauses after scrolling so you can finish reading the entire message")
                        .readingMode(.smart)
                        .speed(.medium)
                }
            }
        }
        .navigationTitle("MarqueeText")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func cell<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}

#Preview { NavigationStack { TextDemoView() } }
