import Foundation
import UIKit

enum StoryChapter: Int, CaseIterable, Codable {
    case courtyard = 1
    case gardens = 2
    case ocean = 3
    case palace = 4

    var title: String {
        switch self {
        case .courtyard: return "Castle Courtyard"
        case .gardens: return "Moonlit Gardens"
        case .ocean: return "Ocean Gate"
        case .palace: return "Star Palace"
        }
    }

    var blurb: String {
        switch self {
        case .courtyard: return "Home of the first crown dash."
        case .gardens: return "Silver vines and night roses."
        case .ocean: return "Pearl shells and sea light."
        case .palace: return "Star crumbs and royal night."
        }
    }

    var collectibleName: String {
        switch self {
        case .courtyard: return "Royal Gem"
        case .gardens: return "Night Rose"
        case .ocean: return "Pearl"
        case .palace: return "Star Crumb"
        }
    }

    var unlockScore: Int {
        switch self {
        case .courtyard: return 0
        case .gardens: return 400
        case .ocean: return 900
        case .palace: return 1600
        }
    }
}

enum DailyGiftKind: String, Codable, CaseIterable {
    case coins, shield, magnet, boost, pardon, sticker

    var title: String {
        switch self {
        case .coins: return "80 coins"
        case .shield: return "Starting shield"
        case .magnet: return "Long magnet"
        case .boost: return "Opening boost"
        case .pardon: return "Royal Pardon"
        case .sticker: return "Album sticker"
        }
    }

    var blurb: String {
        switch self {
        case .coins: return "Spend these in the shop."
        case .shield: return "One free hit this run."
        case .magnet: return "Coins fly to you longer."
        case .boost: return "A burst of speed at the start."
        case .pardon: return "Keeps your streak safe one day."
        case .sticker: return "A new page for the Crown Album."
        }
    }
}

enum AlbumSlot: String, CaseIterable, Codable {
    case firstDash, nightRose, pearl, starCrumb, spark, kofi, pardon, postcard
    case roseRoyal, crystalCrown, moonlight, ballgown, winter, starlight
    case courtyard, gardens, ocean, palace

    var title: String {
        switch self {
        case .firstDash: return "First Dash"
        case .nightRose: return "Night Rose"
        case .pearl: return "Ocean Pearl"
        case .starCrumb: return "Star Crumb"
        case .spark: return "I met Spark"
        case .kofi: return "I met Kofi"
        case .pardon: return "Royal Pardon"
        case .postcard: return "First Postcard"
        case .roseRoyal: return "Rose Royal"
        case .crystalCrown: return "Crystal Crown"
        case .moonlight: return "Moonlight Gown"
        case .ballgown: return "Ballgown"
        case .winter: return "Winter Cloak"
        case .starlight: return "Starlight"
        case .courtyard: return "Castle Courtyard"
        case .gardens: return "Moonlit Gardens"
        case .ocean: return "Ocean Gate"
        case .palace: return "Star Palace"
        }
    }

    var group: String {
        switch self {
        case .firstDash, .nightRose, .pearl, .starCrumb: return "Stickers"
        case .spark, .kofi, .pardon, .postcard: return "I met…"
        case .roseRoyal, .crystalCrown, .moonlight, .ballgown, .winter, .starlight: return "Outfits"
        case .courtyard, .gardens, .ocean, .palace: return "Places"
        }
    }
}

enum ExtraOutfit: String, CaseIterable, Codable {
    case ballgown, winter, starlight

    var title: String {
        switch self {
        case .ballgown: return "Ballgown"
        case .winter: return "Winter Cloak"
        case .starlight: return "Starlight"
        }
    }

    var cost: Int {
        switch self {
        case .ballgown: return 180
        case .winter: return 220
        case .starlight: return 260
        }
    }
}

enum RunnerSilhouette {
    case dress, tunic, coat, cloak
}

enum RunnerHairStyle {
    case ponytail, puff, crop, sweep, braid
}

struct RunnerLook {
    var skin: UIColor
    var skinShade: UIColor
    var hair: UIColor
    var hairShine: UIColor
    var outfit: UIColor
    var accent: UIColor
    var panel: UIColor
    var gem: UIColor
    var shoe: UIColor
    var shoeAccent: UIColor
    var silhouette: RunnerSilhouette
    var hairStyle: RunnerHairStyle
    var usesPaintedCutout: Bool
}

