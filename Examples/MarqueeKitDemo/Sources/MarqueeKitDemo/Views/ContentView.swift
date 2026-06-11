import SwiftUI
import MarqueeKit

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("MarqueeText") { TextDemoView() }
                NavigationLink("MarqueeContent") { ContentDemoView() }
                NavigationLink("MarqueeTicker") { TickerDemoView() }
                NavigationLink("MarqueeBanner") { BannerDemoView() }
                NavigationLink("Effects & Themes") { EffectsDemoView() }
                NavigationLink("Synchronised Group") { GroupDemoView() }
                NavigationLink("UIKit Bridge") { UIKitDemoView() }
            }
            .navigationTitle("MarqueeKit Demo")
        }
    }
}

#Preview {
    ContentView()
}
