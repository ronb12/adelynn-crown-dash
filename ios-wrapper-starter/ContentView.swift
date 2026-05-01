import SwiftUI
import WebKit

struct LocalGameWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black

        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Game") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct ContentView: View {
    var body: some View {
        LocalGameWebView()
            .ignoresSafeArea()
            .statusBarHidden(true)
    }
}
