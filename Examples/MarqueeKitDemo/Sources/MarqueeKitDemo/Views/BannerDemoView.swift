import SwiftUI
import MarqueeKit

struct BannerDemoView: View {

    @State private var showSystemBanner = false
    @State private var customMessage = "New software update available — tap to install"

    var body: some View {
        List {
            Section("Default") {
                MarqueeBanner("New software update available — tap to install version 18.2 now")
                    .frame(height: 44)
            }

            Section("With icon") {
                MarqueeBanner(
                    "System alert: Low storage space. Free up space to continue receiving updates.",
                    icon: "exclamationmark.triangle.fill"
                )
                .frame(height: 44)
            }

            Section("Glass theme") {
                MarqueeBanner("Now playing: Bohemian Rhapsody — Queen (Remastered 2011)")
                    .marqueeTheme(.glass)
                    .speed(.slow)
                    .frame(height: 44)
            }

            Section("Announcement bar") {
                MarqueeBanner(
                    "🎉  Welcome to MarqueeKit — the most modern scrolling component for SwiftUI"
                )
                .marqueeTheme(.modern)
                .fadeEdges(true)
                .frame(height: 48)
            }

            Section("Custom message") {
                TextField("Banner message", text: $customMessage)
                MarqueeBanner(customMessage, icon: "bell.fill")
                    .speed(.adaptive)
                    .fadeEdges(true)
                    .frame(height: 44)
            }
        }
        .navigationTitle("MarqueeBanner")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview { NavigationStack { BannerDemoView() } }
