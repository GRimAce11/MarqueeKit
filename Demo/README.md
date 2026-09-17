# MarqueeKit Demo

A small SwiftUI app that exercises the real components — used to record the README GIF.

## Run it

The project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from
`project.yml`, and references MarqueeKit by local path, so it builds without an SPM fetch:

```bash
cd Demo
xcodegen generate      # only needed if project.yml changed
open MarqueeKitDemo.xcodeproj
```

## Recording the GIF

```bash
DEV=<simulator-udid>
xcrun simctl status_bar $DEV override --time 9:41 --batteryState charged --batteryLevel 100
xcrun simctl launch $DEV com.grimace11.MarqueeKitDemo
xcrun simctl io $DEV recordVideo --codec h264 out.mov
```

Then crop and convert with ffmpeg.

## Known gap

`.glass` and `.modern` are deliberately absent from the showcase. Both clip their text
vertically — see the note in the root README's Known Issues.
