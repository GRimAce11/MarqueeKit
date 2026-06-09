import SwiftUI

/// A container that synchronises the scroll phase of all marquee views inside it.
///
/// ## Overview
///
/// Wrap multiple marquee views in a `MarqueeGroup` to make them start at the
/// same position and scroll at the same rate. This is useful for dashboards,
/// scoreboards, and any UI that shows parallel data streams.
///
/// ```swift
/// MarqueeGroup {
///     MarqueeText("AAPL  $192.40  +1.2%")
///     MarqueeText("MSFT  $415.00  +0.8%")
///     MarqueeText("GOOGL $175.20  -0.3%")
/// }
/// ```
///
/// Access the group controller through the environment to programmatically
/// pause or re-synchronise the group:
///
/// ```swift
/// @Environment(\.marqueeGroupSyncController) var sync
///
/// Button("Pause All") { sync?.pauseAll() }
/// ```
public struct MarqueeGroup<Content: View>: View {

    @ViewBuilder private let content: () -> Content
    @State private var controller = MarqueeSyncController()

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .environment(\.marqueeGroupSyncController, controller)
            .onAppear { controller.synchronize() }
    }
}
