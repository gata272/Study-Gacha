import Foundation
import SwiftUI

// MARK: - レアリティ

enum Rarity: Int, Codable, CaseIterable {
    case common = 0
    case rare
    case superRare
    case ultraRare
    case legend

    var name: String {
        switch self {
        case .common: return "コモン"
        case .rare: return "レア"
        case .superRare: return "スーパーレア"
        case .ultraRare: return "ウルトラレア"
        case .legend: return "レジェンド"
        }
    }

    var shortName: String {
        switch self {
        case .common: return "C"
        case .rare: return "R"
        case .superRare: return "SR"
        case .ultraRare: return "UR"
        case .legend: return "LR"
        }
    }

    var color: Color {
        switch self {
        case .common: return Color(red: 0.62, green: 0.66, blue: 0.72)
        case .rare: return Color(red: 0.20, green: 0.55, blue: 0.98)
        case .superRare: return Color(red: 0.66, green: 0.35, blue: 0.98)
        case .ultraRare: return Color(red: 0.98, green: 0.62, blue: 0.10)
        case .legend: return Color(red: 0.98, green: 0.30, blue: 0.55)
        }
    }

    /// 出現率（%）。合計100
    var weight: Int {
        switch self {
        case .common: return 50
        case .rare: return 30
        case .superRare: return 14
        case .ultraRare: return 5
        case .legend: return 1
        }
    }

    /// ダブったときに還元されるコイン
    var dupRefund: Int {
        switch self {
        case .common: return 5
        case .rare: return 15
        case .superRare: return 40
        case .ultraRare: return 120
        case .legend: return 400
        }
    }
}

// MARK: - ガチャアイテム（図鑑）

struct GachaItem: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var symbol: String
    var rarity: Rarity
    var flavor: String
}

enum Catalog {
    static let items: [GachaItem] = [
        // コモン
        GachaItem(id: "c01", name: "えんぴつ君", symbol: "pencil", rarity: .common, flavor: "削られるほど賢くなる、素直な相棒。"),
        GachaItem(id: "c02", name: "クリップ坊や", symbol: "paperclip", rarity: .common, flavor: "バラバラの知識をひとつに留めてくれる。"),
        GachaItem(id: "c03", name: "ブックン", symbol: "book.fill", rarity: .common, flavor: "ページの向こう側に夢中な本の妖精。"),
        GachaItem(id: "c04", name: "リーフン", symbol: "leaf.fill", rarity: .common, flavor: "光合成ならぬ「光暗記」で育つ葉っぱ。"),
        GachaItem(id: "c05", name: "くもっち", symbol: "cloud.fill", rarity: .common, flavor: "ぼんやり考えごとが得意。雨の日は復習日和。"),
        GachaItem(id: "c06", name: "ありんこ隊員", symbol: "ant.fill", rarity: .common, flavor: "小さな努力を毎日運ぶ、働き者。"),
        GachaItem(id: "c07", name: "ぷくぷく", symbol: "fish.fill", rarity: .common, flavor: "記憶の海をすいすい泳ぐ金魚（？）。"),
        GachaItem(id: "c08", name: "にくきゅう", symbol: "pawprint.fill", rarity: .common, flavor: "踏んだノートは全部覚えてしまうらしい。"),
        // レア
        GachaItem(id: "r01", name: "ねこ先生", symbol: "cat.fill", rarity: .rare, flavor: "気まぐれだが、教え方は天才的。"),
        GachaItem(id: "r02", name: "わんこ助教", symbol: "dog.fill", rarity: .rare, flavor: "褒められると何倍も頑張れるタイプ。"),
        GachaItem(id: "r03", name: "うさぎ特急", symbol: "hare.fill", rarity: .rare, flavor: "速読の達人。ただし昼寝も速い。"),
        GachaItem(id: "r04", name: "かめ教授", symbol: "tortoise.fill", rarity: .rare, flavor: "「継続は力なり」を体現する生き証人。"),
        GachaItem(id: "r05", name: "ひらめき電球", symbol: "lightbulb.fill", rarity: .rare, flavor: "分からない問題のそばでピカッと光る。"),
        GachaItem(id: "r06", name: "ときの番人", symbol: "clock.fill", rarity: .rare, flavor: "集中した25分間を見守ってくれる。"),
        GachaItem(id: "r07", name: "ランドセル騎士", symbol: "backpack.fill", rarity: .rare, flavor: "教科書を背負ってどこへでも同行する。"),
        GachaItem(id: "r08", name: "集中ヘッドホン", symbol: "headphones", rarity: .rare, flavor: "雑音を消して、頭の中を静かにする。"),
        // スーパーレア
        GachaItem(id: "s01", name: "首席卒業生", symbol: "graduationcap.fill", rarity: .superRare, flavor: "卒業式で総代を務めた秀才。その実力は本物。"),
        GachaItem(id: "s02", name: "やる気の炎", symbol: "flame.fill", rarity: .superRare, flavor: "一度ついたら消えない、情熱の炎。"),
        GachaItem(id: "s03", name: "稲妻の記憶術", symbol: "bolt.fill", rarity: .superRare, flavor: "一瞬で暗記する電光石火のテクニック。"),
        GachaItem(id: "s04", name: "実験マッド博士", symbol: "testtube.2", rarity: .superRare, flavor: "失敗は成功のデータと言う、理科の求道者。"),
        GachaItem(id: "s05", name: "世界旅行家", symbol: "globe.americas.fill", rarity: .superRare, flavor: "地理も歴史も、歩いて覚えた冒険家。"),
        GachaItem(id: "s06", name: "魔法の参考書", symbol: "wand.and.stars", rarity: .superRare, flavor: "開くと勝手に要点を教えてくれる不思議な本。"),
        GachaItem(id: "s07", name: "冷静の結晶", symbol: "snowflake", rarity: .superRare, flavor: "本番でも焦らない、氷のような集中力。"),
        // ウルトラレア
        GachaItem(id: "u01", name: "栄光のトロフィー", symbol: "trophy.fill", rarity: .ultraRare, flavor: "努力した者だけが手にできる輝き。"),
        GachaItem(id: "u02", name: "天才の脳", symbol: "brain", rarity: .ultraRare, flavor: "シナプスが光の速さでつながる頭脳。"),
        GachaItem(id: "u03", name: "原子の賢者", symbol: "atom", rarity: .ultraRare, flavor: "万物の仕組みを見通す、理系の賢者。"),
        GachaItem(id: "u04", name: "太陽の加護", symbol: "sun.max.fill", rarity: .ultraRare, flavor: "朝の光とともに最高のパフォーマンスを。"),
        GachaItem(id: "u05", name: "合格への鍵", symbol: "key.fill", rarity: .ultraRare, flavor: "どんな難問の扉も開けるという伝説の鍵。"),
        // レジェンド
        GachaItem(id: "l01", name: "勉強王", symbol: "crown.fill", rarity: .legend, flavor: "全ての学習者を見守る王。継続の日々がこの冠を作った。"),
        GachaItem(id: "l02", name: "知識の女神", symbol: "sparkles", rarity: .legend, flavor: "知を愛する者にだけ姿を現す、伝説の女神。"),
    ]

