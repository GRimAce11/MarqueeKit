import SwiftUI

/// A notification-style banner that scrolls its message across the screen.
///
/// ## Overview
///
/// `MarqueeBanner` is optimised for one-off announcements, alerts, and status
/// messages. By default it uses the `.modern` theme and stops scrolling after
/// a configurable number of loops.
///
/// ```swift
/// MarqueeBanner("New software update available — tap to install")
///     .marqueeTheme(.glass)
///     .speed(.slow)
/// ```
public struct MarqueeBanner: View {

    // MARK: Properties

    private let message: String
    private let icon: String?
    private let maxLoops: Int?
    @State private var engine: MarqueeEngine
    @State private var loopCount: Int = 0
    @Environment(\.marqueeGroupSyncController) private var syncController

    // MARK: Init

    /// Creates a banner with a text message.
    ///
    /// - Parameters:
    ///   - message: The message to display.
    ///   - icon: An optional SF Symbol name displayed to the left of the message.
    ///   - maxLoops: If set, scrolling stops after this many complete cycles.
    ///   - configuration: Base configuration.
    public init(
        _ message: String,
        icon: String? = nil,
        maxLoops: Int? = nil,
        configuration: MarqueeConfiguration = .default
    ) {
        self.message = message
        self.icon = icon
        self.maxLoops = maxLoops
        var config = configuration
        if config.theme.backgroundColor == nil && config.theme.backgroundMaterial == nil {
            config.theme = .modern
        }
        _engine = State(wrappedValue: MarqueeEngine(configuration: config))
    }

    // MARK: Body

    public var body: some View {
        MarqueeScrollCore(engine: engine) {
            bannerContent
        }
        .accessibilityLabel(message)
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
        .environment(\.marqueeEngine, engine)
    }

    // MARK: Banner content

    private var bannerContent: some View {
        HStack(spacing: 8) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
            }
            Text(message)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
}

// MARK: - View modifiers

public extension MarqueeBanner {
    func speed(_ speed: MarqueeSpeed) -> MarqueeBanner {
        applying { $0.speed = speed }
    }

    func direction(_ direction: MarqueeDirection) -> MarqueeBanner {
        applying { $0.direction = direction }
    }

    func fadeEdges(_ enabled: Bool, width: CGFloat = 20) -> MarqueeBanner {
        applying {
            $0.fadeEdges = enabled
            $0.fadeWidth = width
        }
    }

    func pauseOnTouch(_ enabled: Bool) -> MarqueeBanner {
        applying { $0.pauseOnTouch = enabled }
    }

    func marqueeTheme(_ theme: MarqueeTheme) -> MarqueeBanner {
        applying { $0.theme = theme }
    }

    func loopSpacing(_ spacing: CGFloat) -> MarqueeBanner {
        applying { $0.loopSpacing = spacing }
    }

    private func applying(_ mutation: (inout MarqueeConfiguration) -> Void) -> MarqueeBanner {
        var config = _engine.wrappedValue.configuration
        mutation(&config)
        var copy = self
        copy._engine = State(wrappedValue: MarqueeEngine(configuration: config))
        return copy
    }
}