enum FeaturedRunner: String, CaseIterable, Codable {
    case adelynn, kofi, unicorn, ember, mermaid
    case amara, jabari, rowan, lark

    var title: String {
        switch self {
        case .adelynn: return "Princess Adelynn"
        case .kofi: return "Prince Kofi"
        case .unicorn: return "Royal Unicorn"
        case .ember: return "Ember Wyrmling"
        case .mermaid: return "Mermaid Princess"
        case .amara: return "Princess Amara"
        case .jabari: return "Prince Jabari"
        case .rowan: return "Prince Rowan"
        case .lark: return "Duchess Lark"
        }
    }

    var shortTitle: String {
        switch self {
        case .adelynn: return "Adelynn"
        case .kofi: return "Kofi"
        case .unicorn: return "Unicorn"
        case .ember: return "Wyrmling"
        case .mermaid: return "Mermaid"
        case .amara: return "Amara"
        case .jabari: return "Jabari"
        case .rowan: return "Rowan"
        case .lark: return "Lark"
        }
    }

    var blurb: String {
        switch self {
        case .adelynn: return "Brave and bright"
        case .kofi: return "Lucky coins on every dash"
        case .unicorn: return "Floaty, lofty jumps"
        case .ember: return "Burns vines and thorns"
        case .mermaid: return "Safer in the water"
        case .amara: return "Emerald gown and gold crown"
        case .jabari: return "Ivory tunic and gold sash"
        case .rowan: return "Royal blue coat"
        case .lark: return "Teal riding cloak"
        }
    }

    var jumpMul: CGFloat { self == .unicorn ? 1.12 : 1 }
    var gravMul: CGFloat {
        switch self {
        case .unicorn: return 0.82
        case .mermaid: return 0.90
        default: return 1
        }
    }

    var isMale: Bool {
        switch self {
        case .kofi, .jabari, .rowan: return true
        default: return false
        }
    }

