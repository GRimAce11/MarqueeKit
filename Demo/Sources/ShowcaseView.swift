import SwiftUI
import MarqueeKit

/// Showcase used for the README GIF. Every row is a real MarqueeKit component — nothing here
/// is a mock-up or a hand-rolled animation.
struct ShowcaseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {

                section("MarqueeText", "Zero config — overflow is detected for you") {
                    MarqueeText("Breaking: MarqueeKit detects overflow automatically, so you never configure whether scrolling is needed.")
                        .font(.headline)
                }


                section("Themes", ".glass", chrome: false) {
                    MarqueeText("Frosted background, rounded corners, subtle border — the glass theme.")
                        .marqueeTheme(.glass)
                }

                section("Themes", ".modern", chrome: false) {
                    MarqueeText("A tinted, contemporary treatment for headlines and now-playing rows.")
                        .marqueeTheme(.modern)
                }

                section("Themes", ".ticker", chrome: false) {
                    MarqueeText("AAPL 232.14  ▲ 1.2%    MSFT 418.90  ▲ 0.4%    NVDA 138.02  ▼ 0.8%")
                        .marqueeTheme(.ticker)
                }


                section("Speed", ".slow / .fast") {
                    VStack(alignment: .leading, spacing: 10) {
                        MarqueeText("Slow — comfortable reading pace for long-form copy.")
                            .speed(.slow)
                        MarqueeText("Fast — urgent, attention-grabbing, for alerts and tickers.")
                            .speed(.fast)
                    }
                }

                section("Edge fading", "fadeEdges(true)") {
                    MarqueeText("Content dissolves into the background at both edges instead of being hard-clipped.")
                        .fadeEdges(true, width: 28)
                }

            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private func section(
        _ title: String,
        _ subtitle: String,
        chrome: Bool = true,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, chrome ? 14 : 0)
                .padding(.horizontal, chrome ? 14 : 0)
                .background {
                    if chrome {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemGroupedBackground))
                    }
                }
        }
    }
}
