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

// MARK: - ガチャアイテム（バッジ）

/// 小テストジェネレーターの「バッジガチャ」を参考にしたコレクションバッジ。
/// 食べ物・キッチン用品をひらがな名で集める、全200種類。
/// ウルトラレア以上は「ゴールドバッジ」として金色に表示される
struct GachaItem: Identifiable, Codable, Hashable {
    var id: String
    var name: String    // ひらがなのバッジ名（ゴールドは★付き）
    var emoji: String   // バッジの絵柄
    var rarity: Rarity

    var isGold: Bool { rarity == .ultraRare || rarity == .legend }
}

enum Catalog {
    static let items: [GachaItem] = [
        GachaItem(id: "l001", name: "すてーきもりあわせ", emoji: "🥩", rarity: .legend),
        GachaItem(id: "l002", name: "★だぶるちーずばーがー", emoji: "🍔", rarity: .legend),
        GachaItem(id: "l003", name: "★だぶるばーがー", emoji: "🍔", rarity: .legend),
        GachaItem(id: "l004", name: "★いかついぱんぷきん", emoji: "🎃", rarity: .legend),
        GachaItem(id: "l005", name: "いちごのほーるけーき", emoji: "🎂", rarity: .legend),
        GachaItem(id: "l006", name: "なべにはいったびーふしちゅー", emoji: "🍲", rarity: .legend),
        GachaItem(id: "l007", name: "いくらのまきずし", emoji: "🍣", rarity: .legend),
        GachaItem(id: "l008", name: "しちめんちょう", emoji: "🦃", rarity: .legend),
        GachaItem(id: "u001", name: "★あいすきゃんでぃーのぼう", emoji: "🍭", rarity: .ultraRare),
        GachaItem(id: "u002", name: "★やさいもはいったやきとり", emoji: "🍢", rarity: .ultraRare),
        GachaItem(id: "u003", name: "★なまのべーこん", emoji: "🥓", rarity: .ultraRare),
        GachaItem(id: "u004", name: "ちゅうごくのふぁすとふーど", emoji: "🥡", rarity: .ultraRare),
        GachaItem(id: "u005", name: "にくをたたいてやわらかくするやつ", emoji: "🔨", rarity: .ultraRare),
        GachaItem(id: "u006", name: "ほうちょうをたてとくやつ", emoji: "🔪", rarity: .ultraRare),
        GachaItem(id: "u007", name: "にくまんをむすやつ", emoji: "🥟", rarity: .ultraRare),
        GachaItem(id: "u008", name: "くりーむをあわだてるやつ", emoji: "🥣", rarity: .ultraRare),
        GachaItem(id: "u009", name: "じんじゃーぶれっどのかながた", emoji: "🍪", rarity: .ultraRare),
        GachaItem(id: "u010", name: "そーせーじをつかったりょうり", emoji: "🌭", rarity: .ultraRare),
        GachaItem(id: "u011", name: "ほっとどっぐににているやつ", emoji: "🌭", rarity: .ultraRare),
        GachaItem(id: "u012", name: "ていくあうとのりょうり", emoji: "🥡", rarity: .ultraRare),
        GachaItem(id: "u013", name: "ちーずきるやつ", emoji: "🧀", rarity: .ultraRare),
        GachaItem(id: "u014", name: "けーききるやつ", emoji: "🍰", rarity: .ultraRare),
        GachaItem(id: "u015", name: "ぴざをきるやつ", emoji: "🍕", rarity: .ultraRare),
        GachaItem(id: "u016", name: "こしょういれるやつ", emoji: "🧂", rarity: .ultraRare),
        GachaItem(id: "s001", name: "はんぶんのそーせーじ", emoji: "🌭", rarity: .superRare),
        GachaItem(id: "s002", name: "あいすくりーむのかっぷ", emoji: "🍨", rarity: .superRare),
        GachaItem(id: "s003", name: "ふくろつきのちょこばー", emoji: "🍫", rarity: .superRare),
        GachaItem(id: "s004", name: "ぱいなっぷるのあいすきゃんでぃー", emoji: "🍍", rarity: .superRare),
        GachaItem(id: "s005", name: "いちごどーなつ", emoji: "🍩", rarity: .superRare),
        GachaItem(id: "s006", name: "とくしゅなふぉーく", emoji: "🍴", rarity: .superRare),
        GachaItem(id: "s007", name: "たるみたいなまぐかっぷ", emoji: "☕", rarity: .superRare),
        GachaItem(id: "s008", name: "はんぶんのたまねぎ", emoji: "🧅", rarity: .superRare),
        GachaItem(id: "s009", name: "ていくあうとようのようき", emoji: "🥡", rarity: .superRare),
        GachaItem(id: "s010", name: "しょくぱんいっきん", emoji: "🍞", rarity: .superRare),
        GachaItem(id: "s011", name: "たまごおくやつ", emoji: "🥚", rarity: .superRare),
        GachaItem(id: "s012", name: "にくのぱてぃー", emoji: "🥩", rarity: .superRare),
        GachaItem(id: "s013", name: "にこみりょうりをいれるようき", emoji: "🍲", rarity: .superRare),
        GachaItem(id: "s014", name: "つぶれたこーらのかん", emoji: "🥤", rarity: .superRare),
        GachaItem(id: "s015", name: "ひらいたにまいがい", emoji: "🦪", rarity: .superRare),
        GachaItem(id: "s016", name: "ちょこどーなつ", emoji: "🍩", rarity: .superRare),
        GachaItem(id: "s017", name: "はんぶんのれもん", emoji: "🍋", rarity: .superRare),
        GachaItem(id: "s018", name: "あかいおはし", emoji: "🥢", rarity: .superRare),
        GachaItem(id: "s019", name: "ちゅうかほうちょう", emoji: "🔪", rarity: .superRare),
        GachaItem(id: "s020", name: "ふかいなべのふた", emoji: "🍳", rarity: .superRare),
        GachaItem(id: "s021", name: "いれてるとちゅうのおちゃ", emoji: "🍵", rarity: .superRare),
        GachaItem(id: "s022", name: "ぴーなっつばたー", emoji: "🥜", rarity: .superRare),
        GachaItem(id: "s023", name: "みんとのあいすくりーむ", emoji: "🍨", rarity: .superRare),
        GachaItem(id: "s024", name: "あいすくりーむのこーん", emoji: "🍦", rarity: .superRare),
        GachaItem(id: "s025", name: "ふらいどぽてとのはこ", emoji: "🍟", rarity: .superRare),
        GachaItem(id: "s026", name: "いちごぎゅうにゅう", emoji: "🍓", rarity: .superRare),
        GachaItem(id: "s027", name: "こっぷのしたにあるおさら", emoji: "🍽️", rarity: .superRare),
        GachaItem(id: "s028", name: "ぱぷりかのすらいす", emoji: "🫑", rarity: .superRare),
        GachaItem(id: "s029", name: "はんぶんのあぼかど", emoji: "🥑", rarity: .superRare),
        GachaItem(id: "s030", name: "いちごとちょこのあいすきゃんでぃー", emoji: "🍬", rarity: .superRare),
        GachaItem(id: "s031", name: "にくとやさいのすーぷ", emoji: "🍲", rarity: .superRare),
        GachaItem(id: "s032", name: "さーもんのまきずし", emoji: "🍣", rarity: .superRare),
        GachaItem(id: "s033", name: "はんぶんのようなし", emoji: "🍐", rarity: .superRare),
        GachaItem(id: "s034", name: "はんぶんのここなっつ", emoji: "🥥", rarity: .superRare),
        GachaItem(id: "r001", name: "かみぶくろ", emoji: "🛍️", rarity: .rare),
        GachaItem(id: "r002", name: "わっふる", emoji: "🧇", rarity: .rare),
        GachaItem(id: "r003", name: "まるいまないた", emoji: "🍽️", rarity: .rare),
        GachaItem(id: "r004", name: "ここなっつ", emoji: "🥥", rarity: .rare),
        GachaItem(id: "r005", name: "すしたまご", emoji: "🍣", rarity: .rare),
        GachaItem(id: "r006", name: "ふかいなべ", emoji: "🍲", rarity: .rare),
        GachaItem(id: "r007", name: "しりある", emoji: "🥣", rarity: .rare),
        GachaItem(id: "r008", name: "ふかいさら", emoji: "🍽️", rarity: .rare),
        GachaItem(id: "r009", name: "もくせいのすぷーん", emoji: "🥄", rarity: .rare),
        GachaItem(id: "r010", name: "かりふらわー", emoji: "🥦", rarity: .rare),
        GachaItem(id: "r011", name: "はんぶんのにく", emoji: "🥩", rarity: .rare),
        GachaItem(id: "r012", name: "びんのこーら", emoji: "🥤", rarity: .rare),
        GachaItem(id: "r013", name: "ふらいぱんのふた", emoji: "🍳", rarity: .rare),
        GachaItem(id: "r014", name: "まないた", emoji: "🍽️", rarity: .rare),
        GachaItem(id: "r015", name: "すりこぎぼう", emoji: "🥣", rarity: .rare),
        GachaItem(id: "r016", name: "ちいさいないふ", emoji: "🔪", rarity: .rare),
        GachaItem(id: "r017", name: "なまのそーせーじ", emoji: "🌭", rarity: .rare),
        GachaItem(id: "r018", name: "めだまやき", emoji: "🍳", rarity: .rare),
        GachaItem(id: "r019", name: "すしさーもん", emoji: "🍣", rarity: .rare),
        GachaItem(id: "r020", name: "すりばち", emoji: "🥣", rarity: .rare),
        GachaItem(id: "r021", name: "てんしん", emoji: "🥟", rarity: .rare),
        GachaItem(id: "r022", name: "ないふ", emoji: "🔪", rarity: .rare),
        GachaItem(id: "r023", name: "さらだまき", emoji: "🍣", rarity: .rare),
        GachaItem(id: "r024", name: "あかわいん", emoji: "🍷", rarity: .rare),
        GachaItem(id: "r025", name: "あいたかん", emoji: "🥫", rarity: .rare),
        GachaItem(id: "r026", name: "はんばーがー", emoji: "🍔", rarity: .rare),
        GachaItem(id: "r027", name: "りぶにく", emoji: "🍖", rarity: .rare),
        GachaItem(id: "r028", name: "なまくりーむ", emoji: "🍦", rarity: .rare),
        GachaItem(id: "r029", name: "かくてる", emoji: "🍸", rarity: .rare),
        GachaItem(id: "r030", name: "ぱい", emoji: "🥧", rarity: .rare),
        GachaItem(id: "r031", name: "すーぷ", emoji: "🍲", rarity: .rare),
        GachaItem(id: "r032", name: "ぷりん", emoji: "🍮", rarity: .rare),
        GachaItem(id: "r033", name: "けちゃっぷ", emoji: "🍅", rarity: .rare),
        GachaItem(id: "r034", name: "やいたべーこん", emoji: "🥓", rarity: .rare),
        GachaItem(id: "r035", name: "くろわっさん", emoji: "🥐", rarity: .rare),
        GachaItem(id: "r036", name: "とうがらし", emoji: "🌶️", rarity: .rare),
        GachaItem(id: "r037", name: "ぱんぷきん", emoji: "🎃", rarity: .rare),
        GachaItem(id: "r038", name: "ぱんけーき", emoji: "🥞", rarity: .rare),
        GachaItem(id: "r039", name: "さらだ", emoji: "🥗", rarity: .rare),
        GachaItem(id: "r040", name: "こーら", emoji: "🥤", rarity: .rare),
        GachaItem(id: "r041", name: "そーだぐらす", emoji: "🥤", rarity: .rare),
        GachaItem(id: "r042", name: "ぴざのはこ", emoji: "🍕", rarity: .rare),
        GachaItem(id: "r043", name: "しかくいおさら", emoji: "🍽️", rarity: .rare),
        GachaItem(id: "r044", name: "びーふしちゅー", emoji: "🍲", rarity: .rare),
        GachaItem(id: "r045", name: "しょうゆこざら", emoji: "🍶", rarity: .rare),
        GachaItem(id: "r046", name: "へら", emoji: "🍳", rarity: .rare),
        GachaItem(id: "r047", name: "ちょこばー", emoji: "🍫", rarity: .rare),
        GachaItem(id: "r048", name: "ばげっと", emoji: "🥖", rarity: .rare),
        GachaItem(id: "r049", name: "わいんぐらす", emoji: "🍷", rarity: .rare),
        GachaItem(id: "r050", name: "ちーずばーがー", emoji: "🍔", rarity: .rare),
        GachaItem(id: "r051", name: "まふぃん", emoji: "🧁", rarity: .rare),
        GachaItem(id: "r052", name: "まるいちーず", emoji: "🧀", rarity: .rare),
        GachaItem(id: "r053", name: "ふらっぺ", emoji: "🥤", rarity: .rare),
        GachaItem(id: "r054", name: "ぼうる", emoji: "🥣", rarity: .rare),
        GachaItem(id: "r055", name: "あめりかんどっぐ", emoji: "🌭", rarity: .rare),
        GachaItem(id: "r056", name: "ちょこくっきー", emoji: "🍪", rarity: .rare),
        GachaItem(id: "r057", name: "ぺろぺろきゃんでぃー", emoji: "🍭", rarity: .rare),
        GachaItem(id: "r058", name: "くっきー", emoji: "🍪", rarity: .rare),
        GachaItem(id: "c001", name: "ふらいどぽてと", emoji: "🍟", rarity: .common),
        GachaItem(id: "c002", name: "みかん", emoji: "🍊", rarity: .common),
        GachaItem(id: "c003", name: "どりんく", emoji: "🥤", rarity: .common),
        GachaItem(id: "c004", name: "こしょう", emoji: "🧂", rarity: .common),
        GachaItem(id: "c005", name: "おはし", emoji: "🥢", rarity: .common),
        GachaItem(id: "c006", name: "ますたーど", emoji: "🌭", rarity: .common),
        GachaItem(id: "c007", name: "おにぎり", emoji: "🍙", rarity: .common),
        GachaItem(id: "c008", name: "ばなな", emoji: "🍌", rarity: .common),
        GachaItem(id: "c009", name: "そーせーじ", emoji: "🌭", rarity: .common),
        GachaItem(id: "c010", name: "さくらんぼ", emoji: "🍒", rarity: .common),
        GachaItem(id: "c011", name: "ねぎ", emoji: "🧅", rarity: .common),
        GachaItem(id: "c012", name: "きれたちーず", emoji: "🧀", rarity: .common),
        GachaItem(id: "c013", name: "にんじん", emoji: "🥕", rarity: .common),
        GachaItem(id: "c014", name: "とうもろこし", emoji: "🌽", rarity: .common),
        GachaItem(id: "c015", name: "やきとり", emoji: "🍢", rarity: .common),
        GachaItem(id: "c016", name: "あいすくりーむ", emoji: "🍨", rarity: .common),
        GachaItem(id: "c017", name: "さら", emoji: "🍽️", rarity: .common),
        GachaItem(id: "c018", name: "はんぶんのたまご", emoji: "🥚", rarity: .common),
        GachaItem(id: "c019", name: "どーなつ", emoji: "🍩", rarity: .common),
        GachaItem(id: "c020", name: "ぱぷりか", emoji: "🫑", rarity: .common),
        GachaItem(id: "c021", name: "ぶどう", emoji: "🍇", rarity: .common),
        GachaItem(id: "c022", name: "さかな", emoji: "🐟", rarity: .common),
        GachaItem(id: "c023", name: "ぴざ", emoji: "🍕", rarity: .common),
        GachaItem(id: "c024", name: "あぼかど", emoji: "🥑", rarity: .common),
        GachaItem(id: "c025", name: "おちゃ", emoji: "🍵", rarity: .common),
        GachaItem(id: "c026", name: "しお", emoji: "🧂", rarity: .common),
        GachaItem(id: "c027", name: "しょくぱん", emoji: "🍞", rarity: .common),
        GachaItem(id: "c028", name: "たまご", emoji: "🥚", rarity: .common),
        GachaItem(id: "c029", name: "だいこん", emoji: "🥬", rarity: .common),
        GachaItem(id: "c030", name: "かん", emoji: "🥫", rarity: .common),
        GachaItem(id: "c031", name: "きゃべつ", emoji: "🥬", rarity: .common),
        GachaItem(id: "c032", name: "にく", emoji: "🥩", rarity: .common),
        GachaItem(id: "c033", name: "りんご", emoji: "🍎", rarity: .common),
        GachaItem(id: "c034", name: "れもん", emoji: "🍋", rarity: .common),
        GachaItem(id: "c035", name: "ぎゅうにゅう", emoji: "🥛", rarity: .common),
        GachaItem(id: "c036", name: "ちいさいかみぶくろ", emoji: "🛍️", rarity: .common),
        GachaItem(id: "c037", name: "こっぷ", emoji: "🥤", rarity: .common),
        GachaItem(id: "c038", name: "きのこ", emoji: "🍄", rarity: .common),
        GachaItem(id: "c039", name: "せろり", emoji: "🥬", rarity: .common),
        GachaItem(id: "c040", name: "はちみつ", emoji: "🍯", rarity: .common),
        GachaItem(id: "c041", name: "とじたにまいがい", emoji: "🦪", rarity: .common),
        GachaItem(id: "c042", name: "かっぷけーき", emoji: "🧁", rarity: .common),
        GachaItem(id: "c043", name: "いたちょこ", emoji: "🍫", rarity: .common),
        GachaItem(id: "c044", name: "みーとぱい", emoji: "🥧", rarity: .common),
        GachaItem(id: "c045", name: "なすび", emoji: "🍆", rarity: .common),
        GachaItem(id: "c046", name: "たまねぎ", emoji: "🧅", rarity: .common),
        GachaItem(id: "c047", name: "さんどいっち", emoji: "🥪", rarity: .common),
        GachaItem(id: "c048", name: "ぱいなっぷる", emoji: "🍍", rarity: .common),
        GachaItem(id: "c049", name: "しろわいん", emoji: "🍷", rarity: .common),
        GachaItem(id: "c050", name: "おりーぶおいる", emoji: "🫒", rarity: .common),
        GachaItem(id: "c051", name: "ぶろっこりー", emoji: "🥦", rarity: .common),
        GachaItem(id: "c052", name: "ふぉーく", emoji: "🍴", rarity: .common),
        GachaItem(id: "c053", name: "なべ", emoji: "🍲", rarity: .common),
        GachaItem(id: "c054", name: "はんぶんのりんご", emoji: "🍎", rarity: .common),
        GachaItem(id: "c055", name: "はんぶんのきのこ", emoji: "🍄", rarity: .common),
        GachaItem(id: "c056", name: "ぐらす", emoji: "🥤", rarity: .common),
        GachaItem(id: "c057", name: "びーつ", emoji: "🍠", rarity: .common),
        GachaItem(id: "c058", name: "ようなし", emoji: "🍐", rarity: .common),
        GachaItem(id: "c059", name: "さかなのほね", emoji: "🐟", rarity: .common),
        GachaItem(id: "c060", name: "まるいぱん", emoji: "🍞", rarity: .common),
        GachaItem(id: "c061", name: "ちいさいかん", emoji: "🥫", rarity: .common),
        GachaItem(id: "c062", name: "ほっとどっぐ", emoji: "🌭", rarity: .common),
        GachaItem(id: "c063", name: "にくとたまごのりょうり", emoji: "🍳", rarity: .common),
        GachaItem(id: "c064", name: "らーめん", emoji: "🍜", rarity: .common),
        GachaItem(id: "c065", name: "かれーらいす", emoji: "🍛", rarity: .common),
        GachaItem(id: "c066", name: "おむらいす", emoji: "🍳", rarity: .common),
        GachaItem(id: "c067", name: "たこやき", emoji: "🐙", rarity: .common),
        GachaItem(id: "c068", name: "たいやき", emoji: "🐟", rarity: .common),
        GachaItem(id: "c069", name: "かきごおり", emoji: "🍧", rarity: .common),
        GachaItem(id: "c070", name: "みたらしだんご", emoji: "🍡", rarity: .common),
        GachaItem(id: "c071", name: "わらびもち", emoji: "🍡", rarity: .common),
        GachaItem(id: "c072", name: "ようかん", emoji: "🍡", rarity: .common),
        GachaItem(id: "c073", name: "かすてら", emoji: "🍰", rarity: .common),
        GachaItem(id: "c074", name: "しゅーくりーむ", emoji: "🍰", rarity: .common),
        GachaItem(id: "c075", name: "まかろん", emoji: "🍬", rarity: .common),
        GachaItem(id: "c076", name: "そふとくりーむ", emoji: "🍦", rarity: .common),
        GachaItem(id: "c077", name: "ぽっぷこーん", emoji: "🍿", rarity: .common),
        GachaItem(id: "c078", name: "おたま", emoji: "🥄", rarity: .common),
        GachaItem(id: "c079", name: "ふらいぱん", emoji: "🍳", rarity: .common),
        GachaItem(id: "c080", name: "ゆのみ", emoji: "🍵", rarity: .common),
        GachaItem(id: "c081", name: "どんぶり", emoji: "🍚", rarity: .common),
        GachaItem(id: "c082", name: "おわん", emoji: "🍚", rarity: .common),
        GachaItem(id: "c083", name: "すぷーん", emoji: "🥄", rarity: .common),
        GachaItem(id: "c084", name: "なぷきん", emoji: "🍽️", rarity: .common),
    ]

    static func item(id: String) -> GachaItem? {
        items.first { $0.id == id }
    }

    static func items(rarity: Rarity) -> [GachaItem] {
        items.filter { $0.rarity == rarity }
    }

    static var goldItems: [GachaItem] { items.filter { $0.isGold } }
    static var standardItems: [GachaItem] { items.filter { !$0.isGold } }
}
// MARK: - 科目

enum Subjects {
    static let all = ["国語", "数学ⅠA", "数学ⅡB", "数学ⅢC", "英語", "化学", "物理", "社会", "その他"]

    static func color(_ subject: String) -> Color {
        switch subject {
        case "国語": return .pink
        case "数学ⅠA": return .blue
        case "数学ⅡB": return .teal
        case "数学ⅢC": return .indigo
        case "英語": return .orange
        case "化学": return .green
        case "物理": return .cyan
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
    var collection: [String: Int] = [:]   // カードID -> 所持数
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
