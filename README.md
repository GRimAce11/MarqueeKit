# MarqueeKit

Modern scrolling text and content components for SwiftUI and UIKit.

![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange)
![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

---

## Overview

MarqueeKit provides production-ready scrolling components that feel native to Apple platforms. Smart overflow detection means you never configure whether scrolling is needed — the SDK figures it out automatically.

```swift
// Zero config. Just works.
MarqueeText("Breaking News: Apple releases iOS 18 with major AI features")

// Fully customised.
MarqueeText(headline)
    .speed(.adaptive)
    .fadeEdges(true)
    .pauseOnTouch(true)
    .marqueeTheme(.glass)
```

---

## Requirements

| | Minimum |
|--|--|
| iOS | 17.0 |
| macOS | 14.0 |
| tvOS | 17.0 |
| Swift | 5.9 |
| Xcode | 15.0 |

---

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies**

```
https://github.com/GRimAce11/MarqueeKit
```

Or add to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/GRimAce11/MarqueeKit", from: "1.0.0"),
]
```

Then add `"MarqueeKit"` to your target dependencies.

---

## Components

| Component | Purpose |
|-----------|---------|
| `MarqueeText` | Scrolling plain text |
| `MarqueeContent` | Scrolling any SwiftUI view |
| `MarqueeTicker` | Multi-item news / stock ticker |
| `MarqueeBanner` | Single-message notification banner |
| `MarqueeGroup` | Synchronised group of marquees |

---

## Usage

### MarqueeText

```swift
import MarqueeKit

// Simple
MarqueeText("Apple WWDC 2025 — Watch the keynote live")

// With modifiers
MarqueeText("Live coverage of WWDC 2025 — Session recordings available now")
    .speed(.adaptive)
    .direction(.left)
    .fadeEdges(true)
    .pauseOnTouch(true)
    .readingMode(.smart)
    .marqueeTheme(.glass)
    .haptics(.loop)
```

### MarqueeContent

Scroll any SwiftUI view — icons, buttons, badges, custom layouts:

```swift
MarqueeContent {
    HStack(spacing: 12) {
        Image(systemName: "star.fill").foregroundStyle(.yellow)
        Text("Featured Item of the Day").fontWeight(.semibold)
        Button("Learn more") { }
    }
}
.speed(.medium)
.fadeEdges(true)
```

### MarqueeTicker

Purpose-built for live data feeds:

```swift
MarqueeTicker(stockQuotes) { quote in
    HStack(spacing: 6) {
        Text(quote.symbol).fontWeight(.bold)
        Text(quote.price, format: .currency(code: "USD"))
        Text(quote.changeFormatted)
            .foregroundStyle(quote.isPositive ? .green : .red)
    }
}
.marqueeTheme(.ticker)
.speed(.medium)
.fadeEdges(true)

// Strings shorthand
MarqueeTicker(["AAPL · $192", "MSFT · $415", "GOOGL · $175"])
```

### MarqueeBanner

Notification-style banners:

```swift
MarqueeBanner(
    "New update available — tap to install version 18.2",
    icon: "arrow.down.circle.fill"
)
.marqueeTheme(.glass)
.speed(.slow)
```

### MarqueeGroup

Wrap multiple marquees in a `MarqueeGroup` to make them scroll in perfect lockstep. The group waits until every child has measured its content, then fires a single synchronized start so all animations begin from position 0 at the same moment. It also computes a shared scroll speed from the maximum of all members' resolved speeds, so engines with different font sizes or content lengths travel at the same velocity and never drift apart.

```swift
MarqueeGroup {
    MarqueeText("AAPL  $192.40  +1.2%   MSFT  $415.00  +0.8%")
    MarqueeText("BTC  $67,840  +3.2%   ETH  $3,520  -1.8%")
}
.marqueeTheme(.ticker)
```

Control the whole group from anywhere in the hierarchy:

```swift
@Environment(\.marqueeGroupSyncController) var sync

Button("Pause All") { sync?.pauseAll() }
Button("Resume")    { sync?.resumeAll() }
Button("Re-sync")   { sync?.synchronize() } // resets all to the same start position
```

All children share a single reference `Date` for their offset computation — pausing, resuming, and re-syncing are applied atomically across the group.

---

## Modifiers

All components share the same fluent modifier API:

| Modifier | Description |
|----------|-------------|
| `.speed(.adaptive)` | Auto-compute ideal speed |
| `.speed(.fixed(80))` | Constant pixels per second |
| `.direction(.left)` | `.left` `.right` `.up` `.down` |
| `.fadeEdges(true)` | Gradient fade at both edges |
| `.pauseOnTouch(true)` | Pause on user touch |
| `.readingMode(.smart)` | Auto pause for reading |
| `.trigger(.tap)` | Scroll once on tap |
| `.effect(.elastic)` | Visual effect during scroll |
| `.marqueeTheme(.glass)` | Visual container theme |
| `.haptics(.loop)` | Haptic on each loop |
| `.loopSpacing(40)` | Gap between repetitions |
| `.liveActivityOptimized()` | Widget / Live Activity mode |

---

## Themes

```swift
.marqueeTheme(.minimal)  // No background (default)
.marqueeTheme(.glass)    // Frosted glass, rounded corners
.marqueeTheme(.ticker)   // Dark background, green text
.marqueeTheme(.modern)   // Card with subtle border

// Custom
.marqueeTheme(MarqueeTheme(
    backgroundColor: .indigo,
    foregroundColor: .white,
    cornerRadius: 10,
    padding: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
))
```

---

## Speed

```swift
.speed(.slow)          //  30 px/s
.speed(.medium)        //  60 px/s
.speed(.fast)          // 120 px/s
.speed(.adaptive)      // auto — based on content length
.speed(.fixed(90))     // exactly 90 px/s
.speed(.custom { ctx in ctx.overflowDistance / 5 })
```

---

## UIKit

Use `MarqueeTextView` anywhere in a UIKit hierarchy:

```swift
import MarqueeKit

let label = MarqueeTextView()
label.text = "Your scrolling message"
label.configuration = MarqueeConfiguration(
    speed: .adaptive,
    fadeEdges: true,
    theme: .glass
)
view.addSubview(label)
```

For arbitrary SwiftUI content in UIKit:

```swift
let host = MarqueeHostingView {
    MarqueeContent {
        HStack { Image(systemName: "bolt.fill"); Text("Live") }
    }
    .speed(.medium)
}
view.addSubview(host)
```

---

## Accessibility

MarqueeKit handles accessibility automatically:

- **Reduce Motion** — Static text, no animation overhead.
- **VoiceOver** — Reads the full string; not interrupted by scroll.
- **Dynamic Type** — Overflow recomputed on font-size changes.

---

## Architecture

```
MarqueeKit
├── Components          MarqueeText, MarqueeContent, MarqueeTicker, MarqueeBanner
├── Core                MarqueeEngine (@Observable), SpeedCalculator, ReadingModeAnalyzer
├── Internal            MarqueeScrollCore (TimelineView renderer), SizeTracker, HapticsEngine
├── Group               MarqueeGroup, MarqueeSyncController
├── Effects             EffectModifiers (wave, parallax, depth, elastic)
├── Types               Configuration, Speed, Direction, Theme, Haptics …
└── UIKit               MarqueeTextView, MarqueeHostingView
```

The animation engine uses `TimelineView(.animation)` for mathematical offset
computation — no `CADisplayLink`, no `Timer`, no layout thrashing. The content
position is a pure function of elapsed time, making pause/resume and
synchronisation trivial and exact.

---

## License

MarqueeKit is available under the MIT license. See [LICENSE](LICENSE) for details.
