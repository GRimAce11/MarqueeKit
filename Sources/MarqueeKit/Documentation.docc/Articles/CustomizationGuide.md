# Customisation Guide

Deep dive into speed, themes, effects, and advanced configuration.

## Speed

The ``MarqueeSpeed`` type controls how fast content scrolls.

### Presets

```swift
MarqueeText(text).speed(.slow)    //  30 px/s
MarqueeText(text).speed(.medium)  //  60 px/s
MarqueeText(text).speed(.fast)    // 120 px/s
```

### Adaptive Speed

`.adaptive` analyses the overflow distance and targets a reading time of
roughly 4 – 6 seconds for a comfortable, natural feel:

```swift
MarqueeText(longHeadline).speed(.adaptive)
```

### Fixed Speed

```swift
MarqueeText(text).speed(.fixed(80))  // exactly 80 pixels per second
```

### Custom Speed

Compute speed dynamically based on content metrics:

```swift
MarqueeText(text).speed(.custom { context in
    // context.overflowDistance, .contentWidth, .containerWidth, .characterCount
    return context.overflowDistance / 5
})
```

## Themes

Apply a visual container to the marquee with ``MarqueeTheme``:

```swift
MarqueeText(text).marqueeTheme(.minimal)  // no background (default)
MarqueeText(text).marqueeTheme(.glass)    // frosted glass, rounded
MarqueeText(text).marqueeTheme(.ticker)   // dark bg, green text
MarqueeText(text).marqueeTheme(.modern)   // card with border
```

### Custom Theme

```swift
let myTheme = MarqueeTheme(
    backgroundColor: .indigo,
    foregroundColor: .white,
    cornerRadius: 8,
    padding: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
)

MarqueeText(text).marqueeTheme(myTheme)
```

## Effects

Visual effects are applied per-frame at GPU speed and do not affect performance:

```swift
MarqueeText(text).effect(.none)     // plain scrolling (default)
MarqueeText(text).effect(.elastic)  // bounce at loop boundary
```

## Reading Mode

Smart reading mode estimates how long the text takes to read and adds an
automatic pause after each scroll cycle:

```swift
MarqueeText(longArticleHeadline)
    .readingMode(.smart)

// Manual words-per-minute
MarqueeText(text)
    .readingMode(.wordsPerMinute(180))

// Fixed pause after each cycle
MarqueeText(text)
    .readingMode(.pauseAfterScroll(2.0))  // 2-second pause
```

## Triggers

By default, scrolling begins automatically. Change this with `.trigger()`:

```swift
// Tap once to scroll one cycle
MarqueeText(productName)
    .trigger(.tap)

// Full programmatic control
@State var engine: MarqueeEngine?

MarqueeText(text)
    .onAppear { engine = ... }

Button("Start") { engine?.start() }
Button("Pause") { engine?.pause() }
Button("Reset") { engine?.reset() }
```

## Haptics

Generate haptic feedback on each loop:

```swift
MarqueeText(text)
    .haptics(.loop)   // subtle on loop restart
    .haptics(.edge)   // on enter/exit edge
    .haptics(.full)   // both
```

## Live Activity & Widget Optimisation

Reduce frame rate and disable effects when running in a widget or Live Activity:

```swift
MarqueeText(text)
    .liveActivityOptimized(true)
```

## Synchronised Groups

Keep multiple marquees phase-aligned using ``MarqueeGroup``. The group uses cancel-and-replace debouncing to wait until every child has finished measuring its content — even when measurements arrive across separate async layout passes — then issues one synchronized start with a shared speed equal to the maximum of all members' resolved speeds. Every marquee begins from position 0 at the same instant and travels at the same velocity. Font size, content length, and speed preset do not cause drift:

```swift
MarqueeGroup {
    MarqueeText("Line 1 of data")
    MarqueeText("Line 2 of data")
    MarqueeContent { CustomRow() }
}
```

Pause, resume, or re-synchronise all marquees in the group at once:

```swift
@Environment(\.marqueeGroupSyncController) var sync

Button("Pause")  { sync?.pauseAll() }
Button("Resume") { sync?.resumeAll() }
Button("Sync")   { sync?.synchronize() }
```

Calling `synchronize()` resets every member to position 0 from a fresh shared start date — useful after content changes or to add a deliberate "restart all" control to your UI.
