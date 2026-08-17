import SpriteKit
import UIKit
import AudioToolbox

final class NativeCrownDashScene: SKScene {
    private enum Mode {
        case splash
        case menu
        case running
        case gameOver
        case paused
        case tutorial
        case settings
        case wardrobe
        case missions
        case upgrades
        case playroom
        case gift
        case spin
        case album
        case family
        case chapters
        case friends
    }

    private enum HazardKind {
        case thorn
        case tide
        case rock
        case beam
        case shadow
        case shell
        case starBeam
        case shadowImp
        case tideCrab
        case starWisp

        var ducksUnder: Bool {
            switch self {
            case .beam, .starBeam, .starWisp: return true
            default: return false
            }
        }

        var jumpsOver: Bool {
            switch self {
            case .rock, .shell, .tideCrab: return true
            default: return false
            }
        }

        var bloomsWithRose: Bool {
            switch self {
            case .thorn, .shadow, .shadowImp: return true
            default: return false
            }
        }

        var spawnHeight: CGFloat {
            if ducksUnder { return 70 }
            if self == .tide { return 22 }
            return 32
        }

        var warningMark: String {
            if ducksUnder { return "↓" }
            if jumpsOver { return "↑" }
            if bloomsWithRose { return "✿" }
            return "!"
        }
    }

    private enum Power: String {
        case bloom = "Rose Bloom"
        case tide = "Crystal Tide"
        case star = "Crown Sparkle"
    }
    
    private enum Zone: String, CaseIterable {
        case courtyard = "Castle Courtyard"
        case roseGarden = "Rose Garden"
        case crystalBridge = "Crystal Bridge"
        case ballroom = "Moonlit Ballroom"
        case moonlitGardens = "Moonlit Gardens"
        case oceanGate = "Ocean Gate"
        case starPalace = "Star Palace"
        
        var colors: (path: UIColor, trim: UIColor, lane: UIColor) {
            switch self {
            case .courtyard:
                return (UIColor(red: 0.17, green: 0.08, blue: 0.18, alpha: 1), UIColor(red: 0.95, green: 0.72, blue: 0.28, alpha: 0.9), UIColor(white: 1, alpha: 0.18))
            case .roseGarden:
                return (UIColor(red: 0.18, green: 0.07, blue: 0.13, alpha: 1), UIColor(red: 1.0, green: 0.45, blue: 0.68, alpha: 0.92), UIColor(red: 1, green: 0.75, blue: 0.84, alpha: 0.22))
            case .crystalBridge:
                return (UIColor(red: 0.05, green: 0.12, blue: 0.20, alpha: 1), UIColor(red: 0.54, green: 0.92, blue: 1, alpha: 0.95), UIColor(red: 0.75, green: 0.95, blue: 1, alpha: 0.24))
            case .ballroom:
                return (UIColor(red: 0.12, green: 0.07, blue: 0.22, alpha: 1), UIColor(red: 0.86, green: 0.66, blue: 1, alpha: 0.92), UIColor(red: 1, green: 0.88, blue: 0.55, alpha: 0.2))
            case .moonlitGardens:
                return (UIColor(red: 0.08, green: 0.10, blue: 0.16, alpha: 1), UIColor(red: 0.72, green: 0.86, blue: 1.0, alpha: 0.92), UIColor(red: 0.78, green: 0.90, blue: 1.0, alpha: 0.22))
            case .oceanGate:
                return (UIColor(red: 0.03, green: 0.14, blue: 0.22, alpha: 1), UIColor(red: 0.28, green: 0.86, blue: 0.92, alpha: 0.95), UIColor(red: 0.55, green: 0.95, blue: 0.90, alpha: 0.24))
            case .starPalace:
                return (UIColor(red: 0.08, green: 0.05, blue: 0.20, alpha: 1), UIColor(red: 1.0, green: 0.84, blue: 0.38, alpha: 0.94), UIColor(red: 1.0, green: 0.92, blue: 0.62, alpha: 0.22))
            }
        }
    }
    
    private enum Outfit: String, CaseIterable {
        case rose = "Rose Royal"
        case crystal = "Crystal Crown"
        case moon = "Moonlight Gown"
        case ballgown = "Ballgown"
        case winter = "Winter Cloak"
        case starlight = "Starlight"
        
        var cost: Int {
            switch self {
            case .rose: return 0
            case .crystal: return 80
            case .moon: return 160
            case .ballgown: return 180
            case .winter: return 220
            case .starlight: return 260
            }
        }
        
        var dress: UIColor {
            switch self {
            case .rose: return UIColor(red: 1, green: 0.48, blue: 0.78, alpha: 1)
            case .crystal: return UIColor(red: 0.42, green: 0.78, blue: 1, alpha: 1)
            case .moon: return UIColor(red: 0.62, green: 0.45, blue: 0.92, alpha: 1)
            case .ballgown: return UIColor(red: 0.86, green: 0.28, blue: 0.62, alpha: 1)
            case .winter: return UIColor(red: 0.78, green: 0.90, blue: 1.0, alpha: 1)
            case .starlight: return UIColor(red: 1.0, green: 0.86, blue: 0.42, alpha: 1)
            }
        }
        
        var cape: UIColor {
            switch self {
            case .rose: return UIColor(red: 0.94, green: 0.24, blue: 0.58, alpha: 0.72)
            case .crystal: return UIColor(red: 0.26, green: 0.62, blue: 1, alpha: 0.70)
            case .moon: return UIColor(red: 0.42, green: 0.28, blue: 0.76, alpha: 0.72)
            case .ballgown: return UIColor(red: 0.62, green: 0.12, blue: 0.42, alpha: 0.74)
            case .winter: return UIColor(red: 0.55, green: 0.72, blue: 0.92, alpha: 0.74)
            case .starlight: return UIColor(red: 0.92, green: 0.62, blue: 0.18, alpha: 0.74)
            }
        }

        var albumSlot: AlbumSlot {
            switch self {
            case .rose: return .roseRoyal
            case .crystal: return .crystalCrown
            case .moon: return .moonlight
            case .ballgown: return .ballgown
            case .winter: return .winter
            case .starlight: return .starlight
            }
        }
    }
    
    private enum MissionKind: String {
        case coins = "Collect 12 coins"
        case powers = "Clear 3 hazards with powers"
        case dashes = "Dash 6 times"
        case ducks = "Duck under 4 beams"
    }
    
    private enum PowerUpKind: CaseIterable {
        case shield
        case magnet
        case boost
        case revive
        
        var title: String {
            switch self {
            case .shield: return "Shield"
            case .magnet: return "Magnet"
            case .boost: return "Boost"
            case .revive: return "Revive"
            }
        }
    }
    
    private enum ControlInput {
        case left
        case right
        case jump
        case duck
        case power
    }
    
    private struct Mission {
        let kind: MissionKind
        let target: Int
        let reward: Int
        var progress: Int = 0
        var completed: Bool { progress >= target }
    }

    private struct Obstacle {
        let node: SKNode
        let kind: HazardKind
        let lane: Int?
        var scoredCloseCall: Bool = false
    }

    private struct Coin {
        let node: SKNode
        var risky: Bool
    }
    
    private struct PowerUpNode {
        let node: SKNode
        let kind: PowerUpKind
    }
    
    private struct BonusNode {
        let node: SKNode
        let value: Int
        var isChapterItem: Bool = false
        var isKofi: Bool = false
    }

    /// Floating ledge the player can land on (surface at node.y).
    private struct Platform {
        let node: SKNode
        let halfWidth: CGFloat
    }

    private let world = SKNode()
    private let environmentLayer = SKNode()
    private let hud = SKNode()
    private let menuLayer = SKNode()
    private let fxLayer = SKNode()
    private let backgroundArt = SKSpriteNode(imageNamed: "SplashBackground")
    private let player = SKNode()
    private let scorePanel = SKShapeNode()
    private let statusPanel = SKShapeNode()
    private let missionPanel = SKShapeNode()
    private let healthBarBack = SKShapeNode()
    private let healthBarFill = SKShapeNode()
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let coinLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let healthLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let powerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let messageLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let leftControl = SKShapeNode()
    private let rightControl = SKShapeNode()
    private let jumpControl = SKShapeNode()
    private let duckControl = SKShapeNode()
    private let powerControl = SKShapeNode()
    private let leftControlLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let rightControlLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let jumpControlLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let duckControlLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let powerControlLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let startButton = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let restartButton = SKLabelNode(fontNamed: "AvenirNext-Heavy")
    private let zoneLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let missionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let tutorialLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let pauseButton = SKShapeNode()
    private let pauseButtonLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")

    private var mode: Mode = .splash
    private var lastUpdateTime: TimeInterval = 0
    private var score = 0
    private var coins = 0
    private var health = 100
    private static let distanceScorePerSecond: CGFloat = 12
    private static let maxComboMultiplier = 2
    private static let comboActionsPerMultiplier = 8
    private var shieldCharges = 1
    private var playerLane = 1
    private var playerVelocityX: CGFloat = 0
    private var playerVelocityY: CGFloat = 0
    private var playerGrounded = true
    private var jumpCount = 0
    private var dashTimer: CGFloat = 0
    private var duckTimer: CGFloat = 0
    private var duckHeld = false
    private var duckDustTimer: CGFloat = 0
    /// Sweeps 0 → 1 and always runs to completion, so the roll can never leave the rig rotated.
    private var flipProgress: CGFloat = 0
    private var flipActive = false
    private static let duckDuration: CGFloat = 0.62
    private static let flipDuration: CGFloat = 0.52
    /// Time allowed to finish the remaining rotation once she touches down mid-roll.
    private static let flipRecovery: CGFloat = 0.16
    /// Crouch pose targets. Hips drop enough to clear a beam while both feet stay planted.
    /// Negative torso pitch leans the chest forward over the lead knee (positive pitched her
    /// the wrong way — that was the old baseball-slide lean).
    private static let duckHipDrop: CGFloat = 19
    private static let duckTorsoPitch: CGFloat = -0.28
    private static let duckNearLegRot: CGFloat = 1.02
    private static let duckFarLegRot: CGFloat = -0.94
    private var invincibleTimer: CGFloat = 0
    private var magnetTimer: CGFloat = 0
    private var boostTimer: CGFloat = 0
    private var power: Power = .bloom
    private var spawnTimer: CGFloat = 0
    private var coinTimer: CGFloat = 0
    private var powerUpTimer: CGFloat = 0
    private var bonusTimer: CGFloat = 0
    private var platformTimer: CGFloat = 0
    private var environmentTimer: CGFloat = 0
    private var speedLineTimer: CGFloat = 0
    private var powerStreak = 0
    private var comboCount = 0
    private var comboTimer: CGFloat = 0
    private var scoreCarry: CGFloat = 0
    private var runTime: CGFloat = 0
    private var characterPoseTime: CGFloat = 0
    /// Footfall tracking so dust puffs fire once per step.
    private var lastFootfallIndex = 0
    /// 1 → 0 decay driving landing squash on the rig.
    private var landSquash: CGFloat = 0
    /// 1 → 0 punch on takeoff so the first frames tuck extra hard.
    private var jumpPunch: CGFloat = 0
    private var afterimageTimer: CGFloat = 0
    /// Debug-only: auto-hop onto approaching platforms so the mechanic can be tested headlessly.
    private var debugAutoPlatformJump = false
    private var debugMechanicsTestActive = false
    private var debugLogTimer: CGFloat = 0
    private var obstacles: [Obstacle] = []
    private var coinNodes: [Coin] = []
    private var powerUpNodes: [PowerUpNode] = []
    private var bonusNodes: [BonusNode] = []
    private var platforms: [Platform] = []
    private var laneGuides: [SKShapeNode] = []
    private var activeControlTouches: [ObjectIdentifier: ControlInput] = [:]
    private var leftPressed = false
    private var rightPressed = false
    private var totalCoins = UserDefaults.standard.integer(forKey: "crownDash.totalCoins")
    private var selectedOutfit = Outfit(rawValue: UserDefaults.standard.string(forKey: "crownDash.selectedOutfit") ?? "") ?? .rose
    private var unlockedOutfits: Set<String> = {
        let saved = UserDefaults.standard.stringArray(forKey: "crownDash.unlockedOutfits") ?? [Outfit.rose.rawValue]
        return Set(saved)
    }()
    private var currentZone: Zone = .courtyard
    private var missions: [Mission] = [
        Mission(kind: .coins, target: 12, reward: 20),
        Mission(kind: .powers, target: 3, reward: 30),
        Mission(kind: .dashes, target: 6, reward: 25)
    ]
    private var completedMissionKinds: Set<MissionKind> = []
    private var reviveTokens = 0
    private var shieldLevel = UserDefaults.standard.integer(forKey: "crownDash.upgrade.shield")
    private var magnetLevel = UserDefaults.standard.integer(forKey: "crownDash.upgrade.magnet")
    private var boostLevel = UserDefaults.standard.integer(forKey: "crownDash.upgrade.boost")
    private var tutorialStep = 0
    private var tutorialSeen = UserDefaults.standard.bool(forKey: "crownDash.tutorialSeen")
    private var soundEnabled = UserDefaults.standard.object(forKey: "crownDash.soundEnabled") as? Bool ?? true
    private var hapticsEnabled = UserDefaults.standard.object(forKey: "crownDash.hapticsEnabled") as? Bool ?? true
    private var reducedMotion = UserDefaults.standard.object(forKey: "crownDash.reducedMotion") as? Bool ?? UIAccessibility.isReduceMotionEnabled
    private let retention = CrownDashRetention.shared
    private let sparkCompanion = SKNode()
    private let familyGhost = SKNode()
    private var ghostSamples: [GhostSample] = []
    private var ghostSampleTimer: CGFloat = 0
    private var coyoteTimer: CGFloat = 0
    private var collectedChapterItem = false
    private var metKofi = false
    private var lastRecapStars = 1
    private var lastRecapPraise = "What a dash, Princess!"
    private var lastSurviveSecond = 0
    private var didAutoPresentGift = false
    private var characterSelectFromPlayroom = false
    private var paintedTextureCache: [String: SKTexture] = [:]
    private var selectedRunner: FeaturedRunner { retention.runner }
    private var featuredFriend: String {
        "\(selectedRunner.title) — \(selectedRunner.blurb)"
    }

