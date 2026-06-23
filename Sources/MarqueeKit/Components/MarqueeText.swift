import SwiftUI

/// A scrolling text view that automatically detects when its content overflows
/// and begins scrolling, with no configuration required.
///
/// ## Overview
///
/// `MarqueeText` is the simplest entry point into MarqueeKit. Pass any `String`
/// or `LocalizedStringKey` and the view handles overflow detection, looping,
/// and accessibility automatically.
///
/// ```swift
/// // Minimum usage
/// MarqueeText("Breaking News: Apple releases iOS 18")
///
/// // Fully customised
/// MarqueeText(headline)
///     .speed(.adaptive)
///     .direction(.left)
///     .fadeEdges(true)
///     .pauseOnTouch(true)
///     .marqueeTheme(.glass)
/// ```
///
/// ## Smart overflow
///
/// When the text fits within its container, `MarqueeText` renders as a plain
/// static `Text` — no animation overhead. Scrolling begins automatically the
/// moment the content is wider than the frame.
///
/// ## Accessibility
///
/// - **Reduce Motion:** Static text is shown; no animation runs.
/// - **VoiceOver:** Reads the complete string regardless of scroll state.
/// - **Dynamic Type:** Recomputes overflow on font-size changes.
public struct MarqueeText: View {

    // MARK: Content storage

    private enum Content {
        case string(String, Font?)
        case localizedKey(LocalizedStringKey, Font?)
    }

    private let content: Content
    private let textAlignment: TextAlignment

    // MARK: Engine

    @State private var engine: MarqueeEngine
    @Environment(\.marqueeGroupSyncController) private var syncController

    // MARK: Init

    /// Creates a marquee from a plain `String`.
    public init(
        _ text: String,
        font: Font? = nil,
        alignment: TextAlignment = .leading,
        configuration: MarqueeConfiguration = .default
    ) {
        self.content = .string(text, font)
        self.textAlignment = alignment
        _engine = State(wrappedValue: MarqueeEngine(configuration: configuration))
    }

    /// Creates a marquee from a `LocalizedStringKey`.
    public init(
        _ key: LocalizedStringKey,
        font: Font? = nil,
        alignment: TextAlignment = .leading,
        configuration: MarqueeConfiguration = .default
    ) {
        self.content = .localizedKey(key, font)
        self.textAlignment = alignment
        _engine = State(wrappedValue: MarqueeEngine(configuration: configuration))
    }

    // MARK: Body

    public var body: some View {
        // The anchor is a hidden single-line Text that gives the view its natural
        // frame: min(naturalTextWidth, proposedWidth) — exactly how SwiftUI Text
        // behaves. MarqueeScrollCore lives in the overlay so its GeometryReader
        // is constrained to that frame instead of filling all available space.
        anchorView
            .overlay {
                MarqueeScrollCore(engine: engine) {
                    textView
                }
            }
            .accessibilityLabel(accessibilityLabel)
            .onAppear {
                updateContentMetrics()
                if let controller = syncController {
                    engine.syncGroupStartDate = controller.sharedStartDate
                }
            }
            .environment(\.marqueeEngine, engine)
    }

    // MARK: Computed subviews

    /// A hidden single-line Text that acts as the layout anchor.
    /// lineLimit(1) makes it size to min(natural, proposed) — compact when the
    /// text fits, full proposed-width when it would overflow.
    @ViewBuilder
    private var anchorView: some View {
        switch content {
        case .string(let s, let font):
            Text(s)
                .applyFont(font)
                .lineLimit(1)
                .hidden()
        case .localizedKey(let key, let font):
            Text(key)
                .applyFont(font)
                .lineLimit(1)
                .hidden()
        }
    }

    @ViewBuilder
    private var textView: some View {
        switch content {
        case .string(let s, let font):
            Text(s)
                .applyFont(font)
                .multilineTextAlignment(textAlignment)
                .fixedSize(horizontal: true, vertical: false)
        case .localizedKey(let key, let font):
            Text(key)
                .applyFont(font)
                .multilineTextAlignment(textAlignment)
                .fixedSize(horizontal: true, vertical: false)
        }
    }

    private var accessibilityLabel: String {
        switch content {
        case .string(let s, _): return s
        case .localizedKey: return ""  // VoiceOver reads the key directly
        }
    }

    /// Feeds text metrics to the engine so reading modes that pace the
    /// inter-loop pause to readability (`.smart`, `.wordsPerMinute`) have the
    /// data they need.
    private func updateContentMetrics() {
        guard case .string(let s, _) = content else { return }
        engine.contentCharacterCount = s.count
        engine.contentWordCount = s.wordCount
    }
}

// MARK: - Font helper

private extension Text {
    @ViewBuilder
    func applyFont(_ font: Font?) -> some View {
        if let font {
            self.font(font)
        } else {
            self
        }
    }
}

// MARK: - View modifiers

public extension MarqueeText {

    /// Sets the scroll speed.
    func speed(_ speed: MarqueeSpeed) -> MarqueeText {
        applied { $0.speed = speed }
    }

    /// Sets the scroll direction.
    func direction(_ direction: MarqueeDirection) -> MarqueeText {
        applied { $0.direction = direction }
    }

    /// Enables or disables the edge fade gradient.
    func fadeEdges(_ enabled: Bool, width: CGFloat = 20) -> MarqueeText {
        applied {
            $0.fadeEdges = enabled
            $0.fadeWidth = width
        }
    }

    /// When `true`, touching the marquee pauses scrolling.
    func pauseOnTouch(_ enabled: Bool) -> MarqueeText {
        applied { $0.pauseOnTouch = enabled }
    }

    /// Sets the reading mode for automatic pause after each scroll cycle.
    func readingMode(_ mode: MarqueeReadingMode) -> MarqueeText {
        applied { $0.readingMode = mode }
    }

    /// Sets what causes scrolling to start.
    func trigger(_ trigger: MarqueeTrigger) -> MarqueeText {
        applied { $0.trigger = trigger }
    }

    /// Applies a built-in visual effect during scrolling.
    func effect(_ effect: MarqueeEffect) -> MarqueeText {
        applied { $0.effect = effect }
    }

    /// Applies a visual theme to the marquee container.
    func marqueeTheme(_ theme: MarqueeTheme) -> MarqueeText {
        applied { $0.theme = theme }
    }

    /// Enables haptic feedback.
    func haptics(_ haptics: MarqueeHaptics) -> MarqueeText {
        applied { $0.haptics = haptics }
    }

    /// Controls the spacing inserted between repetitions of the content.
    func loopSpacing(_ spacing: CGFloat) -> MarqueeText {
        applied { $0.loopSpacing = spacing }
    }

    /// Reduces animation overhead for widget and Live Activity contexts.
    func liveActivityOptimized(_ optimized: Bool = true) -> MarqueeText {
        applied { $0.liveActivityOptimized = optimized }
    }

    // MARK: Private

    private func applied(_ mutation: (inout MarqueeConfiguration) -> Void) -> MarqueeText {
        var config = _engine.wrappedValue.configuration
        mutation(&config)
        var copy = self
        copy._engine = State(wrappedValue: MarqueeEngine(configuration: config))
        return copy
    }
}
