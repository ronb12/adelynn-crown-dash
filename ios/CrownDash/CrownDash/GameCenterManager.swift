import Foundation
import GameKit
import UIKit

final class GameCenterManager {
    static let shared = GameCenterManager()

    private let highScoreKey = "crownDash.highScore"
    private let leaderboardID = "com.bradleyvirtual.crowndash.leaderboard.highscore"
    private let crownMasterID = "com.bradleyvirtual.crowndash.achievement.crownmaster"
    private var authStarted = false
    private var isAuthenticated: Bool { GKLocalPlayer.local.isAuthenticated }

    private init() {}

    var highScore: Int {
        UserDefaults.standard.integer(forKey: highScoreKey)
    }
    
    func authenticate() {
        guard !authStarted else { return }
        authStarted = true
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController {
                #if targetEnvironment(simulator)
                print("[CrownDash GameCenter] Simulator auth prompt skipped for gameplay testing.")
                return
                #else
                Self.topViewController()?.present(viewController, animated: true)
                return
                #endif
            }
            if let error {
                print("[CrownDash GameCenter] Auth failed:", error.localizedDescription)
            }
        }
    }

    func submitHighScore(_ rawScore: Int) {
        let score = max(0, rawScore)
        if score > highScore {
            UserDefaults.standard.set(score, forKey: highScoreKey)
        }
        guard isAuthenticated else { return }
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { error in
            if let error {
                print("[CrownDash GameCenter] Leaderboard submit failed:", error.localizedDescription)
            }
        }
        if score >= 1000 {
            reportAchievement(id: crownMasterID, percent: 100)
        }
    }
    
    func reportAchievement(id: String, percent: Double) {
        guard isAuthenticated else { return }
        let achievement = GKAchievement(identifier: id)
        achievement.percentComplete = percent
        achievement.showsCompletionBanner = true
        GKAchievement.report([achievement]) { error in
            if let error {
                print("[CrownDash GameCenter] Achievement failed:", error.localizedDescription)
            }
        }
    }
    
    private static func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let root = scenes
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
        var top = root
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
