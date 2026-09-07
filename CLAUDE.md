# Lucarne

v1.0.0, WebKit browser. One SwiftUI file, one xcodegen target for iOS and macOS. No web build (it's a browser).

## Files

- `ios/App/LucarneApp.swift`: everything. `resolve()` turns input into a URL, `Page` wraps one `WKWebView` + nav delegate, `Tabs` holds pages, `PageView` is the chrome.
- `ios/Tests/LucarneTests.swift`: resolve + tabs.
- `landing/`: static page → lucarne.heyitsmejosh.com via `deploy.sh`.

## Build

```bash
cd ios && xcodegen generate
xcodebuild test -project Lucarne.xcodeproj -scheme Lucarne -destination 'platform=macOS'
xcodebuild build -project Lucarne.xcodeproj -scheme Lucarne -destination 'generic/platform=iOS Simulator'
```

## Rules

- WebKit does the browsing. Don't add a rendering, history or cookie layer; if the OS has it, use it.
- Tabs are in memory. Persist only when someone asks.
- ASC record not created yet. Run asc-name-creator first; "Lucarne" is likely taken.
