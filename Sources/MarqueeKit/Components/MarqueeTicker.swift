import SwiftUI

/// A news-ticker style component that scrolls through a collection of items
/// continuously.
///
/// ## Overview
///
/// `MarqueeTicker` is purpose-built for live data feeds: stock prices, sports
/// scores, breaking news, crypto quotes.
///
/// ```swift
/// MarqueeTicker(items) { item in
///     HStack(spacing: 12) {
///         Text(item.symbol)
///             .fontWeight(.bold)
///         Text(item.price, format: .currency(code: "USD"))
///             .foregroundStyle(item.isPositive ? .green : .red)
///     }
/// }
/// .marqueeTheme(.ticker)
/// .speed(.medium)
/// ```
///
/// - Note: Items are laid out in a single horizontal row separated by
///   a configurable divider. The whole row scrolls as one unit.
public struct MarqueeTicker<Item: Identifiable, ItemContent: View>: View {

    // MARK: Properties

    private let items: [Item]
    @ViewBuilder private let itemContent: (Item) -> ItemContent
    private let separator: AnyView
    @State private var engine: MarqueeEngine
    @Environment(\.marqueeGroupSyncController) private var syncController

    // MARK: Init

    /// Creates a ticker from an array of identifiable items.
    ///
    /// - Parameters:
    ///   - items: The data to display.
    ///   - separator: A view inserted between consecutive items. Defaults to `"·"`.
    ///   - configuration: Initial configuration; override with modifiers.
    ///   - content: A view builder producing the row for each item.
    public init(
        _ items: [Item],
        separator: some View = Text("·").foregroundStyle(.secondary),
        configuration: MarqueeConfiguration = .default,
        @ViewBuilder content: @escaping (Item) -> ItemContent
    ) {
        self.items = items
        self.itemContent = content
        self.separator = AnyView(separator)
        var config = configuration
        config.direction = .left
        _engine = State(wrappedValue: MarqueeEngine(configuration: config))
    }

    // MARK: Body

    public var body: some View {
        MarqueeScrollCore(engine: engine) {
            tickerRow
        }
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
            controller.requestSynchronize()
        }
        .environment(\.marqueeEngine, engine)
    }

    // MARK: Ticker row

    private var tickerRow: some View {
        HStack(spacing: 16) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                itemContent(item)
                if index < items.count - 1 {
                    separator
                }
            }
        }
        .fixedSize()
    }
}

// MARK: - String convenience init

public extension MarqueeTicker where Item == TickerItem, ItemContent == Text {
    /// Creates a ticker from an array of strings.
    init(
        _ strings: [String],
        configuration: MarqueeConfiguration = .default
    ) {
        let items = strings.enumerated().map { TickerItem(id: $0.offset, text: $0.element) }
        self.init(items, configuration: configuration) { item in
            Text(item.text)
        }
    }
}

/// A minimal identifiable wrapper for string-based tickers.
public struct TickerItem: Identifiable {
    public let id: Int
    public let text: String
}

// MARK: - View modifiers

public extension MarqueeTicker {
    func speed(_ speed: MarqueeSpeed) -> MarqueeTicker {
        applying { $0.speed = speed }
    }

    func fadeEdges(_ enabled: Bool, width: CGFloat = 20) -> MarqueeTicker {
        applying {
            $0.fadeEdges = enabled
            $0.fadeWidth = width
        }
    }

    func marqueeTheme(_ theme: MarqueeTheme) -> MarqueeTicker {
        applying { $0.theme = theme }
    }

    func loopSpacing(_ spacing: CGFloat) -> MarqueeTicker {
        applying { $0.loopSpacing = spacing }
    }

    func haptics(_ haptics: MarqueeHaptics) -> MarqueeTicker {
        applying { $0.haptics = haptics }
    }

    private func applying(_ mutation: (inout MarqueeConfiguration) -> Void) -> MarqueeTicker {
        var config = _engine.wrappedValue.configuration
        mutation(&config)
        var copy = self
        copy._engine = State(wrappedValue: MarqueeEngine(configuration: config))
        return copy
    }
}