    var look: RunnerLook {
        switch self {
        case .adelynn:
            return RunnerLook(
                skin: UIColor(red: 0.74, green: 0.54, blue: 0.42, alpha: 1),
                skinShade: UIColor(red: 0.60, green: 0.40, blue: 0.30, alpha: 1),
                hair: UIColor(red: 0.58, green: 0.45, blue: 0.24, alpha: 1),
                hairShine: UIColor(red: 0.76, green: 0.62, blue: 0.36, alpha: 1),
                outfit: UIColor(red: 1, green: 0.48, blue: 0.78, alpha: 1),
                accent: UIColor(red: 0.94, green: 0.24, blue: 0.58, alpha: 1),
                panel: UIColor(red: 1.0, green: 0.86, blue: 0.92, alpha: 1),
                gem: UIColor(red: 1.0, green: 0.35, blue: 0.62, alpha: 1),
                shoe: UIColor(red: 1.0, green: 0.98, blue: 0.99, alpha: 1),
                shoeAccent: UIColor(red: 0.95, green: 0.18, blue: 0.55, alpha: 1),
                silhouette: .dress,
                hairStyle: .ponytail,
                usesPaintedCutout: true
            )
        case .kofi:
            return RunnerLook(
                skin: UIColor(red: 0.43, green: 0.23, blue: 0.14, alpha: 1),
                skinShade: UIColor(red: 0.32, green: 0.16, blue: 0.10, alpha: 1),
                hair: UIColor(red: 0.12, green: 0.08, blue: 0.06, alpha: 1),
                hairShine: UIColor(red: 0.28, green: 0.18, blue: 0.12, alpha: 1),
                outfit: UIColor(red: 0.70, green: 0.18, blue: 0.22, alpha: 1),
                accent: UIColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 1),
                panel: UIColor(red: 0.86, green: 0.32, blue: 0.34, alpha: 1),
                gem: UIColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 1),
                shoe: UIColor(red: 0.18, green: 0.10, blue: 0.08, alpha: 1),
                shoeAccent: UIColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 1),
                silhouette: .tunic,
                hairStyle: .crop,
                usesPaintedCutout: true
            )
        case .unicorn:
            return RunnerLook(
                skin: UIColor(red: 0.96, green: 0.88, blue: 1.0, alpha: 1),
                skinShade: UIColor(red: 0.86, green: 0.76, blue: 0.96, alpha: 1),
                hair: UIColor(red: 0.55, green: 0.42, blue: 0.92, alpha: 1),
                hairShine: UIColor(red: 0.82, green: 0.70, blue: 1.0, alpha: 1),
                outfit: UIColor(red: 0.96, green: 0.90, blue: 1.0, alpha: 1),
                accent: UIColor(red: 1.0, green: 0.62, blue: 0.84, alpha: 1),
                panel: UIColor(red: 1.0, green: 0.94, blue: 1.0, alpha: 1),
                gem: UIColor(red: 1.0, green: 0.72, blue: 0.88, alpha: 1),
                shoe: .white,
                shoeAccent: UIColor(red: 0.82, green: 0.58, blue: 1.0, alpha: 1),
                silhouette: .dress,
                hairStyle: .braid,
                usesPaintedCutout: true
            )
        case .ember:
            return RunnerLook(
                skin: UIColor(red: 0.42, green: 0.72, blue: 0.48, alpha: 1),
                skinShade: UIColor(red: 0.28, green: 0.52, blue: 0.32, alpha: 1),
                hair: UIColor(red: 0.18, green: 0.38, blue: 0.20, alpha: 1),
                hairShine: UIColor(red: 0.96, green: 0.52, blue: 0.18, alpha: 1),
                outfit: UIColor(red: 0.22, green: 0.58, blue: 0.32, alpha: 1),
                accent: UIColor(red: 1.0, green: 0.62, blue: 0.18, alpha: 1),
                panel: UIColor(red: 0.96, green: 0.78, blue: 0.28, alpha: 1),
                gem: UIColor(red: 1.0, green: 0.42, blue: 0.12, alpha: 1),
                shoe: UIColor(red: 0.16, green: 0.28, blue: 0.14, alpha: 1),
                shoeAccent: UIColor(red: 1.0, green: 0.62, blue: 0.18, alpha: 1),
                silhouette: .cloak,
                hairStyle: .sweep,
                usesPaintedCutout: true
            )
        case .mermaid:
            return RunnerLook(
                skin: UIColor(red: 0.95, green: 0.76, blue: 0.62, alpha: 1),
                skinShade: UIColor(red: 0.86, green: 0.62, blue: 0.50, alpha: 1),
                hair: UIColor(red: 0.48, green: 0.18, blue: 0.58, alpha: 1),
                hairShine: UIColor(red: 0.72, green: 0.38, blue: 0.82, alpha: 1),
                outfit: UIColor(red: 0.18, green: 0.74, blue: 0.82, alpha: 1),
                accent: UIColor(red: 0.78, green: 0.48, blue: 1.0, alpha: 1),
                panel: UIColor(red: 0.62, green: 0.92, blue: 0.96, alpha: 1),
                gem: UIColor(red: 1.0, green: 0.82, blue: 0.42, alpha: 1),
                shoe: UIColor(red: 0.12, green: 0.52, blue: 0.62, alpha: 1),
                shoeAccent: UIColor(red: 0.78, green: 0.48, blue: 1.0, alpha: 1),
                silhouette: .dress,
                hairStyle: .braid,
                usesPaintedCutout: true
            )
        case .amara:
            return RunnerLook(
                skin: UIColor(red: 0.48, green: 0.26, blue: 0.16, alpha: 1),
                skinShade: UIColor(red: 0.36, green: 0.18, blue: 0.11, alpha: 1),
                hair: UIColor(red: 0.10, green: 0.06, blue: 0.05, alpha: 1),
                hairShine: UIColor(red: 0.28, green: 0.16, blue: 0.10, alpha: 1),
                outfit: UIColor(red: 0.07, green: 0.55, blue: 0.38, alpha: 1),
                accent: UIColor(red: 1.0, green: 0.82, blue: 0.22, alpha: 1),
                panel: UIColor(red: 0.18, green: 0.72, blue: 0.52, alpha: 1),
                gem: UIColor(red: 1.0, green: 0.82, blue: 0.22, alpha: 1),
                shoe: UIColor(red: 0.12, green: 0.08, blue: 0.05, alpha: 1),
                shoeAccent: UIColor(red: 1.0, green: 0.82, blue: 0.22, alpha: 1),
                silhouette: .dress,
                hairStyle: .puff,
                usesPaintedCutout: true
            )
        case .jabari:
            return RunnerLook(
                skin: UIColor(red: 0.36, green: 0.20, blue: 0.13, alpha: 1),
                skinShade: UIColor(red: 0.26, green: 0.13, blue: 0.08, alpha: 1),
                hair: UIColor(red: 0.08, green: 0.05, blue: 0.04, alpha: 1),
                hairShine: UIColor(red: 0.22, green: 0.14, blue: 0.10, alpha: 1),
                outfit: UIColor(red: 0.96, green: 0.90, blue: 0.78, alpha: 1),
                accent: UIColor(red: 0.82, green: 0.62, blue: 0.16, alpha: 1),
                panel: UIColor(red: 1.0, green: 0.96, blue: 0.88, alpha: 1),
                gem: UIColor(red: 0.82, green: 0.18, blue: 0.22, alpha: 1),
                shoe: UIColor(red: 0.16, green: 0.10, blue: 0.06, alpha: 1),
                shoeAccent: UIColor(red: 0.82, green: 0.62, blue: 0.16, alpha: 1),
                silhouette: .tunic,
                hairStyle: .crop,
                usesPaintedCutout: true
            )
        case .rowan:
            return RunnerLook(
                skin: UIColor(red: 0.96, green: 0.78, blue: 0.64, alpha: 1),
                skinShade: UIColor(red: 0.88, green: 0.66, blue: 0.52, alpha: 1),
                hair: UIColor(red: 0.32, green: 0.18, blue: 0.10, alpha: 1),
                hairShine: UIColor(red: 0.52, green: 0.32, blue: 0.18, alpha: 1),
                outfit: UIColor(red: 0.18, green: 0.40, blue: 0.82, alpha: 1),
                accent: UIColor(red: 0.86, green: 0.18, blue: 0.28, alpha: 1),
                panel: UIColor(red: 0.42, green: 0.62, blue: 0.96, alpha: 1),
                gem: UIColor(red: 1.0, green: 0.84, blue: 0.28, alpha: 1),
                shoe: UIColor(red: 0.16, green: 0.14, blue: 0.22, alpha: 1),
                shoeAccent: UIColor(red: 0.86, green: 0.18, blue: 0.28, alpha: 1),
                silhouette: .coat,
                hairStyle: .sweep,
                usesPaintedCutout: true
            )
        case .lark:
            return RunnerLook(
                skin: UIColor(red: 0.98, green: 0.82, blue: 0.70, alpha: 1),
                skinShade: UIColor(red: 0.90, green: 0.70, blue: 0.58, alpha: 1),
                hair: UIColor(red: 0.62, green: 0.28, blue: 0.12, alpha: 1),
                hairShine: UIColor(red: 0.84, green: 0.48, blue: 0.22, alpha: 1),
                outfit: UIColor(red: 0.10, green: 0.58, blue: 0.62, alpha: 1),
                accent: UIColor(red: 0.96, green: 0.78, blue: 0.28, alpha: 1),
                panel: UIColor(red: 0.86, green: 0.96, blue: 0.94, alpha: 1),
                gem: UIColor(red: 0.96, green: 0.78, blue: 0.28, alpha: 1),
                shoe: UIColor(red: 0.28, green: 0.16, blue: 0.10, alpha: 1),
                shoeAccent: UIColor(red: 0.10, green: 0.58, blue: 0.62, alpha: 1),
                silhouette: .cloak,
                hairStyle: .braid,
                usesPaintedCutout: true
            )
        }
    }
}

