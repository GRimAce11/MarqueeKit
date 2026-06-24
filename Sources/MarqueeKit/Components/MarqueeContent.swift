import SwiftUI

/// A scrolling view that wraps any SwiftUI content.
///
/// ## Overview
///
/// Use `MarqueeContent` when you need to scroll rich layouts — images, icons,
/// buttons, or custom views — not just plain text.
///
/// ```swift
/// MarqueeContent {
///     HStack(spacing: 8) {
///         Image(systemName: "star.fill")
///             .foregroundStyle(.yellow)
///         Text("Featured Item")
///             .fontWeight(.semibold)
///         Button("Learn more") { ... }
///     }
/// }
/// .speed(.medium)
/// .fadeEdges(true)
/// ```
///
/// Any SwiftUI view is valid content, including interactive controls.
/// Buttons and gestures inside the content remain functional during scrolling.
public struct MarqueeContent<Content: View>: View {

    // MARK: Properties

    @ViewBuilder private let content: () -> Content
    @State private var engine: MarqueeEngine
    @Environment(\.marqueeGroupSyncController) private var syncController

    // MARK: Init

    /// Creates a marquee wrapping the provided view-builder content.
    public init(
        configuration: MarqueeConfiguration = .default,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        _engine = State(wrappedValue: MarqueeEngine(configuration: configuration))
    }

    // MARK: Body

    public var body: some View {
        MarqueeScrollCore(engine: engine, content: content)
            .onAppear {
                if let controller = syncController {
                    controller.register(engine)
                    engine.syncGroupStartDate = controller.sharedStartDate
                }
            }
            .onDisappear {
                syncController?.unregister(engine)
            }
            .onChange(of: syncController?.sharedStartDate) { _, newDate in
                guard let date = newDate else { return }
                engine.syncGroupStartDate = date
                if engine.isOverflowing { engine.start() }
            }
            .onChange(of: engine.isOverflowing) { _, nowOverflowing in
                guard nowOverflowing, let controller = syncController else { return }
                if engine.isScrolling {
                    controller.updateGroupSpeed()
                } else {
                    controller.requestSynchronize()
                }
            }
            .environment(\.marqueeEngine, engine)
    }
}

// MARK: - View modifiers

public extension MarqueeContent {
    func speed(_ speed: MarqueeSpeed) -> MarqueeContent {
        applying { $0.speed = speed }
    }

    func direction(_ direction: MarqueeDirection) -> MarqueeContent {
        applying { $0.direction = direction }
    }

    func fadeEdges(_ enabled: Bool, width: CGFloat = 20) -> MarqueeContent {
        applying {
            $0.fadeEdges = enabled
            $0.fadeWidth = width
        }
    }

    func pauseOnTouch(_ enabled: Bool) -> MarqueeContent {
        applying { $0.pauseOnTouch = enabled }
    }

    func readingMode(_ mode: MarqueeReadingMode) -> MarqueeContent {
        applying { $0.readingMode = mode }
    }

    func trigger(_ trigger: MarqueeTrigger) -> MarqueeContent {
        applying { $0.trigger = trigger }
    }

    func effect(_ effect: MarqueeEffect) -> MarqueeContent {
        applying { $0.effect = effect }
    }

    func marqueeTheme(_ theme: MarqueeTheme) -> MarqueeContent {
        applying { $0.theme = theme }
    }

    func haptics(_ haptics: MarqueeHaptics) -> MarqueeContent {
        applying { $0.haptics = haptics }
    }

    func loopSpacing(_ spacing: CGFloat) -> MarqueeContent {
        applying { $0.loopSpacing = spacing }
    }

    func liveActivityOptimized(_ optimized: Bool = true) -> MarqueeContent {
        applying { $0.liveActivityOptimized = optimized }
    }

    // MARK: Private helper

    private func applying(_ mutation: (inout MarqueeConfiguration) -> Void) -> MarqueeContent {
        var config = _engine.wrappedValue.configuration
        mutation(&config)
        var copy = self
        copy._engine = State(wrappedValue: MarqueeEngine(configuration: config))
        return copy
    }
}
