import SwiftUI
import SpriteKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var scene = NativeCrownDashScene(size: CGSize(width: 390, height: 844))

    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: scene, options: [.ignoresSiblingOrder])
                .ignoresSafeArea()
                .onAppear {
                    scene.scaleMode = .resizeFill
                    scene.size = proxy.size
                    scene.layoutScene()
                    let process = ProcessInfo.processInfo
                    if process.arguments.contains("-CrownDashMechanicsTest") {
                        scene.startDebugMechanicsTest()
                    } else if process.arguments.contains("-CrownDashAutoRun") || process.environment["CROWN_DASH_AUTO_RUN"] == "1" {
                        scene.startDebugAutoRunForScreenshots()
                    }
                }
                .onChange(of: proxy.size) { newSize in
                    scene.size = newSize
                    scene.layoutScene()
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        scene.resumeFromAppLifecycle()
                    } else {
                        scene.pauseForAppLifecycle()
                    }
                }
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
    }
}

#Preview {
    ContentView()
}
