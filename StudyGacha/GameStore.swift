import Foundation
import SwiftUI

/// ゲーム全体の状態とロジック（コイン、記録、ガチャ、タイマー）
@MainActor
final class GameStore: ObservableObject {
    @Published var state = GameState()

    // タイマー（セッション内のみ保持）
    @Published var timerRunning = false
    @Published var timerSubject = "数学"
    private var timerStartDate: Date?
    private var timerBaseSeconds = 0

    static let singleCost = 100
    static let tenCost = 900

    init() {
        load()
    }

    // MARK: - 保存

    private var saveURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("studygacha-state.json")
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL),
              let decoded = try? JSONDecoder().decode(GameState.self, from: data) else { return }
        state = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(state) {
            try? data.write(to: saveURL, options: .atomic)
        }
    }

    // MARK: - レベル

    var level: Int { state.totalMinutes / 600 + 1 }

    var levelProgress: Double { Double(state.totalMinutes % 600) / 600.0 }

    var minutesToNextLevel: Int { 600 - (state.totalMinutes % 600) }

    var levelTitle: String {
        switch level {
        case ..<3: return "勉強見習い"
        case ..<6: return "駆け出し学習者"
        case ..<10: return "一人前の学習者"
        case ..<15: return "努力の達人"
        case ..<20: return "知識の探求者"
        case ..<30: return "勉強マスター"
        default: return "勉強の神"
        }
    }

    // MARK: - 集計

    func minutes(on day: Date) -> Int {
        let cal = Calendar.current
        return state.records
            .filter { cal.isDate($0.date, inSameDayAs: day) }
            .reduce(0) { $0 + $1.minutes }
    }

    var todayMinutes: Int { minutes(on: Date()) }

    /// 連続勉強日数（今日、なければ昨日から遡る）
    var currentStreak: Int {
        let cal = Calendar.current
        let days = Set(state.records.map { cal.startOfDay(for: $0.date) })
        var streak = 0
        var day = cal.startOfDay(for: Date())
        if !days.contains(day) {
            day = cal.date(byAdding: .day, value: -1, to: day) ?? day
        }
        while days.contains(day) {
            streak += 1
            day = cal.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return streak
    }

    /// 直近7日分（古い順）: (日付, 分)
    var last7Days: [(date: Date, minutes: Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<7).reversed().map { offset in
            let d = cal.date(byAdding: .day, value: -offset, to: today) ?? today
            return (date: d, minutes: minutes(on: d))
        }
    }

    /// 科目別の累計分（多い順）
    var subjectTotals: [(subject: String, minutes: Int)] {
        var map: [String: Int] = [:]
        for r in state.records { map[r.subject, default: 0] += r.minutes }
        return map.map { (subject: $0.key, minutes: $0.value) }
            .sorted { $0.minutes > $1.minutes }
    }

    // MARK: - 記録

    /// 勉強を記録してコインを付与する。獲得内訳を返す
    @discardableResult
    func addRecord(minutes: Int, subject: String, date: Date) -> EarnResult {
        let base = minutes
        let sessionBonus: Int
        switch minutes {
        case 120...: sessionBonus = 50
        case 60...: sessionBonus = 20
        case 30...: sessionBonus = 10
        default: sessionBonus = 0
        }

        let cal = Calendar.current
        let isFirstOfDay = !state.records.contains { cal.isDate($0.date, inSameDayAs: date) }

        let record = StudyRecord(id: UUID(), date: date, minutes: minutes, subject: subject, coinsEarned: 0)
        state.records.append(record)

        var streakBonus = 0
        var streakDays = currentStreak
        if isFirstOfDay {
            streakBonus = min(streakDays * 5, 50)
        } else {
            streakDays = 0
        }

        let total = base + sessionBonus + streakBonus
        state.coins += total
        state.totalMinutes += minutes
        if let idx = state.records.firstIndex(where: { $0.id == record.id }) {
            state.records[idx].coinsEarned = total
        }
        save()
        return EarnResult(minutes: minutes, subject: subject, base: base,
                          sessionBonus: sessionBonus, streakDays: streakDays,
                          streakBonus: streakBonus)
    }

    func deleteRecord(_ record: StudyRecord) {
        state.records.removeAll { $0.id == record.id }
        state.totalMinutes = max(0, state.totalMinutes - record.minutes)
        state.coins = max(0, state.coins - record.coinsEarned)
        save()
    }

    // MARK: - タイマー

    func timerElapsed(now: Date) -> Int {
        var sec = timerBaseSeconds
        if timerRunning, let start = timerStartDate {
            sec += max(0, Int(now.timeIntervalSince(start)))
        }
        return sec
    }

    func timerStart() {
        guard !timerRunning else { return }
        timerStartDate = Date()
        timerRunning = true
    }

    func timerPause() {
        guard timerRunning, let start = timerStartDate else { return }
        timerBaseSeconds += max(0, Int(Date().timeIntervalSince(start)))
        timerStartDate = nil
        timerRunning = false
    }

    func timerReset() {
        timerStartDate = nil
        timerBaseSeconds = 0
        timerRunning = false
    }

    /// タイマーを止めて、その分数を記録する（1分未満はnil）
    func timerFinish(subject: String) -> EarnResult? {
        let seconds = timerElapsed(now: Date())
        let minutes = seconds / 60
        guard minutes >= 1 else { return nil }
        timerReset()
        return addRecord(minutes: minutes, subject: subject, date: Date())
    }

    // MARK: - ガチャ

    func cost(for count: Int) -> Int {
        count == 10 ? Self.tenCost : Self.singleCost
    }

    func canPull(_ count: Int) -> Bool {
        state.coins >= cost(for: count)
    }

    private func rollRarity() -> Rarity {
        let total = Rarity.allCases.reduce(0) { $0 + $1.weight }
        var r = Int.random(in: 0..<total)
        for rarity in Rarity.allCases {
            if r < rarity.weight { return rarity }
            r -= rarity.weight
        }
        return .common
    }

    private func rollHighRarity() -> Rarity {
        // SR以上の重み（14:5:1）で引き直す（10連の確定枠用）
        let pool: [(Rarity, Int)] = [(.superRare, 14), (.ultraRare, 5), (.legend, 1)]
        var r = Int.random(in: 0..<20)
        for (rarity, w) in pool {
            if r < w { return rarity }
            r -= w
        }
        return .superRare
    }

    /// ガチャを回す。コイン不足ならnil
    func pull(_ count: Int) -> [PullResult]? {
        let price = cost(for: count)
        guard state.coins >= price else { return nil }
        state.coins -= price
        state.totalPulls += count

        var rarities = (0..<count).map { _ in rollRarity() }
        if count == 10 && !rarities.contains(where: { $0.rawValue >= Rarity.superRare.rawValue }) {
            rarities[9] = rollHighRarity()
        }

        var results: [PullResult] = []
        for rarity in rarities {
            let candidates = Catalog.items(rarity: rarity)
            guard let item = candidates.randomElement() else { continue }
            let isNew = (state.collection[item.id] ?? 0) == 0
            state.collection[item.id, default: 0] += 1
            var refund = 0
            if !isNew {
                refund = rarity.dupRefund
                state.coins += refund
            }
            results.append(PullResult(item: item, isNew: isNew, refund: refund))
        }
        save()
        return results
    }

    // MARK: - 図鑑

    func ownedCount(itemID: String) -> Int {
        state.collection[itemID] ?? 0
    }

    var ownedKinds: Int {
        state.collection.values.filter { $0 > 0 }.count
    }

    func ownedKinds(rarity: Rarity) -> Int {
        Catalog.items(rarity: rarity).filter { ownedCount(itemID: $0.id) > 0 }.count
    }

    var completionRate: Double {
        Double(ownedKinds) / Double(max(Catalog.items.count, 1))
    }
}
