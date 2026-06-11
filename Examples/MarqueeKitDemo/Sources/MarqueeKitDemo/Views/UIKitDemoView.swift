import SwiftUI
import MarqueeKit
#if canImport(UIKit)
import UIKit

// MARK: - UIViewRepresentable wrapper for the demo

private struct MarqueeTextViewRepresentable: UIViewRepresentable {
    let text: String
    let configuration: MarqueeConfiguration

    func makeUIView(context: Context) -> MarqueeTextView {
        let view = MarqueeTextView()
        view.text = text
        view.configuration = configuration
        return view
    }

    func updateUIView(_ uiView: MarqueeTextView, context: Context) {
        uiView.text = text
        uiView.configuration = configuration
    }
}

#endif

struct UIKitDemoView: View {
    var body: some View {
        List {
            Section("MarqueeTextView (UIKit)") {
                #if canImport(UIKit)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Default configuration").font(.caption).foregroundStyle(.secondary)
                    MarqueeTextViewRepresentable(
                        text: "UIKit bridged marquee — MarqueeTextView wraps SwiftUI inside a UIView",
                        configuration: .default
                    )
                    .frame(height: 24)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Fade edges + glass theme").font(.caption).foregroundStyle(.secondary)
                    MarqueeTextViewRepresentable(
                        text: "Glass theme applied via UIKit bridge — fully theme-aware",
                        configuration: MarqueeConfiguration(
                            fadeEdges: true,
                            theme: .glass
                        )
                    )
                    .frame(height: 40)
                }
                #else
                Text("UIKit not available on this platform.")
                    .foregroundStyle(.secondary)
                #endif
            }

            Section("How to use in UIKit") {
                Text(
                    """
                    let label = MarqueeTextView()
                    label.text = "Your scrolling text"
                    label.configuration = MarqueeConfiguration(
                        speed: .adaptive,
                        fadeEdges: true
                    )
                    view.addSubview(label)
                    """
                )
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("UIKit Bridge")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview { NavigationStack { UIKitDemoView() } }