struct DailyGoal: Codable, Equatable {
    var id: String
    var title: String
    var target: Int
    var progress: Int
    var done: Bool
}

struct GhostSample: Codable {
    var t: Double
    var y: Double
    var lane: Int
}

struct FamilyGhost: Codable {
    var name: String
    var score: Int
    var samples: [GhostSample]
}

final class CrownDashRetention {
    static let shared = CrownDashRetention()

    private let defaults = UserDefaults.standard
    private let key = "crownDash.retention.v1"

    var lastLoginDay: String
    var loginStreak: Int
    var giftClaimedDay: String
    var spinUsedDay: String
    var pardonCharges: Int
    var pardonWeek: String
    var chapter: StoryChapter
    var unlockedChapters: Set<Int>
    var stickers: Set<String>
    var gentleMode: Bool
    var extraOutfits: Set<String>
    var selectedExtraOutfit: String
    var familyCode: String
    var familyName: String
    var lastGhost: FamilyGhost?
    var familyBoard: [FamilyGhost]
    var dailyGoals: [DailyGoal]
    var goalsDay: String
    var sparkUnlocked: Bool
    var pendingGift: DailyGiftKind?
    var pendingSpinBuff: String
    var xp: Int
    var starsEarned: Int
    var selectedRunner: String
    var pendingBankCoins: Int
    var awardedStreaks: Set<Int>

