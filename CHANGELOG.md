# Changelog

All notable changes to MarqueeKit are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Demo app in `Demo/` showing every component and theme, and a README GIF recorded from it.

### Fixed

- Themed marquees no longer clip their text.
- The package now builds for tvOS, which `Package.swift` has always listed: haptics used
  `UIImpactFeedbackGenerator`, which tvOS does not have. Haptics are iOS-only and do nothing on
  macOS and tvOS, and `pauseOnTouch` has no effect on tvOS, which has no touch screen.

## [1.0.0] - 2026-06-24

First release.

### Added

- `MarqueeText` and `MarqueeContent`: scroll text or any view, but only when it overflows.
- `MarqueeTicker`, `MarqueeBanner` and `MarqueeGroup` (synchronised rows).
- Adaptive speed, edge fading, pause on touch, haptics and themes, as view modifiers.
- UIKit versions of the components.
- VoiceOver support and Reduce Motion handling.

[Unreleased]: https://github.com/GRimAce11/MarqueeKit/compare/1.0.0...HEAD
[1.0.0]: https://github.com/GRimAce11/MarqueeKit/releases/tag/1.0.0
