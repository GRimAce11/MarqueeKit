import SwiftUI
import MarqueeKit

struct GroupDemoView: View {

    @Environment(\.marqueeGroupSyncController) private var sync
    @State private var isPaused = false

    var body: some View {
        VStack(spacing: 0) {
            MarqueeGroup {
                VStack(spacing: 1) {
                    groupRow("AAPL  $192.40  +1.2%   MSFT  $415.00  +0.8%")
                    groupRow("GOOGL  $175.20  -0.3%   AMZN  $185.60  +2.1%")
                    groupRow("BTC  $67,840  +3.2%   ETH  $3,520  -1.8%")
                }
            }
            .marqueeTheme(.ticker)

            Divider()

            Button(isPaused ? "Resume All" : "Pause All") {
                isPaused.toggle()
                // In a real app, store the sync controller and call pauseAll()/resumeAll()
            }
            .buttonStyle(.bordered)
            .padding()
        }
        .navigationTitle("Synchronised Group")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func groupRow(_ text: String) -> some View {
        MarqueeText(text)
            .font(.system(.body, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 36)
            .padding(.horizontal)
    }
}

#Preview { NavigationStack { GroupDemoView() } }