    private init() {
        lastLoginDay = ""
        loginStreak = 0
        giftClaimedDay = ""
        spinUsedDay = ""
        pardonCharges = 0
        pardonWeek = ""
        chapter = .courtyard
        unlockedChapters = [1]
        stickers = []
        gentleMode = false
        extraOutfits = []
        selectedExtraOutfit = ""
        familyCode = ""
        familyName = "Adelynn"
        lastGhost = nil
        familyBoard = []
        dailyGoals = []
        goalsDay = ""
        sparkUnlocked = false
        pendingGift = nil
        pendingSpinBuff = ""
        xp = 0
        starsEarned = 0
        selectedRunner = FeaturedRunner.adelynn.rawValue
        pendingBankCoins = 0
        awardedStreaks = []
        load()
        bumpDay()
    }

    private struct Snapshot: Codable {
        var lastLoginDay: String
        var loginStreak: Int
        var giftClaimedDay: String
        var spinUsedDay: String
        var pardonCharges: Int
        var pardonWeek: String
        var chapter: Int
        var unlockedChapters: [Int]
        var stickers: [String]
        var gentleMode: Bool
        var extraOutfits: [String]
        var selectedExtraOutfit: String
        var familyCode: String
        var familyName: String
        var lastGhost: FamilyGhost?
        var familyBoard: [FamilyGhost]
        var dailyGoals: [DailyGoal]
        var goalsDay: String
        var sparkUnlocked: Bool
        var xp: Int
        var starsEarned: Int
        var selectedRunner: String?
        var pendingBankCoins: Int?
        var awardedStreaks: [Int]?
    }

    private func todayKey() -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private func weekKey() -> String {
        let cal = Calendar(identifier: .gregorian)
        let week = cal.component(.weekOfYear, from: Date())
        let year = cal.component(.yearForWeekOfYear, from: Date())
        return "\(year)-W\(week)"
    }

    func bumpDay() {
        let today = todayKey()
        let week = weekKey()
        if pardonWeek != week {
            pardonWeek = week
            pardonCharges = 1
        }
        if lastLoginDay != today {
            if let last = date(from: lastLoginDay), let gap = Calendar.current.dateComponents([.day], from: last, to: Date()).day {
                if gap == 1 {
                    loginStreak += 1
                } else if gap > 1 {
                    if pardonCharges > 0 {
                        pardonCharges -= 1
                        unlock(.pardon)
                    } else {
                        loginStreak = 1
                    }
                }
            } else {
                loginStreak = max(1, loginStreak)
            }
            lastLoginDay = today
        }
        if loginStreak <= 0 { loginStreak = 1 }
        if goalsDay != today {
            goalsDay = today
            dailyGoals = Self.makeDailyGoals()
        }
        ensureBloomImpGoal()
        applyStreakMilestones()
        save()
    }

