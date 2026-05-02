import SwiftUI
import WebKit
import AVFoundation

/// Loads the bundled game from `Game/` (offline — no network required).
/// Service workers are not used on `file://` (see index.html); assets load directly from the app bundle.
struct LocalGameWebView: UIViewRepresentable {
    let scenePhase: ScenePhase

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    /// `crownDashDebug` → Xcode console. `crownDashGameCenter` → Game Center leaderboard score (native).
    final class Coordinator: NSObject, WKScriptMessageHandler {
        static let debugHandlerName = "crownDashDebug"
        static let gameCenterHandlerName = "crownDashGameCenter"
        var lastScenePhase: ScenePhase?

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case Self.debugHandlerName:
                if let text = message.body as? String {
                    print("[CrownDash JS]", text)
                } else {
                    print("[CrownDash JS]", String(describing: message.body))
                }
            case Self.gameCenterHandlerName:
                guard let score = Self.parseScorePayload(message.body) else { return }
                GameCenterManager.shared.submitHighScore(score)
            default:
                break
            }
        }

        private static func parseScorePayload(_ body: Any) -> Int? {
            if let n = body as? Int { return n }
            if let n = body as? Double { return Int(n) }
            if let n = body as? NSNumber { return n.intValue }
            if let dict = body as? [String: Any] {
                if let s = dict["score"] as? NSNumber { return s.intValue }
                if let s = dict["score"] as? Int { return s }
            }
            if let s = body as? String, let n = Int(s) { return n }
            return nil
        }
    }

    private static func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("[CrownDash iOS] Audio session setup failed:", error.localizedDescription)
        }
    }

    func makeUIView(context: Context) -> WKWebView {
        Self.configureAudioSession()

        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.suppressesIncrementalRendering = false

        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = preferences

        if #available(iOS 14.0, *) {
            config.limitsNavigationsToAppBoundDomains = false
        }

        // Large GLBs fail under file:// (XHR/fetch "Load failed"); serve Game/ assets via a custom scheme instead.
        config.setURLSchemeHandler(GameAssetSchemeHandler(), forURLScheme: "appassets")
        let injectAssetsScheme = "window.__CD_USE_APP_ASSETS_SCHEME=1;"
        config.userContentController.addUserScript(
            WKUserScript(source: injectAssetsScheme, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        )
        config.userContentController.addUserScript(
            WKUserScript(source: Self.iosPolishScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        )

        config.userContentController.add(context.coordinator, name: Coordinator.debugHandlerName)
        config.userContentController.add(context.coordinator, name: Coordinator.gameCenterHandlerName)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.06, green: 0.04, blue: 0.12, alpha: 1)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.delaysContentTouches = false
        webView.scrollView.canCancelContentTouches = true
        webView.allowsBackForwardNavigationGestures = false
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }

        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Game") {
            // Entire .app bundle — avoids WKWebView blocking ES-module / asset loads under file://
            let accessRoot = Bundle.main.bundleURL
            webView.loadFileURL(url, allowingReadAccessTo: accessRoot)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard context.coordinator.lastScenePhase != scenePhase else { return }
        context.coordinator.lastScenePhase = scenePhase

        let eventName = scenePhase == .active ? "crownDashResume" : "crownDashPause"
        uiView.evaluateJavaScript("window.dispatchEvent(new Event('\(eventName)'));") { _, error in
            if let error {
                print("[CrownDash iOS] lifecycle JS failed:", error.localizedDescription)
            }
        }
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: Coordinator.debugHandlerName)
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: Coordinator.gameCenterHandlerName)
    }

    private static let iosPolishScript = """
    (() => {
      const style = document.createElement('style');
      style.textContent = `
        html, body, canvas, button {
          -webkit-touch-callout: none !important;
          -webkit-user-select: none !important;
          user-select: none !important;
        }
        button { touch-action: manipulation !important; }
        .screen--menu { min-height: 100svh; }
      `;
      document.head.appendChild(style);
      document.documentElement.classList.add('ios-app');
      document.addEventListener('gesturestart', event => event.preventDefault(), { passive: false });
      window.addEventListener('crownDashPause', () => {
        try {
          if (typeof running !== 'undefined' && running && !paused && typeof togglePause === 'function') togglePause();
          if (typeof audioCtx !== 'undefined' && audioCtx && audioCtx.state === 'running') audioCtx.suspend();
        } catch (error) {
          window.webkit?.messageHandlers?.crownDashDebug?.postMessage?.('pause hook failed: ' + error.message);
        }
      });
      window.addEventListener('crownDashResume', () => {
        try {
          if (typeof resumeAudioIfNeeded === 'function') resumeAudioIfNeeded();
        } catch (error) {
          window.webkit?.messageHandlers?.crownDashDebug?.postMessage?.('resume hook failed: ' + error.message);
        }
      });
    })();
    """
}

/// Brief branded overlay after the system launch screen; fades to reveal the game menu.
private struct SplashOverlay: View {
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var introContent = false
    @State private var overlayOpacity = 1.0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.05, blue: 0.12),
                    Color(red: 0.16, green: 0.08, blue: 0.26),
                    Color(red: 0.07, green: 0.04, blue: 0.11)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(red: 0.55, green: 0.28, blue: 0.72).opacity(0.28))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: -90, y: -140)

            Circle()
                .fill(Color(red: 0.98, green: 0.58, blue: 0.85).opacity(0.15))
                .frame(width: 220, height: 220)
                .blur(radius: 55)
                .offset(x: 120, y: 180)

            VStack(spacing: 18) {
                Image("SplashLogo")
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 108, height: 108)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.42), radius: 22, y: 14)
                    .scaleEffect(introContent ? 1 : 0.9)
                    .opacity(introContent ? 1 : 0)

                VStack(spacing: 6) {
                    Text("Adelynn's Crown Dash")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)

                    Text("Princess Run · Lumendale")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.72))
                }
                .opacity(introContent ? 1 : 0)

                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.white.opacity(0.88))
                    .padding(.top, 8)
                    .opacity(introContent ? 1 : 0)
            }
            .padding(28)
        }
        .opacity(overlayOpacity)
        .onAppear {
            let spring = reduceMotion ? 0.01 : 0.52
            withAnimation(.spring(response: spring, dampingFraction: 0.82)) {
                introContent = true
            }

            let delay = reduceMotion ? 0.75 : 1.65
            let fadeOut = reduceMotion ? 0.22 : 0.48
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: fadeOut)) {
                    overlayOpacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + fadeOut + 0.06) {
                    onFinished()
                }
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSplashOverlay = true

    var body: some View {
        ZStack {
            LocalGameWebView(scenePhase: scenePhase)
                .ignoresSafeArea()

            if showSplashOverlay {
                SplashOverlay {
                    showSplashOverlay = false
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .statusBarHidden(true)
    }
}

#Preview {
    ContentView()
}
