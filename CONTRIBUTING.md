# Contributing to MarqueeKit

Bug reports, feature requests and pull requests are welcome.

## Filing an issue

Use the issue templates and include:

- Platform and OS version (iOS, macOS or tvOS), and device or simulator
- Xcode and Swift versions
- SwiftUI or UIKit, and which component (`MarqueeText`, `MarqueeContent`, `MarqueeTicker`, …)
- The modifiers and theme you applied
- Steps to reproduce, and expected vs actual behaviour

## Pull requests

- Keep PRs focused: one concern per PR.
- `swift build` and `swift test` must pass. CI also builds for the iOS and tvOS simulators,
  because the UIKit components are invisible to a macOS build — check those jobs on your PR.
- Add or update tests when you change behaviour (`Tests/MarqueeKitTests`).
- Add your change to `CHANGELOG.md` under `[Unreleased]`.
- Public API needs a doc comment: a one-sentence summary, then parameters where they are not obvious.
- Respect Reduce Motion and VoiceOver in anything that animates.

## Building locally

```sh
swift build
swift test
```

The demo app in `Demo/` uses the package from this folder, so it shows your changes immediately.

## Releasing

1. Move `[Unreleased]` in `CHANGELOG.md` into a new version section with the date.
2. Update the `from:` version in the README's install snippet.
3. Commit, then tag without a `v` prefix: `git tag -a X.Y.Z -m "X.Y.Z"`.
4. Push the commit and the tag, and create a GitHub release from the changelog section.
