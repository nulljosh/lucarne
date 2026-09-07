import SwiftUI
import WebKit

@main
struct NookApp: App {
    var body: some Scene {
        WindowGroup { BrowserView() }
        #if os(macOS)
        .commands { CommandGroup(replacing: .newItem) {} }
        #endif
    }
}

/// Turns what the user typed into a URL: a scheme-less host gets https, anything else becomes a search.
func resolve(_ input: String) -> URL? {
    let s = input.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !s.isEmpty else { return nil }
    if s.contains("://"), let u = URL(string: s) { return u }
    if !s.contains(" "), s.contains("."), let u = URL(string: "https://" + s) { return u }
    var c = URLComponents(string: "https://duckduckgo.com/")!
    c.queryItems = [URLQueryItem(name: "q", value: s)]
    return c.url
}

@MainActor
final class Page: NSObject, ObservableObject, WKNavigationDelegate {
    let web = WKWebView()
    @Published var address = ""
    @Published var title = ""
    @Published var loading = false
    @Published var canBack = false
    @Published var canForward = false

    override init() {
        super.init()
        web.navigationDelegate = self
        web.allowsBackForwardNavigationGestures = true
        go("https://duckduckgo.com")
    }

    func go(_ input: String) {
        guard let u = resolve(input) else { return }
        web.load(URLRequest(url: u))
    }

    private func sync() {
        address = web.url?.absoluteString ?? address
        title = web.title ?? ""
        loading = web.isLoading
        canBack = web.canGoBack
        canForward = web.canGoForward
    }
    func webView(_ w: WKWebView, didStartProvisionalNavigation n: WKNavigation!) { sync() }
    func webView(_ w: WKWebView, didFinish n: WKNavigation!) { sync() }
    func webView(_ w: WKWebView, didFail n: WKNavigation!, withError e: Error) { sync() }
    func webView(_ w: WKWebView, didFailProvisionalNavigation n: WKNavigation!, withError e: Error) { sync() }
}

#if os(macOS)
struct WebView: NSViewRepresentable {
    let web: WKWebView
    func makeNSView(context: Context) -> WKWebView { web }
    func updateNSView(_ v: WKWebView, context: Context) {}
}
#else
struct WebView: UIViewRepresentable {
    let web: WKWebView
    func makeUIView(context: Context) -> WKWebView { web }
    func updateUIView(_ v: WKWebView, context: Context) {}
}
#endif

struct BrowserView: View {
    @StateObject private var page = Page()
    @FocusState private var editing: Bool

    var body: some View {
        WebView(web: page.web)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle(page.title)
            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    Button { page.web.goBack() } label: { Image(systemName: "chevron.left") }
                        .disabled(!page.canBack).keyboardShortcut("[", modifiers: .command)
                    Button { page.web.goForward() } label: { Image(systemName: "chevron.right") }
                        .disabled(!page.canForward).keyboardShortcut("]", modifiers: .command)
                }
                ToolbarItem(placement: .principal) {
                    TextField("Search or enter address", text: $page.address)
                        .textFieldStyle(.roundedBorder)
                        .focused($editing)
                        .onSubmit { page.go(page.address); editing = false }
                        #if os(iOS)
                        .keyboardType(.webSearch).textInputAutocapitalization(.never).autocorrectionDisabled()
                        #endif
                        .frame(minWidth: 240, idealWidth: 600)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { if page.loading { page.web.stopLoading() } else { page.web.reload() } } label: {
                        Image(systemName: page.loading ? "xmark" : "arrow.clockwise")
                    }.keyboardShortcut("r", modifiers: .command)
                }
            }
            .wrappedInNavigation()
    }
}

extension View {
    /// iOS needs a NavigationStack to host a toolbar; macOS toolbars attach to the window directly.
    @ViewBuilder func wrappedInNavigation() -> some View {
        #if os(iOS)
        NavigationStack { self.navigationBarTitleDisplayMode(.inline) }
        #else
        self
        #endif
    }
}
