import SwiftUI

/// The internal rendering engine shared by all marquee components.
///
/// Measures content, detects overflow, then drives a `TimelineView`-based
/// scroll loop. All theme, effect, and accessibility concerns are handled here.
struct MarqueeScrollCore<Content: View>: View {

    let engine: MarqueeEngine
    @ViewBuilder let content: () -> Content

    // MARK: Accessibility

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: Body

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: alignment) {
                if engine.isOverflowing && !reduceMotion && !engine.configuration.liveActivityOptimized {
                    scrollingLayer(containerSize: proxy.size)
                } else {
                    staticLayer
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: alignment)
            .onChange(of: proxy.size) { _, newSize in
                engine.updateSizes(content: engine.contentSize, container: newSize)
            }
        }
        .clipped()
        .overlay { if engine.configuration.fadeEdges { fadeOverlay } }
        .applyTheme(engine.configuration.theme)
        .gesture(touchGesture)
        .onAppear { HapticsEngine.shared.prepare() }
    }

    // MARK: Static (no overflow / reduce motion)

    private var staticLayer: some View {
        content()
            .trackContentSize { size in
                engine.updateSizes(content: size, container: engine.containerSize)
            }
    }

    // MARK: Scrolling

    private func scrollingLayer(containerSize: CGSize) -> some View {
        let isHorizontal = engine.configuration.direction.isHorizontal
        let loopDistance: CGFloat = isHorizontal
            ? engine.contentSize.width  + engine.configuration.loopSpacing
            : engine.contentSize.height + engine.configuration.loopSpacing

        return TimelineView(.animation(paused: engine.isPaused)) { context in
            let rawOffset = engine.offset(at: context.date, loopDistance: loopDistance)
            let effectOffset = applyEffect(base: rawOffset, at: context.date, loopDistance: loopDistance)

            if isHorizontal {
                HStack(spacing: engine.configuration.loopSpacing) {
                    contentMeasured
                    content()
                }
                .offset(x: effectOffset)
            } else {
                VStack(spacing: engine.configuration.loopSpacing) {
                    contentMeasured
                    content()
                }
                .offset(y: effectOffset)
            }
        }
        .fixedSize()
    }

    private var contentMeasured: some View {
        content()
            .trackContentSize { size in
                engine.updateSizes(content: size, container: engine.containerSize)
            }
    }

    // MARK: Effects

    private func applyEffect(base: CGFloat, at date: Date, loopDistance: CGFloat) -> CGFloat {
        switch engine.configuration.effect {
        case .elastic:
            guard loopDistance > 0 else { return base }
            let progress = abs(Double(base)).truncatingRemainder(dividingBy: 20)
            return base + CGFloat(sin(progress / 20 * .pi) * 3)
        default:
            return base
        }
    }

    // MARK: Touch gesture

    private var touchGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in if engine.configuration.pauseOnTouch { engine.pause() } }
            .onEnded   { _ in if engine.configuration.pauseOnTouch { engine.resume() } }
    }

    // MARK: Edge fade overlay

    @ViewBuilder
    private var fadeOverlay: some View {
        let width = engine.configuration.fadeWidth
        let isHorizontal = engine.configuration.direction.isHorizontal

        if isHorizontal {
            HStack(spacing: 0) {
                fadeGradient(from: .black, to: .clear, width: width)
                Spacer()
                fadeGradient(from: .clear, to: .black, width: width)
            }
            .allowsHitTesting(false)
        } else {
            VStack(spacing: 0) {
                fadeGradient(from: .black, to: .clear, height: width)
                Spacer()
                fadeGradient(from: .clear, to: .black, height: width)
            }
            .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func fadeGradient(from: Color, to: Color, width: CGFloat) -> some View {
        LinearGradient(colors: [from, to], startPoint: .leading, endPoint: .trailing)
            .frame(width: width)
            .blendMode(.destinationOut)
            .compositingGroup()
    }

    @ViewBuilder
    private func fadeGradient(from: Color, to: Color, height: CGFloat) -> some View {
        LinearGradient(colors: [from, to], startPoint: .top, endPoint: .bottom)
            .frame(height: height)
            .blendMode(.destinationOut)
            .compositingGroup()
    }

    // MARK: Alignment helper

    private var alignment: Alignment {
        switch engine.configuration.direction {
        case .left:  return .leading
        case .right: return .trailing
        case .up:    return .top
        case .down:  return .bottom
        }
    }
}

// MARK: - Theme application

private extension View {
    @ViewBuilder
    func applyTheme(_ theme: MarqueeTheme) -> some View {
        let padded = self.padding(theme.padding)

        let backgrounded = padded.background {
            Group {
                if let material = theme.backgroundMaterial {
                    RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                        .fill(material)
                } else if let bg = theme.backgroundColor {
                    RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                        .fill(bg)
                }
            }
        }

        let bordered = backgrounded.overlay {
            if let border = theme.borderColor, theme.borderWidth > 0 {
                RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                    .strokeBorder(border, lineWidth: theme.borderWidth)
            }
        }

        if let fg = theme.foregroundColor {
            bordered.foregroundStyle(fg)
        } else {
            bordered
        }
    }
}