    private func date(from key: String) -> Date? {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: key)
    }

    var giftAvailable: Bool { giftClaimedDay != todayKey() }
    var spinAvailable: Bool { spinUsedDay != todayKey() }

    func giftForToday() -> DailyGiftKind {
        let pool: [DailyGiftKind] = [.coins, .shield, .magnet, .boost, .sticker, .pardon]
        let idx = abs(todayKey().hashValue) % pool.count
        return pool[idx]
    }

    func claimGift() -> DailyGiftKind {
        let gift = giftForToday()
        giftClaimedDay = todayKey()
        pendingGift = gift
        if gift == .pardon { pardonCharges += 1 }
        if gift == .sticker { unlockRandomSticker() }
        if gift == .coins { pendingBankCoins += 80 }
        save()
        return gift
    }

    func spin() -> String {
        spinUsedDay = todayKey()
        let rewards = ["Starting shield", "Coin magnet", "Opening boost", "40 coins", "Album sticker"]
        let pick = rewards.randomElement() ?? "Starting shield"
        pendingSpinBuff = pick
        if pick == "Album sticker" { unlockRandomSticker() }
        if pick == "40 coins" { pendingBankCoins += 40 }
        save()
        return pick
    }

    func consumeRunBuffs() -> (shield: Bool, magnet: Bool, boost: Bool, coins: Int) {
        var shield = false
        var magnet = false
        var boost = false
        if let gift = pendingGift {
            switch gift {
            case .shield: shield = true
            case .magnet: magnet = true
            case .boost: boost = true
            case .coins, .pardon, .sticker: break
            }
            pendingGift = nil
        }
        switch pendingSpinBuff {
        case "Starting shield": shield = true
        case "Coin magnet": magnet = true
        case "Opening boost": boost = true
        default: break
        }
        pendingSpinBuff = ""
        save()
        return (shield, magnet, boost, 0)
    }

    func takePendingBankCoins() -> Int {
        let coins = pendingBankCoins
        pendingBankCoins = 0
        if coins > 0 { save() }
        return coins
    }

    var runner: FeaturedRunner {
        FeaturedRunner(rawValue: selectedRunner) ?? .adelynn
    }

    func selectRunner(_ next: FeaturedRunner) {
        selectedRunner = next.rawValue
        save()
    }

    func setChapter(_ next: StoryChapter) {
        guard unlockedChapters.contains(next.rawValue) else { return }
        chapter = next
        save()
    }

    func unlockChapterIfNeeded(bestScore: Int) {
        for ch in StoryChapter.allCases where bestScore >= ch.unlockScore {
            unlockedChapters.insert(ch.rawValue)
        }
        save()
    }

    func unlock(_ slot: AlbumSlot) {
        stickers.insert(slot.rawValue)
        save()
    }

    func has(_ slot: AlbumSlot) -> Bool {
        stickers.contains(slot.rawValue)
    }

    func unlockRandomSticker() {
        let missing = AlbumSlot.allCases.filter { !has($0) }
        if let pick = missing.randomElement() {
            unlock(pick)
        }
    }

    func awardRunStickers(score: Int, collectedChapterItem: Bool, metKofi: Bool) {
        unlock(.firstDash)
        unlock(chapter == .courtyard ? .courtyard : chapter == .gardens ? .gardens : chapter == .ocean ? .ocean : .palace)
        if collectedChapterItem {
            switch chapter {
            case .courtyard: break
            case .gardens: unlock(.nightRose)
            case .ocean: unlock(.pearl)
            case .palace: unlock(.starCrumb)
            }
        }
        if metKofi { unlock(.kofi) }
        if sparkUnlocked { unlock(.spark) }
        if score >= 200 { sparkUnlocked = true; unlock(.spark) }
        save()
    }

    func ownExtra(_ outfit: ExtraOutfit) -> Bool {
        extraOutfits.contains(outfit.rawValue)
    }

    func buyExtra(_ outfit: ExtraOutfit) {
        extraOutfits.insert(outfit.rawValue)
        unlock(outfit == .ballgown ? .ballgown : outfit == .winter ? .winter : .starlight)
        save()
    }

    func selectExtra(_ outfit: ExtraOutfit?) {
        selectedExtraOutfit = outfit?.rawValue ?? ""
        save()
    }

    func setFamily(code: String, name: String) {
        familyCode = String(code.uppercased().filter(\.isLetter).prefix(4))
        familyName = String(name.prefix(12))
        save()
    }

    func recordGhost(score: Int, samples: [GhostSample]) {
        let ghost = FamilyGhost(name: familyName.isEmpty ? "Adelynn" : familyName, score: score, samples: samples)
        lastGhost = ghost
        if !familyCode.isEmpty {
            familyBoard.removeAll { $0.name == ghost.name }
            familyBoard.append(ghost)
            familyBoard.sort { $0.score > $1.score }
            familyBoard = Array(familyBoard.prefix(6))
        }
        save()
    }

    func markGoal(id: String, amount: Int = 1) {
        guard let idx = dailyGoals.firstIndex(where: { $0.id == id }) else { return }
        if dailyGoals[idx].done { return }
        dailyGoals[idx].progress += amount
        if dailyGoals[idx].progress >= dailyGoals[idx].target {
            dailyGoals[idx].done = true
            dailyGoals[idx].progress = dailyGoals[idx].target
        }
        save()
    }

    func activeGoalText() -> String {
        if let open = dailyGoals.first(where: { !$0.done }) {
            return "\(open.title)  \(open.progress)/\(open.target)"
        }
        return "All of today's goals are done!"
    }

    func addXP(_ amount: Int) {
        xp += amount
        save()
    }

    func royalRank() -> String {
        switch xp {
        case ..<80: return "Page"
        case ..<200: return "Squire"
        case ..<400: return "Knight"
        case ..<700: return "Baron"
        default: return "Royal Star"
        }
    }

    func recap(score: Int, coins: Int) -> (stars: Int, praise: String) {
        let stars = score >= 800 ? 3 : score >= 350 ? 2 : 1
        starsEarned += stars
        addXP(12 + score / 40)
        let lines = [
            "What a dash, Princess!",
            "The court is cheering!",
            "Spark is so proud!",
            "That was brave and bright!",
            "A royal finish!"
        ]
        return (stars, lines.randomElement() ?? "What a dash, Princess!")
    }

    func postcardText(score: Int) -> String {
        "Adelynn dashed through \(chapter.title) and scored \(score)! Crown Dash 👑"
    }

    private func applyStreakMilestones() {
        let rewards = [3: 20, 7: 50, 14: 80, 30: 150]
        for (day, coins) in rewards where loginStreak >= day && !awardedStreaks.contains(day) {
            awardedStreaks.insert(day)
            pendingBankCoins += coins
        }
        if loginStreak >= 3 { unlock(.firstDash) }
        if loginStreak >= 7 { pardonCharges = max(pardonCharges, 1) }
    }

    private static func makeDailyGoals() -> [DailyGoal] {
        [
            DailyGoal(id: "bloomImps", title: "Bloom 3 shadow imps", target: 3, progress: 0, done: false),
            DailyGoal(id: "jumps", title: "Jump 8 times", target: 8, progress: 0, done: false),
            DailyGoal(id: "coins", title: "Catch 20 coins", target: 20, progress: 0, done: false),
            DailyGoal(id: "survive", title: "Dash 20 seconds", target: 20, progress: 0, done: false)
        ]
    }

    private func ensureBloomImpGoal() {
        guard !dailyGoals.contains(where: { $0.id == "bloomImps" }) else { return }
        dailyGoals.insert(
            DailyGoal(id: "bloomImps", title: "Bloom 3 shadow imps", target: 3, progress: 0, done: false),
            at: 0
        )
    }

    private func load() {
        guard let data = defaults.data(forKey: key),
              let snap = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        lastLoginDay = snap.lastLoginDay
        loginStreak = snap.loginStreak
        giftClaimedDay = snap.giftClaimedDay
        spinUsedDay = snap.spinUsedDay
        pardonCharges = snap.pardonCharges
        pardonWeek = snap.pardonWeek
        chapter = StoryChapter(rawValue: snap.chapter) ?? .courtyard
        unlockedChapters = Set(snap.unlockedChapters)
        stickers = Set(snap.stickers)
        gentleMode = snap.gentleMode
        extraOutfits = Set(snap.extraOutfits)
        selectedExtraOutfit = snap.selectedExtraOutfit
        familyCode = snap.familyCode
        familyName = snap.familyName
        lastGhost = snap.lastGhost
        familyBoard = snap.familyBoard
        dailyGoals = snap.dailyGoals
        goalsDay = snap.goalsDay
        sparkUnlocked = snap.sparkUnlocked
        xp = snap.xp
        starsEarned = snap.starsEarned
        selectedRunner = snap.selectedRunner ?? FeaturedRunner.adelynn.rawValue
        pendingBankCoins = snap.pendingBankCoins ?? 0
        awardedStreaks = Set(snap.awardedStreaks ?? [])
    }

    func save() {
        let snap = Snapshot(
            lastLoginDay: lastLoginDay,
            loginStreak: loginStreak,
            giftClaimedDay: giftClaimedDay,
            spinUsedDay: spinUsedDay,
            pardonCharges: pardonCharges,
            pardonWeek: pardonWeek,
            chapter: chapter.rawValue,
            unlockedChapters: Array(unlockedChapters),
            stickers: Array(stickers),
            gentleMode: gentleMode,
            extraOutfits: Array(extraOutfits),
            selectedExtraOutfit: selectedExtraOutfit,
            familyCode: familyCode,
            familyName: familyName,
            lastGhost: lastGhost,
            familyBoard: familyBoard,
            dailyGoals: dailyGoals,
            goalsDay: goalsDay,
            sparkUnlocked: sparkUnlocked,
            xp: xp,
            starsEarned: starsEarned,
            selectedRunner: selectedRunner,
            pendingBankCoins: pendingBankCoins,
            awardedStreaks: Array(awardedStreaks)
        )
        if let data = try? JSONEncoder().encode(snap) {
            defaults.set(data, forKey: key)
        }
    }
}