    static func item(id: String) -> GachaItem? {
        items.first { $0.id == id }
    }

    static func items(rarity: Rarity) -> [GachaItem] {
        items.filter { $0.rarity == rarity }
    }
}

// MARK: - 科目

enum Subjects {
    static let all = ["国語", "数学", "英語", "理科", "社会", "その他"]

    static func color(_ subject: String) -> Color {
        switch subject {
        case "国語": return .pink
        case "数学": return .blue
        case "英語": return .orange
        case "理科": return .green
        case "社会": return .brown
        default: return .gray
        }
    }
}

// MARK: - 勉強記録

struct StudyRecord: Identifiable, Codable {
    var id: UUID
    var date: Date
    var minutes: Int
    var subject: String
    var coinsEarned: Int
}

// MARK: - 保存されるゲーム状態

struct GameState: Codable {
    var coins: Int = 0
    var totalMinutes: Int = 0
    var totalPulls: Int = 0
    var records: [StudyRecord] = []
    var collection: [String: Int] = [:]   // アイテムID -> 所持数
}

// MARK: - 記録時の獲得内訳

struct EarnResult: Identifiable {
    var id = UUID()
    var minutes: Int
    var subject: String
    var base: Int
    var sessionBonus: Int
    var streakDays: Int
    var streakBonus: Int
    var total: Int { base + sessionBonus + streakBonus }
}

// MARK: - ガチャ結果

struct PullResult: Identifiable {
    var id = UUID()
    var item: GachaItem
    var isNew: Bool
    var refund: Int   // ダブり還元コイン（新規のときは0）
}

// MARK: - 表示用フォーマット

enum SFmt {
    static func minutes(_ m: Int) -> String {
        if m >= 60 {
            let h = m / 60, rest = m % 60
            return rest > 0 ? "\(h)時間\(rest)分" : "\(h)時間"
        }
        return "\(m)分"
    }

    static func clock(seconds: Int) -> String {
        let h = seconds / 3600, m = (seconds % 3600) / 60, s = seconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    static func dateShort(_ d: Date) -> String {
        let c = Calendar.current.dateComponents([.month, .day], from: d)
        return "\(c.month ?? 0)/\(c.day ?? 0)"
    }

    static let weekdayNames = ["日", "月", "火", "水", "木", "金", "土"]
}
