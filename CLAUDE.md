# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

This is an Xcode iOS project. Build and run using:

```bash
# Build from command line
xcodebuild -project TennisChartingApp/TennisChartingApp.xcodeproj -scheme TennisChartingApp -sdk iphonesimulator build

# Run tests (when test targets are added)
xcodebuild -project TennisChartingApp/TennisChartingApp.xcodeproj -scheme TennisChartingApp -sdk iphonesimulator test
```

Or open `TennisChartingApp/TennisChartingApp.xcodeproj` in Xcode and use Cmd+B to build, Cmd+R to run.

## Architecture

- **Platform**: iOS (iPhone and iPad)
- **UI Framework**: SwiftUI
- **Minimum iOS Version**: 26.2
- **Swift Version**: 5.0

### Project Structure

```
TennisChartingApp/
├── TennisChartingApp.xcodeproj    # Xcode project configuration
└── TennisChartingApp/
    ├── TennisChartingAppApp.swift  # App entry point (@main)
    ├── ContentView.swift           # Root view
    └── Assets.xcassets/            # App icons and colors
```

### Key Configuration

- Bundle ID: `com.hassan.TennisChartingApp`
- Uses Swift strict concurrency with `MainActor` default isolation
- Supports all orientations on iPad, portrait and landscape on iPhone
