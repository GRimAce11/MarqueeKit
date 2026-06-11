# ``MarqueeKit``

Modern scrolling text and content components for SwiftUI and UIKit.

## Overview

MarqueeKit provides a suite of production-ready marquee components that feel
native to Apple platforms. Every component automatically detects overflow,
adapts to accessibility settings, and works out of the box with zero
configuration.

```swift
// Zero config — just works
MarqueeText("Breaking News: Apple releases iOS 18 with major AI features")

// Fully customised
MarqueeText(headline)
    .speed(.adaptive)
    .fadeEdges(true)
    .pauseOnTouch(true)
    .marqueeTheme(.glass)
```

## Topics

### Components

- ``MarqueeText``
- ``MarqueeContent``
- ``MarqueeTicker``
- ``MarqueeBanner``
- ``MarqueeGroup``

### Configuration

- ``MarqueeConfiguration``
- ``MarqueeSpeed``
- ``MarqueeDirection``
- ``MarqueeEffect``
- ``MarqueeTheme``
- ``MarqueeHaptics``
- ``MarqueeReadingMode``
- ``MarqueeTrigger``

### Engine

- ``MarqueeEngine``
- ``MarqueeSyncController``

### UIKit

- ``MarqueeTextView``
- ``MarqueeHostingView``

### Guides

- <doc:GettingStarted>
- <doc:CustomizationGuide>
