import Foundation
import GameKit
import UIKit

/// Leaderboard ID — create a matching leaderboard in App Store Connect (Games → Game Center).
enum GameCenterLeaderboards {
    static let highScore = "com.bradleyvirtual.crowndash.leaderboard.highscore"
}

final class GameCenterManager: NSObject {
    static let shared = GameCenterManager()

    private var authStarted = false

    private override init() {
        super.init()
    }

    /// Call once at launch; presents Game Center sign-in UI only when required.
    func authenticate(from viewController: UIViewController?) {
        guard !authStarted else { return }
        authStarted = true

        GKLocalPlayer.local.authenticateHandler = { [weak self] gcViewController, error in
            if let gcViewController {
                guard let root = Self.topViewController(from: viewController) else {
                    print("[CrownDash GC] No presenter for Game Center UI")
                    return
                }
                root.present(gcViewController, animated: true)
                return
            }
            if let error {
                print("[CrownDash GC] Auth error:", error.localizedDescription)
                return
            }
            if GKLocalPlayer.local.isAuthenticated {
                print("[CrownDash GC] Authenticated as", GKLocalPlayer.local.displayName)
            } else {
                print("[CrownDash GC] Player not authenticated")
            }
            _ = self // keep singleton alive
        }
    }

    func submitHighScore(_ rawScore: Int) {
        let score = max(0, rawScore)
        guard GKLocalPlayer.local.isAuthenticated else {
            print("[CrownDash GC] Skip submit — not authenticated")
            return
        }

        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [GameCenterLeaderboards.highScore]
        ) { error in
            if let error {
                print("[CrownDash GC] Submit failed:", error.localizedDescription)
            } else {
                print("[CrownDash GC] Submitted score", score)
            }
        }
    }

    private static func topViewController(from preferred: UIViewController?) -> UIViewController? {
        if let preferred {
            var top = preferred
            while let presented = top.presentedViewController {
                top = presented
            }
            return top
        }
        guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first(where: { $0.activationState == .foregroundActive }),
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first { $0.isKeyWindow }?
                .rootViewController
        }
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}
