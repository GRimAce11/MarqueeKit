import SwiftUI
import MarqueeKit

struct ContentDemoView: View {
    var body: some View {
        List {
            Section("Rich layouts") {
                cell("Icon + text") {
                    MarqueeContent {
                        HStack(spacing: 10) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            Text("Featured Item of the Day")
                                .fontWeight(.semibold)
                        }
                    }
                }

                cell("Multiple SF Symbols") {
                    MarqueeContent {
                        HStack(spacing: 14) {
                            ForEach(
                                ["sun.max.fill", "cloud.rain.fill", "wind", "snowflake"],
                                id: \.self
                            ) { symbol in
                                HStack(spacing: 4) {
                                    Image(systemName: symbol)
                                    Text("City \(symbol.prefix(3).capitalized)")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .fadeEdges(true)
                }

                cell("Badges") {
                    MarqueeContent {
                        HStack(spacing: 8) {
                            ForEach(["Swift", "SwiftUI", "iOS 17", "SPM"], id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.15), in: Capsule())
                            }
                        }
                    }
                }
            }

            Section("Interactive content") {
                cell("Buttons scroll too") {
                    MarqueeContent {
                        HStack(spacing: 12) {
                            Button("Like") {}
                                .buttonStyle(.bordered)
                            Button("Share") {}
                                .buttonStyle(.bordered)
                            Button("Bookmark") {}
                                .buttonStyle(.bordered)
                            Button("Report") {}
                                .buttonStyle(.bordered)
                        }
                    }
                    .speed(.slow)
                    .pauseOnTouch(true)
                }
            }
        }
        .navigationTitle("MarqueeContent")
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

#Preview { NavigationStack { ContentDemoView() } }
