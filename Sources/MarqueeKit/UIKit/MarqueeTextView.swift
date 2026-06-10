#if canImport(UIKit)
import UIKit
import SwiftUI

/// A `UIView` subclass that renders a scrolling text marquee.
///
/// ## Overview
///
/// `MarqueeTextView` bridges MarqueeKit into UIKit. Internally it hosts a
/// `MarqueeText` SwiftUI view using `UIHostingController`.
///
/// ```swift
/// let label = MarqueeTextView()
/// label.text = "Breaking News: Apple releases iOS 18"
/// label.configuration = MarqueeConfiguration(speed: .adaptive, fadeEdges: true)
/// view.addSubview(label)
/// ```
///
/// AutoLayout is fully supported. The view derives its intrinsic height from
/// the font metrics and clips horizontally to its frame.
open class MarqueeTextView: UIView {

    // MARK: Public properties

    /// The string to display. Setting this updates the hosted SwiftUI view.
    open var text: String = "" {
        didSet { update() }
    }

    /// The font used for the text. Defaults to the system body font.
    open var textFont: UIFont = .preferredFont(forTextStyle: .body) {
        didSet { update() }
    }

    /// The configuration that controls speed, direction, and visual style.
    open var configuration: MarqueeConfiguration = .default {
        didSet { update() }
    }

    // MARK: Private

    private var hostingController: UIHostingController<MarqueeText>?
    private var hostView: UIView? { hostingController?.view }

    // MARK: Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: Setup

    private func setup() {
        clipsToBounds = true
        update()
    }

    private func update() {
        let marquee = MarqueeText(
            text,
            font: Font(textFont),
            configuration: configuration
        )

        if let existing = hostingController {
            existing.rootView = marquee
        } else {
            let hc = UIHostingController(rootView: marquee)
            hc.view.backgroundColor = .clear
            hc.view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(hc.view)
            NSLayoutConstraint.activate([
                hc.view.topAnchor.constraint(equalTo: topAnchor),
                hc.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                hc.view.trailingAnchor.constraint(equalTo: trailingAnchor),
                hc.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
            hostingController = hc
        }
    }

    // MARK: Intrinsic size

    open override var intrinsicContentSize: CGSize {
        let height = textFont.lineHeight + textFont.leading
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}
#endif
