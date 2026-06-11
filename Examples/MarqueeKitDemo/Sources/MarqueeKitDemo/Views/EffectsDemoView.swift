import SwiftUI
import MarqueeKit

struct EffectsDemoView: View {

    private let demoText = "MarqueeKit  ·  Beautiful scrolling for SwiftUI"

    var body: some View {
        List {
            Section("Themes") {
                themeRow("Minimal (default)", MarqueeText(demoText).marqueeTheme(.minimal))
                themeRow("Glass",     MarqueeText(demoText).marqueeTheme(.glass))
                themeRow("Ticker",    MarqueeText(demoText).marqueeTheme(.ticker))
                themeRow("Modern",    MarqueeText(demoText).marqueeTheme(.modern))
            }

            Section("Effects") {
                effectRow("None",     .none)
                effectRow("Elastic",  .elastic)
            }

            Section("Edge fade widths") {
                MarqueeText(demoText)
                    .fadeEdges(true, width: 10)
                    .speed(.slow)
                    .overlay(alignment: .topLeading) { label("10 pt") }

                MarqueeText(demoText)
                    .fadeEdges(true, width: 30)
                    .speed(.slow)
                    .overlay(alignment: .topLeading) { label("30 pt") }

                MarqueeText(demoText)
                    .fadeEdges(true, width: 60)
                    .speed(.slow)
                    .overlay(alignment: .topLeading) { label("60 pt") }
            }
        }
        .navigationTitle("Effects & Themes")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func themeRow<Content: View>(_ title: String, _ content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            content.frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func effectRow(_ title: String, _ effect: MarqueeEffect) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            MarqueeText(demoText)
                .effect(effect)
                .speed(.medium)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9))
            .foregroundStyle(.secondary)
            .padding(.leading, 2)
    }
}

#Preview { NavigationStack { EffectsDemoView() } }
