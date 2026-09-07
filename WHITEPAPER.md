# Nook Technical Whitepaper

**v1.0.0** | September 2026

A web browser that writes no browser code. Nook is a `WKWebView` inside a SwiftUI toolbar, shipped for macOS, iOS and iPadOS from one target.

## Core Mechanic: WebKit Is the Browser

Rendering, JavaScript, networking, cookies, back-forward cache, swipe navigation, reader-safe text sizing, password autofill and content blocking all live inside WebKit. Nook does not reimplement or wrap any of it. Each tab is one `WKWebView` owned by a `Page` object that also acts as its navigation delegate, mirroring five values into SwiftUI state: address, title, loading, can go back, can go forward.

## Address Resolution

One pure function, `resolve`, turns typed text into a URL. Text with a scheme loads as is. A single token with a dot gets `https://` in front. Anything else becomes a DuckDuckGo query. It is the only logic in the app and the only thing with unit tests beyond the tab list.

## Tabs

`Tabs` is an array of pages and a current id. Adding appends and selects; closing removes and selects the neighbour, and never closes the last one. Tabs live in memory for the process lifetime. Persisting them is a deliberate omission until there is a reason.

## Platform Split

The one `#if` per concern rule: `WebView` is an `NSViewRepresentable` on Mac and a `UIViewRepresentable` on iOS. iOS wraps the content in a `NavigationStack` because that is where its toolbar lives; macOS toolbars attach to the window. Keyboard shortcuts (⌘[, ⌘], ⌘R, ⌘T, ⌘W) are declared once and work on both.

## What Is Deliberately Missing

Bookmarks, history UI, downloads, extensions, sync, telemetry. Each is a feature, and each gets added when someone using Nook wants it, not before.
