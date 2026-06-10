#if canImport(UIKit)
import UIKit
import SwiftUI

/// A generic `UIView` that hosts any SwiftUI marquee view.
///
/// Use this when you need to embed `MarqueeContent` or other marquee components
/// into a UIKit hierarchy.
///
/// ```swift
/// let host = MarqueeHostingView {
///     MarqueeContent {
///         HStack {
///             Image(systemName: "bolt.fill")
///             Text("Live  •  Updated just now")
///         }
///     }
///     .speed(.adaptive)
///     .fadeEdges(true)
/// }
/// view.addSubview(host)
/// ```
open class MarqueeHostingView<Content: View>: UIView {

    // MARK: Private

    private let hostingController: UIHostingController<Content>

    // MARK: Init

    /// Creates a hosting view with the provided SwiftUI content.
    public init(@ViewBuilder content: () -> Content) {
        self.hostingController = UIHostingController(rootView: content())
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported — use init(content:) instead.")
    }

    // MARK: Setup

    private func setup() {
        clipsToBounds = true
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    // MARK: Content update

    /// Replaces the hosted content.
    open func setContent(_ content: Content) {
        hostingController.rootView = content
    }
}
#endif
