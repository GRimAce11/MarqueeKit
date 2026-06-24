# Getting Started with MarqueeKit

Learn how to add scrolling text and content to your app in minutes.

## Installation

### Swift Package Manager

Add MarqueeKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/GRimAce11/MarqueeKit", from: "1.0.0"),
]
```

Or in Xcode: **File → Add Package Dependencies**, paste the repository URL.

## Your First Marquee

Import the module and drop in a `MarqueeText`:

```swift
import MarqueeKit

struct MyView: View {
    var body: some View {
        MarqueeText("Hello from MarqueeKit — swipe to reveal more content")
            .padding()
    }
}
```

The view automatically detects whether the text is wider than its container. If
it fits, a plain static `Text` is rendered. If it overflows, scrolling begins.

## Choosing a Component

| Scenario | Component |
|----------|-----------|
| Single string | ``MarqueeText`` |
| Rich layout (icons, buttons) | ``MarqueeContent`` |
| List of items (stocks, news) | ``MarqueeTicker`` |
| Announcement / alert | ``MarqueeBanner`` |

## Customisation

Every component accepts the same fluent modifiers:

```swift
MarqueeText("Live scores — Chelsea 2:1 Arsenal — Man City 0:0 Liverpool")
    .speed(.adaptive)          // auto-compute the ideal speed
    .fadeEdges(true)           // gradient fade at both ends
    .pauseOnTouch(true)        // pause while the user touches
    .readingMode(.smart)       // pause after each cycle
    .marqueeTheme(.glass)      // frosted-glass container
    .haptics(.loop)            // subtle haptic on each loop
```

## Synchronised Groups

Wrap multiple marquees in ``MarqueeGroup`` to keep them in lockstep. The group defers the start until every child has finished measuring its content, then picks a unified scroll speed from the maximum of all members' resolved speeds. This means all animations fire from position 0 at the same moment and travel at the same velocity — font size and content length do not affect sync:

```swift
MarqueeGroup {
    MarqueeText("AAPL  $192.40  +1.2%")
    MarqueeText("MSFT  $415.00  +0.8%")
    MarqueeText("GOOGL $175.20  -0.3%")
}
```

## Accessibility

MarqueeKit automatically handles:

- **Reduce Motion** — static text, no animation.
- **VoiceOver** — reads the full string regardless of scroll state.
- **Dynamic Type** — overflow is recomputed on font-size changes.

No extra code required.

## UIKit

Use ``MarqueeTextView`` in any UIKit hierarchy:

```swift
let label = MarqueeTextView()
label.text = "Your scrolling text here"
label.configuration = MarqueeConfiguration(speed: .adaptive, fadeEdges: true)
view.addSubview(label)
```