    private var homeTitleText: String {
        let parts = selectedRunner.title.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0])\n\(parts.dropFirst().joined(separator: " "))"
        }
        return selectedRunner.title
    }

    private var isLandscape: Bool { size.width > size.height + 24 }
    private var groundY: CGFloat { max(isLandscape ? 96 : 118, size.height * (isLandscape ? 0.24 : 0.20)) }
    private var pathWidth: CGFloat { min(size.width * 0.82, 560) }
    private var playerSize: CGSize { CGSize(width: 58, height: 108) }
    private var playerX: CGFloat { size.width * (isLandscape ? 0.16 : 0.20) }

    private var menuSafeTop: CGFloat {
        size.height - max(isLandscape ? 12 : 52, (view?.safeAreaInsets.top ?? 0) + 6)
    }

    private var menuSafeBottom: CGFloat {
        max(isLandscape ? 14 : 28, (view?.safeAreaInsets.bottom ?? 0) + 8)
    }

    private func spacedYs(_ count: Int, top: CGFloat? = nil, bottom: CGFloat? = nil) -> [CGFloat] {
        let t = top ?? menuSafeTop - (isLandscape ? 40 : 72)
        let b = bottom ?? menuSafeBottom + (isLandscape ? 26 : 44)
        guard count > 1 else { return [(t + b) / 2] }
        let step = (t - b) / CGFloat(count - 1)
        return (0..<count).map { t - CGFloat($0) * step }
    }

    private func landscapeColumns() -> (left: CGFloat, right: CGFloat, width: CGFloat) {
        let width = min(340, size.width * 0.40)
        let gap: CGFloat = 18
        return (size.width / 2 - width / 2 - gap / 2, size.width / 2 + width / 2 + gap / 2, width)
    }

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.04, green: 0.04, blue: 0.12, alpha: 1)
        view.isMultipleTouchEnabled = true
        backgroundArt.zPosition = -100
        environmentLayer.zPosition = -16
        addChild(backgroundArt)
        addChild(environmentLayer)
        addChild(world)
        addChild(fxLayer)
        addChild(hud)
        addChild(menuLayer)
        buildPlayer()
        world.addChild(player)
        sparkCompanion.zPosition = 3
        sparkCompanion.isHidden = true
        world.addChild(sparkCompanion)
        familyGhost.zPosition = 1
        familyGhost.alpha = 0.42
        familyGhost.isHidden = true
        world.addChild(familyGhost)
        buildHUD()
        syncOutfitsFromRetention()
        flushBankCoins()
        showSplash()
        layoutScene()
    }

    func layoutScene() {
        guard size.width > 0, size.height > 0 else { return }
        updateBackground()
        layoutHUD()
        layoutPlayer(animated: false)
        layoutMenu()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard oldSize != .zero, oldSize != size, size.width > 1, size.height > 1 else { return }
        layoutScene()
    }

    func pauseForAppLifecycle() {
        if mode == .running {
            showPause()
        }
    }

    func resumeFromAppLifecycle() {
        if mode == .paused {
            lastUpdateTime = 0
            mode = .running
            message("Run resumed")
        }
    }
    
    func startDebugAutoRunForScreenshots() {
        guard mode != .running else { return }
        removeAllActions()
        menuLayer.removeAllActions()
        menuLayer.removeAction(forKey: "splashTransition")
        menuLayer.removeAllChildren()
        menuLayer.alpha = 0
        run(.sequence([
            .wait(forDuration: 0.25),
            .run { [weak self] in
                guard let self else { return }
                self.startRun()
                self.rightPressed = true
                self.updateControlButtonStates()
            }
        ]), withKey: "debugAutoRun")
    }

    /// Debug-only: scripted pass over jump, double jump (flip), duck, and platform landing.
    func startDebugMechanicsTest() {
        guard mode != .running else { return }
        removeAllActions()
        menuLayer.removeAllActions()
        menuLayer.removeAction(forKey: "splashTransition")
        menuLayer.removeAllChildren()
        menuLayer.alpha = 0
        run(.sequence([
            .wait(forDuration: 0.25),
            .run { [weak self] in
                guard let self else { return }
                self.startRun()
                self.debugMechanicsTestActive = true
                self.rightPressed = true
                self.updateControlButtonStates()
            },
            .wait(forDuration: 1.6),
            .run { [weak self] in self?.jump() },
            .wait(forDuration: 1.6),
            .run { [weak self] in self?.jump() },
            .wait(forDuration: 0.24),
            .run { [weak self] in self?.jump() },
            .wait(forDuration: 1.8),
            .run { [weak self] in self?.duck() },
            .wait(forDuration: 1.8),
            .run { [weak self] in self?.debugAutoPlatformJump = true }
        ]), withKey: "debugMechanicsTest")
    }

    override func update(_ currentTime: TimeInterval) {
        guard mode == .running else {
            lastUpdateTime = currentTime
            return
        }
        let dt = min(CGFloat(currentTime - lastUpdateTime), 1 / 30)
        lastUpdateTime = currentTime
        step(dt)
    }

    private func step(_ dt: CGFloat) {
        let inputActive = leftPressed || rightPressed || abs(playerVelocityX) > 8
        let gentle: CGFloat = retention.gentleMode ? 0.82 : 1
        let worldSpeed = inputActive ? (max(0, playerVelocityX) * 1.28 + (dashTimer > 0 ? 220 : 0) + (boostTimer > 0 ? 120 + CGFloat(boostLevel) * 20 : 0)) * gentle : 0
        let worldMoving = worldSpeed > 18
        runTime += worldMoving ? dt : dt * 0.18
        if worldMoving {
            scoreCarry += Self.distanceScorePerSecond * dt
            if scoreCarry >= 1 {
                let gained = Int(scoreCarry)
                score += gained
                scoreCarry -= CGFloat(gained)
            }
        }
        dashTimer = max(0, dashTimer - dt)
        duckTimer = max(0, duckTimer - dt)
        // Holding the DUCK button keeps the crouch alive; releasing eases back out.
        if duckHeld {
            duckTimer = max(duckTimer, 0.16)
        }
        duckDustTimer = max(0, duckDustTimer - dt)
        advanceFlip(dt)
        invincibleTimer = max(0, invincibleTimer - dt)
        magnetTimer = max(0, magnetTimer - dt)
        boostTimer = max(0, boostTimer - dt)
        comboTimer = max(0, comboTimer - dt)
        landSquash = max(0, landSquash - dt * 6)
        jumpPunch = max(0, jumpPunch - dt * 4.8)
        updateSpeedFX(dt: dt)
        if comboTimer == 0 {
            comboCount = 0
        }
        if worldMoving {
            spawnTimer -= dt
            coinTimer -= dt
            powerUpTimer -= dt
            bonusTimer -= dt
            environmentTimer -= dt
            speedLineTimer -= dt

            if spawnTimer <= 0 {
                spawnObstacle()
                spawnTimer = max(0.62, 1.32 - CGFloat(score) / 9000) + CGFloat.random(in: 0.16...0.46)
            }
            if coinTimer <= 0 {
                spawnCoins()
                coinTimer = max(0.82, 1.48 - CGFloat(score) / 12000)
            }
            if powerUpTimer <= 0 {
                spawnPowerUp()
                powerUpTimer = CGFloat.random(in: 7.0...12.0)
            }
            if bonusTimer <= 0 {
                spawnRoyalGem()
                bonusTimer = CGFloat.random(in: 10.0...15.5)
            }
            platformTimer -= dt
            if platformTimer <= 0 {
                if runTime > 1.8 {
                    spawnPlatform()
                    platformTimer = CGFloat.random(in: 2.6...4.4)
                } else {
                    platformTimer = 0.35
                }
            }
            if speedLineTimer <= 0 {
                spawnSpeedLine()
                speedLineTimer = dashTimer > 0 || boostTimer > 0 ? 0.045 : 0.085
            }
        }

        if debugAutoPlatformJump, playerGrounded {
            // Lead the jump by the flight time back down to ledge height.
            let lead = worldSpeed * 0.72
            for platform in platforms {
                let dx = platform.node.position.x - player.position.x
                if dx > lead - 28, dx < lead + 28 {
                    jump()
                    break
                }
            }
        }
        updatePlayer(dt)
        if debugMechanicsTestActive, mode == .running {
            invincibleTimer = max(invincibleTimer, 0.4)
            debugLogTimer -= dt
            if debugLogTimer <= 0 {
                debugLogTimer = 0.05
                var nearDX: CGFloat = 9999
                var nearTop: CGFloat = 0
                var nearHW: CGFloat = 0
                for platform in platforms {
                    let dx = platform.node.position.x - player.position.x
                    if abs(dx) < abs(nearDX) {
                        nearDX = dx
                        nearTop = platform.node.position.y - groundY
                        nearHW = platform.halfWidth
                    }
                }
                let rigRot = player.childNode(withName: "PrincessAdelynnRig")?.zRotation ?? player.zRotation
                NSLog("CDTEST t=%.2f y=%.1f vy=%.0f grnd=%d sup=%.1f duck=%.2f jc=%d flip=%.2f zrot=%.3f np=%d ndx=%.0f ntop=%.0f nhw=%.0f",
                      runTime, player.position.y - groundY, playerVelocityY, playerGrounded ? 1 : 0,
                      currentSupportY() - groundY, duckTimer, jumpCount, flipActive ? flipProgress : 0, rigRot,
                      platforms.count, nearDX, nearTop, nearHW)
            }
        }
        if Int(runTime) > lastSurviveSecond {
            lastSurviveSecond = Int(runTime)
            retention.markGoal(id: "survive")
        }
        ghostSampleTimer -= dt
        if ghostSampleTimer <= 0 {
            ghostSampleTimer = 0.12
            ghostSamples.append(GhostSample(t: Double(runTime), y: Double(player.position.y), lane: playerLane))
        }
        updateSparkCompanion(dt)
        updateFamilyGhost()
        updateZone()
        moveEnvironment(speed: worldSpeed, dt: dt)
        moveWorld(speed: worldSpeed, dt: dt)
        resolveCollisions()
        updateHUD()
    }

    private func updatePlayer(_ dt: CGFloat) {
        let input: CGFloat = (rightPressed ? 1 : 0) - (leftPressed ? 1 : 0)
        let moveSpeed: CGFloat = dashTimer > 0 ? 440 : 260
        let targetVelocityX = input * moveSpeed
        playerVelocityX += (targetVelocityX - playerVelocityX) * min(1, dt * 16)
        player.position.x += playerVelocityX * dt
        // Gait clock runs off ground speed, so a dash steps faster as well as further.
        // Freeze the cycle while ducking so she holds the crouch instead of running through it.
        let gaitRate = duckTimer > 0 ? 0.08 : 1
        characterPoseTime += dt * gaitRate * max(min(1.7, abs(playerVelocityX) / 230), (rightPressed || leftPressed) ? 0.95 : 0)
        let minX = max(40, size.width * 0.09)
        let maxX = min(size.width - 40, size.width * 0.48)
        if player.position.x < minX {
            player.position.x = minX
            playerVelocityX = max(0, playerVelocityX)
        } else if player.position.x > maxX {
            player.position.x = maxX
            // Keep forward run speed while pinned so the world (and coins) keep scrolling.
            if rightPressed || dashTimer > 0 {
                playerVelocityX = max(playerVelocityX, dashTimer > 0 ? 440 : 260)
            } else {
                playerVelocityX = min(0, playerVelocityX)
            }
        }
        
        playerVelocityY -= (retention.gentleMode ? 1420 : 1850) * selectedRunner.gravMul * dt
        player.position.y += playerVelocityY * dt
        let supportY = currentSupportY()
        if player.position.y <= supportY {
            if !playerGrounded && playerVelocityY < -220 {
                landingDust()
                landSquash = 1
                feedback(.light)
            }
            player.position.y = supportY
            playerVelocityY = 0
            playerGrounded = true
            jumpCount = 0
            coyoteTimer = retention.gentleMode ? 0.16 : 0.08
        } else if playerVelocityY > 0 {
            playerGrounded = false
            coyoteTimer = max(0, coyoteTimer - dt)
        } else {
            // Falling but not yet on a surface.
            playerGrounded = false
            coyoteTimer = max(0, coyoteTimer - dt)
        }
        let lean = input * -0.04 + (dashTimer > 0 ? 0.12 : 0)
        player.zRotation += (lean - player.zRotation) * min(1, dt * 12)
        let targetScaleX: CGFloat = dashTimer > 0 ? 1.08 : 1
        player.xScale += (targetScaleX - player.xScale) * min(1, dt * 12)
        // Ducking is posed on the rig. Squashing `player` also flattened the name pill, which read
        // as the character being crushed rather than crouching, so this only ever settles back to 1.
        player.yScale += (1 - player.yScale) * min(1, dt * 12)
        updateRunPose()
    }

    private func updateRunPose() {
        // Facing on the Sims soft-capsule rig only — never on `player` — so the name pill stays readable.
        let facing: CGFloat = (leftPressed && !rightPressed) || playerVelocityX < -28 ? -1 : 1
        guard let rig = player.childNode(withName: "PrincessAdelynnRig") else { return }
        let baseScale: CGFloat = 0.94
        if reducedMotion {
            if rig.userData?["cutout"] as? Bool == true, !playerGrounded || duckTimer > 0 || flipActive {
                updateCutoutRunPose(rig: rig, facing: facing, baseScale: baseScale)
                return
            }
            rig.xScale = facing * baseScale
            rig.yScale = baseScale
            // Still show the crouch — it is game state, not decoration — but hold it perfectly still.
            if rig.userData?["cutout"] as? Bool == true {
                poseCutoutStillCrouch(rig: rig, blend: duckTimer > 0 ? 1 : 0)
            }
            return
        }
        if rig.userData?["cutout"] as? Bool == true {
            updateCutoutRunPose(rig: rig, facing: facing, baseScale: baseScale)
            return
        }
        let strideBoost: CGFloat = dashTimer > 0 || boostTimer > 0 ? 1.55 : 1
        let movement = min(1.25, max(abs(playerVelocityX) / 230, (rightPressed || leftPressed) ? 0.85 : 0))
        let airborne = !playerGrounded
        let crouch = duckBlend
        if movement < 0.08, playerGrounded, crouch == 0, dashTimer <= 0, !flipActive {
            rig.position.y += (4 - rig.position.y) * 0.25
            rig.zRotation += (-0.04 - rig.zRotation) * 0.25
            rig.xScale += (facing * baseScale - rig.xScale) * 0.25
            rig.yScale += (baseScale - rig.yScale) * 0.25
            poseLeg(rig.childNode(withName: "leftLeg"), side: -1, stride: -0.18)
            poseLeg(rig.childNode(withName: "rightLeg"), side: 1, stride: 0.18)
            poseArm(rig.childNode(withName: "leftArm"), side: -1, stride: 0.12)
            poseArm(rig.childNode(withName: "rightArm"), side: 1, stride: -0.12)
            rig.childNode(withName: "cape")?.zRotation = -0.18
            rig.childNode(withName: "dress")?.zRotation = -0.04
            updateSwayPonytail(on: rig, moving: false, airborne: false, phase: CGFloat(lastUpdateTime) * 2 * .pi)
            return
        }
        let cycle = characterPoseTime * Self.runCadence * strideBoost
        let step = cycle.truncatingRemainder(dividingBy: 1)
        let phase = cycle * 2 * .pi
        // Duty-cycled gait: short stance, long flight. Opposite arm and leg travel together.
        let left = runLegPose(cycle: step).rotation / Self.runLegReach
        let right = runLegPose(cycle: (step + 0.5).truncatingRemainder(dividingBy: 1)).rotation / Self.runLegReach
        // Hips sink into the strike, then float through the gap where neither foot is down.
        let bounce = playerGrounded ? runBodyBob(cycle: step) * movement * 0.8 : (airborne ? 6 : 3)
        rig.position.y = 4 + bounce - crouch * 8
        let stretchX = dashTimer > 0 ? 1.06 : (1.0 + abs(sin(phase)) * 0.028 * movement)
        // Never squash the rig vertically — the crouch is posed, not flattened.
        let stretchY = 1.0 - abs(sin(phase)) * 0.022 * movement
        rig.xScale = facing * baseScale * stretchX
        rig.yScale = baseScale * stretchY
        let rise = airborne && playerVelocityY > 40
        let fall = airborne && playerVelocityY < -40
        let runLean: CGFloat = rise ? -0.04 : (fall ? -0.16 : (airborne ? -0.08 : (dashTimer > 0 ? -0.16 : -0.12)))
        let steerLean: CGFloat = rightPressed ? -0.02 : (leftPressed ? 0.03 : 0)
        if flipActive {
            let ball = somersaultTuck(progress: flipProgress)
            let spin = somersaultSpin(progress: flipProgress)
            poseLeg(rig.childNode(withName: "leftLeg"), side: -1, stride: 1.12 * ball)
            poseLeg(rig.childNode(withName: "rightLeg"), side: 1, stride: 1.18 * ball)
            poseArm(rig.childNode(withName: "leftArm"), side: -1, stride: 0.95 * ball)
            poseArm(rig.childNode(withName: "rightArm"), side: 1, stride: 1.05 * ball)
            rig.childNode(withName: "cape")?.zRotation = poseMix(-0.38, 0.55, ball)
            rig.childNode(withName: "dress")?.zRotation = poseMix(-0.08, 0.22, ball)
            let lean = runLean + steerLean - spin * 2 * .pi
            rig.zRotation = lean
            let pivotY: CGFloat = 64
            rig.position.x = facing * baseScale * stretchX * pivotY * sin(lean)
            rig.position.y = 4 + bounce + baseScale * stretchY * pivotY * (1 - cos(lean))
        } else if airborne, crouch == 0 {
            let nearStride: CGFloat = rise ? 1.05 : (fall ? 0.42 : 0.78)
            let farStride: CGFloat = rise ? -0.82 : (fall ? -0.48 : -0.62)
            poseLeg(rig.childNode(withName: "leftLeg"), side: -1, stride: farStride)
            poseLeg(rig.childNode(withName: "rightLeg"), side: 1, stride: nearStride)
            poseArm(rig.childNode(withName: "leftArm"), side: -1, stride: rise ? -0.72 : (fall ? 0.18 : 0.28))
            poseArm(rig.childNode(withName: "rightArm"), side: 1, stride: rise ? 0.95 : (fall ? 0.32 : 0.55))
            rig.childNode(withName: "cape")?.zRotation = -0.38 + max(-0.22, min(0.18, playerVelocityY / 1400))
            rig.childNode(withName: "dress")?.zRotation = -0.08 + sin(characterPoseTime * 9) * 0.05
            rig.zRotation = runLean + steerLean + sin(phase * 0.5) * 0.022 * movement
        } else {
            let armBoost: CGFloat = crouch * 0.5
            let strideAmp: CGFloat = 1.2 - crouch * 0.5
            poseLeg(rig.childNode(withName: "leftLeg"), side: -1, stride: left * strideAmp)
            poseLeg(rig.childNode(withName: "rightLeg"), side: 1, stride: right * strideAmp)
            poseArm(rig.childNode(withName: "leftArm"), side: -1, stride: right + armBoost)
            poseArm(rig.childNode(withName: "rightArm"), side: 1, stride: left + armBoost)
            rig.childNode(withName: "cape")?.zRotation = -0.22 + sin(phase * 0.7) * 0.12
            rig.childNode(withName: "dress")?.zRotation = -0.03 + sin(phase) * 0.03 * movement
            rig.zRotation = runLean + steerLean + sin(phase * 0.5) * 0.022 * movement
        }
        let headDip = crouch * 10
        rig.childNode(withName: "hair")?.position = CGPoint(x: -2 - sin(phase + 0.8) * 1.8, y: 126 - bounce * 0.20 - headDip)
        rig.childNode(withName: "head")?.position = CGPoint(x: 6 + sin(phase) * 0.4, y: 120 + bounce * 0.08 - headDip)
        rig.childNode(withName: "face")?.position = CGPoint(x: 6 + sin(phase) * 0.4, y: 120 + bounce * 0.08 - headDip)
        rig.childNode(withName: "crown")?.position = CGPoint(x: 4 + sin(phase) * 0.4, y: 152 + bounce * 0.10 - headDip)
        updateSwayPonytail(on: rig, moving: true, airborne: airborne, phase: phase, flipping: flipActive)
    }

    private func poseLeg(_ node: SKNode?, side: CGFloat, stride: CGFloat) {
        guard let node else { return }
        let forward = max(0, stride)
        let back = max(0, -stride)
        // Hips tucked under dress hem; shin does most of the visible stride.
        let hipX = side * 6 + forward * 12 - back * 9
        node.position = CGPoint(x: hipX, y: 18 + forward * 4.5)
        node.zRotation = -forward * 0.52 + back * 0.42 + side * 0.01
        node.xScale = 1
        node.yScale = 1
        node.alpha = 1
        
        let lower = node.childNode(withName: "lower")
        lower?.position = CGPoint(x: forward * 6 - back * 4, y: -28 + forward * 3)
        // Keep the knee bent through the whole cycle: driving through in front, heel folded up behind.
        lower?.zRotation = forward * 0.95 - back * 0.70
        lower?.xScale = 1
        
        if let foot = node.childNode(withName: "end") {
            foot.position = CGPoint(x: forward * 14 - back * 10, y: -54 + forward * 5 - back * 1)
            foot.zRotation = forward * 0.10 - back * 0.18
            foot.xScale = 1.0 + forward * 0.05
            foot.yScale = 1.0 - forward * 0.03
        }
    }

    private func poseArm(_ node: SKNode?, side: CGFloat, stride: CGFloat) {
        guard let node else { return }
        let forward = max(0, stride)
        let back = max(0, -stride)
        node.position = CGPoint(x: side * 14 + forward * 7 - back * 5, y: 78 + forward * 3 - back * 3)
        node.zRotation = side * 0.06 - forward * 0.62 + back * 0.52
        node.yScale = 0.96 + back * 0.03 - forward * 0.02
        node.alpha = 1
        
        let lower = node.childNode(withName: "lower")
        lower?.position = CGPoint(x: forward * 6 - back * 4, y: -20)
        lower?.zRotation = forward * 0.72 - back * 0.50
        
        if let hand = node.childNode(withName: "end") {
            hand.position = CGPoint(x: forward * 14 - back * 10, y: -38 + forward * 3)
            hand.zRotation = -forward * 0.14 + back * 0.08
        }
    }

    private func moveWorld(speed: CGFloat, dt: CGFloat) {
        for index in obstacles.indices {
            obstacles[index].node.position.x -= speed * dt
        }
        for index in coinNodes.indices {
            let coin = coinNodes[index].node
            coin.position.x -= speed * dt
            coin.zRotation += dt * 5
            let magnetActive = power == .star || magnetTimer > 0
            let pullRange: CGFloat = magnetActive ? (230 + CGFloat(magnetLevel) * 35) : 78
            let pullStrength: CGFloat = magnetActive ? 5.8 : 2.4
            let dx = player.position.x - coin.position.x
            let dy = player.position.y + 42 - coin.position.y
            let distance = hypot(dx, dy)
            if distance < pullRange {
                coin.position.x += dx * dt * pullStrength
                coin.position.y += dy * dt * pullStrength
            }
        }
        for index in powerUpNodes.indices {
            let item = powerUpNodes[index].node
            item.position.x -= speed * dt
            item.zRotation += dt * 2
        }
        for index in bonusNodes.indices {
            let item = bonusNodes[index].node
            item.position.x -= speed * dt * 0.96
            item.position.y += sin(runTime * 4 + CGFloat(index)) * dt * 10
            item.zRotation += dt * 1.7
        }
        for index in platforms.indices {
            platforms[index].node.position.x -= speed * dt
        }
        obstacles.removeAll { item in
            if item.node.position.x < -160 {
                item.node.removeFromParent()
                return true
            }
            return false
        }
        coinNodes.removeAll { item in
            if item.node.position.x < -120 {
                item.node.removeFromParent()
                return true
            }
            return false
        }
        powerUpNodes.removeAll { item in
            if item.node.position.x < -120 {
                item.node.removeFromParent()
                return true
            }
            return false
        }
        bonusNodes.removeAll { item in
            if item.node.position.x < -120 {
                item.node.removeFromParent()
                return true
            }
            return false
        }
        platforms.removeAll { item in
            if item.node.position.x < -200 {
                item.node.removeFromParent()
                return true
            }
            return false
        }
    }

    /// Highest surface under the player feet right now (ground or platform top).
    private func currentSupportY() -> CGFloat {
        var support = groundY
        guard playerVelocityY <= 40 else { return support }
        let footX = player.position.x
        let footY = player.position.y
        for platform in platforms {
            let top = platform.node.position.y
            let left = platform.node.position.x - platform.halfWidth + 6
            let right = platform.node.position.x + platform.halfWidth - 6
            guard footX >= left, footX <= right else { continue }
            // Only snap when falling onto / standing on the top band.
            if footY <= top + 10, footY >= top - 22 {
                support = max(support, top)
            }
        }
        return support
    }
    
    private func addCombo(points: Int, messageText: String? = nil) {
        comboCount += 1
        comboTimer = 2.4
        let multiplier = min(Self.maxComboMultiplier, 1 + comboCount / Self.comboActionsPerMultiplier)
        score += points * multiplier
        if comboCount >= Self.comboActionsPerMultiplier || multiplier > 1 {
            message(messageText ?? "Royal combo x\(multiplier)")
        }
    }

    private func moveEnvironment(speed: CGFloat, dt: CGFloat) {
        guard mode == .running else { return }
        if environmentTimer <= 0 {
            spawnEnvironmentRow()
            environmentTimer = max(0.24, 0.44 - min(CGFloat(score) / 24000, 0.14))
        }
        for node in environmentLayer.children {
            let parallax = (node.userData?["parallax"] as? NSNumber).map { CGFloat(truncating: $0) } ?? 1
            node.position.x -= speed * dt * parallax
        }
        environmentLayer.children
            .filter { $0.position.x < -180 }
            .forEach { $0.removeFromParent() }
    }

    private func seedEnvironmentMotion() {
        environmentLayer.removeAllChildren()
        guard mode == .running else { return }
        environmentTimer = 0
        let spacing = max(size.width * 0.19, 84)
        var x = -40 as CGFloat
        while x < size.width + 140 {
            spawnEnvironmentRow(at: x)
            x += spacing
        }
    }

    private func spawnEnvironmentRow(at x: CGFloat? = nil) {
        let marker = makeEnvironmentMarker()
        marker.position = CGPoint(x: x ?? size.width + 96, y: groundY - 18)
        marker.alpha = 0.64
        environmentLayer.addChild(marker)
        
        if Bool.random() || x != nil {
            let scenery = makeSideScenery()
            scenery.userData = ["parallax": 0.72]
            scenery.position = CGPoint(x: x ?? size.width + 130, y: groundY + 68)
            scenery.xScale = 0.78
            scenery.yScale = 0.78
            scenery.alpha = 0.82
            environmentLayer.addChild(scenery)
        }
    }
    
    private func spawnSpeedLine() {
        guard mode == .running, !reducedMotion else { return }
        let line = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 28...76), height: CGFloat.random(in: 1.0...2.2)), cornerRadius: 1)
        line.fillColor = UIColor(red: 1.0, green: 0.62, blue: 0.86, alpha: dashTimer > 0 || boostTimer > 0 ? 0.44 : 0.22)
        line.strokeColor = .clear
        line.position = CGPoint(x: size.width + 40, y: CGFloat.random(in: groundY + 84...max(groundY + 92, size.height * 0.62)))
        line.zPosition = -14
        line.userData = ["parallax": 1.36]
        environmentLayer.addChild(line)
        line.run(.sequence([.fadeOut(withDuration: 0.42), .removeFromParent()]))
    }

    private func resolveCollisions() {
        let isDucking = duckTimer > 0
        let playerRect = CGRect(
            x: player.position.x - 24,
            y: player.position.y + (isDucking ? 6 : 12),
            width: 48,
            height: isDucking ? 48 : playerSize.height - 18
        )

        for index in obstacles.indices {
            let obstacle = obstacles[index]
            let rect = obstacle.node.calculateAccumulatedFrame()
            if playerRect.intersects(rect) {
                let emberClear = selectedRunner == .ember && obstacle.kind.bloomsWithRose
                let matched = (obstacle.kind.bloomsWithRose && power == .bloom)
                    || (obstacle.kind == .tide && power == .tide)
                    || emberClear
                let jumpedRock = obstacle.kind.jumpsOver && player.position.y > groundY + 22
                let duckedBeam = obstacle.kind.ducksUnder && duckTimer > 0
                if matched || jumpedRock || duckedBeam || dashTimer > 0 || invincibleTimer > 0 {
                    clearObstacle(at: index, matched: matched, avoided: jumpedRock || duckedBeam)
                    return
                }
                var hit = obstacle.kind.ducksUnder ? 20 : 25
                if selectedRunner == .mermaid && (obstacle.kind == .tide || obstacle.kind == .shell || obstacle.kind == .tideCrab) {
                    hit = max(8, Int(CGFloat(hit) * 0.45))
                }
                takeDamage(retention.gentleMode ? max(8, hit - 10) : hit)
                // takeDamage may end the run and clear obstacles — guard before mutating.
                if obstacles.indices.contains(index) {
                    obstacles[index].node.removeFromParent()
                    obstacles.remove(at: index)
                }
                return
            }
            guard obstacles.indices.contains(index) else { continue }
            if !obstacles[index].scoredCloseCall && rect.insetBy(dx: -12, dy: -12).intersects(playerRect) {
                obstacles[index].scoredCloseCall = true
                addCombo(points: 4, messageText: "Close call combo")
            }
        }

        for index in coinNodes.indices.reversed() {
            let rect = coinNodes[index].node.calculateAccumulatedFrame().insetBy(dx: -16, dy: -18)
            if playerRect.intersects(rect) {
                var value = coinNodes[index].risky ? 2 : 1
                if selectedRunner == .kofi { value += 1 }
                coins += value
                scorePopup("+\(value)", at: coinNodes[index].node.position, color: UIColor(red: 1.0, green: 0.86, blue: 0.34, alpha: 1))
                addCombo(points: coinNodes[index].risky ? 20 : 12)
                trackMission(.coins, amount: value)
                retention.markGoal(id: "coins", amount: value)
                playCue(1105)
                sparkle(at: coinNodes[index].node.position, color: .systemYellow)
                coinNodes[index].node.removeFromParent()
                coinNodes.remove(at: index)
            }
        }
        
        for index in bonusNodes.indices.reversed() {
            let rect = bonusNodes[index].node.calculateAccumulatedFrame().insetBy(dx: -16, dy: -16)
            if playerRect.intersects(rect) {
                let value = bonusNodes[index].value
                coins += value
                scorePopup("+\(value)", at: bonusNodes[index].node.position, color: UIColor(red: 1.0, green: 0.48, blue: 0.80, alpha: 1))
                addCombo(points: 32 + value * 6, messageText: bonusNodes[index].isKofi ? "Kofi waved!" : "Royal gem +\(value)")
                if bonusNodes[index].isChapterItem { collectedChapterItem = true }
                if bonusNodes[index].isKofi { metKofi = true }
                invincibleTimer = max(invincibleTimer, 0.55)
                playCue(1105)
                sparkle(at: bonusNodes[index].node.position, color: .systemPink)
                bonusNodes[index].node.removeFromParent()
                bonusNodes.remove(at: index)
            }
        }
        
        for index in powerUpNodes.indices.reversed() {
            let rect = powerUpNodes[index].node.calculateAccumulatedFrame().insetBy(dx: -14, dy: -14)
            if playerRect.intersects(rect) {
                collectPowerUp(powerUpNodes[index].kind)
                sparkle(at: powerUpNodes[index].node.position, color: .systemMint)
                powerUpNodes[index].node.removeFromParent()
                powerUpNodes.remove(at: index)
            }
        }
    }

    private func clearObstacle(at index: Int, matched: Bool, avoided: Bool = false) {
        guard obstacles.indices.contains(index) else { return }
        let pos = obstacles[index].node.position
        let kind = obstacles[index].kind
        obstacles[index].node.removeFromParent()
        obstacles.remove(at: index)
        if matched {
            trackMission(.powers, amount: 1)
            powerStreak += 1
            if kind == .shadowImp {
                retention.markGoal(id: "bloomImps")
                addCombo(points: 24 + powerStreak * 4, messageText: "Bloomed a shadow imp")
                if retention.dailyGoals.first(where: { $0.id == "bloomImps" })?.done == true {
                    message("Bloomed 3 shadow imps!")
                }
            } else {
                addCombo(points: 20 + powerStreak * 4, messageText: "Matched power")
            }
            if powerStreak >= 3 {
                shieldCharges = min(2, shieldCharges + 1)
                powerStreak = 0
                message("Power streak shield")
            }
        } else if avoided {
            if kind.ducksUnder {
                trackMission(.ducks, amount: 1)
                addCombo(points: 14, messageText: kind == .starWisp ? "Ducked a star wisp" : "Clean dodge")
            } else {
                addCombo(points: 14, messageText: kind == .tideCrab ? "Jumped a tide crab" : "Clean dodge")
            }
        } else {
            addCombo(points: 12, messageText: "Perfect dash")
        }
        sparkle(at: pos, color: powerColor)
        cameraShake(amount: 3, duration: 0.10)
    }

    private func takeDamage(_ amount: Int) {
        if invincibleTimer > 0 { return }
        if shieldCharges > 0 {
            shieldCharges -= 1
            invincibleTimer = retention.gentleMode ? 1.35 : 1.0
            message("Crown shield blocked it")
            feedback(.heavy)
            sparkle(at: player.position, color: .systemCyan)
            cameraShake(amount: 5, duration: 0.14)
            return
        }
        health = max(0, health - amount)
        invincibleTimer = 1.25
        powerStreak = 0
        comboCount = 0
        comboTimer = 0
        player.run(.sequence([.fadeAlpha(to: 0.35, duration: 0.08), .fadeAlpha(to: 1, duration: 0.12)]))
        cameraShake(amount: 8, duration: 0.20)
        feedback(.heavy)
        message("-\(amount)% health")
        if health <= 0 {
            if reviveTokens > 0 {
                reviveTokens -= 1
                health = 45
                invincibleTimer = 2.0
                message("Revived")
                sparkle(at: player.position, color: .systemPink)
                return
            }
            endRun()
        }
    }

    private func startRun() {
        mode = .running
        menuLayer.removeAllActions()
        menuLayer.removeAllChildren()
        menuLayer.alpha = 1
        updateHUDVisibility()
        player.isHidden = false
        score = 0
        coins = 0
        health = 100
        shieldCharges = 1 + min(2, shieldLevel)
        collectedChapterItem = false
        metKofi = false
        ghostSamples = []
        ghostSampleTimer = 0
        lastSurviveSecond = 0
        coyoteTimer = 0
        lastRecapStars = 1
        lastRecapPraise = "What a dash, Princess!"
        playerLane = 1
        playerVelocityX = 0
        playerVelocityY = 0
        playerGrounded = true
        jumpCount = 0
        jumpPunch = 0
        dashTimer = 0
        duckTimer = 0
        duckHeld = false
        duckDustTimer = 0
        flipActive = false
        flipProgress = 0
        invincibleTimer = 0
        magnetTimer = 0
        boostTimer = 0
        power = .bloom
        currentZone = startingZone(for: retention.chapter)
        scoreCarry = 0
        runTime = 0
        characterPoseTime = 0
        spawnTimer = 0.75
        coinTimer = 0.15
        powerUpTimer = 4.5
        bonusTimer = 9.0
        platformTimer = 2.2
        environmentTimer = 0
        speedLineTimer = 0
        powerStreak = 0
        comboCount = 0
        comboTimer = 0
        activeControlTouches.removeAll()
        leftPressed = false
        rightPressed = false
        updateControlButtonStates()
        reviveTokens = 0
        missions = [
            Mission(kind: .coins, target: 12, reward: 20),
            Mission(kind: .powers, target: 3, reward: 30),
            Mission(kind: .dashes, target: 6, reward: 25),
            Mission(kind: .ducks, target: 4, reward: 25)
        ]
        completedMissionKinds.removeAll()
        lastUpdateTime = 0
        obstacles.forEach { $0.node.removeFromParent() }
        coinNodes.forEach { $0.node.removeFromParent() }
        powerUpNodes.forEach { $0.node.removeFromParent() }
        bonusNodes.forEach { $0.node.removeFromParent() }
        platforms.forEach { $0.node.removeFromParent() }
        obstacles.removeAll()
        coinNodes.removeAll()
        powerUpNodes.removeAll()
        bonusNodes.removeAll()
        platforms.removeAll()
        menuLayer.removeAllChildren()
        tutorialLabel.alpha = 0
        let buffs = retention.consumeRunBuffs()
        if buffs.shield { shieldCharges += 1 }
        if buffs.magnet { magnetTimer = max(magnetTimer, 6.5) }
        if buffs.boost {
            boostTimer = max(boostTimer, 2.4)
            invincibleTimer = max(invincibleTimer, 0.8)
        }
        if buffs.coins > 0 {
            coins += buffs.coins
            totalCoins += buffs.coins
            UserDefaults.standard.set(totalCoins, forKey: "crownDash.totalCoins")
        }
        if retention.gentleMode {
            shieldCharges += 1
            invincibleTimer = max(invincibleTimer, 1.2)
        }
        buildSparkCompanion()
        buildFamilyGhost()
        updateBackground()
        seedEnvironmentMotion()
        layoutPlayer(animated: false)
        updateHUD()
        updateRunnerNamePill()
        message(retention.gentleMode ? "Gentle Mode • \(selectedRunner.title)" : "\(selectedRunner.title) • \(retention.chapter.title)")
    }

    private func endRun() {
        mode = .gameOver
        leftPressed = false
        rightPressed = false
        obstacles.forEach { $0.node.removeFromParent() }
        coinNodes.forEach { $0.node.removeFromParent() }
        powerUpNodes.forEach { $0.node.removeFromParent() }
        bonusNodes.forEach { $0.node.removeFromParent() }
        platforms.forEach { $0.node.removeFromParent() }
        obstacles.removeAll()
        coinNodes.removeAll()
        powerUpNodes.removeAll()
        bonusNodes.removeAll()
        platforms.removeAll()
        environmentLayer.removeAllChildren()
        fxLayer.removeAllChildren()
        let reward = claimMissionRewards()
        totalCoins += coins + reward
        UserDefaults.standard.set(totalCoins, forKey: "crownDash.totalCoins")
        GameCenterManager.shared.submitHighScore(score)
        retention.unlockChapterIfNeeded(bestScore: max(score, GameCenterManager.shared.highScore))
        retention.awardRunStickers(score: score, collectedChapterItem: collectedChapterItem, metKofi: metKofi)
        retention.recordGhost(score: score, samples: ghostSamples)
        let recap = retention.recap(score: score, coins: coins)
        lastRecapStars = recap.stars
        lastRecapPraise = recap.praise
        sparkCompanion.isHidden = true
        familyGhost.isHidden = true
        showGameOver()
    }

    private func jump() {
        let canFirstJump = playerGrounded || coyoteTimer > 0
        guard mode == .running, jumpCount < 2, jumpCount > 0 || canFirstJump else { return }
        playerGrounded = false
        coyoteTimer = 0
        jumpPunch = 1
        let first: CGFloat = retention.gentleMode ? 780 : 820
        let second: CGFloat = retention.gentleMode ? 640 : 660
        playerVelocityY = (jumpCount == 0 ? first : second) * selectedRunner.jumpMul
        jumpCount += 1
        retention.markGoal(id: "jumps")
        if jumpCount == 2 {
            message("Crown flip")
            // Somersault on the rig, not on `player`, so the name pill stays upright.
            flipActive = true
            flipProgress = 0
        }
        feedback(.light)
        sparkle(at: CGPoint(x: player.position.x, y: player.position.y + 12), color: .systemCyan)
    }

    private func dash() {
        guard mode == .running else { return }
        dashTimer = 0.25
        invincibleTimer = max(invincibleTimer, 0.22)
        trackMission(.dashes, amount: 1)
        feedback(.medium)
        sparkle(at: CGPoint(x: player.position.x + 26, y: player.position.y + 54), color: powerColor)
    }
    
    /// Drives the somersault to completion. Landing mid-roll speeds the remainder up
    /// instead of cancelling it, so the rig can never be left lying on its side.
    private func advanceFlip(_ dt: CGFloat) {
        guard flipActive else { return }
        let wasAirborne = !playerGrounded
        let duration = playerGrounded ? Self.flipRecovery : Self.flipDuration
        flipProgress += dt / max(duration, 0.01)
        if flipProgress >= 1 {
            flipProgress = 0
            flipActive = false
            // Only reward a flip that finished while she was still in the air.
            if wasAirborne {
                addCombo(points: 14, messageText: "Clean flip")
                if !reducedMotion {
                    sparkle(at: CGPoint(x: player.position.x, y: player.position.y + 54), color: .systemPink)
                }
            }
        }
    }

    /// Crouch that drops the hitbox under beams. Airborne it also pulls her down so the
    /// crouch is ready by the time she reaches the beam.
    private func duck() {
        guard mode == .running else { return }
        duckTimer = Self.duckDuration
        if !playerGrounded {
            playerVelocityY = min(playerVelocityY, -520)
        }
        feedback(.light)
        sparkle(at: CGPoint(x: player.position.x, y: player.position.y + 18), color: .systemPurple)
    }

    private func shiftLane(_ delta: Int) {
        guard mode == .running else { return }
        if delta > 0 {
            dash()
        } else {
            duck()
        }
    }

    private func cyclePower() {
        guard mode == .running else { return }
        switch power {
        case .bloom: power = .tide
        case .tide: power = .star
        case .star: power = .bloom
        }
        message(power.rawValue)
        playCue(1104)
        updateHUD()
    }

    private func spawnObstacle() {
        let kind = chapterHazard()
        let lane: Int? = nil
        let node = makeObstacle(kind: kind)
        let spawnX = size.width + node.calculateAccumulatedFrame().width + CGFloat.random(in: 80...200)
        node.position = CGPoint(x: spawnX, y: groundY + kind.spawnHeight)
        attachHazardWarning(to: node, kind: kind)
        world.addChild(node)
        if !reducedMotion {
            let bob: SKAction
            switch kind {
            case .tideCrab:
                bob = .sequence([.moveBy(x: 0, y: 8, duration: 0.18), .moveBy(x: 0, y: -8, duration: 0.18), .wait(forDuration: 0.22)])
            case .starWisp:
                bob = .sequence([.moveBy(x: 0, y: 6, duration: 0.32), .moveBy(x: 0, y: -6, duration: 0.32)])
            case .shadowImp:
                bob = .sequence([.moveBy(x: 0, y: 4, duration: 0.22), .moveBy(x: 0, y: -4, duration: 0.22)])
            default:
                bob = .sequence([.moveBy(x: 0, y: 2.5, duration: 0.24), .moveBy(x: 0, y: -2.5, duration: 0.24)])
            }
            node.run(.repeatForever(bob), withKey: "hazardReadabilityBob")
        }
        obstacles.append(Obstacle(node: node, kind: kind, lane: lane))
    }

    private func spawnCoins() {
        let startX = size.width + 90
        // Mix: ground lane, mid-air arc, or platform-top row.
        let roll = CGFloat.random(in: 0...1)
        let mode: Int = roll < 0.55 ? 0 : (roll < 0.82 ? 1 : 2)
        for i in 0..<4 {
            let risky = i == 3 && Bool.random()
            let coin = makeCoin(risky: risky)
            let y: CGFloat
            switch mode {
            case 1:
                let yOffset = sin(CGFloat(i) / 3 * .pi) * 52
                y = groundY + 78 + yOffset
            case 2:
                y = groundY + 118 + CGFloat(i % 2) * 10
            default:
                y = groundY + 46 + CGFloat(i % 2) * 8
            }
            coin.position = CGPoint(
                x: startX + CGFloat(i) * 58,
                y: y
            )
            world.addChild(coin)
            if !reducedMotion {
                coin.run(.repeatForever(.sequence([
                    .moveBy(x: 0, y: 3, duration: 0.34 + Double(i) * 0.03),
                    .moveBy(x: 0, y: -3, duration: 0.34 + Double(i) * 0.03)
                ])), withKey: "coinFloat")
            }
            coinNodes.append(Coin(node: coin, risky: risky))
        }
    }

    /// Floating royal ledge with an optional arc of A-coins above it.
    private func spawnPlatform() {
        let width = CGFloat.random(in: 120...180)
        let half = width / 2
        let topY = groundY + CGFloat.random(in: 92...136)
        let node = makePlatform(width: width)
        // Spawn closer so the ledge is readable sooner.
        node.position = CGPoint(x: size.width + half + CGFloat.random(in: 20...90), y: topY)
        world.addChild(node)
        platforms.append(Platform(node: node, halfWidth: half))

        // Coin arc sitting just above the ledge so jumping onto it pays off.
        let coinCount = Int.random(in: 3...5)
        for i in 0..<coinCount {
            let t = CGFloat(i) / CGFloat(max(1, coinCount - 1))
            let coin = makeCoin(risky: false)
            let arc = sin(t * .pi) * 22
            coin.position = CGPoint(
                x: node.position.x - half + 18 + t * (width - 36),
                y: topY + 34 + arc
            )
            world.addChild(coin)
            if !reducedMotion {
                coin.run(.repeatForever(.sequence([
                    .moveBy(x: 0, y: 2.5, duration: 0.30 + Double(i) * 0.02),
                    .moveBy(x: 0, y: -2.5, duration: 0.30 + Double(i) * 0.02)
                ])), withKey: "coinFloat")
            }
            coinNodes.append(Coin(node: coin, risky: false))
        }
    }

    private func makePlatform(width: CGFloat) -> SKNode {
        let root = SKNode()
        root.name = "platform"
        let height: CGFloat = 22

        let shadow = SKShapeNode(rectOf: CGSize(width: width + 10, height: 10), cornerRadius: 5)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.28)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -12)
        shadow.zPosition = -1
        root.addChild(shadow)

        // Gold-trimmed marble ledge — clearly readable against the purple midground.
        let deck = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 9)
        deck.fillColor = UIColor(red: 0.92, green: 0.78, blue: 0.96, alpha: 1)
        deck.strokeColor = UIColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 1)
        deck.lineWidth = 3
        deck.position = CGPoint(x: 0, y: -height / 2)
        deck.zPosition = 1
        root.addChild(deck)

        let topEdge = SKShapeNode(rectOf: CGSize(width: width - 12, height: 5), cornerRadius: 2)
        topEdge.fillColor = UIColor(red: 1.0, green: 0.94, blue: 0.98, alpha: 1)
        topEdge.strokeColor = .clear
        topEdge.position = CGPoint(x: 0, y: -4)
        topEdge.zPosition = 2
        root.addChild(topEdge)

        for x in [-width * 0.28, 0.0, width * 0.28] {
            let jewel = SKShapeNode(circleOfRadius: 3.5)
            jewel.fillColor = UIColor(red: 1.0, green: 0.78, blue: 0.22, alpha: 1)
            jewel.strokeColor = UIColor.white.withAlphaComponent(0.75)
            jewel.lineWidth = 1
            jewel.position = CGPoint(x: x, y: -height / 2)
            jewel.zPosition = 3
            root.addChild(jewel)
        }

        // Short posts so it reads as a raised platform, not a ground stripe.
        for x in [-width * 0.38, width * 0.38] {
            let post = SKShapeNode(rectOf: CGSize(width: 7, height: 16), cornerRadius: 2)
            post.fillColor = UIColor(red: 0.78, green: 0.48, blue: 0.86, alpha: 0.95)
            post.strokeColor = UIColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 0.9)
            post.lineWidth = 1.2
            post.position = CGPoint(x: x, y: -height - 6)
            post.zPosition = 0
            root.addChild(post)
        }
        return root
    }
    
    private func spawnPowerUp() {
        guard runTime > 5 else { return }
        let kind = PowerUpKind.allCases.randomElement() ?? .shield
        let node = makePowerUp(kind: kind)
        node.position = CGPoint(x: size.width + 130, y: groundY + 92)
        world.addChild(node)
        if !reducedMotion {
            node.run(.repeatForever(.sequence([
                .scale(to: 1.16, duration: 0.34),
                .scale(to: 1.0, duration: 0.34)
            ])), withKey: "powerUpPulse")
        }
        powerUpNodes.append(PowerUpNode(node: node, kind: kind))
    }
    
    private func spawnRoyalGem() {
        guard runTime > 8 else { return }
        let node = makeRoyalGem()
        let highRoute = Bool.random()
        node.position = CGPoint(
            x: size.width + CGFloat.random(in: 140...260),
            y: groundY + (highRoute ? CGFloat.random(in: 138...190) : CGFloat.random(in: 74...118))
        )
        world.addChild(node)
        if !reducedMotion {
            node.run(.repeatForever(.sequence([
                .scale(to: 1.12, duration: 0.42),
                .scale(to: 0.96, duration: 0.42)
            ])), withKey: "royalGemPulse")
        }
        bonusNodes.append(BonusNode(node: node, value: highRoute ? 5 : 3, isChapterItem: true))
        if runTime > 14, Bool.random(), !metKofi {
            spawnKofi()
        }
    }

    private func spawnKofi() {
        let node = makeKofiFriend()
        node.position = CGPoint(x: size.width + 180, y: groundY + 96)
        world.addChild(node)
        if !reducedMotion {
            node.run(.repeatForever(.sequence([
                .moveBy(x: 0, y: 8, duration: 0.38),
                .moveBy(x: 0, y: -8, duration: 0.38)
            ])), withKey: "kofiWave")
        }
        bonusNodes.append(BonusNode(node: node, value: 8, isKofi: true))
    }
    
    private func attachHazardWarning(to node: SKNode, kind: HazardKind) {
        let warning = SKNode()
        warning.name = "hazardWarning"
        warning.position = CGPoint(x: 0, y: kind.ducksUnder ? 38 : 58)
        warning.zPosition = 20
        
        let bubble = SKShapeNode(circleOfRadius: 13)
        bubble.fillColor = UIColor(red: 1.0, green: 0.28, blue: 0.62, alpha: 0.86)
        bubble.strokeColor = UIColor(red: 1.0, green: 0.88, blue: 0.96, alpha: 1)
        bubble.lineWidth = 2
        warning.addChild(bubble)
        
        let mark = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        mark.text = kind.warningMark
        mark.fontSize = 17
        mark.fontColor = .white
        mark.verticalAlignmentMode = .center
        mark.horizontalAlignmentMode = .center
        mark.position = CGPoint(x: 0, y: -1)
        warning.addChild(mark)
        node.addChild(warning)
        
        if !reducedMotion {
            warning.run(.repeatForever(.sequence([
                .scale(to: 1.16, duration: 0.16),
                .scale(to: 1.0, duration: 0.16),
                .wait(forDuration: 0.36)
            ])), withKey: "warningPulse")
        }
    }
    
    private func collectPowerUp(_ kind: PowerUpKind) {
        switch kind {
        case .shield:
            shieldCharges = min(3 + shieldLevel, shieldCharges + 1)
        case .magnet:
            magnetTimer = max(magnetTimer, 5.0 + CGFloat(magnetLevel) * 1.5)
        case .boost:
            boostTimer = max(boostTimer, 3.8 + CGFloat(boostLevel) * 0.9)
            invincibleTimer = max(invincibleTimer, 0.9)
        case .revive:
            reviveTokens = min(2, reviveTokens + 1)
        }
        addCombo(points: 18, messageText: "\(kind.title) combo")
        playCue(1105)
        feedback(.medium)
        message("\(kind.title) powerup")
        updateHUD()
    }

    private func buildPlayer() {
        player.removeAllChildren()
        player.name = "PrincessAdelynn"

        let shadow = SKShapeNode(ellipseOf: CGSize(width: 48, height: 12))
        shadow.fillColor = UIColor.black.withAlphaComponent(0.22)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -4)
        shadow.zPosition = -2
        player.addChild(shadow)

        let look = paintedLook(for: selectedRunner)
        let cutout = makePaintedRunnerRig(look: look, runner: selectedRunner)
        let rig = cutout ?? makeStyledRunnerRig(look: look)
        rig.setScale(0.94)
        rig.zRotation = -0.03
        rig.position = CGPoint(x: 0, y: cutout == nil ? 8 : 0)
        rig.zPosition = 2
        player.addChild(rig)

        // Name pill stays on player root so facing flip never mirrors the text.
        let namePill = SKShapeNode(rectOf: CGSize(width: 118, height: 26), cornerRadius: 13)
        namePill.name = "PrincessAdelynnNamePill"
        namePill.fillColor = look.panel.withAlphaComponent(0.97)
        namePill.strokeColor = .white
        namePill.lineWidth = 2.2
        namePill.position = CGPoint(x: 0, y: 168)
        namePill.zPosition = 8
        player.addChild(namePill)

        let nameLabel = label(selectedRunner.title, size: 10, weight: .heavy)
        nameLabel.name = "PrincessAdelynnName"
        nameLabel.fontColor = UIColor(red: 0.38, green: 0.10, blue: 0.26, alpha: 1)
        nameLabel.position = CGPoint(x: 0, y: 163)
        nameLabel.zPosition = 9
        player.addChild(nameLabel)

        startCharacterSecondaryAnimation(on: rig)
        updateRunnerNamePill()
    }

    private func updateRunnerNamePill() {
        (player.childNode(withName: "PrincessAdelynnName") as? SKLabelNode)?.text = selectedRunner.title
        if let pill = player.childNode(withName: "PrincessAdelynnNamePill") as? SKShapeNode {
            let width = max(118, CGFloat(selectedRunner.title.count) * 7.2)
            setRoundedRect(pill, size: CGSize(width: width, height: 26), cornerRadius: 13)
        }
    }

    /// Joint layout for the painted cut-out rig (rig-local units, y up, feet at y = 0).
    private enum PrincessRig {
        static let torsoHeight: CGFloat = 58
        static let torsoAnchor = CGPoint(x: 0.5, y: 0.0)
        static let torsoPos = CGPoint(x: 0, y: 30)
        static let headHeight: CGFloat = 70
        static let headAnchor = CGPoint(x: 0.628, y: 0.077)
        static let headPos = CGPoint(x: 4, y: 86)
        static let hipY: CGFloat = 40
        static let nearHipX: CGFloat = 2
        static let farHipX: CGFloat = -6
        static let shinHeight: CGFloat = 44
        static let shinAnchor = CGPoint(x: 0.34, y: 0.97)
        static let shoulderY: CGFloat = 76
        /// Side view: shoulders sit on the ribcage, not the leading chest edge.
        static let nearShoulderX: CGFloat = 4
        static let farShoulderX: CGFloat = -8
        /// Side-view princes: shoulders sit on the ribcage, not the leading chest edge.
        static let maleNearShoulderX: CGFloat = -2
        static let maleFarShoulderX: CGFloat = -9
        static let maleHeadPos = CGPoint(x: 1, y: 88)
        /// The painted piece is a whole arm (shoulder to fist), so it hangs from the shoulder.
        static let armHeight: CGFloat = 44
        static let armAnchor = CGPoint(x: 0.49, y: 0.97)
        /// Far-side limbs are dimmed so the side view reads with depth.
        static let farTint = UIColor(red: 0.55, green: 0.28, blue: 0.42, alpha: 1)
        static let farBlend: CGFloat = 0.12
    }

    private func cutoutIsMale(_ rig: SKNode) -> Bool {
        (rig.userData?["male"] as? NSNumber)?.boolValue == true
    }

    private func cutoutLayout(for rig: SKNode) -> (nearShoulderX: CGFloat, farShoulderX: CGFloat, headPos: CGPoint) {
        let data = rig.userData
        if let near = data?["nearShoulderX"] as? NSNumber,
           let far = data?["farShoulderX"] as? NSNumber,
           let headX = data?["headX"] as? NSNumber,
           let headY = data?["headY"] as? NSNumber {
            return (CGFloat(truncating: near), CGFloat(truncating: far), CGPoint(x: CGFloat(truncating: headX), y: CGFloat(truncating: headY)))
        }
        if cutoutIsMale(rig) {
            return (PrincessRig.maleNearShoulderX, PrincessRig.maleFarShoulderX, PrincessRig.maleHeadPos)
        }
        return (PrincessRig.nearShoulderX, PrincessRig.farShoulderX, PrincessRig.headPos)
    }

    private func malePantColor(_ look: RunnerLook) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if look.outfit.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: min(1, s * 1.08), brightness: max(0.12, b * 0.42), alpha: 1)
        }
        return shadedBack(look.outfit)
    }

    /// Darkens a colour for far-side limbs so depth reads in a strict side view.
    private func shadedBack(_ color: UIColor) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard color.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return color }
        return UIColor(hue: h, saturation: min(1, s * 0.92), brightness: b * 0.74, alpha: a)
    }

    private func princessPartTexture(named name: String) -> SKTexture? {
        let texture = SKTexture(imageNamed: name)
        let size = texture.size()
        guard size.width > 8, size.height > 8 else { return nil }
        texture.filteringMode = .linear
        return texture
    }

    /// Palette used on Adelynn's painted parts. Other runners keep her cut-out build
    /// and only swap skin, hair, and gown colors.
    private func paintedLook(for runner: FeaturedRunner) -> RunnerLook {
        var look = runner.look
        if runner == .adelynn {
            look.outfit = selectedOutfit.dress
            look.accent = selectedOutfit.cape.withAlphaComponent(1)
        }
        return look
    }

    private func paintedPartTexture(named name: String, look: RunnerLook, runner: FeaturedRunner) -> SKTexture? {
        let key = "\(name)|\(runner.rawValue)|\(selectedOutfit.rawValue)|skin10"
        if let cached = paintedTextureCache[key] { return cached }
        guard let base = princessPartTexture(named: name) else { return nil }
        let mapped = recolorPrincessTexture(
            base,
            look: look,
            outfitOnly: false,
            eraseFeminineHair: runner.isMale && name.contains("Head"),
            maleShoes: runner.isMale && name.contains("Shin"),
            forceSkin: name.contains("Forearm"),
            erasePaintedPonytail: !runner.isMale && name.contains("Head")
        )
        paintedTextureCache[key] = mapped
        return mapped
    }

    private func rgba(_ color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if !color.getRed(&r, green: &g, blue: &b, alpha: &a) {
            color.getHue(&r, saturation: &g, brightness: &b, alpha: &a)
            let converted = UIColor(hue: r, saturation: g, brightness: b, alpha: a)
            converted.getRed(&r, green: &g, blue: &b, alpha: &a)
        }
        return (r, g, b)
    }

    private func shadeMappedColor(_ target: (r: CGFloat, g: CGFloat, b: CGFloat), luma: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let targetLuma = max(0.08, 0.299 * target.r + 0.587 * target.g + 0.114 * target.b)
        let scale = min(1.85, luma / targetLuma)
        return (min(1, target.r * scale), min(1, target.g * scale), min(1, target.b * scale))
    }

    /// Keeps painted highlights but stays close to the face color.
    private func mapToFaceSkin(_ target: (r: CGFloat, g: CGFloat, b: CGFloat), luma: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let lift = max(-0.12, min(0.06, (luma - 0.70) * 0.38))
        return (
            min(1, max(0, target.r + lift)),
            min(1, max(0, target.g + lift * 0.92)),
            min(1, max(0, target.b + lift * 0.88))
        )
    }

    /// Pulls painted hair toward the look color instead of keeping the original dark brown.
    private func mapToHairColor(_ target: (r: CGFloat, g: CGFloat, b: CGFloat), luma: CGFloat) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let lift = max(-0.08, min(0.16, (luma - 0.36) * 0.50))
        return (
            min(1, max(0, target.r + lift)),
            min(1, max(0, target.g + lift * 0.90)),
            min(1, max(0, target.b + lift * 0.70))
        )
    }

    /// Hanging tail in the head PNG: left of the ear, below the bow. Bitmap row 0 is the top of the image.
    private func isHangingPaintedPonytail(col: Int, rowFromTop: Int, width: Int, height: Int) -> Bool {
        col < Int(CGFloat(width) * 0.465) && rowFromTop > Int(CGFloat(height) * 0.22)
    }

    private func paintedPonytailTexture(look: RunnerLook, runner: FeaturedRunner) -> SKTexture? {
        let key = "ponytail|\(runner.rawValue)|skin10"
        if let cached = paintedTextureCache[key] { return cached }
        guard let base = princessPartTexture(named: "PrincessAdelynnHead") else { return nil }
        let mapped = recolorPrincessTexture(base, look: look, outfitOnly: false, extractPonytailOnly: true)
        paintedTextureCache[key] = mapped
        return mapped
    }

    /// Recolors Adelynn's painted art while keeping her shading, crown, and sneakers.
    private func recolorPrincessTexture(_ texture: SKTexture, look: RunnerLook, outfitOnly: Bool, eraseFeminineHair: Bool = false, maleShoes: Bool = false, forceSkin: Bool = false, erasePaintedPonytail: Bool = false, extractPonytailOnly: Bool = false) -> SKTexture {
        let source = texture.cgImage()
        let width = source.width
        let height = source.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return texture }
        ctx.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))

        let outfit = rgba(look.outfit)
        let accent = rgba(look.accent)
        let skin = rgba(look.skin)
        let hair = rgba(look.hair)
        let hairShine = rgba(look.hairShine)
        let shoe = rgba(look.shoe)
        let shoeAccent = rgba(look.shoeAccent)

        for index in stride(from: 0, to: pixels.count, by: 4) {
            let alpha = pixels[index + 3]
            if alpha < 10 { continue }
            let af = CGFloat(alpha) / 255
            let r = min(1, CGFloat(pixels[index]) / 255 / af)
            let g = min(1, CGFloat(pixels[index + 1]) / 255 / af)
            let b = min(1, CGFloat(pixels[index + 2]) / 255 / af)
            var hue: CGFloat = 0, sat: CGFloat = 0, value: CGFloat = 0
            UIColor(red: r, green: g, blue: b, alpha: 1).getHue(&hue, saturation: &sat, brightness: &value, alpha: nil)
            let luma = 0.299 * r + 0.587 * g + 0.114 * b

            let isGold = hue > 0.08 && hue < 0.18 && sat > 0.40 && value > 0.45 && b < 0.55
            let isWhite = sat < 0.16 && value > 0.82
            let isEye = hue > 0.50 && hue < 0.70 && sat > 0.25
            let isPink = sat > 0.25 && value > 0.32 && (hue > 0.80 || hue < 0.08) && b >= g * 0.95
            let isHair = !outfitOnly && hue > 0.0 && hue < 0.15 && value < 0.58 && sat > 0.16 && r >= g * 0.82 && g > b
            let isSkin = !outfitOnly && hue > 0.02 && hue < 0.16 && sat > 0.06 && sat < 0.70 && value > 0.50 && r > g * 0.85 && g > b * 0.85

            if eraseFeminineHair, isPink || isHair {
                pixels[index] = 0
                pixels[index + 1] = 0
                pixels[index + 2] = 0
                pixels[index + 3] = 0
                continue
            }

            let pixel = index / 4
            let col = pixel % width
            let rowFromTop = pixel / width
            let hairMass = isHair || (hue < 0.16 && sat > 0.10 && value < 0.70 && r > g && g > b * 0.65)
            let hangingTail = isHangingPaintedPonytail(col: col, rowFromTop: rowFromTop, width: width, height: height)
                && hairMass && !isGold && !isPink && !isEye && !isSkin

            if extractPonytailOnly, !hangingTail {
                pixels[index] = 0
                pixels[index + 1] = 0
                pixels[index + 2] = 0
                pixels[index + 3] = 0
                continue
            }

            if erasePaintedPonytail, hangingTail {
                pixels[index] = 0
                pixels[index + 1] = 0
                pixels[index + 2] = 0
                pixels[index + 3] = 0
                continue
            }

            var mapped = (r, g, b)
            if forceSkin {
                mapped = mapToFaceSkin(skin, luma: luma)
            } else if isGold || isEye {
                mapped = (r, g, b)
            } else if maleShoes, isPink {
                mapped = shadeMappedColor(shoeAccent, luma: luma)
            } else if maleShoes, isWhite {
                mapped = shadeMappedColor(shoe, luma: max(luma, 0.35))
            } else if isWhite {
                mapped = (r, g, b)
            } else if isPink {
                mapped = shadeMappedColor(value > 0.78 && sat < 0.62 ? outfit : accent, luma: luma)
            } else if isHair {
                mapped = mapToHairColor(value > 0.42 ? hairShine : hair, luma: luma)
            } else if isSkin {
                mapped = mapToFaceSkin(skin, luma: luma)
            }

            pixels[index] = UInt8(max(0, min(255, mapped.0 * af * 255)))
            pixels[index + 1] = UInt8(max(0, min(255, mapped.1 * af * 255)))
            pixels[index + 2] = UInt8(max(0, min(255, mapped.2 * af * 255)))
        }

        guard let output = ctx.makeImage() else { return texture }
        let result = SKTexture(cgImage: output)
        result.filteringMode = .linear
        return result
    }

    /// Painted cut-out runner: Adelynn's illustrated parts on the same joints, recolored per look.
    private func makePaintedRunnerRig(look: RunnerLook, runner: FeaturedRunner) -> SKNode? {
        guard let headTex = paintedPartTexture(named: "PrincessAdelynnHead", look: look, runner: runner),
              let shinTex = paintedPartTexture(named: "PrincessAdelynnShin", look: look, runner: runner),
              let armTex = paintedPartTexture(named: "PrincessAdelynnForearm", look: look, runner: runner) else { return nil }

        let rig = SKNode()
        rig.name = "PrincessAdelynnRig"
        let male = runner.isMale
        let cloth = look.outfit
        let sleeve: CutoutSleeve = male ? .cap : .puff
        let pant = male ? malePantColor(look) : nil
        let nearShoulderX = male ? PrincessRig.maleNearShoulderX : PrincessRig.nearShoulderX
        let farShoulderX = male ? PrincessRig.maleFarShoulderX : PrincessRig.farShoulderX
        let headPos = male ? PrincessRig.maleHeadPos : PrincessRig.headPos
        rig.userData = NSMutableDictionary(dictionary: [
            "cutout": true,
            "male": NSNumber(value: male),
            "nearShoulderX": nearShoulderX,
            "farShoulderX": farShoulderX,
            "headX": headPos.x,
            "headY": headPos.y
        ])

        // Legs sit behind the dress / tunic so the hip joints stay hidden under the hem.
        let farLeg = makeCutoutLeg(name: "leftLeg", texture: shinTex, near: false, pant: pant)
        farLeg.position = CGPoint(x: PrincessRig.farHipX, y: PrincessRig.hipY)
        farLeg.zPosition = 0.4
        rig.addChild(farLeg)

        let nearLeg = makeCutoutLeg(name: "rightLeg", texture: shinTex, near: true, pant: pant)
        nearLeg.position = CGPoint(x: PrincessRig.nearHipX, y: PrincessRig.hipY)
        nearLeg.zPosition = 0.6
        rig.addChild(nearLeg)

        // Far arm MUST stay behind the torso (z < torso). Empty armholes otherwise
        // make it look like both arms sit on the chest.
        let farArm = makeCutoutArm(name: "leftArm", texture: armTex, sleeve: cloth, near: false, style: sleeve)
        farArm.position = CGPoint(x: farShoulderX, y: PrincessRig.shoulderY)
        farArm.zPosition = 0.15
        rig.addChild(farArm)

        if male {
            let torso = makeMaleTorso(look: look)
            torso.zPosition = 2
            rig.addChild(torso)
        } else if let torsoTex = paintedPartTexture(named: "PrincessAdelynnTorso", look: look, runner: runner) {
            let torso = SKSpriteNode(texture: torsoTex)
            torso.name = "torso"
            torso.anchorPoint = PrincessRig.torsoAnchor
            torso.size = CGSize(
                width: PrincessRig.torsoHeight * torsoTex.size().width / torsoTex.size().height,
                height: PrincessRig.torsoHeight
            )
            torso.position = PrincessRig.torsoPos
            torso.zPosition = 2
            rig.addChild(torso)

            // Fill the painted 3/4 armhole so the side-view arm can sit further back.
            let paintedHole = SKShapeNode(ellipseOf: CGSize(width: 16, height: 13))
            paintedHole.fillColor = cloth
            paintedHole.strokeColor = UIColor(red: 0.35, green: 0.10, blue: 0.24, alpha: 0.12)
            paintedHole.lineWidth = 0.6
            paintedHole.position = CGPoint(x: 11, y: PrincessRig.shoulderY - 4)
            paintedHole.zPosition = 2.35
            rig.addChild(paintedHole)

            let shoulderPlug = SKShapeNode(ellipseOf: CGSize(width: 12, height: 11))
            shoulderPlug.fillColor = cloth
            shoulderPlug.strokeColor = UIColor(red: 0.35, green: 0.10, blue: 0.24, alpha: 0.18)
            shoulderPlug.lineWidth = 0.8
            shoulderPlug.position = CGPoint(x: nearShoulderX, y: PrincessRig.shoulderY - 3)
            shoulderPlug.zPosition = 2.4
            rig.addChild(shoulderPlug)
        } else {
            return nil
        }

        if male {
            let head = makeMaleHead(look: look)
            head.zPosition = 3
            rig.addChild(head)
        } else {
            let head = SKSpriteNode(texture: headTex)
            head.name = "head"
            head.anchorPoint = PrincessRig.headAnchor
            head.size = CGSize(
                width: PrincessRig.headHeight * headTex.size().width / headTex.size().height,
                height: PrincessRig.headHeight
            )
            head.position = PrincessRig.headPos
            head.zPosition = 3
            addPaintedHeadLife(to: head, look: look, runner: runner)
            rig.addChild(head)
        }

        // Near arm stays in front of torso/head stack.
        let nearArm = makeCutoutArm(name: "rightArm", texture: armTex, sleeve: cloth, near: true, style: sleeve)
        nearArm.position = CGPoint(x: nearShoulderX, y: PrincessRig.shoulderY)
        nearArm.zPosition = 4.5
        rig.addChild(nearArm)

        return rig
    }

    private func maleTunicPath(coat: Bool) -> CGPath {
        let path = CGMutablePath()
        let top: CGFloat = coat ? 52 : 46
        let bottom: CGFloat = coat ? -2 : 6
        path.move(to: CGPoint(x: -13, y: bottom))
        path.addLine(to: CGPoint(x: 7, y: bottom))
        path.addLine(to: CGPoint(x: 8, y: top - 10))
        path.addLine(to: CGPoint(x: 4, y: top))
        path.addLine(to: CGPoint(x: -10, y: top))
        path.addLine(to: CGPoint(x: -15, y: top - 10))
        path.closeSubpath()
        return path
    }

    private func makeMaleTorso(look: RunnerLook) -> SKNode {
        let torso = SKNode()
        torso.name = "torso"
        torso.position = PrincessRig.torsoPos
        let outline = UIColor(red: 0.16, green: 0.08, blue: 0.10, alpha: 0.42)
        let gold = UIColor(red: 1.0, green: 0.84, blue: 0.28, alpha: 1)
        let isCoat = look.silhouette == .coat
        let top: CGFloat = isCoat ? 52 : 46

        if isCoat {
            let cape = SKShapeNode(path: sideCapePath())
            cape.fillColor = look.outfit.withAlphaComponent(0.90)
            cape.strokeColor = outline
            cape.lineWidth = 1.2
            cape.position = CGPoint(x: -15, y: 22)
            cape.zRotation = -0.10
            cape.xScale = 1.04
            cape.zPosition = -1
            torso.addChild(cape)
        }

        let body = SKShapeNode(path: maleTunicPath(coat: isCoat))
        body.fillColor = look.outfit
        body.strokeColor = outline
        body.lineWidth = 1.5
        body.zPosition = 1
        torso.addChild(body)

        let shine = SKShapeNode(rectOf: CGSize(width: 6, height: top * 0.42), cornerRadius: 3)
        shine.fillColor = UIColor.white.withAlphaComponent(0.14)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: 4, y: top * 0.55)
        shine.zPosition = 1.2
        torso.addChild(shine)

        let sash = SKShapeNode(rectOf: CGSize(width: 28, height: 7), cornerRadius: 2)
        sash.fillColor = look.accent
        sash.strokeColor = outline.withAlphaComponent(0.28)
        sash.lineWidth = 0.6
        sash.position = CGPoint(x: -1, y: 13)
        sash.zPosition = 1.4
        torso.addChild(sash)

        let neck = SKShapeNode(rectOf: CGSize(width: 10, height: 11), cornerRadius: 4)
        neck.fillColor = look.skin
        neck.strokeColor = outline.withAlphaComponent(0.25)
        neck.lineWidth = 0.6
        neck.position = CGPoint(x: 1, y: top + 6)
        neck.zPosition = 1.3
        torso.addChild(neck)

        let collar = SKShapeNode(rectOf: CGSize(width: 16, height: 4), cornerRadius: 1.4)
        collar.fillColor = look.panel
        collar.strokeColor = look.accent
        collar.lineWidth = 1.1
        collar.position = CGPoint(x: 1, y: top + 1)
        collar.zPosition = 1.5
        torso.addChild(collar)

        let brooch = SKShapeNode(ellipseOf: CGSize(width: 7, height: 7))
        brooch.fillColor = gold
        brooch.strokeColor = UIColor.white.withAlphaComponent(0.55)
        brooch.lineWidth = 0.6
        brooch.position = CGPoint(x: 3, y: 18)
        brooch.zPosition = 1.6
        torso.addChild(brooch)
        let gem = SKShapeNode(circleOfRadius: 1.9)
        gem.fillColor = look.gem
        gem.strokeColor = .clear
        brooch.addChild(gem)

        let nearShoulder = SKShapeNode(ellipseOf: CGSize(width: 13, height: 10))
        nearShoulder.fillColor = look.outfit
        nearShoulder.strokeColor = outline.withAlphaComponent(0.25)
        nearShoulder.lineWidth = 0.6
        nearShoulder.position = CGPoint(x: PrincessRig.maleNearShoulderX, y: PrincessRig.shoulderY - PrincessRig.torsoPos.y)
        nearShoulder.zPosition = 1.7
        torso.addChild(nearShoulder)

        let farShoulder = SKShapeNode(ellipseOf: CGSize(width: 11, height: 9))
        farShoulder.fillColor = shadedBack(look.outfit)
        farShoulder.strokeColor = .clear
        farShoulder.position = CGPoint(x: PrincessRig.maleFarShoulderX, y: PrincessRig.shoulderY - PrincessRig.torsoPos.y)
        farShoulder.zPosition = 0.8
        torso.addChild(farShoulder)
        return torso
    }

    private func makeMaleHead(look: RunnerLook) -> SKNode {
        let head = SKNode()
        head.name = "head"
        head.position = PrincessRig.maleHeadPos
        let outline = UIColor(red: 0.16, green: 0.08, blue: 0.10, alpha: 0.38)
        let sweep = look.hairStyle == .sweep

        // Hair sits behind the face so the crop reads as a skull-cap, not a bun.
        let hair = SKShapeNode(ellipseOf: CGSize(width: 40, height: 44))
        hair.fillColor = look.hair
        hair.strokeColor = outline.withAlphaComponent(0.3)
        hair.lineWidth = 0.8
        hair.position = CGPoint(x: -2, y: 16)
        hair.zPosition = -0.2
        head.addChild(hair)

        let hairShine = SKShapeNode(ellipseOf: CGSize(width: 12, height: 6))
        hairShine.fillColor = look.hairShine
        hairShine.strokeColor = .clear
        hairShine.position = CGPoint(x: -4, y: 32)
        hairShine.zPosition = -0.1
        head.addChild(hairShine)

        if sweep {
            let lock = SKShapeNode(ellipseOf: CGSize(width: 12, height: 18))
            lock.fillColor = look.hair
            lock.strokeColor = .clear
            lock.position = CGPoint(x: 14, y: 26)
            lock.zRotation = 0.35
            lock.zPosition = -0.05
            head.addChild(lock)
        }

        let ear = SKShapeNode(ellipseOf: CGSize(width: 7, height: 10))
        ear.fillColor = look.skinShade
        ear.strokeColor = outline.withAlphaComponent(0.3)
        ear.lineWidth = 0.6
        ear.position = CGPoint(x: -11, y: 12)
        ear.zPosition = 0
        head.addChild(ear)

        let face = SKShapeNode(ellipseOf: CGSize(width: 32, height: 38))
        face.fillColor = look.skin
        face.strokeColor = outline
        face.lineWidth = 1.2
        face.position = CGPoint(x: 6, y: 12)
        face.zPosition = 0.2
        head.addChild(face)

        let cheek = SKShapeNode(ellipseOf: CGSize(width: 8, height: 5))
        cheek.fillColor = look.skinShade.withAlphaComponent(0.35)
        cheek.strokeColor = .clear
        cheek.position = CGPoint(x: 12, y: 8)
        cheek.zPosition = 0.25
        head.addChild(cheek)

        let brow = SKShapeNode(rectOf: CGSize(width: 8, height: 1.8), cornerRadius: 0.9)
        brow.fillColor = look.hair
        brow.strokeColor = .clear
        brow.position = CGPoint(x: 13, y: 20)
        brow.zRotation = -0.08
        brow.zPosition = 0.4
        head.addChild(brow)

        let eye = SKShapeNode(ellipseOf: CGSize(width: 5.5, height: 6))
        eye.fillColor = UIColor(red: 0.12, green: 0.08, blue: 0.08, alpha: 1)
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 14, y: 15)
        eye.zPosition = 0.4
        head.addChild(eye)
        addEyelid(to: head, at: CGPoint(x: 14, y: 18.6), width: 7.4, height: 7.2, look: look)
        let glint = SKShapeNode(circleOfRadius: 1.1)
        glint.fillColor = .white
        glint.strokeColor = .clear
        glint.position = CGPoint(x: 13.2, y: 16.2)
        glint.zPosition = 0.45
        head.addChild(glint)

        let nose = SKShapeNode(ellipseOf: CGSize(width: 5, height: 4.5))
        nose.fillColor = look.skinShade
        nose.strokeColor = .clear
        nose.position = CGPoint(x: 20, y: 11)
        nose.zPosition = 0.35
        head.addChild(nose)

        let mouth = SKShapeNode(rectOf: CGSize(width: 6, height: 1.6), cornerRadius: 0.8)
        mouth.fillColor = look.skinShade.withAlphaComponent(0.8)
        mouth.strokeColor = .clear
        mouth.position = CGPoint(x: 14, y: 5)
        mouth.zPosition = 0.35
        head.addChild(mouth)

        let crown = SKShapeNode(path: crownPath())
        crown.fillColor = goldColor
        crown.strokeColor = UIColor.white.withAlphaComponent(0.7)
        crown.lineWidth = 1.0
        crown.setScale(0.30)
        crown.position = CGPoint(x: 0, y: 36)
        crown.zPosition = 0.6
        head.addChild(crown)
        return head
    }

    private var goldColor: UIColor { UIColor(red: 1.0, green: 0.84, blue: 0.28, alpha: 1) }

    private func makePrincessAdelynnCutoutRig() -> SKNode? {
        makePaintedRunnerRig(look: paintedLook(for: selectedRunner), runner: selectedRunner)
    }

    private enum CutoutSleeve {
        case puff
        case cap
    }

    /// Shin + sneaker pivoting at the hip; the knee end is covered by the skirt or pant.
    private func makeCutoutLeg(name: String, texture: SKTexture, near: Bool, pant: UIColor? = nil) -> SKNode {
        let joint = SKNode()
        joint.name = name
        let height = PrincessRig.shinHeight * (near ? 1.0 : 0.96)
        let shin = SKSpriteNode(texture: texture)
        shin.name = "shin"
        shin.anchorPoint = PrincessRig.shinAnchor
        shin.size = CGSize(width: height * texture.size().width / texture.size().height, height: height)
        joint.addChild(shin)
        if let pant {
            let cuff = SKShapeNode(rectOf: CGSize(width: near ? 13 : 12, height: 24), cornerRadius: 4)
            cuff.fillColor = near ? pant : shadedBack(pant)
            cuff.strokeColor = UIColor(red: 0.18, green: 0.08, blue: 0.10, alpha: 0.28)
            cuff.lineWidth = 0.7
            cuff.position = CGPoint(x: 1, y: -14)
            cuff.zPosition = 1.2
            joint.addChild(cuff)
        }
        return joint
    }

    /// One painted arm per side, pivoting at the shoulder, capped by a sleeve.
    private func makeCutoutArm(name: String, texture: SKTexture, sleeve: UIColor, near: Bool, style: CutoutSleeve = .puff) -> SKNode {
        let joint = SKNode()
        joint.name = name

        let height = PrincessRig.armHeight * (near ? 1.0 : 0.94)
        let arm = SKSpriteNode(texture: texture)
        arm.name = "arm"
        arm.anchorPoint = PrincessRig.armAnchor
        arm.size = CGSize(width: height * texture.size().width / texture.size().height, height: height)
        arm.zPosition = 1
        if style == .cap {
            arm.position.x = -5
            if !near {
                arm.alpha = 0.28
            }
        } else {
            arm.position.x = -3
            if !near {
                arm.alpha = 0.42
            }
        }
        joint.addChild(arm)

        let cloth = near ? sleeve : shadedBack(sleeve)
        let outline = UIColor(red: 0.35, green: 0.10, blue: 0.24, alpha: 0.22)
        switch style {
        case .puff:
            let puffWidth: CGFloat = near ? 13 : 11
            let puff = SKShapeNode(ellipseOf: CGSize(width: puffWidth, height: puffWidth * 0.92))
            puff.name = "sleeve"
            puff.fillColor = cloth
            puff.strokeColor = outline
            puff.lineWidth = 0.9
            puff.position = CGPoint(x: 0, y: -2)
            puff.zPosition = 2
            joint.addChild(puff)
        case .cap:
            let cap = SKShapeNode(ellipseOf: CGSize(width: near ? 12 : 10, height: 10))
            cap.name = "sleeve"
            cap.fillColor = cloth
            cap.strokeColor = outline
            cap.lineWidth = 0.8
            cap.position = CGPoint(x: -1, y: -1)
            cap.zPosition = 2
            joint.addChild(cap)
        }
        return joint
    }

    /// Eases the crouch in at the start and out at the end so it never snaps.
    private var duckBlend: CGFloat {
        guard duckTimer > 0 else { return 0 }
        let elapsed = max(0, Self.duckDuration - duckTimer)
        return max(0, min(1, min(elapsed / 0.09, duckTimer / 0.13)))
    }

    private func poseMix(_ from: CGFloat, _ to: CGFloat, _ t: CGFloat) -> CGFloat {
        from + (to - from) * t
    }

    /// 0 = open jump pose, 1 = full cannonball. Holds the tuck through the spin, then opens to land.
    private func somersaultTuck(progress: CGFloat) -> CGFloat {
        let p = max(0, min(1, progress))
        if p < 0.16 {
            let t = p / 0.16
            return t * t * (3 - 2 * t)
        }
        if p < 0.74 {
            return 1
        }
        let t = (p - 0.74) / 0.26
        return 1 - t * t * (3 - 2 * t)
    }

    /// Eased 0→1 of the 360°. Slow kick, fast through the ball, settle on the open.
    private func somersaultSpin(progress: CGFloat) -> CGFloat {
        let p = max(0, min(1, progress))
        if p < 0.16 {
            let t = p / 0.16
            return 0.18 * t * t * (3 - 2 * t)
        }
        if p < 0.74 {
            let t = (p - 0.16) / 0.58
            return 0.18 + 0.70 * t * t * (3 - 2 * t)
        }
        let t = (p - 0.74) / 0.26
        return 0.88 + 0.12 * t * t * (3 - 2 * t)
    }

    /// Positive rotation swings a downward-hanging limb forward (+x).
    private func legSwing(_ stride: CGFloat) -> CGFloat {
        max(0, stride) * 0.42 - max(0, -stride) * 0.35
    }

    private func legShift(_ stride: CGFloat) -> CGFloat {
        max(0, stride) * 4 - max(0, -stride) * 3
    }

    private func armSwing(_ stride: CGFloat) -> CGFloat {
        max(0, stride) * 0.85 - max(0, -stride) * 0.72
    }

    /// One leg sampled at `cycle`, where 0 is footstrike and 1 is the next strike for the
    /// same foot. Stance is deliberately shorter than half the cycle, so between steps
    /// both feet are off the ground — that flight gap is what separates a run from a
    /// fast walk, no matter how quickly the legs are moving.
    private struct RunLegPose {
        var rotation: CGFloat = 0
        /// 0 = leg straight, 1 = knee picked all the way up. The painted shin is a single
        /// rigid piece, so a raised knee is faked by shortening it.
        var tuck: CGFloat = 0
        var hipLift: CGFloat = 0
    }

    /// Stance is well under half the cycle; the rest of the step is flight.
    private static let runStanceDuty: CGFloat = 0.34
    /// Peak forward reach of the swing leg. Doubles as the normaliser that turns a leg
    /// pose back into a -1...1 swing for the opposite arm.
    private static let runLegReach: CGFloat = 0.66
    private static let runLegTrail: CGFloat = 0.72
    /// Gait cycles per unit of `characterPoseTime` — about 2.1 a second at full run speed.
    private static let runCadence: CGFloat = 1.9

    private func runLegPose(cycle: CGFloat) -> RunLegPose {
        let duty = Self.runStanceDuty
        let reach = Self.runLegReach
        let trail = Self.runLegTrail
        var pose = RunLegPose()
        if cycle < duty {
            // Stance: the planted foot sweeps back underneath her while the knee softens
            // through midstance to absorb the landing.
            let p = cycle / duty
            pose.rotation = reach - (reach + trail) * p
            pose.tuck = sin(p * .pi) * 0.10
        } else {
            // Recovery: heel snaps up behind, the knee drives forward past the hip, then
            // the shin unfolds to reach for the next strike.
            let q = (cycle - duty) / (1 - duty)
            let ease = q * q * (3 - 2 * q)
            pose.rotation = -trail + (reach + trail) * ease + sin(q * .pi) * 0.24
            pose.tuck = pow(sin(q * .pi), 0.75) * 0.42
            pose.hipLift = pose.tuck * 9
        }
        return pose
    }

    /// Hip travel across one step: they sink as the stance leg absorbs the landing, then
    /// float upward through the airborne gap.
    private func runBodyBob(cycle: CGFloat) -> CGFloat {
        let step = (cycle * 2).truncatingRemainder(dividingBy: 1)
        let stance = Self.runStanceDuty * 2
        if step < stance {
            return -4.2 * sin(step / stance * .pi)
        }
        return 8.8 * sin((step - stance) / (1 - stance) * .pi)
    }

    private func setJoint(_ node: SKNode?, x: CGFloat, y: CGFloat, rotation: CGFloat) {
        guard let node else { return }
        node.position = CGPoint(x: x, y: y)
        node.zRotation = rotation
    }

    /// Swings a rig-space point around the hip so the head and shoulders stay attached
    /// to a leaning torso instead of drifting off the neck.
    private func rotatedAboutHip(_ point: CGPoint, by angle: CGFloat) -> CGPoint {
        let dx = point.x - PrincessRig.torsoPos.x
        let dy = point.y - PrincessRig.torsoPos.y
        return CGPoint(
            x: PrincessRig.torsoPos.x + dx * cos(angle) - dy * sin(angle),
            y: PrincessRig.torsoPos.y + dx * sin(angle) + dy * cos(angle)
        )
    }

    /// Contralateral run cycle for the cut-out rig, plus distinct air, slide and flip poses.
    private func updateCutoutRunPose(rig: SKNode, facing: CGFloat, baseScale: CGFloat) {
        let ampBoost: CGFloat = dashTimer > 0 || boostTimer > 0 ? 1.12 : 1
        let movement = min(1.25, max(abs(playerVelocityX) / 230, (rightPressed || leftPressed) ? 0.85 : 0))
        let airborne = !playerGrounded
        let moving = movement > 0.08
        // Gait clock in whole cycles: one cycle is two footfalls. Tempo alone never sold the
        // run — a quick sinusoidal leg swing with both feet down is exactly a speed-walk — so
        // the stride comes from a duty-cycled pose with a real flight phase between steps.
        let cycle = characterPoseTime * Self.runCadence
        let step = cycle.truncatingRemainder(dividingBy: 1)
        let phase = cycle * 2 * .pi
        let crouch = duckBlend
        let rising = airborne && playerVelocityY > 40
        let falling = airborne && playerVelocityY < -40

        // Idle keeps a slow breath so she never reads as a frozen sprite.
        let breathe = moving ? 0 : sin(characterPoseTime * 2.4)
        let gaitAmp = min(1, movement) * ampBoost * (airborne ? 0.14 : 1)
        let farGait = runLegPose(cycle: step)
        let nearGait = runLegPose(cycle: (step + 0.5).truncatingRemainder(dividingBy: 1))
        // Normalised -1...1 swing per leg; the opposite arm is driven from it.
        let farSwing = moving ? farGait.rotation / Self.runLegReach : -0.22 + breathe * 0.04
        let nearSwing = moving ? nearGait.rotation / Self.runLegReach : 0.22 - breathe * 0.04
        // Knees tuck up on the way up, then the lead foot reaches down for the landing.
        let airLegBias: CGFloat = rising ? 0.34 : (falling ? -0.22 : 0)
        let airArmBias: CGFloat = rising ? 0.55 : (airborne ? 0.24 : 0)
        // Dash drives the arms back into a sprint pump.
        let dashBias: CGFloat = dashTimer > 0 ? -0.16 : 0
        let armAmp: CGFloat = moving ? 1.18 * ampBoost : 1

        var farLegRot = moving ? farGait.rotation * gaitAmp + airLegBias : legSwing(farSwing)
        var nearLegRot = moving ? nearGait.rotation * gaitAmp + airLegBias : legSwing(nearSwing)
        var farLegX = PrincessRig.farHipX + legShift(farSwing * gaitAmp)
        var nearLegX = PrincessRig.nearHipX + legShift(nearSwing * gaitAmp)
        var farLegY = PrincessRig.hipY + (moving ? farGait.hipLift * gaitAmp : 0)
        var nearLegY = PrincessRig.hipY + (moving ? nearGait.hipLift * gaitAmp : 0)
        // The shin is one rigid painted piece, so a picked-up knee is faked by shortening it.
        var farShin = 1 - (moving ? farGait.tuck * gaitAmp * 0.34 : 0)
        var nearShin = 1 - (moving ? nearGait.tuck * gaitAmp * 0.34 : 0)
        let layout = cutoutLayout(for: rig)
        let maleRest: CGFloat = cutoutIsMale(rig) ? -0.32 : -0.16
        var farArmRot = armSwing(nearSwing * armAmp + airArmBias + dashBias) + maleRest
        var nearArmRot = armSwing(farSwing * armAmp + airArmBias + dashBias) + maleRest
        // Elbows fold at both ends of the pump, hardest on the drive forward.
        var farArmSquash = 1 - max(0, nearSwing) * 0.17 - max(0, -nearSwing) * 0.09
        var nearArmSquash = 1 - max(0, farSwing) * 0.17 - max(0, -farSwing) * 0.09
        var farShoulderX = layout.farShoulderX
        var nearShoulderX = layout.nearShoulderX
        var shoulderY = PrincessRig.shoulderY

        // Hips sink as the stance leg absorbs the strike, then the whole rig lifts through
        // the flight gap so both feet leave the ground.
        let bob: CGFloat = moving && playerGrounded ? runBodyBob(cycle: step) * min(1, movement) : breathe * 0.5
        let bounce = bob * 0.6
        var torsoX = PrincessRig.torsoPos.x
        var torsoY = PrincessRig.torsoPos.y + bounce
        var torsoRot: CGFloat = 0
        var headX = layout.headPos.x + (moving ? sin(phase) * 0.6 : 0)
        var headY = layout.headPos.y + bounce * 1.05
        // Chin holds up against the forward lean so the crown stays readable at speed.
        var headRot: CGFloat = moving ? 0.05 * min(1, movement) + sin(phase * 0.5) * 0.02 * movement : 0
        var rigLean: CGFloat = airborne ? -0.10 : (dashTimer > 0 ? -0.20 : (moving ? -0.13 * min(1, movement) : -0.01))
        var rigX: CGFloat = 0
        var rigY: CGFloat = moving && playerGrounded ? max(0, bob) * 0.5 : 0
        var stretchX = (dashTimer > 0 ? 1.06 : 1.0) + landSquash * 0.10
        var stretchY = 1 - landSquash * 0.14 - (moving ? abs(sin(phase)) * 0.012 * movement : 0)

        if airborne, crouch == 0 {
            // Rise: both knees tuck, arms throw up. Apex: compact hang. Fall: lead
            // leg reaches for the ground while the trail knee stays bent.
            let riseW = max(0, min(1, playerVelocityY / 500))
            let fallW = max(0, min(1, -playerVelocityY / 560))
            let hangW = max(0, 1 - riseW - fallW)
            let punch = jumpPunch
            let flutter = sin(characterPoseTime * 8.2) * 0.07

            nearLegRot = riseW * 1.02 + hangW * 0.88 + fallW * 0.46 + punch * 0.12
            farLegRot = riseW * -0.92 + hangW * -0.74 + fallW * -0.42 - punch * 0.10
            nearLegX = PrincessRig.nearHipX + 5 * riseW + 3 * hangW + 7 * fallW
            farLegX = PrincessRig.farHipX - 4 * riseW - 3 * hangW - 2 * fallW
            nearLegY = PrincessRig.hipY + 8 * riseW + 7 * hangW + 3 * fallW + punch * 3
            farLegY = PrincessRig.hipY + 10 * riseW + 8 * hangW + 5 * fallW + punch * 3
            nearShin = max(0.58, 0.68 * riseW + 0.72 * hangW + 0.84 * fallW - punch * 0.08)
            farShin = max(0.56, 0.64 * riseW + 0.70 * hangW + 0.78 * fallW - punch * 0.08)

            nearArmRot = riseW * 1.08 + hangW * 0.58 + fallW * 0.24 + flutter + maleRest
            farArmRot = riseW * -0.88 + hangW * 0.22 + fallW * -0.40 - flutter * 0.7 + maleRest
            nearArmSquash = 0.82 * riseW + 0.88 * hangW + 0.94 * fallW
            farArmSquash = 0.84 * riseW + 0.90 * hangW + 0.94 * fallW
            shoulderY = PrincessRig.shoulderY + 5 * riseW + 3 * hangW + 1 * fallW

            torsoRot = riseW * 0.10 + hangW * 0.02 + fallW * -0.14
            torsoY = PrincessRig.torsoPos.y + 3 * riseW + 2 * hangW - 2 * fallW
            headRot = riseW * 0.16 + hangW * 0.05 + fallW * -0.12 + flutter * 0.35
            headY = layout.headPos.y + 4 * riseW + 2 * hangW - 1 * fallW
            rigLean = riseW * -0.05 + hangW * -0.08 + fallW * -0.16
            rigY = 3 * riseW + 4 * hangW + 1 * fallW
            stretchX = 0.94 * riseW + 0.98 * hangW + 0.97 * fallW
            stretchY = 1.08 * riseW + 1.03 * hangW + 1.05 * fallW
        }

        if landSquash > 0.02, !airborne, crouch == 0, !flipActive {
            // Knees absorb the landing instead of only squashing the whole sprite.
            nearLegRot = poseMix(nearLegRot, 0.58, landSquash)
            farLegRot = poseMix(farLegRot, -0.50, landSquash)
            nearShin = poseMix(nearShin, 0.72, landSquash)
            farShin = poseMix(farShin, 0.68, landSquash)
            nearLegY = poseMix(nearLegY, PrincessRig.hipY - 5, landSquash)
            farLegY = poseMix(farLegY, PrincessRig.hipY - 5, landSquash)
            torsoY = poseMix(torsoY, PrincessRig.torsoPos.y - 5, landSquash)
            headY = poseMix(headY, layout.headPos.y - 4, landSquash)
            nearArmRot = poseMix(nearArmRot, 0.42, landSquash)
            farArmRot = poseMix(farArmRot, 0.28, landSquash)
        }

        if crouch > 0, !flipActive {
            // Crouch: hips drop, knees fold out front and back far enough to keep both feet on
            // the deck, chest pitched forward over the lead knee, arms tucked in. No squash —
            // the rig is only ever posed, never flattened.
            let hipDrop = Self.duckHipDrop
            let torsoPitch = Self.duckTorsoPitch
            nearLegRot = poseMix(nearLegRot, Self.duckNearLegRot, crouch)
            farLegRot = poseMix(farLegRot, Self.duckFarLegRot, crouch)
            nearLegX = poseMix(nearLegX, PrincessRig.nearHipX + 3, crouch)
            farLegX = poseMix(farLegX, PrincessRig.farHipX - 2, crouch)
            nearLegY = poseMix(nearLegY, PrincessRig.hipY - hipDrop, crouch)
            farLegY = poseMix(farLegY, PrincessRig.hipY - hipDrop, crouch)
            // Full-length shins and no run bob: the crouch is posed, never bounced.
            nearShin = poseMix(nearShin, 1, crouch)
            farShin = poseMix(farShin, 1, crouch)
            rigY = poseMix(rigY, 0, crouch)
            // Elbows in, forearms across the front — a braced crouch, not a trailing slide.
            nearArmRot = poseMix(nearArmRot, 1.02, crouch)
            farArmRot = poseMix(farArmRot, 0.74, crouch)
            farArmSquash = poseMix(farArmSquash, 0.9, crouch)
            nearArmSquash = poseMix(nearArmSquash, 0.88, crouch)
            torsoRot = poseMix(torsoRot, torsoPitch, crouch)
            torsoY = poseMix(torsoY, PrincessRig.torsoPos.y - hipDrop, crouch)
            // Shoulders and head ride the pitched torso so nothing pops out of its socket.
            let farShoulder = rotatedAboutHip(CGPoint(x: layout.farShoulderX, y: PrincessRig.shoulderY), by: torsoPitch)
            let nearShoulder = rotatedAboutHip(CGPoint(x: layout.nearShoulderX, y: PrincessRig.shoulderY), by: torsoPitch)
            let headRest = rotatedAboutHip(layout.headPos, by: torsoPitch)
            farShoulderX = poseMix(farShoulderX, farShoulder.x, crouch)
            nearShoulderX = poseMix(nearShoulderX, nearShoulder.x, crouch)
            shoulderY = poseMix(shoulderY, nearShoulder.y - hipDrop, crouch)
            headX = poseMix(headX, headRest.x, crouch)
            headY = poseMix(headY, headRest.y - hipDrop, crouch)
            // Chin dips less than the chest pitches, so the crown stays readable.
            headRot = poseMix(headRot, torsoPitch * 0.55, crouch)
            rigLean = poseMix(rigLean, -0.06, crouch)
            stretchX = poseMix(stretchX, 1.04, crouch)
            stretchY = poseMix(stretchY, 1, crouch)
        }

        if flipActive {
            // Cannonball: both knees to the chest, arms hugging, chin down. The
            // tuck holds through the middle of the spin, then she opens to land.
            let ball = somersaultTuck(progress: flipProgress)
            nearLegRot = poseMix(nearLegRot, 1.22, ball)
            farLegRot = poseMix(farLegRot, 1.10, ball)
            nearLegX = poseMix(nearLegX, PrincessRig.nearHipX + 8, ball)
            farLegX = poseMix(farLegX, PrincessRig.farHipX + 6, ball)
            nearLegY = poseMix(nearLegY, PrincessRig.hipY + 10, ball)
            farLegY = poseMix(farLegY, PrincessRig.hipY + 9, ball)
            nearShin = poseMix(nearShin, 0.48, ball)
            farShin = poseMix(farShin, 0.50, ball)
            nearArmRot = poseMix(nearArmRot, 1.38, ball)
            farArmRot = poseMix(farArmRot, 1.22, ball)
            nearArmSquash = poseMix(nearArmSquash, 0.76, ball)
            farArmSquash = poseMix(farArmSquash, 0.78, ball)
            torsoRot = poseMix(torsoRot, 0.18, ball)
            torsoY = poseMix(torsoY, PrincessRig.torsoPos.y + 2, ball)
            headRot = poseMix(headRot, -0.32, ball)
            headY = poseMix(headY, layout.headPos.y - 2, ball)
            stretchX = poseMix(stretchX, 0.84, ball)
            stretchY = poseMix(stretchY, 0.90, ball)
            rigY = poseMix(rigY, 2, ball)
            rigLean -= somersaultSpin(progress: flipProgress) * 2 * .pi
            // Spin about her middle rather than her feet.
            let pivotY: CGFloat = 72
            rigX += facing * baseScale * stretchX * pivotY * sin(rigLean)
            rigY += baseScale * stretchY * pivotY * (1 - cos(rigLean))
        }

        setJoint(rig.childNode(withName: "leftLeg"), x: farLegX, y: farLegY, rotation: farLegRot)
        setJoint(rig.childNode(withName: "rightLeg"), x: nearLegX, y: nearLegY, rotation: nearLegRot)
        setJoint(rig.childNode(withName: "leftArm"), x: farShoulderX, y: shoulderY, rotation: farArmRot)
        setJoint(rig.childNode(withName: "rightArm"), x: nearShoulderX, y: shoulderY, rotation: nearArmRot)
        rig.childNode(withName: "leftArm")?.childNode(withName: "arm")?.yScale = farArmSquash
        rig.childNode(withName: "rightArm")?.childNode(withName: "arm")?.yScale = nearArmSquash
        rig.childNode(withName: "leftLeg")?.childNode(withName: "shin")?.yScale = farShin
        rig.childNode(withName: "rightLeg")?.childNode(withName: "shin")?.yScale = nearShin

        if let torso = rig.childNode(withName: "torso") {
            torso.position = CGPoint(x: torsoX, y: torsoY)
            torso.zRotation = torsoRot
        }
        if let head = rig.childNode(withName: "head") {
            head.position = CGPoint(x: headX, y: headY)
            head.zRotation = headRot
        }

        rig.zRotation = rigLean + (moving && !flipActive ? sin(phase * 0.5) * 0.015 * movement : 0)
        rig.xScale = facing * baseScale * stretchX
        rig.yScale = baseScale * stretchY
        rig.position = CGPoint(x: rigX, y: rigY)

        updateSwayPonytail(on: rig, moving: moving, airborne: airborne, phase: phase, flipping: flipActive)

        if moving, playerGrounded, movement > 0.4, !reducedMotion, crouch == 0 {
            // Dust fires on the two strikes of the cycle rather than at mid-swing.
            let footfall = Int(floor(cycle * 2))
            if footfall != lastFootfallIndex {
                lastFootfallIndex = footfall
                spawnFootDust(offsetX: footfall % 2 == 0 ? 6 : -6)
            }
        }
        if crouch > 0.4, playerGrounded, !reducedMotion, duckDustTimer <= 0 {
            duckDustTimer = 0.05
            spawnFootDust(offsetX: -16)
        }
    }

    /// The same posed crouch as the animated rig, held perfectly still. Ducking changes the
    /// hitbox, so it has to stay readable even with animation turned off.
    private func poseCutoutStillCrouch(rig: SKNode, blend: CGFloat) {
        let crouch = max(0, min(1, blend))
        let hipDrop = Self.duckHipDrop
        let torsoPitch = Self.duckTorsoPitch
        let layout = cutoutLayout(for: rig)
        let farShoulder = rotatedAboutHip(CGPoint(x: layout.farShoulderX, y: PrincessRig.shoulderY), by: torsoPitch)
        let nearShoulder = rotatedAboutHip(CGPoint(x: layout.nearShoulderX, y: PrincessRig.shoulderY), by: torsoPitch)
        let headRest = rotatedAboutHip(layout.headPos, by: torsoPitch)
        let shoulderY = poseMix(PrincessRig.shoulderY, nearShoulder.y - hipDrop, crouch)
        let legY = poseMix(PrincessRig.hipY, PrincessRig.hipY - hipDrop, crouch)

        setJoint(rig.childNode(withName: "leftLeg"),
                 x: poseMix(PrincessRig.farHipX + legShift(-0.22), PrincessRig.farHipX - 2, crouch),
                 y: legY,
                 rotation: poseMix(legSwing(-0.22), Self.duckFarLegRot, crouch))
        setJoint(rig.childNode(withName: "rightLeg"),
                 x: poseMix(PrincessRig.nearHipX + legShift(0.22), PrincessRig.nearHipX + 3, crouch),
                 y: legY,
                 rotation: poseMix(legSwing(0.22), Self.duckNearLegRot, crouch))
        setJoint(rig.childNode(withName: "leftArm"),
                 x: poseMix(layout.farShoulderX, farShoulder.x, crouch),
                 y: shoulderY,
                 rotation: poseMix(armSwing(0.22), 0.74, crouch))
        setJoint(rig.childNode(withName: "rightArm"),
                 x: poseMix(layout.nearShoulderX, nearShoulder.x, crouch),
                 y: shoulderY,
                 rotation: poseMix(armSwing(-0.22), 1.02, crouch))
        rig.childNode(withName: "leftArm")?.childNode(withName: "arm")?.yScale = poseMix(1, 0.9, crouch)
        rig.childNode(withName: "rightArm")?.childNode(withName: "arm")?.yScale = poseMix(1, 0.88, crouch)
        rig.childNode(withName: "leftLeg")?.childNode(withName: "shin")?.yScale = 1
        rig.childNode(withName: "rightLeg")?.childNode(withName: "shin")?.yScale = 1

        if let torso = rig.childNode(withName: "torso") {
            torso.position = CGPoint(x: PrincessRig.torsoPos.x,
                                     y: poseMix(PrincessRig.torsoPos.y, PrincessRig.torsoPos.y - hipDrop, crouch))
            torso.zRotation = poseMix(0, torsoPitch, crouch)
        }
        if let head = rig.childNode(withName: "head") {
            head.position = CGPoint(x: poseMix(layout.headPos.x, headRest.x, crouch),
                                    y: poseMix(layout.headPos.y, headRest.y - hipDrop, crouch))
            head.zRotation = poseMix(0, torsoPitch * 0.55, crouch)
        }
        rig.zRotation = poseMix(-0.01, -0.06, crouch)
        rig.position = .zero
    }

    // MARK: - Speed and pickup feel

    private func updateSpeedFX(dt: CGFloat) {
        guard mode == .running, !reducedMotion, dashTimer > 0 || boostTimer > 0 else { return }
        afterimageTimer -= dt
        if afterimageTimer <= 0 {
            afterimageTimer = 0.05
            spawnDashAfterimage()
        }
    }

    private func spawnDashAfterimage() {
        guard let texture = princessPartTexture(named: "PrincessAdelynnTorso") else { return }
        let ghost = SKSpriteNode(texture: texture)
        ghost.anchorPoint = PrincessRig.torsoAnchor
        let height = PrincessRig.torsoHeight * 0.94
        ghost.size = CGSize(width: height * texture.size().width / texture.size().height, height: height)
        ghost.color = UIColor(red: 1.0, green: 0.58, blue: 0.86, alpha: 1)
        ghost.colorBlendFactor = 1
        ghost.alpha = 0.40
        ghost.zPosition = 18
        ghost.position = CGPoint(x: player.position.x, y: player.position.y + PrincessRig.torsoPos.y * 0.94)
        fxLayer.addChild(ghost)
        ghost.run(.sequence([
            .group([
                .fadeOut(withDuration: 0.26),
                .moveBy(x: -44, y: 0, duration: 0.26),
                .scale(to: 1.06, duration: 0.26)
            ]),
            .removeFromParent()
        ]))
    }

    private func spawnFootDust(offsetX: CGFloat) {
        for index in 0..<3 {
            let puff = SKShapeNode(ellipseOf: CGSize(
                width: CGFloat.random(in: 5...9),
                height: CGFloat.random(in: 2.5...4.5)
            ))
            puff.fillColor = UIColor(red: 1.0, green: 0.74, blue: 0.90, alpha: 0.30)
            puff.strokeColor = .clear
            puff.position = CGPoint(x: player.position.x + offsetX, y: groundY + CGFloat.random(in: 2...7))
            puff.zPosition = 19
            fxLayer.addChild(puff)
            puff.run(.sequence([
                .group([
                    .moveBy(x: -CGFloat(index + 1) * CGFloat.random(in: 6...12), y: CGFloat.random(in: 3...10), duration: 0.28),
                    .fadeOut(withDuration: 0.28),
                    .scale(to: 1.5, duration: 0.28)
                ]),
                .removeFromParent()
            ]))
        }
    }

    private func scorePopup(_ text: String, at point: CGPoint, color: UIColor) {
        guard !reducedMotion else { return }
        let popup = label(text, size: 15, weight: .heavy)
        popup.fontColor = color
        popup.position = point
        popup.zPosition = 62
        popup.setScale(0.6)
        fxLayer.addChild(popup)
        popup.run(.sequence([
            .group([.scale(to: 1.16, duration: 0.11), .moveBy(x: 0, y: 15, duration: 0.11)]),
            .scale(to: 1.0, duration: 0.09),
            .group([.moveBy(x: 0, y: 26, duration: 0.40), .fadeOut(withDuration: 0.40)]),
            .removeFromParent()
        ]))
    }

    /// Polished Sims/soft-toy Adelynn — plush capsules, skirt-over-hips, sleeve+skin arms.
    private func makeStyledRunnerRig(look: RunnerLook) -> SKNode {
        let rig = SKNode()
        rig.name = "PrincessAdelynnRig"
        let outline = UIColor(red: 0.18, green: 0.08, blue: 0.10, alpha: 0.42)
        let skin = look.skin
        let skinShade = look.skinShade
        let shirt = look.outfit
        let accent = look.accent
        let gold = UIColor(red: 1.0, green: 0.84, blue: 0.28, alpha: 1)
        let wearsSkirt = look.silhouette == .dress || look.silhouette == .cloak
        let pant = look.silhouette == .tunic || look.silhouette == .coat
            ? accent.withAlphaComponent(0.92)
            : skinShade

        let cape = SKShapeNode(path: look.silhouette == .cloak ? sideCapePath() : sideCapePath())
        cape.name = "cape"
        cape.fillColor = accent.withAlphaComponent(look.silhouette == .cloak ? 0.92 : 0.78)
        cape.strokeColor = outline
        cape.lineWidth = 1.4
        cape.position = CGPoint(x: look.silhouette == .cloak ? -18 : -14, y: 50)
        cape.zPosition = 0
        cape.zRotation = -0.16
        cape.xScale = look.silhouette == .cloak ? 1.18 : 1
        rig.addChild(cape)

        let leftLeg = makeLimb(
            name: "leftLeg",
            anchor: CGPoint(x: -6, y: 22),
            end: CGPoint(x: -2, y: -48),
            upperColor: wearsSkirt ? skinShade : pant,
            lowerColor: wearsSkirt ? skin : pant,
            width: 10,
            shoe: look.shoe,
            shoeAccent: look.shoeAccent,
            near: false
        )
        let rightLeg = makeLimb(
            name: "rightLeg",
            anchor: CGPoint(x: 7, y: 22),
            end: CGPoint(x: 12, y: -48),
            upperColor: wearsSkirt ? skin : pant,
            lowerColor: wearsSkirt ? skin : pant,
            width: 10,
            shoe: look.shoe,
            shoeAccent: look.shoeAccent,
            near: true
        )
        leftLeg.zPosition = 1.8
        rightLeg.zPosition = 2.6
        rig.addChild(leftLeg)
        rig.addChild(rightLeg)

        switch look.silhouette {
        case .dress, .cloak:
            let dress = SKShapeNode(path: sideDressPath())
            dress.name = "dress"
            dress.fillColor = shirt
            dress.strokeColor = outline
            dress.lineWidth = 1.6
            dress.zPosition = 3.0
            dress.zRotation = -0.03
            rig.addChild(dress)
            let hem = SKShapeNode(rectOf: CGSize(width: 52, height: 5.5), cornerRadius: 2.6)
            hem.fillColor = look.panel
            hem.strokeColor = outline.withAlphaComponent(0.28)
            hem.lineWidth = 0.7
            hem.position = CGPoint(x: 2, y: 14)
            hem.zPosition = 3.15
            rig.addChild(hem)
        case .tunic:
            let tunic = SKShapeNode(rectOf: CGSize(width: 36, height: 44), cornerRadius: 10)
            tunic.name = "dress"
            tunic.fillColor = shirt
            tunic.strokeColor = outline
            tunic.lineWidth = 1.5
            tunic.position = CGPoint(x: 2, y: 42)
            tunic.zPosition = 3.0
            rig.addChild(tunic)
        case .coat:
            let coat = SKShapeNode(rectOf: CGSize(width: 40, height: 58), cornerRadius: 8)
            coat.name = "dress"
            coat.fillColor = shirt
            coat.strokeColor = outline
            coat.lineWidth = 1.6
            coat.position = CGPoint(x: 2, y: 38)
            coat.zPosition = 3.0
            rig.addChild(coat)
            let lapel = SKShapeNode(rectOf: CGSize(width: 10, height: 28), cornerRadius: 3)
            lapel.fillColor = look.panel
            lapel.strokeColor = .clear
            lapel.position = CGPoint(x: 10, y: 48)
            lapel.zPosition = 3.2
            rig.addChild(lapel)
        }

        let torso = softCapsule(width: look.silhouette == .coat ? 30 : 28, height: 32, color: shirt, highlight: 0.28)
        torso.position = CGPoint(x: 3, y: 64)
        torso.zPosition = 3.3
        rig.addChild(torso)

        let sash = softCapsule(width: 30, height: look.silhouette == .tunic ? 9 : 7, color: accent, highlight: 0.28)
        sash.position = CGPoint(x: 2, y: 46)
        sash.zPosition = 3.6
        rig.addChild(sash)

        let brooch = SKShapeNode(ellipseOf: CGSize(width: 10, height: 10))
        brooch.fillColor = gold
        brooch.strokeColor = UIColor.white.withAlphaComponent(0.7)
        brooch.lineWidth = 1.0
        brooch.position = CGPoint(x: 8, y: 74)
        brooch.zPosition = 3.7
        rig.addChild(brooch)
        let gem = SKShapeNode(circleOfRadius: 2.6)
        gem.fillColor = look.gem
        gem.strokeColor = .clear
        brooch.addChild(gem)

        let leftArm = makeLimb(
            name: "leftArm",
            anchor: CGPoint(x: -11, y: 78),
            end: CGPoint(x: -4, y: -38),
            upperColor: shirt,
            lowerColor: skin,
            width: 8,
            shoe: nil,
            shoeAccent: nil,
            near: false
        )
        let rightArm = makeLimb(
            name: "rightArm",
            anchor: CGPoint(x: 15, y: 78),
            end: CGPoint(x: 18, y: -38),
            upperColor: shirt,
            lowerColor: skin,
            width: 8,
            shoe: nil,
            shoeAccent: nil,
            near: true
        )
        leftArm.zPosition = 1.6
        rightArm.zPosition = 5.2
        rig.addChild(leftArm)
        rig.addChild(rightArm)

        let neck = softCapsule(width: 11, height: 9, color: skin, highlight: 0.18)
        neck.position = CGPoint(x: 5, y: 90)
        neck.zPosition = 4.5
        rig.addChild(neck)

        let head = SKShapeNode(ellipseOf: CGSize(width: 50, height: 54))
        head.name = "head"
        head.fillColor = skin
        head.strokeColor = outline
        head.lineWidth = 1.5
        head.position = CGPoint(x: 6, y: 120)
        head.zPosition = 6
        rig.addChild(head)

        let cheek = SKShapeNode(ellipseOf: CGSize(width: 10, height: 6))
        cheek.fillColor = skinShade.withAlphaComponent(0.55)
        cheek.strokeColor = .clear
        cheek.position = CGPoint(x: 16, y: 112)
        cheek.zPosition = 6.4
        rig.addChild(cheek)

        let eye = SKShapeNode(ellipseOf: CGSize(width: 7, height: 8))
        eye.fillColor = UIColor(red: 0.12, green: 0.08, blue: 0.08, alpha: 1)
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 16, y: 124)
        eye.zPosition = 6.5
        rig.addChild(eye)
        let spark = SKShapeNode(circleOfRadius: 1.5)
        spark.fillColor = .white
        spark.strokeColor = .clear
        spark.position = CGPoint(x: 14.5, y: 126)
        spark.zPosition = 6.6
        rig.addChild(spark)
        addEyelid(to: rig, at: CGPoint(x: 16, y: 128.4), width: 8.6, height: 9.2, look: look)

        addRunnerHair(to: rig, look: look)

        let crown = SKShapeNode(path: crownPath())
        crown.name = "crown"
        crown.fillColor = gold
        crown.strokeColor = UIColor.white.withAlphaComponent(0.8)
        crown.lineWidth = 1.4
        crown.setScale(0.52)
        crown.position = CGPoint(x: 4, y: look.hairStyle == .puff ? 158 : 152)
        crown.zPosition = 7.2
        rig.addChild(crown)
        return rig
    }

    private func addRunnerHair(to rig: SKNode, look: RunnerLook) {
        let hair = SKNode()
        hair.name = "hair"
        hair.position = CGPoint(x: -2, y: 126)
        hair.zPosition = 5.5
        switch look.hairStyle {
        case .puff:
            let puff = SKShapeNode(circleOfRadius: 24)
            puff.fillColor = look.hair
            puff.strokeColor = look.hairShine.withAlphaComponent(0.5)
            puff.lineWidth = 1.2
            puff.position = CGPoint(x: 6, y: 10)
            hair.addChild(puff)
            let puff2 = SKShapeNode(circleOfRadius: 16)
            puff2.fillColor = look.hairShine
            puff2.strokeColor = .clear
            puff2.position = CGPoint(x: -8, y: 4)
            hair.addChild(puff2)
            let hoop = SKShapeNode(circleOfRadius: 4)
            hoop.fillColor = .clear
            hoop.strokeColor = look.accent
            hoop.lineWidth = 1.6
            hoop.position = CGPoint(x: -12, y: -8)
            hair.addChild(hoop)
        case .crop:
            let cap = SKShapeNode(ellipseOf: CGSize(width: 50, height: 20))
            cap.fillColor = look.hair
            cap.strokeColor = .clear
            cap.position = CGPoint(x: 6, y: 16)
            hair.addChild(cap)
            let edge = SKShapeNode(ellipseOf: CGSize(width: 48, height: 12))
            edge.fillColor = look.hairShine
            edge.strokeColor = .clear
            edge.position = CGPoint(x: 6, y: 10)
            hair.addChild(edge)
        case .sweep:
            let cap = SKShapeNode(ellipseOf: CGSize(width: 52, height: 28))
            cap.fillColor = look.hair
            cap.strokeColor = .clear
            cap.position = CGPoint(x: 4, y: 14)
            hair.addChild(cap)
            let lock = SKShapeNode(ellipseOf: CGSize(width: 16, height: 28))
            lock.fillColor = look.hair
            lock.strokeColor = .clear
            lock.position = CGPoint(x: 22, y: -2)
            lock.zRotation = 0.35
            hair.addChild(lock)
        case .braid:
            let cap = SKShapeNode(ellipseOf: CGSize(width: 50, height: 26))
            cap.fillColor = look.hair
            cap.strokeColor = .clear
            cap.position = CGPoint(x: 4, y: 14)
            hair.addChild(cap)
            for i in 0..<3 {
                let bead = SKShapeNode(ellipseOf: CGSize(width: 12, height: 14))
                bead.fillColor = i.isMultiple(of: 2) ? look.hair : look.hairShine
                bead.strokeColor = .clear
                bead.position = CGPoint(x: -16, y: -8 - CGFloat(i) * 12)
                hair.addChild(bead)
            }
        case .ponytail:
            let cap = SKShapeNode(ellipseOf: CGSize(width: 52, height: 32))
            cap.fillColor = look.hair
            cap.strokeColor = .clear
            cap.position = CGPoint(x: 4, y: 12)
            hair.addChild(cap)
            let tailJoint = SKNode()
            tailJoint.name = "ponytail"
            tailJoint.position = CGPoint(x: -12, y: 2)
            tailJoint.zRotation = 0.4
            tailJoint.userData = NSMutableDictionary(dictionary: ["rest": 0.4])
            let tail = SKShapeNode(ellipseOf: CGSize(width: 16, height: 36))
            tail.fillColor = look.hair
            tail.strokeColor = .clear
            tail.position = CGPoint(x: -6, y: -16)
            tail.zRotation = 0.12
            tailJoint.addChild(tail)
            let tip = SKShapeNode(ellipseOf: CGSize(width: 14, height: 12))
            tip.name = "ponyTip"
            tip.fillColor = look.hairShine
            tip.strokeColor = .clear
            tip.position = CGPoint(x: -8, y: -32)
            tip.zRotation = 0.16
            tip.userData = NSMutableDictionary(dictionary: ["rest": 0.16])
            tailJoint.addChild(tip)
            hair.addChild(tailJoint)
        }
        rig.addChild(hair)
    }

    private func makePrincessAdelynnRig() -> SKNode {
        let rig = SKNode()
        rig.name = "PrincessAdelynnRig"

        let outline = UIColor(red: 0.38, green: 0.12, blue: 0.26, alpha: 0.42)
        let skin = UIColor(red: 0.74, green: 0.54, blue: 0.42, alpha: 1)
        let skinShade = UIColor(red: 0.60, green: 0.40, blue: 0.30, alpha: 1)
        let hairBrown = UIColor(red: 0.58, green: 0.45, blue: 0.24, alpha: 1)
        let hairShine = UIColor(red: 0.76, green: 0.62, blue: 0.36, alpha: 1)
        let hairDeep = UIColor(red: 0.40, green: 0.28, blue: 0.14, alpha: 1)
        let shirt = selectedOutfit.dress
        let accent = selectedOutfit.cape.withAlphaComponent(1)
        let shoeWhite = UIColor(red: 1.0, green: 0.98, blue: 0.99, alpha: 1)
        let shoeAccent = UIColor(red: 0.95, green: 0.18, blue: 0.55, alpha: 1)
        let panel = UIColor(red: 1.0, green: 0.86, blue: 0.92, alpha: 1)
        let gold = UIColor(red: 1.0, green: 0.84, blue: 0.28, alpha: 1)

        // Trailing cape
        let cape = SKShapeNode(path: sideCapePath())
        cape.name = "cape"
        cape.fillColor = accent.withAlphaComponent(0.82)
        cape.strokeColor = outline
        cape.lineWidth = 1.4
        cape.position = CGPoint(x: -14, y: 50)
        cape.zPosition = 0
        cape.zRotation = -0.16
        rig.addChild(cape)

        // Legs: skin shins under dress (hips covered by skirt).
        let leftLeg = makeLimb(
            name: "leftLeg",
            anchor: CGPoint(x: -6, y: 22),
            end: CGPoint(x: -2, y: -48),
            upperColor: skinShade,
            lowerColor: skin,
            width: 10,
            shoe: shoeWhite,
            shoeAccent: shoeAccent,
            near: false
        )
        let rightLeg = makeLimb(
            name: "rightLeg",
            anchor: CGPoint(x: 7, y: 22),
            end: CGPoint(x: 12, y: -48),
            upperColor: skin,
            lowerColor: skin,
            width: 10,
            shoe: shoeWhite,
            shoeAccent: shoeAccent,
            near: true
        )
        leftLeg.zPosition = 1.8
        rightLeg.zPosition = 2.6
        rig.addChild(leftLeg)
        rig.addChild(rightLeg)

        // Fuller A-line dress covering hips.
        let dress = SKShapeNode(path: sideDressPath())
        dress.name = "dress"
        dress.fillColor = shirt
        dress.strokeColor = outline
        dress.lineWidth = 1.6
        dress.zPosition = 3.0
        dress.zRotation = -0.03
        rig.addChild(dress)

        let hemTrim = SKShapeNode(rectOf: CGSize(width: 52, height: 5.5), cornerRadius: 2.6)
        hemTrim.fillColor = .white
        hemTrim.strokeColor = outline.withAlphaComponent(0.28)
        hemTrim.lineWidth = 0.7
        hemTrim.position = CGPoint(x: 2, y: 14)
        hemTrim.zPosition = 3.15
        rig.addChild(hemTrim)

        let hemRuffle = SKShapeNode(rectOf: CGSize(width: 48, height: 3.2), cornerRadius: 1.6)
        hemRuffle.fillColor = panel
        hemRuffle.strokeColor = .clear
        hemRuffle.position = CGPoint(x: 2, y: 18)
        hemRuffle.zPosition = 3.12
        rig.addChild(hemRuffle)

        // Soft torso + bodice highlight
        let torso = softCapsule(width: 28, height: 32, color: shirt, highlight: 0.34)
        torso.position = CGPoint(x: 3, y: 64)
        torso.zPosition = 3.3
        rig.addChild(torso)

        let frontPanel = softCapsule(width: 11, height: 18, color: panel, highlight: 0.26)
        frontPanel.position = CGPoint(x: 9, y: 62)
        frontPanel.zPosition = 3.45
        rig.addChild(frontPanel)

        let sash = softCapsule(width: 30, height: 7, color: accent, highlight: 0.28)
        sash.position = CGPoint(x: 2, y: 46)
        sash.zPosition = 3.6
        rig.addChild(sash)

        let brooch = SKShapeNode(ellipseOf: CGSize(width: 10, height: 10))
        brooch.fillColor = gold
        brooch.strokeColor = UIColor.white.withAlphaComponent(0.7)
        brooch.lineWidth = 1.0
        brooch.position = CGPoint(x: 8, y: 74)
        brooch.zPosition = 3.7
        rig.addChild(brooch)
        let gem = SKShapeNode(circleOfRadius: 2.6)
        gem.fillColor = UIColor(red: 1.0, green: 0.35, blue: 0.62, alpha: 1)
        gem.strokeColor = .clear
        gem.position = .zero
        brooch.addChild(gem)

        let collar = SKShapeNode(ellipseOf: CGSize(width: 20, height: 9))
        collar.fillColor = UIColor(red: 1.0, green: 0.98, blue: 0.99, alpha: 1)
        collar.strokeColor = accent.withAlphaComponent(0.9)
        collar.lineWidth = 1.8
        collar.position = CGPoint(x: 5, y: 82)
        collar.zPosition = 3.8
        rig.addChild(collar)

        // Arms: pink sleeve upper + skin forearm
        let leftArm = makeLimb(
            name: "leftArm",
            anchor: CGPoint(x: -11, y: 78),
            end: CGPoint(x: -4, y: -38),
            upperColor: shirt,
            lowerColor: skin,
            width: 8,
            shoe: nil,
            shoeAccent: nil,
            near: false
        )
        let rightArm = makeLimb(
            name: "rightArm",
            anchor: CGPoint(x: 15, y: 78),
            end: CGPoint(x: 18, y: -38),
            upperColor: shirt,
            lowerColor: skin,
            width: 8,
            shoe: nil,
            shoeAccent: nil,
            near: true
        )
        leftArm.zPosition = 1.6
        rightArm.zPosition = 5.2
        rig.addChild(leftArm)
        rig.addChild(rightArm)

        let neck = softCapsule(width: 11, height: 9, color: skin, highlight: 0.18)
        neck.position = CGPoint(x: 5, y: 90)
        neck.zPosition = 4.5
        rig.addChild(neck)

        // Big cute-kid head
        let head = SKShapeNode(ellipseOf: CGSize(width: 50, height: 54))
        head.name = "head"
        head.fillColor = skin
        head.strokeColor = outline
        head.lineWidth = 1.5
        head.position = CGPoint(x: 6, y: 120)
        head.zPosition = 6
        rig.addChild(head)

        let headShine = SKShapeNode(ellipseOf: CGSize(width: 16, height: 10))
        headShine.fillColor = UIColor.white.withAlphaComponent(0.22)
        headShine.strokeColor = .clear
        headShine.position = CGPoint(x: -2, y: 132)
        headShine.zPosition = 6.2
        rig.addChild(headShine)

        let ear = SKShapeNode(ellipseOf: CGSize(width: 8, height: 12))
        ear.fillColor = skinShade
        ear.strokeColor = outline.withAlphaComponent(0.28)
        ear.lineWidth = 0.7
        ear.position = CGPoint(x: -10, y: 118)
        ear.zPosition = 5.8
        rig.addChild(ear)

        // Cohesive ponytail hair
        let hair = SKNode()
        hair.name = "hair"
        hair.position = CGPoint(x: -2, y: 126)
        hair.zPosition = 5.5

        let hairCap = SKShapeNode(ellipseOf: CGSize(width: 52, height: 32))
        hairCap.fillColor = hairBrown
        hairCap.strokeColor = outline
        hairCap.lineWidth = 1.2
        hairCap.position = CGPoint(x: 5, y: 8)
        hair.addChild(hairCap)

        let hairVolume = SKShapeNode(ellipseOf: CGSize(width: 40, height: 16))
        hairVolume.fillColor = hairShine
        hairVolume.strokeColor = .clear
        hairVolume.position = CGPoint(x: 3, y: 15)
        hair.addChild(hairVolume)

        // Short forehead fringe only — never covers the eye.
        let fringe = softCapsule(width: 28, height: 8, color: hairBrown, highlight: 0.12)
        fringe.position = CGPoint(x: 8, y: 2)
        hair.addChild(fringe)

        let bang = softCapsule(width: 8, height: 8, color: hairDeep, highlight: 0.08)
        bang.position = CGPoint(x: 16, y: -2)
        bang.zRotation = 0.12
        hair.addChild(bang)

        let temple = SKShapeNode(ellipseOf: CGSize(width: 14, height: 16))
        temple.fillColor = hairBrown
        temple.strokeColor = .clear
        temple.position = CGPoint(x: -10, y: -2)
        hair.addChild(temple)

        // Pink bow
        let bowCenter = SKShapeNode(circleOfRadius: 4.8)
        bowCenter.fillColor = accent
        bowCenter.strokeColor = UIColor.white.withAlphaComponent(0.55)
        bowCenter.lineWidth = 0.9
        bowCenter.position = CGPoint(x: -16, y: 6)
        hair.addChild(bowCenter)
        for dx: CGFloat in [-8, 8] {
            let loop = SKShapeNode(ellipseOf: CGSize(width: 13, height: 9))
            loop.fillColor = accent.withAlphaComponent(0.97)
            loop.strokeColor = outline.withAlphaComponent(0.28)
            loop.lineWidth = 0.7
            loop.position = CGPoint(x: -16 + dx, y: 8)
            hair.addChild(loop)
        }

        let tailJoint = SKNode()
        tailJoint.name = "ponytail"
        tailJoint.position = CGPoint(x: -24, y: -12)
        tailJoint.zRotation = 0.48
        tailJoint.userData = NSMutableDictionary(dictionary: ["rest": 0.48])
        let ponytail = softCapsule(width: 14, height: 40, color: hairBrown, highlight: 0.14)
        tailJoint.addChild(ponytail)

        let ponyTip = SKShapeNode(ellipseOf: CGSize(width: 16, height: 14))
        ponyTip.name = "ponyTip"
        ponyTip.fillColor = hairShine
        ponyTip.strokeColor = outline.withAlphaComponent(0.25)
        ponyTip.lineWidth = 0.7
        ponyTip.position = CGPoint(x: -10, y: -22)
        ponyTip.zRotation = 0.12
        ponyTip.userData = NSMutableDictionary(dictionary: ["rest": 0.12])
        tailJoint.addChild(ponyTip)
        hair.addChild(tailJoint)
        rig.addChild(hair)

        // Soft profile face
        let face = SKNode()
        face.name = "face"
        face.position = CGPoint(x: 6, y: 120)
        face.zPosition = 7.5

        let cheek = SKShapeNode(ellipseOf: CGSize(width: 11, height: 7))
        cheek.fillColor = UIColor(red: 1.0, green: 0.50, blue: 0.60, alpha: 0.45)
        cheek.strokeColor = .clear
        cheek.position = CGPoint(x: 14, y: -10)
        face.addChild(cheek)

        let eyeWhite = SKShapeNode(ellipseOf: CGSize(width: 13, height: 14))
        eyeWhite.fillColor = UIColor(red: 1, green: 0.99, blue: 0.98, alpha: 1)
        eyeWhite.strokeColor = outline.withAlphaComponent(0.28)
        eyeWhite.lineWidth = 0.8
        eyeWhite.position = CGPoint(x: 14, y: 4)
        face.addChild(eyeWhite)

        let iris = SKShapeNode(ellipseOf: CGSize(width: 8.5, height: 9.5))
        iris.fillColor = UIColor(red: 0.30, green: 0.55, blue: 0.92, alpha: 1)
        iris.strokeColor = .clear
        iris.position = CGPoint(x: 15.2, y: 4)
        face.addChild(iris)

        let pupil = SKShapeNode(ellipseOf: CGSize(width: 3.8, height: 4.4))
        pupil.fillColor = UIColor(red: 0.06, green: 0.04, blue: 0.08, alpha: 1)
        pupil.strokeColor = .clear
        pupil.position = CGPoint(x: 16.0, y: 4.2)
        face.addChild(pupil)

        let spark = SKShapeNode(circleOfRadius: 1.8)
        spark.fillColor = .white
        spark.strokeColor = .clear
        spark.position = CGPoint(x: 13.2, y: 6.6)
        face.addChild(spark)
        addEyelid(to: face, at: CGPoint(x: 14, y: 11.2), width: 13.4, height: 15.0, look: paintedLook(for: .adelynn))

        let brow = SKShapeNode(rectOf: CGSize(width: 11, height: 2.0), cornerRadius: 1.0)
        brow.fillColor = hairDeep.withAlphaComponent(0.9)
        brow.strokeColor = .clear
        brow.position = CGPoint(x: 14, y: 14)
        brow.zRotation = -0.10
        face.addChild(brow)

        let nose = SKShapeNode(ellipseOf: CGSize(width: 5, height: 4.2))
        nose.fillColor = skinShade
        nose.strokeColor = .clear
        nose.position = CGPoint(x: 21, y: -1)
        face.addChild(nose)

        let smilePath = CGMutablePath()
        smilePath.move(to: CGPoint(x: 10, y: -15))
        smilePath.addQuadCurve(to: CGPoint(x: 20, y: -15), control: CGPoint(x: 15, y: -19.5))
        let smile = SKShapeNode(path: smilePath)
        smile.strokeColor = UIColor(red: 0.90, green: 0.34, blue: 0.46, alpha: 0.95)
        smile.lineWidth = 2.0
        smile.lineCap = .round
        smile.fillColor = .clear
        face.addChild(smile)
        rig.addChild(face)

        // Crown
        let crown = SKShapeNode(path: crownPath())
        crown.name = "crown"
        crown.fillColor = gold
        crown.strokeColor = UIColor.white.withAlphaComponent(0.8)
        crown.lineWidth = 1.4
        crown.setScale(0.58)
        crown.position = CGPoint(x: 4, y: 152)
        crown.zPosition = 7.7
        rig.addChild(crown)
        for x in [-9, 0, 9] {
            let jewel = SKShapeNode(circleOfRadius: x == 0 ? 2.6 : 2.0)
            jewel.fillColor = x == 0
                ? UIColor(red: 1.0, green: 0.38, blue: 0.66, alpha: 1)
                : UIColor(red: 0.40, green: 0.88, blue: 1.0, alpha: 1)
            jewel.strokeColor = UIColor.white.withAlphaComponent(0.7)
            jewel.lineWidth = 0.6
            jewel.position = CGPoint(x: CGFloat(x), y: -8)
            jewel.zPosition = 8
            crown.addChild(jewel)
        }

        return rig
    }

    /// Soft chubby capsule limbs — sleeve+skin arms, skin legs under skirt, punchy sneakers.
    private func makeLimb(
        name: String,
        anchor: CGPoint,
        end: CGPoint,
        upperColor: UIColor,
        lowerColor: UIColor,
        width: CGFloat,
        shoe: UIColor?,
        shoeAccent: UIColor? = nil,
        near: Bool = true
    ) -> SKNode {
        let joint = SKNode()
        joint.name = name
        joint.position = anchor
        joint.alpha = near ? 1.0 : 0.88

        let isLeg = shoe != nil
        // Legs: short thigh (hidden under skirt) + longer shin. Arms: puffy sleeve + forearm.
        let segmentHeight = isLeg ? 14.0 : 18.0
        let segmentWidth = (isLeg ? width + 4 : width + 7) * (near ? 1.0 : 0.90)
        let outline = UIColor(red: 0.38, green: 0.12, blue: 0.26, alpha: 0.36)

        let upper = softCapsuleSegment(name: "upper", width: segmentWidth, height: segmentHeight, color: upperColor, highlightAlpha: near ? 0.30 : 0.18)
        upper.position = CGPoint(x: 0, y: -segmentHeight / 2)
        upper.zPosition = 1
        joint.addChild(upper)

        let kneeY = -segmentHeight
        let hinge = SKShapeNode(circleOfRadius: width * (isLeg ? 0.50 : 0.62))
        hinge.fillColor = isLeg ? lowerColor : upperColor
        hinge.strokeColor = outline
        hinge.lineWidth = 0.7
        hinge.position = CGPoint(x: 0, y: kneeY)
        hinge.zPosition = 2.2
        joint.addChild(hinge)

        let lowerH = isLeg ? 28.0 : 17.0
        let lower = softCapsuleSegment(name: "lower", width: segmentWidth * (isLeg ? 0.90 : 0.78), height: lowerH, color: lowerColor, highlightAlpha: near ? 0.24 : 0.14)
        lower.position = CGPoint(x: 0, y: kneeY - lowerH / 2)
        lower.zPosition = 1.5
        joint.addChild(lower)

        let handOrShoe = SKShapeNode(
            rectOf: CGSize(width: isLeg ? width + 20 : width + 7, height: isLeg ? width + 6.5 : width + 7),
            cornerRadius: isLeg ? 5.0 : (width + 7) / 2
        )
        handOrShoe.name = "end"
        handOrShoe.fillColor = shoe ?? lowerColor
        handOrShoe.strokeColor = outline
        handOrShoe.lineWidth = 1.0
        handOrShoe.position = end
        handOrShoe.zRotation = isLeg ? 0.04 : 0
        handOrShoe.zPosition = 2.5
        joint.addChild(handOrShoe)

        if isLeg {
            let sock = SKShapeNode(rectOf: CGSize(width: width + 8, height: 5), cornerRadius: 1.5)
            sock.fillColor = UIColor.white.withAlphaComponent(0.95)
            sock.strokeColor = .clear
            sock.position = CGPoint(x: 1, y: 5)
            sock.zPosition = 2.8
            handOrShoe.addChild(sock)

            let sole = SKShapeNode(rectOf: CGSize(width: width + 18, height: 3.6), cornerRadius: 1.6)
            sole.fillColor = shoeAccent ?? UIColor(red: 0.95, green: 0.18, blue: 0.55, alpha: 1)
            sole.strokeColor = .clear
            sole.position = CGPoint(x: 2, y: -3.2)
            sole.zPosition = 3
            handOrShoe.addChild(sole)

            let accentStripe = SKShapeNode(rectOf: CGSize(width: width + 12, height: 3.4), cornerRadius: 1.6)
            accentStripe.fillColor = shoeAccent ?? UIColor(red: 0.95, green: 0.18, blue: 0.55, alpha: 1)
            accentStripe.strokeColor = .clear
            accentStripe.position = CGPoint(x: 2, y: 1.2)
            accentStripe.zPosition = 3.2
            handOrShoe.addChild(accentStripe)
        }
        return joint
    }

    private func softCapsule(width: CGFloat, height: CGFloat, color: UIColor, highlight: CGFloat) -> SKNode {
        softCapsuleSegment(name: nil, width: width, height: height, color: color, highlightAlpha: highlight)
    }

    private func softCapsuleSegment(name: String?, width: CGFloat, height: CGFloat, color: UIColor, highlightAlpha: CGFloat) -> SKNode {
        let node = SKNode()
        if let name { node.name = name }
        let corner = min(width, height) / 2
        let outline = UIColor(red: 0.38, green: 0.12, blue: 0.26, alpha: 0.32)

        let shadow = SKShapeNode(rectOf: CGSize(width: width + 2.0, height: height + 1.4), cornerRadius: corner)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.10)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 1.2, y: -1.4)
        shadow.zPosition = 0
        node.addChild(shadow)

        let body = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: corner)
        body.fillColor = color
        body.strokeColor = outline
        body.lineWidth = 0.9
        body.zPosition = 1
        node.addChild(body)

        // Bottom shade for plush volume
        let shade = SKShapeNode(rectOf: CGSize(width: max(2, width * 0.72), height: max(2, height * 0.28)), cornerRadius: max(1, width * 0.12))
        shade.fillColor = UIColor.black.withAlphaComponent(0.10)
        shade.strokeColor = .clear
        shade.position = CGPoint(x: width * 0.06, y: -height * 0.28)
        shade.zPosition = 1.5
        node.addChild(shade)

        let highlight = SKShapeNode(rectOf: CGSize(width: max(2, width * 0.34), height: height * 0.58), cornerRadius: max(1, width * 0.14))
        highlight.fillColor = UIColor.white.withAlphaComponent(highlightAlpha)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -width * 0.20, y: height * 0.08)
        highlight.zPosition = 2
        node.addChild(highlight)

        return node
    }

    private func makeLimb(name: String, anchor: CGPoint, end: CGPoint, color: UIColor, width: CGFloat, shoe: UIColor?) -> SKNode {
        makeLimb(name: name, anchor: anchor, end: end, upperColor: color, lowerColor: color, width: width, shoe: shoe, shoeAccent: nil, near: true)
    }

    private func makeLimb(name: String, anchor: CGPoint, end: CGPoint, color: UIColor, width: CGFloat, shoe: UIColor?, shoeAccent: UIColor?) -> SKNode {
        makeLimb(name: name, anchor: anchor, end: end, upperColor: color, lowerColor: color, width: width, shoe: shoe, shoeAccent: shoeAccent, near: true)
    }



    private func roundedSegment(name: String, width: CGFloat, height: CGFloat, color: UIColor, highlightAlpha: CGFloat) -> SKNode {
        softCapsuleSegment(name: name, width: width, height: height, color: color, highlightAlpha: highlightAlpha)
    }

    private func blockSegment(name: String, width: CGFloat, height: CGFloat, color: UIColor, corner: CGFloat, highlightAlpha: CGFloat) -> SKNode {
        softCapsuleSegment(name: name, width: width, height: height, color: color, highlightAlpha: highlightAlpha)
    }

    private func addPaintedHeadLife(to head: SKNode, look: RunnerLook, runner: FeaturedRunner) {
        let nape = SKShapeNode(ellipseOf: CGSize(width: 14, height: 18))
        nape.fillColor = look.hair
        nape.strokeColor = .clear
        nape.lineWidth = 0
        nape.position = CGPoint(x: -13, y: 34)
        nape.zPosition = 0.35
        head.addChild(nape)
        addEyelid(to: head, at: CGPoint(x: 13.4, y: 25.4), width: 8.6, height: 9.0, look: look)
        addSwayPonytail(to: head, look: look, runner: runner)
    }

    /// Skin lid hung from the top of the eye. Rest scale is a lash line; full scale covers the iris.
    private func addEyelid(to parent: SKNode, at point: CGPoint, width: CGFloat, height: CGFloat, look: RunnerLook) {
        let lid = SKNode()
        lid.name = "eyelid"
        lid.position = point
        lid.zPosition = 12
        lid.yScale = 0.14

        let pad = SKShapeNode(ellipseOf: CGSize(width: width, height: height))
        pad.fillColor = look.skin
        pad.strokeColor = .clear
        pad.lineWidth = 0
        pad.position = CGPoint(x: 0, y: -height * 0.5)
        lid.addChild(pad)

        let crease = SKShapeNode(ellipseOf: CGSize(width: width * 0.92, height: height * 0.22))
        crease.fillColor = look.skinShade.withAlphaComponent(0.35)
        crease.strokeColor = .clear
        crease.lineWidth = 0
        crease.position = CGPoint(x: 0.4, y: -height * 0.22)
        lid.addChild(crease)

        let lash = SKShapeNode(rectOf: CGSize(width: width * 0.94, height: 1.6), cornerRadius: 0.8)
        lash.fillColor = look.hair.withAlphaComponent(0.88)
        lash.strokeColor = .clear
        lash.lineWidth = 0
        lash.position = CGPoint(x: 0.2, y: -height + 1.1)
        lash.zRotation = -0.06
        lid.addChild(lash)

        parent.addChild(lid)
        lid.run(naturalBlinkAction(), withKey: "blink")
    }

    /// Overlay that covers the baked tail and pivots from the bow.
    private func addSwayPonytail(to head: SKNode, look: RunnerLook, runner: FeaturedRunner) {
        let joint = SKNode()
        joint.name = "ponytail"
        joint.position = CGPoint(x: -19.4, y: 47.3)
        joint.zPosition = 0.85
        joint.zRotation = 0
        joint.userData = NSMutableDictionary(dictionary: ["rest": 0])

        if let headSprite = head as? SKSpriteNode, let tailTex = paintedPonytailTexture(look: look, runner: runner) {
            let tail = SKSpriteNode(texture: tailTex)
            tail.name = "ponyHair"
            tail.size = headSprite.size
            tail.anchorPoint = headSprite.anchorPoint
            tail.position = CGPoint(x: -joint.position.x, y: -joint.position.y)
            joint.addChild(tail)
        } else {
            let root = SKShapeNode(ellipseOf: CGSize(width: 18, height: 16))
            root.fillColor = look.hair
            root.strokeColor = .clear
            root.lineWidth = 0
            root.position = CGPoint(x: -1, y: -6)
            joint.addChild(root)

            let wave = SKShapeNode(ellipseOf: CGSize(width: 18, height: 24))
            wave.fillColor = look.hair
            wave.strokeColor = .clear
            wave.lineWidth = 0
            wave.position = CGPoint(x: -6, y: -26)
            joint.addChild(wave)

            let tip = SKShapeNode(ellipseOf: CGSize(width: 16, height: 16))
            tip.name = "ponyTip"
            tip.fillColor = look.hair
            tip.strokeColor = .clear
            tip.lineWidth = 0
            tip.position = CGPoint(x: -9, y: -44)
            tip.zRotation = -0.12
            tip.userData = NSMutableDictionary(dictionary: ["rest": -0.12])
            joint.addChild(tip)
        }

        head.addChild(joint)
        startIdlePonytailSway(on: joint)
    }

    private func ponytailRest(of node: SKNode) -> CGFloat {
        (node.userData?["rest"] as? NSNumber).map { CGFloat(truncating: $0) } ?? node.zRotation
    }

    private func naturalBlinkAction() -> SKAction {
        let close = SKAction.scaleY(to: 1.0, duration: 0.08)
        close.timingMode = .easeIn
        let open = SKAction.scaleY(to: 0.14, duration: 0.12)
        open.timingMode = .easeOut
        let blink = SKAction.sequence([close, SKAction.wait(forDuration: 0.05), open])
        let fire = SKAction.customAction(withDuration: 0.001) { node, _ in
            let once = blink.copy() as! SKAction
            if Int.random(in: 0..<4) == 0 {
                node.run(.sequence([once, .wait(forDuration: 0.16), blink.copy() as! SKAction]), withKey: "blinkPulse")
            } else {
                node.run(once, withKey: "blinkPulse")
            }
        }
        return .repeatForever(.sequence([
            .wait(forDuration: 2.5, withRange: 3.8),
            fire,
            .wait(forDuration: 0.55)
        ]))
    }

    private func startIdlePonytailSway(on tail: SKNode) {
        let rest = ponytailRest(of: tail)
        tail.zRotation = rest
        let swingOut = SKAction.rotate(toAngle: rest + 0.34, duration: 0.85)
        swingOut.timingMode = .easeInEaseOut
        let swingIn = SKAction.rotate(toAngle: rest - 0.26, duration: 0.98)
        swingIn.timingMode = .easeInEaseOut
        tail.run(.repeatForever(.sequence([swingOut, swingIn])), withKey: "ponySway")

        if let tip = tail.childNode(withName: "ponyTip") {
            let tipRest = ponytailRest(of: tip)
            let tipOut = SKAction.rotate(toAngle: tipRest + 0.22, duration: 0.72)
            tipOut.timingMode = .easeInEaseOut
            let tipIn = SKAction.rotate(toAngle: tipRest - 0.18, duration: 0.86)
            tipIn.timingMode = .easeInEaseOut
            tip.run(.repeatForever(.sequence([tipOut, tipIn])), withKey: "ponyTipSway")
        }
    }

    private func updateSwayPonytail(on rig: SKNode, moving: Bool, airborne: Bool, phase: CGFloat, flipping: Bool = false) {
        guard let tail = rig.childNode(withName: "//ponytail") else { return }
        tail.removeAction(forKey: "ponySway")
        let rest = ponytailRest(of: tail)
        let t = CGFloat(lastUpdateTime)
        let idle = sin(t * 1.85) * 0.14
        let run = moving ? sin(phase + 0.85) * 0.28 : 0
        let flop = airborne ? max(-0.40, min(0.40, -playerVelocityY / 640)) : 0
        // Hair lags the spin so it whips around the ball instead of sitting still on the neck.
        let whip = flipping ? sin(flipProgress * .pi) * 0.95 : 0
        let target = rest + idle + run + flop + whip
        tail.zRotation += (target - tail.zRotation) * (flipping ? 0.45 : 0.22)

        if let tip = tail.childNode(withName: "ponyTip") {
            tip.removeAction(forKey: "ponyTipSway")
            let tipRest = ponytailRest(of: tip)
            let tipTarget = tipRest + idle * 0.85 + run * 0.7 + flop * 0.75 + whip * 0.8 + sin(t * 2.55) * 0.07
            tip.zRotation += (tipTarget - tip.zRotation) * (flipping ? 0.38 : 0.18)
        }
    }

    private func startCharacterSecondaryAnimation(on rig: SKNode) {
        if let lid = rig.childNode(withName: "//eyelid") {
            lid.removeAction(forKey: "blink")
            lid.yScale = 0.14
            lid.run(naturalBlinkAction(), withKey: "blink")
        }
        if let tail = rig.childNode(withName: "//ponytail"), rig.parent !== player {
            startIdlePonytailSway(on: tail)
        }
        if reducedMotion { return }
        rig.childNode(withName: "crown")?.run(.repeatForever(.sequence([
            .scale(to: 0.66, duration: 0.22),
            .scale(to: 0.62, duration: 0.22)
        ])), withKey: "crownGlint")
    }

    private func buildHUD() {
        scorePanel.zPosition = 96
        scorePanel.fillColor = UIColor(red: 0.13, green: 0.02, blue: 0.15, alpha: 0.88)
        scorePanel.strokeColor = UIColor(red: 1.00, green: 0.74, blue: 0.30, alpha: 0.92)
        scorePanel.lineWidth = 1.8
        hud.addChild(scorePanel)
        
        for divider in [statusPanel, missionPanel] {
            divider.zPosition = 97
            divider.fillColor = UIColor(red: 1.00, green: 0.74, blue: 0.30, alpha: 0.44)
            divider.strokeColor = .clear
            hud.addChild(divider)
        }
        
        healthBarBack.zPosition = 98
        healthBarBack.fillColor = UIColor(red: 0.30, green: 0.05, blue: 0.22, alpha: 0.82)
        healthBarBack.strokeColor = UIColor(red: 1.00, green: 0.78, blue: 0.42, alpha: 0.42)
        healthBarBack.lineWidth = 0.75
        hud.addChild(healthBarBack)
        
        healthBarFill.zPosition = 99
        healthBarFill.fillColor = UIColor(red: 1.00, green: 0.38, blue: 0.68, alpha: 0.96)
        healthBarFill.strokeColor = .clear
        hud.addChild(healthBarFill)
        buildTouchControls()
        
        for label in [scoreLabel, coinLabel, healthLabel, powerLabel, messageLabel, zoneLabel, missionLabel, tutorialLabel] {
            label.zPosition = 100
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.fontColor = .white
            hud.addChild(label)
        }
        scoreLabel.fontColor = UIColor(red: 1.00, green: 0.91, blue: 0.58, alpha: 1)
        coinLabel.fontColor = UIColor(red: 1.00, green: 0.78, blue: 0.34, alpha: 1)
        healthLabel.fontColor = UIColor(red: 1.00, green: 0.88, blue: 0.97, alpha: 1)
        powerLabel.fontColor = UIColor(red: 1.00, green: 0.70, blue: 0.88, alpha: 1)
        zoneLabel.fontColor = UIColor(red: 1.00, green: 0.93, blue: 0.82, alpha: 1)
        missionLabel.fontColor = UIColor(red: 1.00, green: 0.78, blue: 0.91, alpha: 1)
        powerLabel.numberOfLines = 2
        missionLabel.numberOfLines = 2
        tutorialLabel.numberOfLines = 4
        messageLabel.alpha = 0
        tutorialLabel.alpha = 0

        pauseButton.name = "pause"
        pauseButton.zPosition = 106
        pauseButton.fillColor = UIColor(red: 0.18, green: 0.03, blue: 0.17, alpha: 0.62)
        pauseButton.strokeColor = UIColor(red: 1.0, green: 0.58, blue: 0.82, alpha: 0.80)
        pauseButton.lineWidth = 2
        hud.addChild(pauseButton)
        pauseButtonLabel.text = "II"
        pauseButtonLabel.zPosition = 107
        pauseButtonLabel.fontSize = 13
        pauseButtonLabel.fontColor = UIColor(red: 1.0, green: 0.86, blue: 0.96, alpha: 0.96)
        pauseButtonLabel.horizontalAlignmentMode = .center
        pauseButtonLabel.verticalAlignmentMode = .center
        hud.addChild(pauseButtonLabel)
    }
    
    private func buildTouchControls() {
        configureControl(leftControl, label: leftControlLabel, text: "<")
        configureControl(rightControl, label: rightControlLabel, text: ">")
        configureControl(jumpControl, label: jumpControlLabel, text: "JUMP")
        configureControl(duckControl, label: duckControlLabel, text: "DUCK")
        configureControl(powerControl, label: powerControlLabel, text: "POWER")
    }
    
    private func configureControl(_ button: SKShapeNode, label: SKLabelNode, text: String) {
        button.zPosition = 104
        button.fillColor = UIColor(red: 0.18, green: 0.03, blue: 0.17, alpha: 0.52)
        button.strokeColor = UIColor(red: 1.0, green: 0.58, blue: 0.82, alpha: 0.74)
        button.lineWidth = 2
        hud.addChild(button)
        
        label.text = text
        label.zPosition = 105
        label.fontColor = UIColor(red: 1.0, green: 0.86, blue: 0.96, alpha: 0.94)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        hud.addChild(label)
    }

    private func updateBackground() {
        removeChildren(in: laneGuides)
        laneGuides.removeAll()
        environmentLayer.removeAllChildren()
        let palette = currentZone.colors
        backgroundArt.texture = SKTexture(imageNamed: "SplashBackground")
        backgroundArt.position = CGPoint(x: size.width / 2, y: size.height / 2)
        fill(sprite: backgroundArt, in: size)
        backgroundArt.alpha = mode == .running ? 0.30 : 1
        
        let shadeAlpha: CGFloat = mode == .running ? 0.10 : 0.26
        let shade = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        shade.fillColor = UIColor(red: 0.03, green: 0.02, blue: 0.08, alpha: shadeAlpha)
        shade.strokeColor = .clear
        shade.zPosition = -95
        laneGuides.append(shade)
        addChild(shade)
        
        if mode == .running {
            let topBandHeight: CGFloat = 104
            let topBand = SKShapeNode(rect: CGRect(x: 0, y: size.height - topBandHeight, width: size.width, height: topBandHeight))
            topBand.fillColor = UIColor(red: 0.03, green: 0.02, blue: 0.08, alpha: 0.24)
            topBand.strokeColor = .clear
            topBand.zPosition = -94
            laneGuides.append(topBand)
            addChild(topBand)
        }
        
        if mode == .running {
            addBuiltPlatformEnvironment(palette: palette)
            
            let stageWash = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            stageWash.fillColor = UIColor(red: 0.10, green: 0.04, blue: 0.14, alpha: 0.08)
            stageWash.strokeColor = .clear
            stageWash.zPosition = -19
            laneGuides.append(stageWash)
            addChild(stageWash)
            
            let sideStage = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: groundY + 86))
            sideStage.fillColor = UIColor(red: 0.16, green: 0.04, blue: 0.14, alpha: 0.90)
            sideStage.strokeColor = .clear
            sideStage.zPosition = -18.8
            laneGuides.append(sideStage)
            addChild(sideStage)
            
            let farRail = SKShapeNode(rect: CGRect(x: 0, y: groundY + 76, width: size.width, height: 6))
            farRail.fillColor = palette.trim.withAlphaComponent(0.44)
            farRail.strokeColor = UIColor.white.withAlphaComponent(0.16)
            farRail.lineWidth = 1
            farRail.zPosition = -18.4
            laneGuides.append(farRail)
            addChild(farRail)
            
            let gardenBand = SKShapeNode(rect: CGRect(x: 0, y: groundY + 10, width: size.width, height: 70))
            gardenBand.fillColor = UIColor(red: 0.20, green: 0.06, blue: 0.17, alpha: 0.86)
            gardenBand.strokeColor = UIColor.white.withAlphaComponent(0.06)
            gardenBand.lineWidth = 1
            gardenBand.zPosition = -18.3
            laneGuides.append(gardenBand)
            addChild(gardenBand)
            
            let ground = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: groundY - 12))
            ground.fillColor = UIColor(red: 0.09, green: 0.03, blue: 0.11, alpha: 0.98)
            ground.strokeColor = .clear
            ground.zPosition = -18
            laneGuides.append(ground)
            addChild(ground)
            
            addGroundTiles(palette: palette)
            
            let platformShadow = SKShapeNode(rect: CGRect(x: 0, y: groundY - 36, width: size.width, height: 22))
            platformShadow.fillColor = UIColor.black.withAlphaComponent(0.34)
            platformShadow.strokeColor = .clear
            platformShadow.zPosition = -16
            laneGuides.append(platformShadow)
            addChild(platformShadow)
            
            let horizon = SKShapeNode(rect: CGRect(x: 0, y: groundY + 5, width: size.width, height: 3))
            horizon.fillColor = UIColor.white.withAlphaComponent(0.30)
            horizon.strokeColor = .clear
            horizon.zPosition = -15
            laneGuides.append(horizon)
            addChild(horizon)
            seedEnvironmentMotion()
        } else if mode != .splash {
            let menuWash = SKShapeNode(rect: CGRect(origin: .zero, size: size))
            menuWash.fillColor = UIColor(red: 0.22, green: 0.03, blue: 0.18, alpha: 0.10)
            menuWash.strokeColor = .clear
            menuWash.zPosition = -20
            laneGuides.append(menuWash)
            addChild(menuWash)
        }

    }
    
    private func addBuiltPlatformEnvironment(palette: (path: UIColor, trim: UIColor, lane: UIColor)) {
        let sky = SKShapeNode(rect: CGRect(x: 0, y: groundY + 96, width: size.width, height: size.height - groundY - 96))
        sky.fillColor = UIColor(red: 0.62, green: 0.58, blue: 0.92, alpha: 0.28)
        sky.strokeColor = .clear
        sky.zPosition = -93
        laneGuides.append(sky)
        addChild(sky)
        
        // Soft distant rose hedges instead of flat oval placeholders.
        for index in 0..<5 {
            let bush = SKShapeNode(ellipseOf: CGSize(width: 78 + CGFloat(index % 3) * 18, height: 36 + CGFloat(index % 2) * 10))
            bush.fillColor = UIColor(red: 0.78, green: 0.28, blue: 0.54, alpha: 0.34)
            bush.strokeColor = UIColor(red: 1.0, green: 0.72, blue: 0.88, alpha: 0.22)
            bush.lineWidth = 1
            bush.position = CGPoint(
                x: size.width * CGFloat(0.08 + Double(index) * 0.20),
                y: groundY + 98 + CGFloat(index % 2) * 10
            )
            bush.zPosition = -92
            laneGuides.append(bush)
            addChild(bush)
        }
        
        let towerXs: [CGFloat] = [size.width * 0.16, size.width * 0.40, size.width * 0.66, size.width * 0.86]
        for (index, x) in towerXs.enumerated() {
            let towerHeight = CGFloat([96, 128, 110, 142][index])
            let tower = makeSolidCastleTower(height: towerHeight, variant: index)
            tower.position = CGPoint(x: x, y: groundY + 88)
            tower.zPosition = -91
            laneGuides.append(tower)
            addChild(tower)
        }
        
        for index in 0..<2 {
            let cloud = SKShapeNode(ellipseOf: CGSize(width: 58 + CGFloat(index) * 14, height: 14))
            cloud.fillColor = UIColor.white.withAlphaComponent(0.10)
            cloud.strokeColor = .clear
            cloud.position = CGPoint(x: size.width * CGFloat(0.28 + Double(index) * 0.36), y: size.height * 0.74)
            cloud.zPosition = -90
            laneGuides.append(cloud)
            addChild(cloud)
        }
        
        let bridge = SKShapeNode(rect: CGRect(x: 0, y: groundY + 72, width: size.width, height: 20))
        bridge.fillColor = palette.trim.withAlphaComponent(0.28)
        bridge.strokeColor = UIColor.white.withAlphaComponent(0.12)
        bridge.lineWidth = 1
        bridge.zPosition = -18.6
        laneGuides.append(bridge)
        addChild(bridge)
    }

    private func makeSolidCastleTower(height: CGFloat, variant: Int) -> SKShapeNode {
        let node = SKShapeNode()
        let bodyWidth: CGFloat = variant.isMultiple(of: 2) ? 42 : 48
        let stone = UIColor(red: 0.45, green: 0.32, blue: 0.62, alpha: 1)
        let stoneDark = UIColor(red: 0.24, green: 0.16, blue: 0.38, alpha: 1)
        let stoneLight = UIColor(red: 0.69, green: 0.56, blue: 0.80, alpha: 1)
        let gold = UIColor(red: 0.96, green: 0.68, blue: 0.20, alpha: 1)

        let shadow = SKShapeNode(rectOf: CGSize(width: bodyWidth + 7, height: height + 7), cornerRadius: 5)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.34)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 4, y: height / 2 - 4)
        node.addChild(shadow)

        let body = SKShapeNode(rectOf: CGSize(width: bodyWidth, height: height), cornerRadius: 4)
        body.fillColor = stone
        body.strokeColor = stoneLight
        body.lineWidth = 2
        body.position = CGPoint(x: 0, y: height / 2)
        body.zPosition = 1
        node.addChild(body)

        let sideShade = SKShapeNode(rectOf: CGSize(width: bodyWidth * 0.22, height: height - 6), cornerRadius: 2)
        sideShade.fillColor = stoneDark.withAlphaComponent(0.72)
        sideShade.strokeColor = .clear
        sideShade.position = CGPoint(x: bodyWidth * 0.37, y: height / 2 - 1)
        sideShade.zPosition = 2
        node.addChild(sideShade)

        let battlementY = height + 6
        let parapet = SKShapeNode(rectOf: CGSize(width: bodyWidth + 10, height: 15), cornerRadius: 3)
        parapet.fillColor = stoneDark
        parapet.strokeColor = stoneLight
        parapet.lineWidth = 1.5
        parapet.position = CGPoint(x: 0, y: battlementY)
        parapet.zPosition = 3
        node.addChild(parapet)

        for x in stride(from: -bodyWidth / 2, through: bodyWidth / 2, by: bodyWidth / 2) {
            let merlon = SKShapeNode(rectOf: CGSize(width: 11, height: 12), cornerRadius: 2)
            merlon.fillColor = stoneDark
            merlon.strokeColor = stoneLight
            merlon.lineWidth = 1
            merlon.position = CGPoint(x: x, y: battlementY + 11)
            merlon.zPosition = 4
            node.addChild(merlon)
        }

        let windowRows = max(2, Int(height / 38))
        for row in 0..<windowRows {
            let window = SKShapeNode(rectOf: CGSize(width: 10, height: 16), cornerRadius: 5)
            window.fillColor = UIColor(red: 1.0, green: 0.80, blue: 0.30, alpha: 1)
            window.strokeColor = stoneDark
            window.lineWidth = 2
            window.position = CGPoint(x: -3, y: 25 + CGFloat(row) * 29)
            window.zPosition = 3
            node.addChild(window)
        }

        for row in 0..<max(2, Int(height / 30)) {
            let mortar = SKShapeNode(rectOf: CGSize(width: bodyWidth - 7, height: 1.5))
            mortar.fillColor = stoneLight.withAlphaComponent(0.36)
            mortar.strokeColor = .clear
            mortar.position = CGPoint(x: -2, y: 15 + CGFloat(row) * 30)
            mortar.zPosition = 2
            node.addChild(mortar)
        }

        let banner = SKShapeNode(path: {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -7, y: 18))
            path.addLine(to: CGPoint(x: 7, y: 18))
            path.addLine(to: CGPoint(x: 7, y: -15))
            path.addLine(to: CGPoint(x: 0, y: -9))
            path.addLine(to: CGPoint(x: -7, y: -15))
            path.closeSubpath()
            return path
        }())
        banner.fillColor = variant.isMultiple(of: 2)
            ? UIColor(red: 0.94, green: 0.24, blue: 0.57, alpha: 1)
            : UIColor(red: 0.38, green: 0.20, blue: 0.68, alpha: 1)
        banner.strokeColor = gold
        banner.lineWidth = 1.5
        banner.position = CGPoint(x: -bodyWidth / 2 - 8, y: height * 0.66)
        banner.zPosition = 5
        node.addChild(banner)

        let bannerCrown = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        bannerCrown.text = "♛"
        bannerCrown.fontSize = 11
        bannerCrown.fontColor = gold
        bannerCrown.verticalAlignmentMode = .center
        bannerCrown.position = CGPoint(x: 0, y: 4)
        banner.addChild(bannerCrown)

        return node
    }
    
    private func addGroundTiles(palette: (path: UIColor, trim: UIColor, lane: UIColor)) {
        let tileWidth: CGFloat = 54
        var x: CGFloat = 0
        var index = 0
        while x < size.width + tileWidth {
            let tile = SKShapeNode(rect: CGRect(x: x - 1, y: groundY - 17, width: tileWidth + 2, height: 28))
            tile.fillColor = index.isMultiple(of: 2) ? palette.trim.withAlphaComponent(0.96) : UIColor(red: 1.0, green: 0.66, blue: 0.20, alpha: 0.96)
            tile.strokeColor = UIColor.white.withAlphaComponent(0.24)
            tile.lineWidth = 1.2
            tile.zPosition = -17
            laneGuides.append(tile)
            addChild(tile)
            
            let bevel = SKShapeNode(rect: CGRect(x: x + 4, y: groundY + 4, width: tileWidth - 8, height: 4))
            bevel.fillColor = UIColor.white.withAlphaComponent(0.24)
            bevel.strokeColor = .clear
            bevel.zPosition = -16.9
            laneGuides.append(bevel)
            addChild(bevel)
            
            x += tileWidth
            index += 1
        }
    }
    
    private func fill(sprite: SKSpriteNode, in targetSize: CGSize) {
        let textureSize = sprite.texture?.size() ?? targetSize
        guard textureSize.width > 0, textureSize.height > 0, targetSize.width > 0, targetSize.height > 0 else { return }
        let scale = max(targetSize.width / textureSize.width, targetSize.height / textureSize.height)
        sprite.size = CGSize(width: textureSize.width * scale, height: textureSize.height * scale)
    }
    
    private func setRoundedRect(_ node: SKShapeNode, size: CGSize, cornerRadius: CGFloat) {
        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        node.path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    }
    
    private func updateHUDVisibility() {
        hud.isHidden = mode != .running && mode != .paused
    }

    private func layoutHUD() {
        updateHUDVisibility()
        let insets = view?.safeAreaInsets ?? .zero
        // Landscape notch sits on the left/right. Using safeAreaInsets.top here
        // pushed the whole bar down into the playfield.
        let topInset: CGFloat = isLandscape ? 10 : max(58, insets.top + 16)
        let top = size.height - topInset
        let sideInset = isLandscape ? max(24, max(insets.left, insets.right) + 10) : 14
        let boardWidth = min(size.width - sideInset * 2, max(304, size.width * (isLandscape ? 0.90 : 0.90)))
        let columnWidth = boardWidth / 3
        let panelHeight: CGFloat = isLandscape ? 44 : 78
        let panelY = top - panelHeight / 2
        let centerX = size.width / 2
        let leftX = centerX - columnWidth
        let rightX = centerX + columnWidth
        let upperY = panelY + (isLandscape ? 10 : 18)
        let lowerY = panelY - (isLandscape ? 10 : 16)
        
        scorePanel.position = CGPoint(x: centerX, y: panelY)
        setRoundedRect(scorePanel, size: CGSize(width: boardWidth, height: panelHeight), cornerRadius: isLandscape ? 14 : 18)
        statusPanel.position = CGPoint(x: centerX - columnWidth / 2, y: panelY)
        missionPanel.position = CGPoint(x: centerX + columnWidth / 2, y: panelY)
        setRoundedRect(statusPanel, size: CGSize(width: 1.5, height: panelHeight - (isLandscape ? 10 : 14)), cornerRadius: 0.75)
        setRoundedRect(missionPanel, size: CGSize(width: 1.5, height: panelHeight - (isLandscape ? 10 : 14)), cornerRadius: 0.75)
        
        scoreLabel.position = CGPoint(x: leftX, y: upperY)
        coinLabel.position = CGPoint(x: leftX, y: lowerY)
        healthLabel.position = CGPoint(x: rightX, y: upperY)
        powerLabel.position = CGPoint(x: rightX, y: lowerY)
        healthBarBack.position = CGPoint(x: rightX, y: panelY + (isLandscape ? 0 : 2))
        healthBarFill.position = healthBarBack.position
        setRoundedRect(healthBarBack, size: CGSize(width: columnWidth - 26, height: isLandscape ? 6 : 7), cornerRadius: 3.5)
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height * (isLandscape ? 0.52 : 0.58))
        zoneLabel.position = CGPoint(x: centerX, y: upperY)
        missionLabel.position = CGPoint(x: centerX, y: lowerY)
        tutorialLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.58)
        scoreLabel.fontSize = min(isLandscape ? 14 : 20, size.width * 0.045)
        coinLabel.fontSize = min(isLandscape ? 10 : 12.5, size.width * 0.029)
        healthLabel.fontSize = min(isLandscape ? 10 : 11.5, size.width * 0.027)
        powerLabel.fontSize = min(isLandscape ? 8 : 9.2, size.width * 0.021)
        zoneLabel.fontSize = min(isLandscape ? 10 : 11, size.width * 0.026)
        missionLabel.fontSize = min(isLandscape ? 8 : 9, size.width * 0.021)
        messageLabel.fontSize = min(18, size.width * 0.042)
        tutorialLabel.fontSize = min(18, size.width * 0.044)
        layoutTouchControls()
        updateHealthBar(width: columnWidth - 26)
    }
    
    private func layoutTouchControls() {
        let safeBottom = view?.safeAreaInsets.bottom ?? 0
        let y = max(isLandscape ? 40 : 72, safeBottom + (isLandscape ? 30 : 58))
        let small = CGSize(width: isLandscape ? 48 : 54, height: isLandscape ? 38 : 46)
        let medium = CGSize(width: isLandscape ? 70 : 76, height: isLandscape ? 38 : 46)
        let leftX: CGFloat = isLandscape ? 56 : 42
        let rightX: CGFloat = isLandscape ? 114 : 104
        let jumpX = size.width - (isLandscape ? 70 : 58)
        let duckX = size.width - (isLandscape ? 150 : 143)
        let powerX = size.width - (isLandscape ? 230 : 228)
        
        leftControl.position = CGPoint(x: leftX, y: y)
        rightControl.position = CGPoint(x: rightX, y: y)
        jumpControl.position = CGPoint(x: jumpX, y: y)
        duckControl.position = CGPoint(x: duckX, y: y)
        powerControl.position = CGPoint(x: powerX, y: y)
        setRoundedRect(leftControl, size: small, cornerRadius: 18)
        setRoundedRect(rightControl, size: small, cornerRadius: 18)
        setRoundedRect(jumpControl, size: medium, cornerRadius: 18)
        setRoundedRect(duckControl, size: medium, cornerRadius: 18)
        setRoundedRect(powerControl, size: medium, cornerRadius: 18)
        
        for pair in [(leftControl, leftControlLabel), (rightControl, rightControlLabel), (jumpControl, jumpControlLabel), (duckControl, duckControlLabel), (powerControl, powerControlLabel)] {
            pair.1.position = pair.0.position
            pair.1.fontSize = pair.0 === leftControl || pair.0 === rightControl ? 20 : 9.5
        }
        pauseButton.position = CGPoint(x: isLandscape ? 42 : 30, y: y + (isLandscape ? 44 : 54))
        setRoundedRect(pauseButton, size: CGSize(width: isLandscape ? 44 : 36, height: isLandscape ? 36 : 32), cornerRadius: 12)
        pauseButtonLabel.position = pauseButton.position
    }

    private func updateHUD() {
        let comboMultiplier = min(Self.maxComboMultiplier, 1 + comboCount / Self.comboActionsPerMultiplier)
        let comboText = comboMultiplier > 1 ? " x\(comboMultiplier)" : ""
        scoreLabel.text = "SCORE \(score)\(comboText)"
        coinLabel.text = "COINS  \(coins)"
        healthLabel.text = "HEALTH  \(health)%"
        let timerText: String
        if magnetTimer > 0 {
            timerText = "Mag \(Int(ceil(magnetTimer)))"
        } else if boostTimer > 0 {
            timerText = "Boost \(Int(ceil(boostTimer)))"
        } else if reviveTokens > 0 {
            timerText = "Revive \(reviveTokens)"
        } else {
            timerText = "Shield \(shieldCharges)"
        }
        powerLabel.text = "\(power.rawValue)\n\(timerText.uppercased())"
        zoneLabel.text = currentZone.rawValue
        missionLabel.text = activeMissionText()
        updateHealthBar(width: max(72, healthBarBack.frame.width))
    }
    
    private func updateHealthBar(width: CGFloat) {
        let clampedHealth = min(100, max(0, health))
        healthBarFill.fillColor = clampedHealth <= 30
            ? UIColor(red: 1.00, green: 0.25, blue: 0.34, alpha: 1)
            : UIColor(red: 1.00, green: 0.38, blue: 0.68, alpha: 0.98)
        let fillWidth = max(4, width * CGFloat(clampedHealth) / 100)
        let x = healthBarBack.position.x - width / 2 + fillWidth / 2
        healthBarFill.position = CGPoint(x: x, y: healthBarBack.position.y)
        setRoundedRect(healthBarFill, size: CGSize(width: fillWidth, height: 6), cornerRadius: 3)
    }

    private func showMenu() {
        mode = .menu
        flushBankCoins()
        updateHUDVisibility()
        player.isHidden = true
        tutorialLabel.alpha = 0
        menuLayer.removeAction(forKey: "splashTransition")
        updateBackground()
        menuLayer.removeAllChildren()
        if isLandscape {
            showMenuLandscape()
            return
        }
        addMenuScrim(centerY: size.height * 0.48, height: size.height * 0.76)
        addMenuSparkles()
        
        let iconBack = SKShapeNode(rectOf: CGSize(width: 82, height: 82), cornerRadius: 22)
        iconBack.fillColor = UIColor(red: 1.0, green: 0.42, blue: 0.72, alpha: 0.26)
        iconBack.strokeColor = UIColor(red: 1.0, green: 0.72, blue: 0.88, alpha: 0.78)
        iconBack.lineWidth = 2
        iconBack.position = CGPoint(x: size.width / 2, y: size.height * 0.785)
        iconBack.zPosition = 1
        menuLayer.addChild(iconBack)
        
        let appIcon = SKSpriteNode(imageNamed: "AppIconMenu")
        appIcon.size = CGSize(width: 70, height: 70)
        appIcon.position = iconBack.position
        appIcon.zPosition = 2
        menuLayer.addChild(appIcon)
        if !reducedMotion {
            iconBack.run(.repeatForever(.sequence([
                .scale(to: 1.06, duration: 1.0),
                .scale(to: 1.0, duration: 1.0)
            ])), withKey: "menuIconGlow")
            appIcon.run(.repeatForever(.sequence([
                .moveBy(x: 0, y: 5, duration: 0.8),
                .moveBy(x: 0, y: -5, duration: 0.8)
            ])), withKey: "menuIconFloat")
        }
        
        let header = SKShapeNode(rectOf: CGSize(width: min(size.width - 70, 300), height: 34), cornerRadius: 15)
        header.fillColor = UIColor(red: 1.0, green: 0.34, blue: 0.68, alpha: 0.18)
        header.strokeColor = UIColor(red: 1.0, green: 0.72, blue: 0.88, alpha: 0.60)
        header.lineWidth = 1.5
        header.position = CGPoint(x: size.width / 2, y: size.height * 0.715)
        header.zPosition = 1
        menuLayer.addChild(header)
        
        let crownMark = label("CROWN DASH", size: 15, weight: .heavy)
        crownMark.position = CGPoint(x: size.width / 2, y: header.position.y - 5)
        crownMark.fontColor = UIColor(red: 1.0, green: 0.66, blue: 0.84, alpha: 1)
        crownMark.zPosition = 2
        menuLayer.addChild(crownMark)
        if !reducedMotion {
            crownMark.run(.repeatForever(.sequence([
                .fadeAlpha(to: 0.72, duration: 0.9),
                .fadeAlpha(to: 1.0, duration: 0.9)
            ])), withKey: "pinkShimmer")
        }
        
        let title = label(homeTitleText, size: min(34, size.width * 0.084), weight: .heavy)
        title.numberOfLines = 2
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.625)
        title.fontColor = UIColor(red: 1.0, green: 0.82, blue: 0.93, alpha: 1)
        title.zPosition = 2
        menuLayer.addChild(title)

        let subtitle = label("Playing as \(selectedRunner.title)", size: 13, weight: .bold)
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.545)
        subtitle.fontColor = UIColor(red: 1.0, green: 0.74, blue: 0.90, alpha: 0.94)
        subtitle.zPosition = 2
        menuLayer.addChild(subtitle)
        
        addStatChip("Best \(GameCenterManager.shared.highScore)", x: size.width * 0.34, y: size.height * 0.505)
        addStatChip("Coins \(totalCoins)", x: size.width * 0.66, y: size.height * 0.505)
        addStatChip("Streak \(retention.loginStreak)", x: size.width * 0.34, y: size.height * 0.455)
        addStatChip(retention.giftAvailable ? "Chest ready" : "\(retention.royalRank())", x: size.width * 0.66, y: size.height * 0.455)
        
        addPrimaryMenuButton("Start Run", name: "start", y: size.height * 0.385)
        if retention.giftAvailable {
            addMenuButton("Open Daily Chest", name: "openGift", y: size.height * 0.332)
        }
        
        let gridWidth = min(size.width - 62, 318)
        let columnWidth = (gridWidth - 12) / 2
        let leftX = size.width / 2 - columnWidth / 2 - 6
        let rightX = size.width / 2 + columnWidth / 2 + 6
        let gridTop = retention.giftAvailable ? size.height * 0.274 : size.height * 0.305
        let row: CGFloat = 0.057 * size.height
        addMenuButton("Characters", name: "characters", x: leftX, y: gridTop, width: columnWidth, height: 40)
        addMenuButton("Outfits", name: "wardrobe", x: rightX, y: gridTop, width: columnWidth, height: 40)
        addMenuButton("Missions", name: "missions", x: leftX, y: gridTop - row, width: columnWidth, height: 40)
        addMenuButton("Upgrades", name: "upgrades", x: rightX, y: gridTop - row, width: columnWidth, height: 40)
        addMenuButton("Playroom", name: "playroom", x: leftX, y: gridTop - row * 2, width: columnWidth, height: 40)
        addMenuButton("Settings", name: "settings", x: rightX, y: gridTop - row * 2, width: columnWidth, height: 40)

        if retention.giftAvailable, !didAutoPresentGift {
            didAutoPresentGift = true
            run(.sequence([
                .wait(forDuration: 0.45),
                .run { [weak self] in
                    guard let self, self.mode == .menu else { return }
                    self.showDailyGift()
                }
            ]), withKey: "autoGift")
        }
    }

    private func showMenuLandscape() {
        addMenuScrim(centerY: size.height * 0.50, height: size.height * 0.88)
        addMenuSparkles()
        let leftX = size.width * 0.30
        let rightX = size.width * 0.70

        let iconBack = SKShapeNode(rectOf: CGSize(width: 58, height: 58), cornerRadius: 16)
        iconBack.fillColor = UIColor(red: 1.0, green: 0.42, blue: 0.72, alpha: 0.26)
        iconBack.strokeColor = UIColor(red: 1.0, green: 0.72, blue: 0.88, alpha: 0.78)
        iconBack.lineWidth = 2
        iconBack.position = CGPoint(x: leftX, y: size.height * 0.78)
        iconBack.zPosition = 1
        menuLayer.addChild(iconBack)
        let appIcon = SKSpriteNode(imageNamed: "AppIconMenu")
        appIcon.size = CGSize(width: 50, height: 50)
        appIcon.position = iconBack.position
        appIcon.zPosition = 2
        menuLayer.addChild(appIcon)

        let crownMark = label("CROWN DASH", size: 12, weight: .heavy)
        crownMark.position = CGPoint(x: leftX, y: size.height * 0.66)
        crownMark.fontColor = UIColor(red: 1.0, green: 0.66, blue: 0.84, alpha: 1)
        crownMark.zPosition = 2
        menuLayer.addChild(crownMark)

        let title = label(homeTitleText, size: min(26, size.width * 0.034), weight: .heavy)
        title.numberOfLines = 2
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: leftX, y: size.height * 0.54)
        title.fontColor = UIColor(red: 1.0, green: 0.82, blue: 0.93, alpha: 1)
        title.zPosition = 2
        menuLayer.addChild(title)

        let subtitle = label("Playing as \(selectedRunner.title)", size: 11, weight: .bold)
        subtitle.position = CGPoint(x: leftX, y: size.height * 0.42)
        subtitle.fontColor = UIColor(red: 1.0, green: 0.74, blue: 0.90, alpha: 0.94)
        subtitle.zPosition = 2
        menuLayer.addChild(subtitle)

        addStatChip("Best \(GameCenterManager.shared.highScore)", x: leftX - 58, y: size.height * 0.32)
        addStatChip("Coins \(totalCoins)", x: leftX + 58, y: size.height * 0.32)
        addStatChip("Streak \(retention.loginStreak)", x: leftX - 58, y: size.height * 0.22)
        addStatChip(retention.giftAvailable ? "Chest ready" : "\(retention.royalRank())", x: leftX + 58, y: size.height * 0.22)

        addPrimaryMenuButton("Start Run", name: "start", y: size.height * 0.74, x: rightX, compact: true)
        if retention.giftAvailable {
            addMenuButton("Open Daily Chest", name: "openGift", x: rightX, y: size.height * 0.60, width: 220, height: 36)
        }
        let gridTop = retention.giftAvailable ? size.height * 0.48 : size.height * 0.56
        let columnWidth: CGFloat = 118
        let leftCol = rightX - columnWidth / 2 - 6
        let rightCol = rightX + columnWidth / 2 + 6
        let row: CGFloat = 42
        addMenuButton("Characters", name: "characters", x: leftCol, y: gridTop, width: columnWidth, height: 36)
        addMenuButton("Outfits", name: "wardrobe", x: rightCol, y: gridTop, width: columnWidth, height: 36)
        addMenuButton("Missions", name: "missions", x: leftCol, y: gridTop - row, width: columnWidth, height: 36)
        addMenuButton("Upgrades", name: "upgrades", x: rightCol, y: gridTop - row, width: columnWidth, height: 36)
        addMenuButton("Playroom", name: "playroom", x: leftCol, y: gridTop - row * 2, width: columnWidth, height: 36)
        addMenuButton("Settings", name: "settings", x: rightCol, y: gridTop - row * 2, width: columnWidth, height: 36)

        if retention.giftAvailable, !didAutoPresentGift {
            didAutoPresentGift = true
            run(.sequence([
                .wait(forDuration: 0.45),
                .run { [weak self] in
                    guard let self, self.mode == .menu else { return }
                    self.showDailyGift()
                }
            ]), withKey: "autoGift")
        }
    }
    
    private func showSplash() {
        mode = .splash
        updateHUDVisibility()
        player.isHidden = true
        tutorialLabel.alpha = 0
        updateBackground()
        menuLayer.removeAllChildren()
        menuLayer.removeAllActions()
        menuLayer.alpha = 1
        
        let wash = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        wash.fillColor = UIColor(red: 0.26, green: 0.02, blue: 0.20, alpha: 0.30)
        wash.strokeColor = .clear
        wash.zPosition = -2
        menuLayer.addChild(wash)
        
        let vignette = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height * 0.45))
        vignette.fillColor = UIColor(red: 0.46, green: 0.02, blue: 0.28, alpha: 0.20)
        vignette.strokeColor = .clear
        vignette.zPosition = -1
        menuLayer.addChild(vignette)
        
        let safeTop = view?.safeAreaInsets.top ?? 0
        let safeBottom = view?.safeAreaInsets.bottom ?? 0
        let iconY = min(size.height - safeTop - 120, size.height * 0.72)
        let titleY = size.height * 0.53
        let lowerY = max(safeBottom + 98, size.height * 0.22)
        
        let glow = SKShapeNode(ellipseOf: CGSize(width: min(260, size.width * 0.66), height: 118))
        glow.fillColor = UIColor(red: 1.0, green: 0.40, blue: 0.76, alpha: 0.24)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: size.width / 2, y: iconY)
        glow.zPosition = 0
        glow.alpha = 0
        menuLayer.addChild(glow)
        
        let iconBack = SKShapeNode(rectOf: CGSize(width: 120, height: 120), cornerRadius: 30)
        iconBack.fillColor = UIColor(red: 1.0, green: 0.50, blue: 0.78, alpha: 0.24)
        iconBack.strokeColor = UIColor(red: 1.0, green: 0.82, blue: 0.94, alpha: 0.88)
        iconBack.lineWidth = 2.5
        iconBack.position = CGPoint(x: size.width / 2, y: iconY)
        iconBack.zPosition = 1
        iconBack.alpha = 0
        menuLayer.addChild(iconBack)
        
        let icon = SKSpriteNode(imageNamed: "AppIconMenu")
        icon.size = CGSize(width: 104, height: 104)
        icon.position = iconBack.position
        icon.zPosition = 2
        icon.alpha = 0
        icon.setScale(0.72)
        menuLayer.addChild(icon)
        
        let crown = SKShapeNode(path: crownPath())
        crown.fillColor = UIColor(red: 1.0, green: 0.23, blue: 0.64, alpha: 0.96)
        crown.strokeColor = UIColor(red: 1.0, green: 0.88, blue: 0.96, alpha: 0.88)
        crown.lineWidth = 1.6
        crown.position = CGPoint(x: size.width / 2, y: titleY + 80)
        crown.zPosition = 2
        crown.alpha = 0
        crown.setScale(1.78)
        menuLayer.addChild(crown)
        
        let titleShadow = label("Princess\nAdelynn", size: min(42, size.width * 0.098), weight: .heavy)
        titleShadow.fontColor = UIColor(red: 0.38, green: 0.0, blue: 0.25, alpha: 0.78)
        titleShadow.position = CGPoint(x: size.width / 2 + 3, y: titleY - 3)
        titleShadow.zPosition = 2
        titleShadow.alpha = 0
        titleShadow.setScale(0.94)
        menuLayer.addChild(titleShadow)
        
        let title = label("Princess\nAdelynn", size: min(42, size.width * 0.098), weight: .heavy)
        title.numberOfLines = 2
        title.fontColor = UIColor(red: 1.0, green: 0.77, blue: 0.93, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: titleY)
        title.zPosition = 2
        title.alpha = 0
        title.setScale(0.94)
        menuLayer.addChild(title)
        
        let subtitle = label("Royal Runner Adventure", size: min(16, size.width * 0.039), weight: .bold)
        subtitle.fontColor = UIColor(red: 1.0, green: 0.86, blue: 0.96, alpha: 0.94)
        subtitle.position = CGPoint(x: size.width / 2, y: titleY - 86)
        subtitle.zPosition = 2
        subtitle.alpha = 0
        menuLayer.addChild(subtitle)
        
        let loadingTrack = SKShapeNode(rectOf: CGSize(width: min(220, size.width * 0.56), height: 8), cornerRadius: 4)
        loadingTrack.fillColor = UIColor.white.withAlphaComponent(0.16)
        loadingTrack.strokeColor = UIColor(red: 1.0, green: 0.75, blue: 0.90, alpha: 0.34)
        loadingTrack.lineWidth = 1
        loadingTrack.position = CGPoint(x: size.width / 2, y: lowerY)
        loadingTrack.zPosition = 2
        loadingTrack.alpha = 0
        menuLayer.addChild(loadingTrack)
        
        let loadingFill = SKShapeNode(rectOf: CGSize(width: min(220, size.width * 0.56), height: 8), cornerRadius: 4)
        loadingFill.fillColor = UIColor(red: 1.0, green: 0.38, blue: 0.74, alpha: 0.95)
        loadingFill.strokeColor = .clear
        loadingFill.position = loadingTrack.position
        loadingFill.xScale = 0.05
        loadingFill.zPosition = 3
        loadingFill.alpha = 0
        menuLayer.addChild(loadingFill)
        
        let skip = label("Tap to skip", size: 11.5, weight: .bold)
        skip.fontColor = UIColor(red: 1.0, green: 0.78, blue: 0.92, alpha: 0.78)
        skip.position = CGPoint(x: size.width / 2, y: max(safeBottom + 42, loadingTrack.position.y - 42))
        skip.zPosition = 2
        skip.alpha = 0
        menuLayer.addChild(skip)
        
        for index in 0..<18 {
            let sparkle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.8...4.0))
            sparkle.fillColor = UIColor(red: 1.0, green: 0.58, blue: 0.82, alpha: 0.75)
            sparkle.strokeColor = .clear
            sparkle.position = CGPoint(x: size.width / 2, y: titleY + 12)
            sparkle.zPosition = 3
            sparkle.alpha = 0
            menuLayer.addChild(sparkle)
            if !reducedMotion {
                let dx = CGFloat.random(in: -150...150)
                let dy = CGFloat.random(in: -110...120)
                sparkle.run(.sequence([
                    .wait(forDuration: 0.28 + Double(index) * 0.018),
                    .group([
                        .fadeAlpha(to: 0.92, duration: 0.10),
                        .moveBy(x: dx, y: dy, duration: 0.75),
                        .scale(to: 0.18, duration: 0.75)
                    ]),
                    .fadeOut(withDuration: 0.18),
                    .removeFromParent()
                ]))
            }
        }
        
        if reducedMotion {
            glow.alpha = 1
            iconBack.alpha = 1
            icon.alpha = 1
            icon.setScale(1)
            crown.alpha = 1
            titleShadow.alpha = 1
            titleShadow.setScale(1)
            title.alpha = 1
            title.setScale(1)
            subtitle.alpha = 1
            loadingTrack.alpha = 1
            loadingFill.alpha = 1
            loadingFill.xScale = 1
            skip.alpha = 1
            menuLayer.run(.sequence([.wait(forDuration: 1.0), .run { [weak self] in self?.showMenu() }]), withKey: "splashTransition")
            return
        }
        
        glow.run(.group([
            .fadeIn(withDuration: 0.22),
            .repeatForever(.sequence([
                .scale(to: 1.16, duration: 1.0),
                .scale(to: 1.0, duration: 1.0)
            ]))
        ]))
        iconBack.run(.sequence([.fadeIn(withDuration: 0.18), .scale(to: 1.08, duration: 0.18), .scale(to: 1.0, duration: 0.16)]))
        icon.run(.sequence([
            .wait(forDuration: 0.08),
            .group([.fadeIn(withDuration: 0.20), .scale(to: 1.08, duration: 0.22)]),
            .scale(to: 1.0, duration: 0.16),
            .repeat(.sequence([.rotate(byAngle: 0.035, duration: 0.16), .rotate(byAngle: -0.07, duration: 0.32), .rotate(byAngle: 0.035, duration: 0.16)]), count: 1)
        ]))
        crown.run(.sequence([
            .wait(forDuration: 0.26),
            .group([.fadeIn(withDuration: 0.18), .moveBy(x: 0, y: 7, duration: 0.22)])
        ]))
        titleShadow.run(.sequence([
            .wait(forDuration: 0.36),
            .group([.fadeIn(withDuration: 0.22), .scale(to: 1.0, duration: 0.22), .moveBy(x: 0, y: 8, duration: 0.22)])
        ]))
        title.run(.sequence([
            .wait(forDuration: 0.36),
            .group([.fadeIn(withDuration: 0.22), .scale(to: 1.0, duration: 0.22), .moveBy(x: 0, y: 8, duration: 0.22)])
        ]))
        subtitle.run(.sequence([.wait(forDuration: 0.55), .fadeIn(withDuration: 0.24)]))
        loadingTrack.run(.sequence([.wait(forDuration: 0.68), .fadeIn(withDuration: 0.16)]))
        loadingFill.run(.sequence([
            .wait(forDuration: 0.70),
            .fadeIn(withDuration: 0.12),
            .scaleX(to: 1.0, duration: 1.65)
        ]))
        skip.run(.sequence([.wait(forDuration: 0.92), .fadeIn(withDuration: 0.22)]))
        menuLayer.run(.sequence([
            .wait(forDuration: 2.65),
            .fadeOut(withDuration: 0.20),
            .run { [weak self] in
                self?.menuLayer.alpha = 1
                self?.showMenu()
            }
        ]), withKey: "splashTransition")
    }
    
    private func addPrimaryMenuButton(_ text: String, name: String, y: CGFloat, x: CGFloat? = nil, compact: Bool = false) {
        let centerX = x ?? size.width / 2
        let slim = compact || isLandscape
        let width = slim ? min(240, size.width * 0.40) : min(size.width - 72, 272)
        let height: CGFloat = slim ? 46 : 58
        let back = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: height / 2 - 5)
        back.name = name
        back.fillColor = UIColor(red: 1.0, green: 0.34, blue: 0.68, alpha: 0.96)
        back.strokeColor = UIColor(red: 1.0, green: 0.82, blue: 0.94, alpha: 1)
        back.lineWidth = 4
        back.position = CGPoint(x: centerX, y: y)
        back.zPosition = 2
        menuLayer.addChild(back)
        if !reducedMotion {
            back.run(.repeatForever(.sequence([
                .scale(to: 1.025, duration: 0.82),
                .scale(to: 1.0, duration: 0.82)
            ])), withKey: "primaryPulse")
        }
        
        startButton.text = text
        startButton.name = name
        startButton.fontSize = slim ? 18 : 22
        startButton.fontColor = UIColor(red: 0.18, green: 0.03, blue: 0.13, alpha: 1)
        startButton.position = CGPoint(x: centerX, y: y - (slim ? 6 : 8))
        startButton.zPosition = 3
        menuLayer.addChild(startButton)
        if !reducedMotion {
            startButton.run(.repeatForever(.sequence([
                .moveBy(x: 0, y: 1.5, duration: 0.82),
                .moveBy(x: 0, y: -1.5, duration: 0.82)
            ])), withKey: "primaryTextFloat")
        }
    }
    
    private func addMenuButton(_ text: String, name: String, y: CGFloat) {
        addMenuButton(text, name: name, x: size.width / 2, y: y, width: min(size.width - 96, 230))
    }
    
    private func addMenuButton(_ text: String, name: String, x: CGFloat, y: CGFloat, width: CGFloat) {
        addMenuButton(text, name: name, x: x, y: y, width: width, height: 34)
    }
    
    private func addMenuButton(_ text: String, name: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let back = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: min(17, height / 2 - 1))
        back.name = name
        back.fillColor = UIColor(red: 0.22, green: 0.04, blue: 0.18, alpha: 0.78)
        back.strokeColor = UIColor(red: 1.0, green: 0.58, blue: 0.82, alpha: 0.76)
        back.lineWidth = 2
        back.position = CGPoint(x: x, y: y)
        back.zPosition = 2
        menuLayer.addChild(back)
        if !reducedMotion {
            let delay = Double(abs(x - size.width / 2) / max(size.width, 1)) * 0.35
            back.run(.sequence([
                .wait(forDuration: delay),
                .repeatForever(.sequence([
                    .fadeAlpha(to: 0.82, duration: 1.2),
                    .fadeAlpha(to: 1.0, duration: 1.2)
                ]))
            ]), withKey: "menuButtonBreath")
        }
        
        let button = label(text, size: height > 36 ? 14 : 13.5, weight: .bold)
        button.name = name
        button.fontColor = UIColor(red: 1.0, green: 0.88, blue: 0.96, alpha: 0.94)
        button.position = CGPoint(x: x, y: y - 5)
        button.zPosition = 3
        menuLayer.addChild(button)
    }
    
    private func addMenuScrim(centerY: CGFloat, height: CGFloat) {
        let panelWidth = min(size.width - (isLandscape ? 48 : 36), isLandscape ? size.width - 56 : 374)
        let scrim = SKShapeNode(rectOf: CGSize(width: panelWidth, height: height), cornerRadius: 28)
        scrim.position = CGPoint(x: size.width / 2, y: centerY)
        scrim.fillColor = UIColor(red: 0.12, green: 0.02, blue: 0.12, alpha: 0.62)
        scrim.strokeColor = UIColor(red: 1.0, green: 0.58, blue: 0.82, alpha: 0.46)
        scrim.lineWidth = 2
        scrim.zPosition = -1
        menuLayer.addChild(scrim)
    }
    
    private func addStatChip(_ text: String, x: CGFloat, y: CGFloat) {
        let chip = SKShapeNode(rectOf: CGSize(width: 112, height: 30), cornerRadius: 13)
        chip.fillColor = UIColor(red: 1.0, green: 0.44, blue: 0.74, alpha: 0.18)
        chip.strokeColor = UIColor(red: 1.0, green: 0.70, blue: 0.88, alpha: 0.58)
        chip.lineWidth = 1.5
        chip.position = CGPoint(x: x, y: y)
        chip.zPosition = 2
        menuLayer.addChild(chip)
        
        let value = label(text, size: 11, weight: .bold)
        value.fontColor = UIColor(red: 1.0, green: 0.86, blue: 0.96, alpha: 1)
        value.position = CGPoint(x: x, y: y - 4)
        value.zPosition = 3
        menuLayer.addChild(value)
    }
    
    private func addModalShell(title: String, subtitle: String? = nil, centerY: CGFloat, height: CGFloat) {
        addMenuScrim(centerY: centerY, height: height)
        let headerWidth = min(size.width - 92, 252)
        let header = SKShapeNode(rectOf: CGSize(width: headerWidth, height: 38), cornerRadius: 18)
        header.fillColor = UIColor(red: 1.0, green: 0.36, blue: 0.70, alpha: 0.24)
        header.strokeColor = UIColor(red: 1.0, green: 0.74, blue: 0.90, alpha: 0.72)
        header.lineWidth = 1.6
        header.position = CGPoint(x: size.width / 2, y: centerY + height / 2 - (isLandscape ? 28 : 54))
        header.zPosition = 1
        menuLayer.addChild(header)
        
        let titleLabel = label(title, size: min(isLandscape ? 20 : 27, size.width * 0.066), weight: .heavy)
        titleLabel.fontColor = UIColor(red: 1.0, green: 0.84, blue: 0.95, alpha: 1)
        titleLabel.position = CGPoint(x: size.width / 2, y: header.position.y - 5)
        titleLabel.zPosition = 2
        menuLayer.addChild(titleLabel)
        
        if let subtitle {
            let subtitleLabel = label(subtitle, size: 12.5, weight: .bold)
            subtitleLabel.fontColor = UIColor(red: 1.0, green: 0.68, blue: 0.86, alpha: 0.92)
            subtitleLabel.position = CGPoint(x: size.width / 2, y: header.position.y - 38)
            subtitleLabel.zPosition = 2
            menuLayer.addChild(subtitleLabel)
        }
    }
    
    private func addModalCard(_ text: String, y: CGFloat, height: CGFloat, fontSize: CGFloat = 13.5, color: UIColor = UIColor(red: 1.0, green: 0.86, blue: 0.96, alpha: 0.94)) {
        let width = min(size.width - 78, isLandscape ? 440 : 298)
        let card = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 16)
        card.fillColor = UIColor(red: 0.20, green: 0.03, blue: 0.18, alpha: 0.58)
        card.strokeColor = UIColor(red: 1.0, green: 0.58, blue: 0.82, alpha: 0.38)
        card.lineWidth = 1.2
        card.position = CGPoint(x: size.width / 2, y: y)
        card.zPosition = 1
        menuLayer.addChild(card)
        
        let body = label(text, size: fontSize, weight: .bold)
        body.preferredMaxLayoutWidth = width - 26
        body.fontColor = color
        body.position = CGPoint(x: size.width / 2, y: y - 5)
        body.zPosition = 2
        menuLayer.addChild(body)
    }
    
    private func addModalRow(title: String, detail: String, name: String? = nil, y: CGFloat, accent: UIColor, selected: Bool = false, x: CGFloat? = nil, rowWidth: CGFloat? = nil) {
        let width = rowWidth ?? min(size.width - 76, isLandscape ? 360 : 304)
        let rowX = x ?? size.width / 2
        let rowHeight: CGFloat = isLandscape ? 40 : 48
        let row = SKShapeNode(rectOf: CGSize(width: width, height: rowHeight), cornerRadius: 16)
        row.name = name
        row.fillColor = selected ? accent.withAlphaComponent(0.28) : UIColor(red: 0.16, green: 0.02, blue: 0.15, alpha: 0.62)
        row.strokeColor = selected ? UIColor.white.withAlphaComponent(0.82) : accent.withAlphaComponent(0.58)
        row.lineWidth = selected ? 2 : 1.4
        row.position = CGPoint(x: rowX, y: y)
        row.zPosition = 1
        menuLayer.addChild(row)
        
        let swatch = SKShapeNode(circleOfRadius: 8)
        swatch.name = name
        swatch.fillColor = accent
        swatch.strokeColor = UIColor.white.withAlphaComponent(0.68)
        swatch.lineWidth = 1
        swatch.position = CGPoint(x: rowX - width / 2 + 24, y: y)
        swatch.zPosition = 2
        menuLayer.addChild(swatch)
        
        let titleLabel = label(title, size: isLandscape ? 12 : 13.5, weight: .heavy)
        titleLabel.name = name
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.fontColor = UIColor(red: 1.0, green: 0.88, blue: 0.96, alpha: 1)
        titleLabel.position = CGPoint(x: rowX - width / 2 + 42, y: y + 6)
        titleLabel.zPosition = 2
        menuLayer.addChild(titleLabel)
        
        let isToggle = detail == "On" || detail == "Off"
        let detailLabel = label(isToggle ? "Tap to change" : detail, size: isLandscape ? 9.5 : 10.5, weight: .bold)
        detailLabel.name = name
        detailLabel.horizontalAlignmentMode = .left
        detailLabel.fontColor = UIColor(red: 1.0, green: 0.66, blue: 0.84, alpha: 0.88)
        detailLabel.position = CGPoint(x: titleLabel.position.x, y: y - 10)
        detailLabel.zPosition = 2
        menuLayer.addChild(detailLabel)
        if isToggle {
            
            let on = detail == "On"
            let badge = SKShapeNode(rectOf: CGSize(width: 54, height: 24), cornerRadius: 12)
            badge.name = name
            badge.fillColor = on ? UIColor(red: 0.18, green: 0.72, blue: 0.42, alpha: 0.92) : UIColor(red: 0.28, green: 0.12, blue: 0.24, alpha: 0.92)
            badge.strokeColor = on ? UIColor(red: 0.72, green: 1.0, blue: 0.84, alpha: 0.95) : UIColor.white.withAlphaComponent(0.35)
            badge.lineWidth = 1.4
            badge.position = CGPoint(x: rowX + width / 2 - 40, y: y)
            badge.zPosition = 2
            menuLayer.addChild(badge)
            
            let badgeLabel = label(on ? "ON" : "OFF", size: 11, weight: .heavy)
            badgeLabel.name = name
            badgeLabel.fontColor = on ? UIColor.white : UIColor(red: 1.0, green: 0.78, blue: 0.90, alpha: 0.85)
            badgeLabel.position = badge.position
            badgeLabel.zPosition = 3
            menuLayer.addChild(badgeLabel)
        }
    }
    
    private func addMenuSparkles() {
        for index in 0..<8 {
            let sparkle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.0...1.7))
            sparkle.fillColor = index.isMultiple(of: 2)
                ? UIColor(red: 1.0, green: 0.74, blue: 0.90, alpha: 0.55)
                : UIColor.white.withAlphaComponent(0.40)
            sparkle.strokeColor = .clear
            // Keep sparkles inside the modal so they never read as stray edge dots.
            sparkle.position = CGPoint(
                x: CGFloat.random(in: size.width * 0.24...size.width * 0.76),
                y: CGFloat.random(in: size.height * 0.30...size.height * 0.70)
            )
            sparkle.zPosition = 0.4
            sparkle.alpha = 0.7
            menuLayer.addChild(sparkle)
            if !reducedMotion {
                sparkle.run(.repeatForever(.sequence([
                    .fadeAlpha(to: 0.22, duration: Double.random(in: 0.7...1.1)),
                    .fadeAlpha(to: 0.7, duration: Double.random(in: 0.7...1.1))
                ])))
            }
        }
    }
    
    private func showGameOver() {
        updateHUDVisibility()
        player.isHidden = true
        updateBackground()
        menuLayer.removeAllChildren()
        addMenuSparkles()
        spawnRecapConfetti()
        let stars = String(repeating: "★", count: lastRecapStars) + String(repeating: "☆", count: max(0, 3 - lastRecapStars))
        addModalShell(title: lastRecapPraise, subtitle: "\(stars)   \(retention.royalRank())", centerY: size.height * 0.50, height: isLandscape ? size.height * 0.86 : size.height * 0.52)
        let ys = spacedYs(4, top: size.height * (isLandscape ? 0.68 : 0.58), bottom: size.height * (isLandscape ? 0.22 : 0.26))
        addModalCard("Score \(score)\nCoins \(coins)", y: ys[0], height: isLandscape ? 52 : 68, fontSize: isLandscape ? 15 : 18, color: UIColor(red: 1, green: 0.88, blue: 0.38, alpha: 1))
        addModalCard("Best \(GameCenterManager.shared.highScore)   Bank \(totalCoins)\n\(retention.activeGoalText())", y: ys[1], height: isLandscape ? 48 : 62, fontSize: 12)
        addPrimaryMenuButton("Run Again", name: "restart", y: ys[2])
        let gridWidth = min(size.width - 62, isLandscape ? 420 : 318)
        let columnWidth = (gridWidth - 12) / 2
        addMenuButton("Home", name: "home", x: size.width / 2 - columnWidth / 2 - 6, y: ys[3], width: columnWidth, height: 40)
        addMenuButton("Postcard", name: "postcard", x: size.width / 2 + columnWidth / 2 + 6, y: ys[3], width: columnWidth, height: 40)
    }
    
    private func showTutorial() {
        mode = .tutorial
        player.isHidden = true
        updateHUDVisibility()
        updateBackground()
        menuLayer.removeAllChildren()
        tutorialStep = 0
        updateTutorial()
    }
    
    private func updateTutorial() {
        let steps = [
            "Princess Adelynn runs through royal lanes.\nSwipe or tap the sides to change lanes.",
            "Jump over tide crabs. Duck under star wisps.\nTap POWER with Rose Bloom to bloom shadow imps.",
            "Tap POWER to switch royal powers.\nRose Bloom clears imps, Crystal Tide clears waves, Sparkle pulls coins.",
            "Collect powerups and finish missions.\nUse coins for outfits and upgrades."
        ]
        menuLayer.removeAllChildren()
        addMenuSparkles()
        addModalShell(title: "How to Play", subtitle: "Step \(min(tutorialStep + 1, steps.count)) of \(steps.count)", centerY: size.height * 0.50, height: isLandscape ? size.height * 0.82 : size.height * 0.48)
        let ys = spacedYs(3, top: size.height * (isLandscape ? 0.58 : 0.50), bottom: size.height * (isLandscape ? 0.20 : 0.25))
        addModalCard(steps[min(tutorialStep, steps.count - 1)], y: ys[0], height: isLandscape ? 72 : 116, fontSize: isLandscape ? 13 : 14.5)
        addMenuButton("Tap to Continue", name: "continueTutorial", y: ys[1])
        addBackButton(y: ys[2])
    }
    
    private func showSettings() {
        mode = .settings
        player.isHidden = true
        tutorialLabel.alpha = 0
        updateBackground()
        menuLayer.removeAllChildren()
        addMenuSparkles()
        addModalShell(title: "Settings", subtitle: "Tune the royal run", centerY: size.height * 0.50, height: isLandscape ? size.height * 0.88 : size.height * 0.46)
        let ys = spacedYs(6, top: size.height * (isLandscape ? 0.72 : 0.54), bottom: size.height * (isLandscape ? 0.16 : 0.18))
        addModalRow(title: "Sound", detail: soundEnabled ? "On" : "Off", name: "toggleSound", y: ys[0], accent: UIColor.systemPink, selected: soundEnabled)
        addModalRow(title: "Haptics", detail: hapticsEnabled ? "On" : "Off", name: "toggleHaptics", y: ys[1], accent: UIColor.systemPurple, selected: hapticsEnabled)
        addModalRow(title: "Reduced Motion", detail: reducedMotion ? "On" : "Off", name: "toggleMotion", y: ys[2], accent: UIColor.systemCyan, selected: reducedMotion)
        addModalRow(title: "Gentle Mode", detail: retention.gentleMode ? "Softer hits" : "Classic", name: "toggleGentle", y: ys[3], accent: UIColor.systemMint, selected: retention.gentleMode)
        addModalRow(title: "How to Play", detail: "Quick lesson", name: "tutorial", y: ys[4], accent: UIColor.systemYellow, selected: false)
        addBackButton(y: ys[5])
    }
    
    private func showWardrobe() {
        mode = .wardrobe
        player.isHidden = true
        tutorialLabel.alpha = 0
        updateBackground()
        menuLayer.removeAllChildren()
        addMenuSparkles()
        addModalShell(title: "Dress Adelynn", subtitle: "Coin Bank \(totalCoins)", centerY: size.height * 0.50, height: isLandscape ? size.height * 0.88 : size.height * 0.68)
        if !isLandscape {
            let concept = SKSpriteNode(imageNamed: "PrincessAdelynnConcept")
            concept.name = "concept"
            concept.size = CGSize(width: min(58, size.width * 0.14), height: min(58, size.width * 0.14))
            concept.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
            concept.zPosition = 20
            menuLayer.addChild(concept)
        }
        let outfits = Outfit.allCases
        if isLandscape {
            let cols = landscapeColumns()
            let rows = spacedYs(4, top: size.height * 0.70, bottom: size.height * 0.16)
            for (index, outfit) in outfits.enumerated() {
                let owned = unlockedOutfits.contains(outfit.rawValue)
                let active = selectedOutfit == outfit
                let detail = active ? "Wearing" : (owned ? "Tap to wear" : "\(outfit.cost) coins")
                let col = index % 2
                let row = index / 2
                addModalRow(title: outfit.rawValue, detail: detail, name: "outfit:\(outfit.rawValue)", y: rows[row], accent: outfit.dress, selected: active, x: col == 0 ? cols.left : cols.right, rowWidth: cols.width)
            }
            addBackButton(y: rows[3])
        } else {
            for (index, outfit) in outfits.enumerated() {
                let owned = unlockedOutfits.contains(outfit.rawValue)
                let active = selectedOutfit == outfit
                let detail = active ? "Wearing" : (owned ? "Tap to wear" : "\(outfit.cost) coins")
                addModalRow(title: outfit.rawValue, detail: detail, name: "outfit:\(outfit.rawValue)", y: size.height * (0.60 - CGFloat(index) * 0.062), accent: outfit.dress, selected: active)
            }
            addBackButton(y: size.height * 0.16)
        }
    }
    
    private func showMissions() {
        mode = .missions
        player.isHidden = true
        tutorialLabel.alpha = 0
        updateBackground()
        menuLayer.removeAllChildren()
        addMenuSparkles()
        addModalShell(title: "Royal Missions", subtitle: "Today's goals and run missions", centerY: size.height * 0.50, height: isLandscape ? size.height * 0.88 : size.height * 0.58)
        let daily = retention.dailyGoals
        if isLandscape {
            let cols = landscapeColumns()
            let rows = spacedYs(5, top: size.height * 0.70, bottom: size.height * 0.16)
            for (index, goal) in daily.enumerated() {
                addModalRow(title: goal.title, detail: "\(goal.progress)/\(goal.target) today", y: rows[index], accent: goal.done ? UIColor.systemYellow : UIColor.systemPink, selected: goal.done, x: cols.left, rowWidth: cols.width)
            }
            for (index, mission) in missions.enumerated() {
                let detail = "\(min(mission.progress, mission.target))/\(mission.target) complete   Reward +\(mission.reward)"
                addModalRow(title: mission.kind.rawValue, detail: detail, y: rows[index], accent: mission.completed ? UIColor.systemYellow : UIColor.systemPink, selected: mission.completed, x: cols.right, rowWidth: cols.width)
            }
            addBackButton(y: rows[4])
        } else {
            for (index, goal) in daily.enumerated() {
                addModalRow(title: goal.title, detail: "\(goal.progress)/\(goal.target) today", y: size.height * (0.64 - CGFloat(index) * 0.055), accent: goal.done ? UIColor.systemYellow : UIColor.systemPink, selected: goal.done)
            }
            for (index, mission) in missions.enumerated() {
                let detail = "\(min(mission.progress, mission.target))/\(mission.target) complete   Reward +\(mission.reward)"
                addModalRow(title: mission.kind.rawValue, detail: detail, y: size.height * (0.64 - CGFloat(daily.count + index) * 0.055), accent: mission.completed ? UIColor.systemYellow : UIColor.systemPink, selected: mission.completed)
            }
            addBackButton(y: size.height * 0.18)
        }
    }
    
    private func showPlayroom() {
        mode = .playroom
        player.isHidden = true
        tutorialLabel.alpha = 0
        updateBackground()
        menuLayer.removeAllChildren()
        addMenuSparkles()
        addModalShell(title: "Playroom", subtitle: featuredFriend, centerY: size.height * 0.50, height: isLandscape ? size.height * 0.88 : size.height * 0.62)
        let playItems: [(String, String, String, UIColor, Bool)] = [
            ("Daily Chest", retention.giftAvailable ? "A gift is waiting" : retention.giftForToday().title, "openGift", .systemPink, retention.giftAvailable),
            ("Lucky Spin", retention.spinAvailable ? "One spin today" : "Come back tomorrow", "openSpin", .systemOrange, retention.spinAvailable),
            ("Crown Album", "\(retention.stickers.count)/\(AlbumSlot.allCases.count) pages", "openAlbum", .systemPurple, false),
            ("Story Chapters", retention.chapter.title, "openChapters", .systemCyan, false),
            ("Family Race", retention.familyCode.isEmpty ? "Make a 4-letter code" : "Code \(retention.familyCode)", "openFamily", .systemMint, false),
            ("Choose Character", selectedRunner.title, "openFriends", .systemYellow, false)
        ]
        if isLandscape {
            let cols = landscapeColumns()
            let rows = spacedYs(5, top: size.height * 0.70, bottom: size.height * 0.16)
            for (index, item) in playItems.enumerated() {
                let col = index % 2
                let row = index / 2
                addModalRow(title: item.0, detail: item.1, name: item.2, y: rows[row], accent: item.3, selected: item.4, x: col == 0 ? cols.left : cols.right, rowWidth: cols.width)
            }
            addModalCard(retention.activeGoalText(), y: rows[3], height: 36, fontSize: 12)
            addBackButton(y: rows[4])
        } else {
            addModalRow(title: "Daily Chest", detail: retention.giftAvailable ? "A gift is waiting" : retention.giftForToday().title, name: "openGift", y: size.height * 0.64, accent: .systemPink, selected: retention.giftAvailable)
            addModalRow(title: "Lucky Spin", detail: retention.spinAvailable ? "One spin today" : "Come back tomorrow", name: "openSpin", y: size.height * 0.575, accent: .systemOrange, selected: retention.spinAvailable)
            addModalRow(title: "Crown Album", detail: "\(retention.stickers.count)/\(AlbumSlot.allCases.count) pages", name: "openAlbum", y: size.height * 0.51, accent: .systemPurple, selected: false)
            addModalRow(title: "Story Chapters", detail: retention.chapter.title, name: "openChapters", y: size.height * 0.445, accent: .systemCyan, selected: false)
            addModalRow(title: "Family Race", detail: retention.familyCode.isEmpty ? "Make a 4-letter code" : "Code \(retention.familyCode)", name: "openFamily", y: size.height * 0.38, accent: .systemMint, selected: false)
            addModalRow(title: "Choose Character", detail: selectedRunner.title, name: "openFriends", y: size.height * 0.315, accent: .systemYellow, selected: false)
            addModalCard(retention.activeGoalText(), y: size.height * 0.25, height: 40, fontSize: 12)
            addBackButton(y: size.height * 0.16)
        }
    }

    private func showDailyGift() {
        mode = .gift
        player.isHidden = true
        updateHUDVisibility()
        updateBackground()
        menuLayer.removeAllChildren()
        addMenuSparkles()
        let gift = retention.giftForToday()
        addModalShell(title: "Daily Crown Chest", subtitle: "Day \(min(7, retention.loginStreak)) • Streak \(retention.loginStreak)", centerY: size.height * 0.50, height: isLandscape ? size.height * 0.86 : size.height * 0.56)
        let ys = spacedYs(5, top: size.height * (isLandscape ? 0.70 : 0.62), bottom: size.height * (isLandscape ? 0.18 : 0.20))
        addGiftCalendar(y: ys[0])
        addModalCard("\(gift.title)\n\(gift.blurb)", y: ys[1], height: isLandscape ? 56 : 80, fontSize: isLandscape ? 13 : 15, color: UIColor(red: 1, green: 0.86, blue: 0.42, alpha: 1))
        addModalCard(retention.pardonCharges > 0 ? "Royal Pardon ready — a missed day will not wipe your streak." : "Earn a Royal Pardon from the weekly chest.", y: ys[2], height: isLandscape ? 40 : 52, fontSize: 12)
        if retention.giftAvailable {
            addPrimaryMenuButton("Open Chest", name: "claimGift", y: ys[3])
        } else {
            addPrimaryMenuButton("Already opened", name: "back", y: ys[3])
        }
        addBackButton(y: ys[4])
    }

    private func showLuckySpin() {
        mode = .spin
        player.isHidden = true
        updateHUDVisibility()
        updateBackground()
        menuLayer.removeAllChildren()
        addMenuSparkles()
        addModalShell(title: "Lucky Spin", subtitle: "One free spin each day", centerY: size.height * 0.50, height: isLandscape ? size.height * 0.78 : size.height * 0.46)
        let ys = spacedYs(3, top: size.height * (isLandscape ? 0.58 : 0.52), bottom: size.height * (isLandscape ? 0.20 : 0.24))
        addModalCard(retention.spinAvailable ? "Tap spin for a royal surprise.\nNo extra cost." : "You already spun today.\nCome back tomorrow!", y: ys[0], height: isLandscape ? 56 : 80, fontSize: 15)
        if retention.spinAvailable {
            addPrimaryMenuButton("Spin", name: "doSpin", y: ys[1])
            addBackButton(y: ys[2])
        } else {
            addBackButton(y: ys[1])
        }
    }

    private func showAlbum() {
        mode = .album
        player.isHidden = true
        updateHUDVisibility()
        updateBackground()
        menuLayer.removeAllChildren()
        addMenuSparkles()
        addModalShell(title: "Crown Album", subtitle: "\(retention.stickers.count) collected", centerY: size.height * 0.50, height: isLandscape ? size.height * 0.86 : size.height * 0.68)
        let slots = AlbumSlot.allCases
        let cols = isLandscape ? 5 : 3
        let startY = size.height * (isLandscape ? 0.66 : 0.66)
        for (index, slot) in slots.enumerated() {
            let col = index % cols
            let row = index / cols
            let x = isLandscape
                ? size.width * (0.18 + CGFloat(col) * 0.16)
                : size.width * (0.24 + CGFloat(col) * 0.26)
            let y = startY - CGFloat(row) * (isLandscape ? 44 : 52)
            let owned = retention.has(slot)
            let chip = SKShapeNode(rectOf: CGSize(width: 92, height: 44), cornerRadius: 12)
            chip.fillColor = owned ? UIColor(red: 1.0, green: 0.42, blue: 0.72, alpha: 0.88) : UIColor(white: 0.12, alpha: 0.55)
            chip.strokeColor = owned ? UIColor.white.withAlphaComponent(0.8) : UIColor.white.withAlphaComponent(0.22)
            chip.lineWidth = 1.5
            chip.position = CGPoint(x: x, y: y)
            chip.zPosition = 2
            menuLayer.addChild(chip)
            let text = label(owned ? slot.title : "Empty", size: 9, weight: .bold)
            text.position = chip.position
            text.fontColor = owned ? .white : UIColor.white.withAlphaComponent(0.45)
            text.zPosition = 3
            menuLayer.addChild(text)
        }
        addBackButton(y: size.height * (isLandscape ? 0.16 : 0.14))
    }

    private func showFamily() {
        mode = .family
        player.isHidden = true
        updateHUDVisibility()
        updateBackground()
        menuLayer.removeAllChildren()
        addMenuSparkles()
        addModalShell(title: "Family Race", subtitle: "No chat • ghost race only", centerY: size.height * 0.50, height: isLandscape ? size.height * 0.82 : size.height * 0.58)
        let ys = spacedYs(4, top: size.height * (isLandscape ? 0.64 : 0.58), bottom: size.height * (isLandscape ? 0.20 : 0.24))
        let code = retention.familyCode.isEmpty ? "No code yet" : "Code \(retention.familyCode)"
        addModalCard("\(code)\nRunner \(retention.familyName)", y: ys[0], height: isLandscape ? 48 : 64, fontSize: 14)
        let board = retention.familyBoard.isEmpty
            ? "Finish a run to leave a ghost for family."
            : retention.familyBoard.prefix(3).map { "\($0.name)  \($0.score)" }.joined(separator: "\n")
        addModalCard(board, y: ys[1], height: isLandscape ? 52 : 72, fontSize: 13)
        addMenuButton("Make / Join Code", name: "familyCode", y: ys[2])
        addBackButton(y: ys[3])
    }

    private func showChapters() {
        mode = .chapters
        player.isHidden = true
        updateHUDVisibility()
        updateBackground()
        menuLayer.removeAllChildren()
        addMenuSparkles()
        addModalShell(title: "Story Chapters", subtitle: "Pick a royal destination", centerY: size.height * 0.50, height: isLandscape ? size.height * 0.86 : size.height * 0.60)
        let chapters = StoryChapter.allCases
        let ys = spacedYs(chapters.count + 1, top: size.height * (isLandscape ? 0.70 : 0.62), bottom: size.height * (isLandscape ? 0.18 : 0.22))
        for (index, chapter) in chapters.enumerated() {
            let open = retention.unlockedChapters.contains(chapter.rawValue)
            let active = retention.chapter == chapter
            let detail = active ? "Selected" : (open ? chapter.blurb : "Score \(chapter.unlockScore) to open")
            addModalRow(title: chapter.title, detail: detail, name: "chapter:\(chapter.rawValue)", y: ys[index], accent: active ? .systemYellow : .systemPink, selected: active)
        }
        addBackButton(y: ys[chapters.count])
    }

    private func showFriends() {
        showCharacterSelect()
    }

    private func showCharacterSelect() {
        mode = .friends
        player.isHidden = true
        updateHUDVisibility()
        updateBackground()
        menuLayer.removeAllChildren()
        addMenuSparkles()
        addModalShell(title: "Choose a Character", subtitle: selectedRunner.title, centerY: size.height * 0.50, height: isLandscape ? size.height * 0.90 : size.height * 0.78)

        let previewX = isLandscape ? size.width * 0.22 : size.width / 2
        let previewY = isLandscape ? size.height * 0.56 : size.height * 0.72
        let previewBack = SKShapeNode(rectOf: CGSize(width: isLandscape ? 78 : 92, height: isLandscape ? 78 : 92), cornerRadius: 22)
        previewBack.fillColor = selectedRunner.look.outfit.withAlphaComponent(0.28)
        previewBack.strokeColor = selectedRunner.look.accent
        previewBack.lineWidth = 2
        previewBack.position = CGPoint(x: previewX, y: previewY)
        previewBack.zPosition = 2
        menuLayer.addChild(previewBack)
        addCharacterPreview(runner: selectedRunner, at: CGPoint(x: previewX, y: previewY - (isLandscape ? 8 : 25)), scale: isLandscape ? 0.32 : 0.38)

        let outfitLine = label(selectedRunner.blurb, size: isLandscape ? 11 : 12, weight: .bold)
        outfitLine.position = CGPoint(x: isLandscape ? previewX : size.width / 2, y: isLandscape ? size.height * 0.32 : size.height * 0.635)
        outfitLine.fontColor = UIColor(red: 1.0, green: 0.86, blue: 0.94, alpha: 1)
        outfitLine.zPosition = 3
        menuLayer.addChild(outfitLine)

        let runners = FeaturedRunner.allCases
        let cols = 3
        let cardW = min(isLandscape ? 110 : 98, size.width * (isLandscape ? 0.18 : 0.28))
        let gridCenterX = isLandscape ? size.width * 0.66 : size.width / 2
        let startY = size.height * (isLandscape ? 0.68 : 0.56)
        for (index, runner) in runners.enumerated() {
            let col = index % cols
            let row = index / cols
            let x = gridCenterX + (CGFloat(col) - 1) * (cardW + 8)
            let y = startY - CGFloat(row) * (isLandscape ? 50 : 58)
            let active = selectedRunner == runner
            let card = SKShapeNode(rectOf: CGSize(width: cardW, height: 52), cornerRadius: 14)
            card.name = "friend:\(runner.rawValue)"
            card.fillColor = active ? runner.look.outfit.withAlphaComponent(0.90) : UIColor(white: 0.10, alpha: 0.62)
            card.strokeColor = active ? UIColor.white.withAlphaComponent(0.92) : UIColor.white.withAlphaComponent(0.20)
            card.lineWidth = active ? 2.4 : 1.4
            card.position = CGPoint(x: x, y: y)
            card.zPosition = 2
            menuLayer.addChild(card)
            let swatch = SKShapeNode(circleOfRadius: 8)
            swatch.fillColor = runner.look.skin
            swatch.strokeColor = runner.look.hair
            swatch.lineWidth = 2
            swatch.position = CGPoint(x: x, y: y + 10)
            swatch.zPosition = 3
            swatch.name = card.name
            menuLayer.addChild(swatch)
            let title = label(runner.shortTitle, size: 10, weight: .heavy)
            title.position = CGPoint(x: x, y: y - 12)
            title.fontColor = .white
            title.zPosition = 3
            title.name = card.name
            menuLayer.addChild(title)
        }
        addPrimaryMenuButton("Play as \(selectedRunner.shortTitle)", name: "playAs", y: size.height * (isLandscape ? 0.22 : 0.20), x: isLandscape ? gridCenterX : nil, compact: isLandscape)
        addBackButton(y: size.height * (isLandscape ? 0.10 : 0.12))
    }

    private func addCharacterPreview(runner: FeaturedRunner, at point: CGPoint, scale: CGFloat) {
        let look = paintedLook(for: runner)
        let rig = makePaintedRunnerRig(look: look, runner: runner) ?? makeStyledRunnerRig(look: look)
        rig.setScale(scale)
        rig.position = point
        rig.zPosition = 4
        menuLayer.addChild(rig)
        startCharacterSecondaryAnimation(on: rig)
        if !reducedMotion {
            rig.run(.repeatForever(.sequence([
                .moveBy(x: 0, y: 4, duration: 0.7),
                .moveBy(x: 0, y: -4, duration: 0.7)
            ])))
        }
    }

    private func showPause() {
        mode = .paused
        leftPressed = false
        rightPressed = false
        activeControlTouches.removeAll()
        updateControlButtonStates()
        updateHUDVisibility()
        menuLayer.removeAllChildren()
        addMenuSparkles()
        addModalShell(title: "Paused", subtitle: retention.gentleMode ? "Gentle Mode is on" : "Classic run", centerY: size.height * 0.50, height: isLandscape ? size.height * 0.76 : size.height * 0.46)
        let ys = spacedYs(3, top: size.height * (isLandscape ? 0.62 : 0.54), bottom: size.height * (isLandscape ? 0.24 : 0.32))
        addModalRow(title: "Gentle Mode", detail: retention.gentleMode ? "Softer hits • slower" : "Classic", name: "toggleGentle", y: ys[0], accent: .systemMint, selected: retention.gentleMode)
        addPrimaryMenuButton("Resume", name: "resume", y: ys[1])
        addMenuButton("Home", name: "home", y: ys[2])
    }

    private func spawnRecapConfetti() {
        guard !reducedMotion else { return }
        let colors: [UIColor] = [
            UIColor(red: 1.0, green: 0.42, blue: 0.72, alpha: 1),
            UIColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 1),
            UIColor(red: 0.62, green: 0.82, blue: 1.0, alpha: 1),
            UIColor(red: 0.72, green: 0.52, blue: 1.0, alpha: 1),
            .white
        ]
        for _ in 0..<28 {
            let piece = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 5...9), height: CGFloat.random(in: 8...14)), cornerRadius: 1.5)
            piece.fillColor = colors.randomElement() ?? .white
            piece.strokeColor = .clear
            piece.position = CGPoint(x: CGFloat.random(in: 20...size.width - 20), y: size.height * CGFloat.random(in: 0.62...0.92))
            piece.zPosition = 8
            piece.zRotation = CGFloat.random(in: -0.6...0.6)
            menuLayer.addChild(piece)
            piece.run(.sequence([
                .group([
                    .moveBy(x: CGFloat.random(in: -40...40), y: -size.height * 0.55, duration: Double.random(in: 1.1...1.8)),
                    .rotate(byAngle: CGFloat.random(in: -4...4), duration: 1.4),
                    .fadeOut(withDuration: 1.6)
                ]),
                .removeFromParent()
            ]))
        }
    }

    private func addGiftCalendar(y: CGFloat) {
        let spacing: CGFloat = 36
        let startX = size.width / 2 - spacing * 3
        for day in 1...7 {
            let filled = retention.loginStreak >= day
            let claimed = !retention.giftAvailable && filled
            let chip = SKShapeNode(circleOfRadius: 14)
            chip.fillColor = claimed
                ? UIColor(red: 1.0, green: 0.72, blue: 0.28, alpha: 1)
                : (filled ? UIColor(red: 1.0, green: 0.42, blue: 0.72, alpha: 0.92) : UIColor(white: 0.14, alpha: 0.55))
            chip.strokeColor = UIColor.white.withAlphaComponent(filled ? 0.85 : 0.28)
            chip.lineWidth = 1.6
            chip.position = CGPoint(x: startX + CGFloat(day - 1) * spacing, y: y)
            chip.zPosition = 2
            menuLayer.addChild(chip)
            let text = label("\(day)", size: 10, weight: .heavy)
            text.position = chip.position
            text.fontColor = filled ? .white : UIColor.white.withAlphaComponent(0.45)
            text.zPosition = 3
            menuLayer.addChild(text)
        }
    }

    private func addBackButton(y: CGFloat? = nil) {
        addMenuButton("Back", name: "back", y: y ?? size.height * 0.20)
    }
    
    private func showUpgrades() {
        mode = .upgrades
        player.isHidden = true
        updateBackground()
        menuLayer.removeAllChildren()
        addMenuSparkles()
        addModalShell(title: "Royal Upgrades", subtitle: "Coins \(totalCoins)", centerY: size.height * 0.50, height: isLandscape ? size.height * 0.80 : size.height * 0.50)
        let ys = spacedYs(4, top: size.height * (isLandscape ? 0.66 : 0.50), bottom: size.height * (isLandscape ? 0.20 : 0.25))
        addUpgradeButton(title: "Shield", level: shieldLevel, cost: upgradeCost(shieldLevel), name: "upgrade:shield", y: ys[0])
        addUpgradeButton(title: "Magnet", level: magnetLevel, cost: upgradeCost(magnetLevel), name: "upgrade:magnet", y: ys[1])
        addUpgradeButton(title: "Boost", level: boostLevel, cost: upgradeCost(boostLevel), name: "upgrade:boost", y: ys[2])
        addBackButton(y: ys[3])
    }
    
    private func addUpgradeButton(title: String, level: Int, cost: Int, name: String, y: CGFloat) {
        let detail = level >= 3 ? "Max level" : "Level \(level)   \(cost) coins"
        let accent: UIColor
        switch title {
        case "Shield": accent = UIColor.systemCyan
        case "Magnet": accent = UIColor.systemPink
        default: accent = UIColor.systemOrange
        }
        addModalRow(title: title, detail: detail, name: name, y: y, accent: accent, selected: level >= 3)
    }

    private func layoutMenu() {
        switch mode {
        case .menu:
            showMenu()
        case .gameOver:
            showGameOver()
        case .settings:
            showSettings()
        case .wardrobe:
            showWardrobe()
        case .missions:
            showMissions()
        case .upgrades:
            showUpgrades()
        case .tutorial:
            updateTutorial()
        case .playroom:
            showPlayroom()
        case .gift:
            showDailyGift()
        case .spin:
            showLuckySpin()
        case .album:
            showAlbum()
        case .family:
            showFamily()
        case .chapters:
            showChapters()
        case .friends:
            showCharacterSelect()
        case .paused:
            showPause()
        default:
            break
        }
    }

    private func layoutPlayer(animated: Bool) {
        let pos = CGPoint(x: playerX, y: groundY)
        if animated {
            player.run(.move(to: pos, duration: 0.12))
        } else {
            player.position = pos
        }
    }

    private func makeEnvironmentMarker() -> SKNode {
        let node = SKNode()
        node.userData = ["kind": "road"]
        let width = CGFloat.random(in: 64...112)
        
        let band = SKShapeNode(rectOf: CGSize(width: width, height: 8), cornerRadius: 4)
        band.fillColor = UIColor.black.withAlphaComponent(0.24)
        band.strokeColor = UIColor.white.withAlphaComponent(0.14)
        band.lineWidth = 1
        band.zPosition = 1
        node.addChild(band)
        
        let diamond = SKShapeNode(path: diamondPath(width: 16, height: 16))
        diamond.fillColor = UIColor(red: 1, green: 0.82, blue: 0.28, alpha: 0.42)
        diamond.strokeColor = UIColor.white.withAlphaComponent(0.18)
        diamond.lineWidth = 1
        diamond.zPosition = 2
        node.addChild(diamond)
        
        if Bool.random() {
            let petal = SKShapeNode(ellipseOf: CGSize(width: 8, height: 14))
            petal.fillColor = UIColor(red: 1, green: 0.38, blue: 0.70, alpha: 0.42)
            petal.strokeColor = .clear
            petal.position = CGPoint(x: CGFloat.random(in: -width * 0.42...width * 0.42), y: CGFloat.random(in: 10...32))
            petal.zRotation = CGFloat.random(in: -0.8...0.8)
            petal.zPosition = 3
            node.addChild(petal)
        }
        return node
    }

    private func makeSideScenery() -> SKNode {
        let node = SKNode()
        let column = SKShapeNode(rectOf: CGSize(width: 14, height: 58), cornerRadius: 5)
        column.fillColor = UIColor(red: 0.92, green: 0.78, blue: 0.42, alpha: 0.82)
        column.strokeColor = UIColor(red: 1.0, green: 0.90, blue: 0.55, alpha: 0.75)
        column.lineWidth = 1.4
        column.zPosition = 1
        node.addChild(column)
        
        let finial = SKShapeNode(circleOfRadius: 5)
        finial.fillColor = UIColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 0.95)
        finial.strokeColor = UIColor.white.withAlphaComponent(0.7)
        finial.lineWidth = 1
        finial.position = CGPoint(x: 0, y: 34)
        finial.zPosition = 2
        node.addChild(finial)
        
        let crystal = SKShapeNode(path: diamondPath(width: 22, height: 30))
        crystal.fillColor = UIColor(red: 0.45, green: 0.78, blue: 1.0, alpha: 0.78)
        crystal.strokeColor = UIColor.white.withAlphaComponent(0.72)
        crystal.lineWidth = 1.4
        crystal.position = CGPoint(x: 0, y: 48)
        crystal.zPosition = 3
        node.addChild(crystal)
        
        let rose = SKShapeNode(ellipseOf: CGSize(width: 22, height: 16))
        rose.fillColor = UIColor(red: 1.0, green: 0.42, blue: 0.72, alpha: 0.55)
        rose.strokeColor = UIColor(red: 1.0, green: 0.78, blue: 0.90, alpha: 0.45)
        rose.lineWidth = 1
        rose.position = CGPoint(x: -16, y: -8)
        rose.zPosition = 1
        node.addChild(rose)
        
        let glow = SKShapeNode(ellipseOf: CGSize(width: 38, height: 14))
        glow.fillColor = UIColor(red: 1, green: 0.42, blue: 0.72, alpha: 0.16)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: 0, y: -30)
        glow.zPosition = 0
        node.addChild(glow)
        return node
    }

    private func makeObstacle(kind: HazardKind) -> SKNode {
        switch kind {
        case .thorn:
            let node = SKNode()
            for i in 0..<4 {
                let thorn = SKShapeNode(path: trianglePath(width: 24, height: 76))
                thorn.fillColor = UIColor(red: 0.14, green: 0.48, blue: 0.2, alpha: 1)
                thorn.strokeColor = UIColor(red: 1, green: 0.68, blue: 0.84, alpha: 1)
                thorn.lineWidth = 2
                thorn.position = CGPoint(x: CGFloat(i) * 18 - 27, y: 0)
                node.addChild(thorn)
            }
            return node
        case .tide:
            let node = SKNode()
            let pool = SKShapeNode(ellipseOf: CGSize(width: 108, height: 40))
            pool.fillColor = UIColor(red: 0.04, green: 0.56, blue: 0.96, alpha: 0.9)
            pool.strokeColor = UIColor(red: 0.78, green: 0.95, blue: 1, alpha: 1)
            pool.lineWidth = 3
            node.addChild(pool)
            for x in stride(from: -34, through: 34, by: 22) {
                let crestPath = CGMutablePath()
                crestPath.move(to: CGPoint(x: CGFloat(x) - 9, y: 4))
                crestPath.addQuadCurve(to: CGPoint(x: CGFloat(x) + 9, y: 4), control: CGPoint(x: CGFloat(x), y: 16))
                let crest = SKShapeNode(path: crestPath)
                crest.strokeColor = .white.withAlphaComponent(0.82)
                crest.lineWidth = 3
                crest.lineCap = .round
                node.addChild(crest)
            }
            return node
        case .rock:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -30, y: -18))
            path.addLine(to: CGPoint(x: -18, y: 24))
            path.addLine(to: CGPoint(x: 12, y: 31))
            path.addLine(to: CGPoint(x: 32, y: 6))
            path.addLine(to: CGPoint(x: 22, y: -28))
            path.addLine(to: CGPoint(x: -10, y: -34))
            path.closeSubpath()
            let rock = SKShapeNode(path: path)
            rock.fillColor = UIColor(red: 0.33, green: 0.30, blue: 0.40, alpha: 1)
            rock.strokeColor = UIColor(red: 0.87, green: 0.68, blue: 0.38, alpha: 1)
            rock.lineWidth = 3
            let facet = SKShapeNode(path: {
                let p = CGMutablePath()
                p.move(to: CGPoint(x: -14, y: 18))
                p.addLine(to: CGPoint(x: 10, y: 28))
                p.addLine(to: CGPoint(x: 2, y: 2))
                p.closeSubpath()
                return p
            }())
            facet.fillColor = UIColor.white.withAlphaComponent(0.16)
            facet.strokeColor = .clear
            rock.addChild(facet)
            return rock
        case .beam:
            let node = SKNode()
            let glow = SKShapeNode(rectOf: CGSize(width: size.width * 0.72, height: 34), cornerRadius: 17)
            glow.fillColor = UIColor(red: 1, green: 0.70, blue: 0.18, alpha: 0.28)
            glow.strokeColor = .clear
            node.addChild(glow)
            let beam = SKShapeNode(rectOf: CGSize(width: size.width * 0.68, height: 16), cornerRadius: 8)
            beam.fillColor = UIColor(red: 1, green: 0.76, blue: 0.18, alpha: 0.92)
            beam.strokeColor = UIColor(red: 1, green: 0.96, blue: 0.64, alpha: 1)
            beam.lineWidth = 2
            node.addChild(beam)
            return node
        case .shadow:
            let node = SKNode()
            let vine = SKShapeNode(rectOf: CGSize(width: 18, height: 78), cornerRadius: 8)
            vine.fillColor = UIColor(red: 0.16, green: 0.22, blue: 0.38, alpha: 0.92)
            vine.strokeColor = UIColor(red: 0.72, green: 0.84, blue: 1.0, alpha: 0.9)
            vine.lineWidth = 2
            node.addChild(vine)
            let leaf = SKShapeNode(ellipseOf: CGSize(width: 28, height: 14))
            leaf.fillColor = UIColor(red: 0.42, green: 0.70, blue: 0.86, alpha: 0.88)
            leaf.strokeColor = .clear
            leaf.position = CGPoint(x: 16, y: 18)
            node.addChild(leaf)
            return node
        case .shell:
            let shell = SKShapeNode(ellipseOf: CGSize(width: 64, height: 40))
            shell.fillColor = UIColor(red: 1.0, green: 0.82, blue: 0.70, alpha: 1)
            shell.strokeColor = UIColor(red: 1.0, green: 0.94, blue: 0.86, alpha: 1)
            shell.lineWidth = 3
            let ridge = SKShapeNode(ellipseOf: CGSize(width: 36, height: 16))
            ridge.fillColor = UIColor(red: 1.0, green: 0.58, blue: 0.48, alpha: 0.55)
            ridge.strokeColor = .clear
            ridge.position = CGPoint(x: 0, y: 4)
            shell.addChild(ridge)
            return shell
        case .starBeam:
            let node = SKNode()
            let glow = SKShapeNode(rectOf: CGSize(width: size.width * 0.72, height: 34), cornerRadius: 17)
            glow.fillColor = UIColor(red: 0.72, green: 0.52, blue: 1.0, alpha: 0.28)
            glow.strokeColor = .clear
            node.addChild(glow)
            let beam = SKShapeNode(rectOf: CGSize(width: size.width * 0.68, height: 16), cornerRadius: 8)
            beam.fillColor = UIColor(red: 0.86, green: 0.70, blue: 1.0, alpha: 0.94)
            beam.strokeColor = UIColor(red: 1.0, green: 0.92, blue: 0.55, alpha: 1)
            beam.lineWidth = 2
            node.addChild(beam)
            return node
        case .shadowImp:
            return makeShadowImp()
        case .tideCrab:
            return makeTideCrab()
        case .starWisp:
            return makeStarWisp()
        }
    }

    private func makeRoyalFoeTag(_ text: String, color: UIColor) -> SKLabelNode {
        let tag = label(text, size: 8, weight: .heavy)
        tag.fontColor = color
        tag.position = CGPoint(x: 0, y: 36)
        tag.zPosition = 6
        return tag
    }

    /// POWER foe: Rose Bloom clears it.
    private func makeShadowImp() -> SKNode {
        let node = SKNode()
        let glow = SKShapeNode(ellipseOf: CGSize(width: 52, height: 22))
        glow.fillColor = UIColor(red: 0.42, green: 0.28, blue: 0.86, alpha: 0.28)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: 0, y: -6)
        node.addChild(glow)

        let body = SKShapeNode(ellipseOf: CGSize(width: 34, height: 40))
        body.fillColor = UIColor(red: 0.18, green: 0.10, blue: 0.34, alpha: 1)
        body.strokeColor = UIColor(red: 0.78, green: 0.62, blue: 1.0, alpha: 1)
        body.lineWidth = 2.2
        body.position = CGPoint(x: 0, y: 10)
        node.addChild(body)

        for x in [-8.0, 8.0] {
            let horn = SKShapeNode(path: trianglePath(width: 8, height: 12))
            horn.fillColor = UIColor(red: 0.62, green: 0.42, blue: 1.0, alpha: 1)
            horn.strokeColor = .clear
            horn.position = CGPoint(x: x, y: 32)
            node.addChild(horn)
        }

        let crown = SKShapeNode(path: crownPath())
        crown.fillColor = UIColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 1)
        crown.strokeColor = UIColor.white.withAlphaComponent(0.7)
        crown.lineWidth = 0.8
        crown.setScale(0.22)
        crown.position = CGPoint(x: 0, y: 38)
        node.addChild(crown)

        for x in [-6.0, 6.0] {
            let eye = SKShapeNode(circleOfRadius: 3.2)
            eye.fillColor = UIColor(red: 0.86, green: 0.72, blue: 1.0, alpha: 1)
            eye.strokeColor = .clear
            eye.position = CGPoint(x: x, y: 14)
            node.addChild(eye)
            let pupil = SKShapeNode(circleOfRadius: 1.3)
            pupil.fillColor = UIColor(red: 0.12, green: 0.04, blue: 0.22, alpha: 1)
            pupil.strokeColor = .clear
            pupil.position = CGPoint(x: x + 0.6, y: 13.6)
            node.addChild(pupil)
        }

        let smile = SKShapeNode(rectOf: CGSize(width: 8, height: 1.6), cornerRadius: 0.8)
        smile.fillColor = UIColor(red: 1.0, green: 0.62, blue: 0.86, alpha: 0.9)
        smile.strokeColor = .clear
        smile.position = CGPoint(x: 0, y: 7)
        node.addChild(smile)

        for x in [-8.0, 8.0] {
            let foot = SKShapeNode(ellipseOf: CGSize(width: 10, height: 6))
            foot.fillColor = UIColor(red: 0.28, green: 0.16, blue: 0.48, alpha: 1)
            foot.strokeColor = .clear
            foot.position = CGPoint(x: x, y: -10)
            node.addChild(foot)
        }

        node.addChild(makeRoyalFoeTag("Imp", color: UIColor(red: 0.86, green: 0.74, blue: 1.0, alpha: 1)))
        return node
    }

    /// JUMP foe: hop over the crab.
    private func makeTideCrab() -> SKNode {
        let node = SKNode()
        let glow = SKShapeNode(ellipseOf: CGSize(width: 64, height: 18))
        glow.fillColor = UIColor(red: 0.18, green: 0.72, blue: 0.86, alpha: 0.22)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: 0, y: -12)
        node.addChild(glow)

        let shell = SKShapeNode(ellipseOf: CGSize(width: 52, height: 30))
        shell.fillColor = UIColor(red: 0.22, green: 0.72, blue: 0.78, alpha: 1)
        shell.strokeColor = UIColor(red: 1.0, green: 0.92, blue: 0.62, alpha: 1)
        shell.lineWidth = 2.4
        shell.position = CGPoint(x: 0, y: 4)
        node.addChild(shell)

        let ridge = SKShapeNode(ellipseOf: CGSize(width: 28, height: 10))
        ridge.fillColor = UIColor(red: 1.0, green: 0.82, blue: 0.38, alpha: 0.55)
        ridge.strokeColor = .clear
        ridge.position = CGPoint(x: 0, y: 8)
        node.addChild(ridge)

        for x in [-26.0, 26.0] {
            let claw = SKShapeNode(ellipseOf: CGSize(width: 16, height: 12))
            claw.fillColor = UIColor(red: 1.0, green: 0.72, blue: 0.42, alpha: 1)
            claw.strokeColor = UIColor(red: 1.0, green: 0.92, blue: 0.70, alpha: 1)
            claw.lineWidth = 1.4
            claw.position = CGPoint(x: x, y: 6)
            node.addChild(claw)
        }

        for x in [-6.0, 6.0] {
            let eye = SKShapeNode(circleOfRadius: 3.4)
            eye.fillColor = .white
            eye.strokeColor = .clear
            eye.position = CGPoint(x: x, y: 14)
            node.addChild(eye)
            let pupil = SKShapeNode(circleOfRadius: 1.4)
            pupil.fillColor = UIColor(red: 0.10, green: 0.22, blue: 0.28, alpha: 1)
            pupil.strokeColor = .clear
            pupil.position = CGPoint(x: x + 0.5, y: 13.6)
            node.addChild(pupil)
        }

        let crown = SKShapeNode(path: crownPath())
        crown.fillColor = UIColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 1)
        crown.setScale(0.18)
        crown.position = CGPoint(x: 0, y: 22)
        node.addChild(crown)

        node.addChild(makeRoyalFoeTag("Crab", color: UIColor(red: 0.62, green: 0.96, blue: 0.92, alpha: 1)))
        return node
    }

    /// DUCK foe: float at head height so a crouch slips under.
    private func makeStarWisp() -> SKNode {
        let node = SKNode()
        let glow = SKShapeNode(circleOfRadius: 28)
        glow.fillColor = UIColor(red: 1.0, green: 0.82, blue: 0.38, alpha: 0.22)
        glow.strokeColor = .clear
        node.addChild(glow)

        let core = SKShapeNode(path: diamondPath(width: 28, height: 36))
        core.fillColor = UIColor(red: 1.0, green: 0.86, blue: 0.42, alpha: 1)
        core.strokeColor = UIColor(red: 1.0, green: 0.96, blue: 0.78, alpha: 1)
        core.lineWidth = 2
        node.addChild(core)

        let inner = SKShapeNode(path: diamondPath(width: 12, height: 16))
        inner.fillColor = UIColor(red: 0.86, green: 0.62, blue: 1.0, alpha: 0.88)
        inner.strokeColor = .clear
        node.addChild(inner)

        for x in [-5.0, 5.0] {
            let eye = SKShapeNode(circleOfRadius: 2.2)
            eye.fillColor = UIColor(red: 0.28, green: 0.12, blue: 0.42, alpha: 1)
            eye.strokeColor = .clear
            eye.position = CGPoint(x: x, y: 3)
            node.addChild(eye)
        }

        let spark = SKShapeNode(circleOfRadius: 3)
        spark.fillColor = .white
        spark.strokeColor = .clear
        spark.position = CGPoint(x: -7, y: 10)
        node.addChild(spark)

        node.addChild(makeRoyalFoeTag("Wisp", color: UIColor(red: 1.0, green: 0.92, blue: 0.62, alpha: 1)))
        return node
    }

    private func makeCoin(risky: Bool) -> SKNode {
        let root = SKNode()
        let radius: CGFloat = risky ? 15 : 12

        let disc = SKShapeNode(circleOfRadius: radius)
        disc.fillColor = risky
            ? UIColor(red: 1.0, green: 0.58, blue: 0.18, alpha: 1)
            : UIColor(red: 1.0, green: 0.84, blue: 0.26, alpha: 1)
        disc.strokeColor = UIColor(red: 1.0, green: 0.97, blue: 0.72, alpha: 1)
        disc.lineWidth = risky ? 3 : 2.2
        root.addChild(disc)

        let rim = SKShapeNode(circleOfRadius: radius - 3.2)
        rim.fillColor = .clear
        rim.strokeColor = UIColor(red: 0.72, green: 0.42, blue: 0.08, alpha: 0.55)
        rim.lineWidth = 1.4
        root.addChild(rim)

        let letter = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        letter.text = "A"
        letter.fontSize = risky ? 15 : 13
        letter.fontColor = UIColor(red: 0.55, green: 0.28, blue: 0.04, alpha: 1)
        letter.verticalAlignmentMode = .center
        letter.horizontalAlignmentMode = .center
        letter.position = CGPoint(x: 0, y: -0.5)
        letter.zPosition = 2
        root.addChild(letter)

        let shine = SKShapeNode(ellipseOf: CGSize(width: radius * 0.55, height: radius * 0.28))
        shine.fillColor = UIColor.white.withAlphaComponent(0.35)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -radius * 0.22, y: radius * 0.35)
        shine.zPosition = 3
        root.addChild(shine)
        return root
    }
    
    private func makeRoyalGem() -> SKNode {
        let node = SKNode()
        let halo = SKShapeNode(circleOfRadius: 28)
        halo.fillColor = UIColor(red: 1.0, green: 0.26, blue: 0.68, alpha: 0.20)
        halo.strokeColor = UIColor(red: 1.0, green: 0.76, blue: 0.92, alpha: 0.72)
        halo.lineWidth = 2
        node.addChild(halo)
        
        let gem = SKShapeNode(path: diamondPath(width: 34, height: 44))
        switch retention.chapter {
        case .gardens: gem.fillColor = UIColor(red: 0.62, green: 0.42, blue: 0.92, alpha: 1)
        case .ocean: gem.fillColor = UIColor(red: 0.32, green: 0.82, blue: 0.92, alpha: 1)
        case .palace: gem.fillColor = UIColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 1)
        case .courtyard: gem.fillColor = UIColor(red: 1.0, green: 0.28, blue: 0.74, alpha: 1)
        }
        gem.strokeColor = UIColor.white.withAlphaComponent(0.92)
        gem.lineWidth = 2.5
        gem.zPosition = 2
        node.addChild(gem)
        
        let shine = SKShapeNode(path: diamondPath(width: 13, height: 18))
        shine.fillColor = UIColor.white.withAlphaComponent(0.42)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -5, y: 7)
        shine.zPosition = 3
        node.addChild(shine)
        
        let crown = SKShapeNode(path: crownPath())
        crown.fillColor = UIColor(red: 1, green: 0.82, blue: 0.26, alpha: 1)
        crown.strokeColor = UIColor.white.withAlphaComponent(0.75)
        crown.lineWidth = 1
        crown.setScale(0.30)
        crown.position = CGPoint(x: 0, y: 29)
        crown.zPosition = 4
        node.addChild(crown)
        return node
    }

    private func makeKofiFriend() -> SKNode {
        let node = SKNode()
        let halo = SKShapeNode(circleOfRadius: 26)
        halo.fillColor = UIColor(red: 0.28, green: 0.62, blue: 1.0, alpha: 0.22)
        halo.strokeColor = UIColor(red: 0.72, green: 0.88, blue: 1.0, alpha: 0.8)
        halo.lineWidth = 2
        node.addChild(halo)
        let body = SKShapeNode(ellipseOf: CGSize(width: 28, height: 36))
        body.fillColor = UIColor(red: 0.22, green: 0.48, blue: 0.92, alpha: 1)
        body.strokeColor = UIColor.white.withAlphaComponent(0.8)
        body.lineWidth = 1.6
        body.position = CGPoint(x: 0, y: -4)
        node.addChild(body)
        let head = SKShapeNode(circleOfRadius: 11)
        head.fillColor = UIColor(red: 0.86, green: 0.64, blue: 0.42, alpha: 1)
        head.strokeColor = UIColor.white.withAlphaComponent(0.7)
        head.lineWidth = 1.2
        head.position = CGPoint(x: 0, y: 18)
        node.addChild(head)
        let mark = label("K", size: 11, weight: .heavy)
        mark.position = CGPoint(x: 0, y: -6)
        mark.fontColor = .white
        mark.zPosition = 2
        node.addChild(mark)
        return node
    }
    
    private func makePowerUp(kind: PowerUpKind) -> SKNode {
        let node = SKNode()
        let halo = SKShapeNode(circleOfRadius: 20)
        halo.fillColor = powerUpColor(kind).withAlphaComponent(0.24)
        halo.strokeColor = powerUpColor(kind).withAlphaComponent(0.78)
        halo.lineWidth = 3
        node.addChild(halo)
        
        let icon = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        icon.text = powerUpIcon(kind)
        icon.fontSize = 18
        icon.fontColor = .white
        icon.verticalAlignmentMode = .center
        icon.horizontalAlignmentMode = .center
        icon.position = CGPoint(x: 0, y: -1)
        node.addChild(icon)
        return node
    }
    
    private func powerUpIcon(_ kind: PowerUpKind) -> String {
        switch kind {
        case .shield: return "S"
        case .magnet: return "M"
        case .boost: return "B"
        case .revive: return "+"
        }
    }
    
    private func powerUpColor(_ kind: PowerUpKind) -> UIColor {
        switch kind {
        case .shield: return .systemCyan
        case .magnet: return .systemPink
        case .boost: return .systemOrange
        case .revive: return .systemGreen
        }
    }

    private func message(_ text: String) {
        messageLabel.text = text
        messageLabel.removeAllActions()
        messageLabel.alpha = 0
        messageLabel.run(.sequence([.fadeIn(withDuration: 0.08), .wait(forDuration: 0.55), .fadeOut(withDuration: 0.18)]))
    }

    private func sparkle(at point: CGPoint, color: UIColor) {
        let count = reducedMotion ? 3 : 10
        for _ in 0..<count {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            dot.fillColor = color
            dot.strokeColor = .clear
            dot.position = point
            dot.zPosition = 60
            fxLayer.addChild(dot)
            let dx = CGFloat.random(in: -46...46)
            let dy = CGFloat.random(in: -24...62)
            dot.run(.sequence([.group([.moveBy(x: dx, y: dy, duration: 0.38), .fadeOut(withDuration: 0.38)]), .removeFromParent()]))
        }
    }
    
    private func landingDust() {
        guard !reducedMotion else { return }
        for index in 0..<8 {
            let dust = SKShapeNode(ellipseOf: CGSize(width: CGFloat.random(in: 7...14), height: CGFloat.random(in: 3...7)))
            dust.fillColor = UIColor(red: 1.0, green: 0.58, blue: 0.82, alpha: 0.36)
            dust.strokeColor = .clear
            dust.position = CGPoint(x: player.position.x - 4, y: groundY + CGFloat.random(in: 3...12))
            dust.zPosition = 20
            fxLayer.addChild(dust)
            let dx = CGFloat(index - 3) * CGFloat.random(in: 8...16)
            dust.run(.sequence([
                .group([
                    .moveBy(x: dx, y: CGFloat.random(in: 4...18), duration: 0.26),
                    .fadeOut(withDuration: 0.26),
                    .scale(to: 1.45, duration: 0.26)
                ]),
                .removeFromParent()
            ]))
        }
    }
    
    private func cameraShake(amount: CGFloat, duration: TimeInterval) {
        guard !reducedMotion else { return }
        let shakes = max(2, Int(duration / 0.035))
        var actions: [SKAction] = []
        for _ in 0..<shakes {
            actions.append(.moveBy(x: CGFloat.random(in: -amount...amount), y: CGFloat.random(in: -amount...amount), duration: 0.018))
            actions.append(.moveBy(x: CGFloat.random(in: -amount...amount), y: CGFloat.random(in: -amount...amount), duration: 0.018))
        }
        actions.append(.move(to: .zero, duration: 0.035))
        world.removeAction(forKey: "shake")
        world.run(.sequence(actions), withKey: "shake")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mode == .running {
            if let touch = touches.first, pauseButton.calculateAccumulatedFrame().contains(touch.location(in: self)) {
                showPause()
                return
            }
            for touch in touches {
                beginGameplayControl(touch)
            }
            return
        }
        guard let touch = touches.first else { return }
        handleTouch(at: touch.location(in: self), tapCount: touch.tapCount)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mode == .running {
            for touch in touches {
                updateGameplayControl(touch)
            }
            return
        }
        guard let touch = touches.first else { return }
        let now = touch.location(in: self)
        let prev = touch.previousLocation(in: self)
        let dx = now.x - prev.x
        if abs(dx) > 42 {
            if abs(dx) > abs(now.y - prev.y) {
                shiftLane(dx < 0 ? -1 : 1)
            }
        }
        let dy = now.y - prev.y
        if abs(dy) > 42, abs(dy) > abs(dx) {
            if dy > 0 {
                jump()
            } else {
                duck()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            endGameplayControl(touch)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            endGameplayControl(touch)
        }
    }
    
    private func beginGameplayControl(_ touch: UITouch) {
        let point = touch.location(in: self)
        guard let input = controlInput(at: point) else {
            jump()
            return
        }
        activeControlTouches[ObjectIdentifier(touch)] = input
        setControl(input, pressed: true)
        switch input {
        case .jump:
            jump()
        case .duck:
            duck()
        case .power:
            cyclePower()
        case .left, .right:
            break
        }
    }
    
    private func updateGameplayControl(_ touch: UITouch) {
        let id = ObjectIdentifier(touch)
        let point = touch.location(in: self)
        let next = controlInput(at: point)
        if activeControlTouches[id] == next { return }
        if let previous = activeControlTouches[id] {
            setControl(previous, pressed: false)
        }
        activeControlTouches[id] = next
        if let next {
            setControl(next, pressed: true)
        }
    }
    
    private func endGameplayControl(_ touch: UITouch) {
        let id = ObjectIdentifier(touch)
        if let input = activeControlTouches.removeValue(forKey: id) {
            setControl(input, pressed: false)
        }
    }
    
    private func setControl(_ input: ControlInput, pressed: Bool) {
        switch input {
        case .left:
            leftPressed = pressed
        case .right:
            rightPressed = pressed
        case .jump:
            jumpControl.alpha = pressed ? 0.72 : 1
        case .duck:
            duckHeld = pressed
            duckControl.alpha = pressed ? 0.72 : 1
        case .power:
            powerControl.alpha = pressed ? 0.72 : 1
        }
        updateControlButtonStates()
    }
    
    private func updateControlButtonStates() {
        leftControl.alpha = leftPressed ? 0.72 : 1
        rightControl.alpha = rightPressed ? 0.72 : 1
    }
    
    private func controlInput(at point: CGPoint) -> ControlInput? {
        if leftControl.calculateAccumulatedFrame().contains(point) { return .left }
        if rightControl.calculateAccumulatedFrame().contains(point) { return .right }
        if jumpControl.calculateAccumulatedFrame().contains(point) { return .jump }
        if duckControl.calculateAccumulatedFrame().contains(point) { return .duck }
        if powerControl.calculateAccumulatedFrame().contains(point) { return .power }
        return nil
    }

    private func handleTouch(at point: CGPoint, tapCount: Int = 1) {
        switch mode {
        case .splash:
            menuLayer.removeAction(forKey: "splashTransition")
            menuLayer.alpha = 1
            showMenu()
        case .menu:
            let nodes = self.nodes(at: point)
            if nodes.contains(where: { $0.name == "tutorial" }) {
                showTutorial()
            } else if nodes.contains(where: { $0.name == "settings" }) {
                showSettings()
            } else if nodes.contains(where: { $0.name == "wardrobe" }) {
                showWardrobe()
            } else if nodes.contains(where: { $0.name == "missions" }) {
                showMissions()
            } else if nodes.contains(where: { $0.name == "upgrades" }) {
                showUpgrades()
            } else if nodes.contains(where: { $0.name == "playroom" }) {
                showPlayroom()
            } else if nodes.contains(where: { $0.name == "characters" }) {
                characterSelectFromPlayroom = false
                showCharacterSelect()
            } else if nodes.contains(where: { $0.name == "openGift" }) {
                showDailyGift()
            } else if !tutorialSeen {
                showTutorial()
            } else {
                startRun()
            }
        case .gameOver:
            let nodes = self.nodes(at: point)
            if nodes.contains(where: { $0.name == "restart" }) {
                startRun()
            } else if nodes.contains(where: { $0.name == "postcard" }) {
                sharePostcard()
            } else {
                showMenu()
            }
        case .tutorial:
            tutorialStep += 1
            if tutorialStep >= 4 {
                tutorialSeen = true
                UserDefaults.standard.set(true, forKey: "crownDash.tutorialSeen")
                tutorialLabel.alpha = 0
                startRun()
            } else {
                updateTutorial()
            }
        case .settings:
            let nodes = self.nodes(at: point)
            if nodes.contains(where: { $0.name == "toggleSound" }) {
                soundEnabled.toggle()
                UserDefaults.standard.set(soundEnabled, forKey: "crownDash.soundEnabled")
                showSettings()
            } else if nodes.contains(where: { $0.name == "toggleHaptics" }) {
                hapticsEnabled.toggle()
                UserDefaults.standard.set(hapticsEnabled, forKey: "crownDash.hapticsEnabled")
                showSettings()
            } else if nodes.contains(where: { $0.name == "toggleMotion" }) {
                reducedMotion.toggle()
                UserDefaults.standard.set(reducedMotion, forKey: "crownDash.reducedMotion")
                buildPlayer()
                showSettings()
            } else if nodes.contains(where: { $0.name == "toggleGentle" }) {
                retention.gentleMode.toggle()
                retention.save()
                showSettings()
            } else if nodes.contains(where: { $0.name == "tutorial" }) {
                showTutorial()
            } else if nodes.contains(where: { $0.name == "back" }) {
                showMenu()
            }
        case .wardrobe:
            let nodes = self.nodes(at: point)
            if nodes.contains(where: { $0.name == "back" }) {
                showMenu()
                return
            }
            if let outfitNode = nodes.first(where: { $0.name?.hasPrefix("outfit:") == true }),
               let value = outfitNode.name?.replacingOccurrences(of: "outfit:", with: ""),
               let outfit = Outfit(rawValue: value) {
                selectOrUnlock(outfit)
                showWardrobe()
            }
        case .missions:
            if self.nodes(at: point).contains(where: { $0.name == "back" }) {
                showMenu()
            }
        case .upgrades:
            let nodes = self.nodes(at: point)
            if nodes.contains(where: { $0.name == "back" }) {
                showMenu()
            } else if let upgrade = nodes.first(where: { $0.name?.hasPrefix("upgrade:") == true })?.name?.replacingOccurrences(of: "upgrade:", with: "") {
                buyUpgrade(upgrade)
                showUpgrades()
            }
        case .playroom:
            let nodes = self.nodes(at: point)
            if nodes.contains(where: { $0.name == "openGift" }) {
                showDailyGift()
            } else if nodes.contains(where: { $0.name == "openSpin" }) {
                showLuckySpin()
            } else if nodes.contains(where: { $0.name == "openAlbum" }) {
                showAlbum()
            } else if nodes.contains(where: { $0.name == "openChapters" }) {
                showChapters()
            } else if nodes.contains(where: { $0.name == "openFamily" }) {
                showFamily()
            } else if nodes.contains(where: { $0.name == "openFriends" }) {
                characterSelectFromPlayroom = true
                showCharacterSelect()
            } else if nodes.contains(where: { $0.name == "back" }) {
                showMenu()
            }
        case .gift:
            let nodes = self.nodes(at: point)
            if nodes.contains(where: { $0.name == "claimGift" }) {
                let gift = retention.claimGift()
                flushBankCoins()
                message(gift.title)
                feedback(.heavy)
                showDailyGift()
            } else if nodes.contains(where: { $0.name == "back" }) {
                showMenu()
            }
        case .spin:
            let nodes = self.nodes(at: point)
            if nodes.contains(where: { $0.name == "doSpin" }) {
                let prize = retention.spin()
                flushBankCoins()
                message(prize)
                feedback(.heavy)
                showLuckySpin()
            } else if nodes.contains(where: { $0.name == "back" }) {
                showPlayroom()
            }
        case .album:
            if self.nodes(at: point).contains(where: { $0.name == "back" }) {
                showPlayroom()
            }
        case .family:
            let nodes = self.nodes(at: point)
            if nodes.contains(where: { $0.name == "familyCode" }) {
                promptFamilyCode()
            } else if nodes.contains(where: { $0.name == "back" }) {
                showPlayroom()
            }
        case .chapters:
            let nodes = self.nodes(at: point)
            if nodes.contains(where: { $0.name == "back" }) {
                showPlayroom()
            } else if let raw = nodes.first(where: { $0.name?.hasPrefix("chapter:") == true })?.name?.replacingOccurrences(of: "chapter:", with: ""),
                      let value = Int(raw),
                      let chapter = StoryChapter(rawValue: value) {
                if retention.unlockedChapters.contains(value) {
                    retention.setChapter(chapter)
                    currentZone = startingZone(for: chapter)
                    updateBackground()
                    message(chapter.title)
                } else {
                    message("Score \(chapter.unlockScore) to open")
                }
                showChapters()
            }
        case .friends:
            let nodes = self.nodes(at: point)
            if nodes.contains(where: { $0.name == "back" }) {
                if characterSelectFromPlayroom {
                    showPlayroom()
                } else {
                    showMenu()
                }
            } else if nodes.contains(where: { $0.name == "playAs" }) {
                startRun()
            } else if let raw = nodes.first(where: { $0.name?.hasPrefix("friend:") == true })?.name?.replacingOccurrences(of: "friend:", with: ""),
                      let runner = FeaturedRunner(rawValue: raw) {
                retention.selectRunner(runner)
                buildPlayer()
                message(runner.title)
                showCharacterSelect()
            }
        case .paused:
            let nodes = self.nodes(at: point)
            if nodes.contains(where: { $0.name == "toggleGentle" }) {
                retention.gentleMode.toggle()
                retention.save()
                showPause()
            } else if nodes.contains(where: { $0.name == "home" }) {
                endRun()
            } else {
                lastUpdateTime = 0
                menuLayer.removeAllChildren()
                mode = .running
                updateHUDVisibility()
                message("Run resumed")
            }
        case .running:
            if point.y > size.height * 0.72 {
                cyclePower()
            } else if tapCount > 1 {
                dash()
            } else if point.y < size.height * 0.28 {
                duck()
            } else {
                jump()
            }
        }
    }

    private func laneX(_ lane: Int) -> CGFloat {
        let left = (size.width - pathWidth) / 2
        return left + pathWidth * (CGFloat(lane) + 1) / 4
    }

    private var powerColor: UIColor {
        switch power {
        case .bloom: return UIColor(red: 1, green: 0.38, blue: 0.74, alpha: 1)
        case .tide: return UIColor(red: 0.12, green: 0.72, blue: 1, alpha: 1)
        case .star: return UIColor(red: 1, green: 0.86, blue: 0.32, alpha: 1)
        }
    }
    
    private func updateZone() {
        let next: Zone
        switch retention.chapter {
        case .gardens:
            next = .moonlitGardens
        case .ocean:
            next = .oceanGate
        case .palace:
            next = .starPalace
        case .courtyard:
            switch score {
            case 0..<650: next = .courtyard
            case 650..<1300: next = .roseGarden
            case 1300..<2200: next = .crystalBridge
            default: next = .ballroom
            }
        }
        guard next != currentZone else { return }
        currentZone = next
        updateBackground()
        message(next.rawValue)
    }
    
    private func activeMissionText() -> String {
        if let goal = retention.dailyGoals.first(where: { !$0.done }) {
            return "\(goal.title)\n\(goal.progress)/\(goal.target)"
        }
        guard let mission = missions.first(where: { !$0.completed }) else {
            return "All of today's goals are done!"
        }
        return "\(mission.kind.rawValue)\n\(min(mission.progress, mission.target))/\(mission.target)"
    }
    
    private func trackMission(_ kind: MissionKind, amount: Int) {
        guard let index = missions.firstIndex(where: { $0.kind == kind }) else { return }
        missions[index].progress += amount
        if missions[index].completed, !completedMissionKinds.contains(kind) {
            completedMissionKinds.insert(kind)
            message("Mission complete")
            feedback(.heavy)
        }
    }
    
    private func claimMissionRewards() -> Int {
        missions.reduce(0) { total, mission in
            total + (mission.completed ? mission.reward : 0)
        }
    }
    
    private func selectOrUnlock(_ outfit: Outfit) {
        if unlockedOutfits.contains(outfit.rawValue) {
            selectedOutfit = outfit
            UserDefaults.standard.set(outfit.rawValue, forKey: "crownDash.selectedOutfit")
            if let extra = extraOutfit(for: outfit) {
                retention.selectExtra(extra)
            } else {
                retention.selectExtra(nil)
            }
            retention.unlock(outfit.albumSlot)
            buildPlayer()
            feedback(.medium)
            return
        }
        guard totalCoins >= outfit.cost else {
            message("Need \(outfit.cost) coins")
            feedback(.light)
            return
        }
        totalCoins -= outfit.cost
        unlockedOutfits.insert(outfit.rawValue)
        selectedOutfit = outfit
        if let extra = extraOutfit(for: outfit) {
            retention.buyExtra(extra)
            retention.selectExtra(extra)
        }
        retention.unlock(outfit.albumSlot)
        UserDefaults.standard.set(totalCoins, forKey: "crownDash.totalCoins")
        UserDefaults.standard.set(Array(unlockedOutfits), forKey: "crownDash.unlockedOutfits")
        UserDefaults.standard.set(outfit.rawValue, forKey: "crownDash.selectedOutfit")
        buildPlayer()
        feedback(.heavy)
    }

    private func extraOutfit(for outfit: Outfit) -> ExtraOutfit? {
        switch outfit {
        case .ballgown: return .ballgown
        case .winter: return .winter
        case .starlight: return .starlight
        default: return nil
        }
    }

    private func syncOutfitsFromRetention() {
        for extra in ExtraOutfit.allCases where retention.ownExtra(extra) {
            switch extra {
            case .ballgown: unlockedOutfits.insert(Outfit.ballgown.rawValue)
            case .winter: unlockedOutfits.insert(Outfit.winter.rawValue)
            case .starlight: unlockedOutfits.insert(Outfit.starlight.rawValue)
            }
        }
        switch ExtraOutfit(rawValue: retention.selectedExtraOutfit) {
        case .ballgown: selectedOutfit = .ballgown
        case .winter: selectedOutfit = .winter
        case .starlight: selectedOutfit = .starlight
        default: break
        }
    }

    private func flushBankCoins() {
        let extra = retention.takePendingBankCoins()
        guard extra > 0 else { return }
        totalCoins += extra
        UserDefaults.standard.set(totalCoins, forKey: "crownDash.totalCoins")
    }
    
    private func upgradeCost(_ level: Int) -> Int {
        [60, 120, 220][min(level, 2)]
    }
    
    private func buyUpgrade(_ key: String) {
        let current: Int
        switch key {
        case "shield": current = shieldLevel
        case "magnet": current = magnetLevel
        case "boost": current = boostLevel
        default: return
        }
        guard current < 3 else {
            message("Upgrade maxed")
            return
        }
        let cost = upgradeCost(current)
        guard totalCoins >= cost else {
            message("Need \(cost) coins")
            feedback(.light)
            return
        }
        totalCoins -= cost
        switch key {
        case "shield":
            shieldLevel += 1
            UserDefaults.standard.set(shieldLevel, forKey: "crownDash.upgrade.shield")
        case "magnet":
            magnetLevel += 1
            UserDefaults.standard.set(magnetLevel, forKey: "crownDash.upgrade.magnet")
        case "boost":
            boostLevel += 1
            UserDefaults.standard.set(boostLevel, forKey: "crownDash.upgrade.boost")
        default:
            break
        }
        UserDefaults.standard.set(totalCoins, forKey: "crownDash.totalCoins")
        feedback(.heavy)
        message("Upgrade unlocked")
    }
    
    private func feedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard hapticsEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    private func playCue(_ soundID: SystemSoundID) {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(soundID)
    }

    private func label(_ text: String, size: CGFloat, weight: UIFont.Weight) -> SKLabelNode {
        let node = SKLabelNode(fontNamed: weight == .heavy ? "AvenirNext-Heavy" : "AvenirNext-Bold")
        node.text = text
        node.fontSize = size
        node.fontColor = .white
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .center
        node.numberOfLines = 2
        node.preferredMaxLayoutWidth = self.size.width * 0.86
        return node
    }

    private func starPath(radius: CGFloat, innerRadius: CGFloat, points: Int) -> CGPath {
        let path = CGMutablePath()
        for i in 0..<(points * 2) {
            let angle = -CGFloat.pi / 2 + CGFloat(i) * CGFloat.pi / CGFloat(points)
            let r = i.isMultiple(of: 2) ? radius : innerRadius
            let point = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }

    private func crownPath() -> CGPath {
        // Tall pointed crown — reads as royal identity at runner speed.
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -24, y: -12))
        path.addLine(to: CGPoint(x: -20, y: 10))
        path.addLine(to: CGPoint(x: -11, y: -2))
        path.addLine(to: CGPoint(x: 0, y: 18))
        path.addLine(to: CGPoint(x: 11, y: -2))
        path.addLine(to: CGPoint(x: 20, y: 10))
        path.addLine(to: CGPoint(x: 24, y: -12))
        path.addLine(to: CGPoint(x: 17, y: -18))
        path.addLine(to: CGPoint(x: -17, y: -18))
        path.closeSubpath()
        return path
    }

    private func sideCapePath() -> CGPath {
        // Longer trailing cape for motion silhouette (left when facing right).
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 8, y: 42))
        path.addQuadCurve(to: CGPoint(x: -30, y: 24), control: CGPoint(x: -10, y: 46))
        path.addQuadCurve(to: CGPoint(x: -36, y: -28), control: CGPoint(x: -42, y: 2))
        path.addQuadCurve(to: CGPoint(x: -6, y: -20), control: CGPoint(x: -18, y: -32))
        path.addQuadCurve(to: CGPoint(x: 12, y: 30), control: CGPoint(x: 12, y: 0))
        path.closeSubpath()
        return path
    }

    private func sideDressPath() -> CGPath {
        // Fuller A-line skirt that covers hips so only shins/sneakers read under the hem.
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -11, y: 54))
        path.addQuadCurve(to: CGPoint(x: 15, y: 52), control: CGPoint(x: 2, y: 60))
        path.addQuadCurve(to: CGPoint(x: 30, y: 12), control: CGPoint(x: 28, y: 34))
        path.addQuadCurve(to: CGPoint(x: -24, y: 12), control: CGPoint(x: 3, y: 4))
        path.addQuadCurve(to: CGPoint(x: -11, y: 54), control: CGPoint(x: -24, y: 34))
        path.closeSubpath()
        return path
    }

    private func sideHairPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -16, y: 16))
        path.addQuadCurve(to: CGPoint(x: 16, y: 18), control: CGPoint(x: 0, y: 28))
        path.addQuadCurve(to: CGPoint(x: 8, y: -6), control: CGPoint(x: 18, y: 4))
        path.addQuadCurve(to: CGPoint(x: -18, y: -32), control: CGPoint(x: -4, y: -18))
        path.addQuadCurve(to: CGPoint(x: -16, y: 16), control: CGPoint(x: -28, y: -4))
        path.closeSubpath()
        return path
    }

    private func trianglePath(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: -height / 2))
        path.addLine(to: CGPoint(x: -width / 2, y: -height / 2))
        path.closeSubpath()
        return path
    }

    private func diamondPath(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -height / 2))
        path.addLine(to: CGPoint(x: -width / 2, y: 0))
        path.closeSubpath()
        return path
    }

    private func startingZone(for chapter: StoryChapter) -> Zone {
        switch chapter {
        case .courtyard: return .courtyard
        case .gardens: return .moonlitGardens
        case .ocean: return .oceanGate
        case .palace: return .starPalace
        }
    }

    private func chapterHazard() -> HazardKind {
        let roll = CGFloat.random(in: 0...1)
        if roll < 0.42 {
            if roll < 0.20 { return .shadowImp }
            if roll < 0.31 { return .tideCrab }
            return .starWisp
        }
        switch retention.chapter {
        case .gardens:
            return roll < 0.72 ? .shadow : .thorn
        case .ocean:
            return roll < 0.72 ? .shell : .tide
        case .palace:
            return roll < 0.72 ? .starBeam : .rock
        case .courtyard:
            if roll < 0.58 { return .thorn }
            if roll < 0.74 { return .rock }
            if roll < 0.88 { return .tide }
            return .beam
        }
    }

    private func buildSparkCompanion() {
        sparkCompanion.removeAllChildren()
        sparkCompanion.isHidden = false
        let glow = SKShapeNode(circleOfRadius: 16)
        glow.fillColor = UIColor(red: 1.0, green: 0.72, blue: 0.28, alpha: 0.28)
        glow.strokeColor = .clear
        sparkCompanion.addChild(glow)
        let body = SKShapeNode(ellipseOf: CGSize(width: 22, height: 16))
        body.fillColor = UIColor(red: 1.0, green: 0.62, blue: 0.22, alpha: 1)
        body.strokeColor = UIColor(red: 1.0, green: 0.92, blue: 0.62, alpha: 1)
        body.lineWidth = 1.6
        sparkCompanion.addChild(body)
        let ear = SKShapeNode(path: trianglePath(width: 8, height: 10))
        ear.fillColor = UIColor(red: 1.0, green: 0.46, blue: 0.18, alpha: 1)
        ear.strokeColor = .clear
        ear.position = CGPoint(x: -6, y: 10)
        sparkCompanion.addChild(ear)
        let ear2 = SKShapeNode(path: trianglePath(width: 8, height: 10))
        ear2.fillColor = UIColor(red: 1.0, green: 0.46, blue: 0.18, alpha: 1)
        ear2.strokeColor = .clear
        ear2.position = CGPoint(x: 6, y: 10)
        sparkCompanion.addChild(ear2)
        let eye = SKShapeNode(circleOfRadius: 1.6)
        eye.fillColor = .white
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 4, y: 2)
        sparkCompanion.addChild(eye)
        sparkCompanion.position = CGPoint(x: player.position.x - 46, y: player.position.y + 58)
        retention.unlock(.spark)
    }

    private func updateSparkCompanion(_ dt: CGFloat) {
        guard !sparkCompanion.isHidden else { return }
        let target = CGPoint(x: player.position.x - 48, y: player.position.y + 62 + sin(runTime * 3.2) * 8)
        sparkCompanion.position.x += (target.x - sparkCompanion.position.x) * min(1, dt * 7)
        sparkCompanion.position.y += (target.y - sparkCompanion.position.y) * min(1, dt * 7)
        sparkCompanion.xScale = playerVelocityX < -20 ? -1 : 1
    }

    private func buildFamilyGhost() {
        familyGhost.removeAllChildren()
        guard let ghost = retention.lastGhost, !ghost.samples.isEmpty else {
            familyGhost.isHidden = true
            return
        }
        familyGhost.isHidden = false
        let body = SKShapeNode(ellipseOf: CGSize(width: 36, height: 64))
        body.fillColor = UIColor(red: 0.72, green: 0.86, blue: 1.0, alpha: 0.38)
        body.strokeColor = UIColor.white.withAlphaComponent(0.55)
        body.lineWidth = 1.4
        familyGhost.addChild(body)
        let tag = label(ghost.name, size: 8, weight: .bold)
        tag.position = CGPoint(x: 0, y: 42)
        tag.fontColor = UIColor.white.withAlphaComponent(0.8)
        familyGhost.addChild(tag)
        familyGhost.position = CGPoint(x: playerX + 36, y: groundY)
    }

    private func updateFamilyGhost() {
        guard !familyGhost.isHidden, let ghost = retention.lastGhost, !ghost.samples.isEmpty else { return }
        let t = Double(runTime)
        var sample = ghost.samples[0]
        for next in ghost.samples where next.t <= t {
            sample = next
        }
        familyGhost.position = CGPoint(x: playerX + 40, y: CGFloat(sample.y))
        familyGhost.alpha = 0.38 + 0.08 * sin(runTime * 2)
    }

    private func promptFamilyCode() {
        guard let root = view?.window?.rootViewController else {
            message("Open on a device to set a code")
            return
        }
        let alert = UIAlertController(title: "Family Race", message: "A 4-letter code. No chat — only a ghost race.", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "CODE"
            field.autocapitalizationType = .allCharacters
            field.text = self.retention.familyCode
        }
        alert.addTextField { field in
            field.placeholder = "Runner name"
            field.text = self.retention.familyName
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self else { return }
            let code = alert.textFields?.first?.text ?? ""
            let name = alert.textFields?.last?.text ?? "Adelynn"
            self.retention.setFamily(code: code, name: name)
            self.message(self.retention.familyCode.isEmpty ? "Need 4 letters" : "Code \(self.retention.familyCode)")
            self.showFamily()
        })
        root.present(alert, animated: true)
    }

    private func sharePostcard() {
        retention.unlock(.postcard)
        let image = renderPostcardImage()
        let text = retention.postcardText(score: score)
        guard let root = view?.window?.rootViewController else {
            message(text)
            return
        }
        var items: [Any] = [text]
        if let image { items.insert(image, at: 0) }
        let sheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = CGRect(x: size.width / 2, y: size.height * 0.3, width: 8, height: 8)
        }
        root.present(sheet, animated: true)
        message("Postcard ready")
    }

    private func renderPostcardImage() -> UIImage? {
        let card = CGSize(width: 1080, height: 1080)
        let renderer = UIGraphicsImageRenderer(size: card)
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: card)
            UIColor(red: 0.42, green: 0.08, blue: 0.32, alpha: 1).setFill()
            ctx.fill(rect)
            UIColor(red: 1.0, green: 0.42, blue: 0.72, alpha: 0.28).setFill()
            UIBezierPath(ovalIn: CGRect(x: 180, y: 80, width: 720, height: 320)).fill()
            let title = "Crown Dash" as NSString
            title.draw(in: CGRect(x: 60, y: 120, width: 960, height: 90), withAttributes: [
                .font: UIFont(name: "AvenirNext-Heavy", size: 64) ?? UIFont.boldSystemFont(ofSize: 64),
                .foregroundColor: UIColor.white,
                .paragraphStyle: centeredParagraph()
            ])
            let stars = String(repeating: "★", count: lastRecapStars) as NSString
            stars.draw(in: CGRect(x: 60, y: 220, width: 960, height: 70), withAttributes: [
                .font: UIFont(name: "AvenirNext-Heavy", size: 48) ?? UIFont.boldSystemFont(ofSize: 48),
                .foregroundColor: UIColor(red: 1, green: 0.86, blue: 0.32, alpha: 1),
                .paragraphStyle: centeredParagraph()
            ])
            let body = "\(selectedRunner.title)\n\(retention.chapter.title)\nScore \(score)" as NSString
            body.draw(in: CGRect(x: 80, y: 430, width: 920, height: 280), withAttributes: [
                .font: UIFont(name: "AvenirNext-Bold", size: 42) ?? UIFont.boldSystemFont(ofSize: 42),
                .foregroundColor: UIColor(red: 1, green: 0.88, blue: 0.94, alpha: 1),
                .paragraphStyle: centeredParagraph()
            ])
            let footer = lastRecapPraise as NSString
            footer.draw(in: CGRect(x: 80, y: 860, width: 920, height: 80), withAttributes: [
                .font: UIFont(name: "AvenirNext-Bold", size: 28) ?? UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: UIColor.white,
                .paragraphStyle: centeredParagraph()
            ])
        }
    }

    private func centeredParagraph() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }
}
