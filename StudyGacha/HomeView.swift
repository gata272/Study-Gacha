import SwiftUI
import Charts

struct HomeView: View {
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var router: TabRouter

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    todayRow
                    actionRow
                    weekChartCard
                    subjectCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("スタディガチャ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - ヘッダー（レベルとコイン）

    private var headerCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(AppTheme.gradient)
            VStack(spacing: 14) {
                HStack(alignment: .center, spacing: 14) {
                    levelRing
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Lv.\(store.level)")
                            .font(.system(size: 30, weight: .black))
                            .foregroundStyle(.white)
                        Text(store.levelTitle)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.9))
                        Text("次のレベルまで あと\(store.minutesToNextLevel)分")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    Spacer()
                }
                HStack {
                    Label("累計 \(SFmt.minutes(store.state.totalMinutes))", systemImage: "clock.fill")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                    CoinBadge(amount: store.state.coins, big: true)
                }
            }
            .padding(18)
        }
        .shadow(color: Color(red: 0.45, green: 0.25, blue: 0.85).opacity(0.35), radius: 12, y: 6)
    }

    private var levelRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 7)
            Circle()
                .trim(from: 0, to: store.levelProgress)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: store.levelProgress)
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 22))
                .foregroundStyle(.white)
        }
        .frame(width: 68, height: 68)
    }

    // MARK: - 今日の記録

    private var todayRow: some View {
        HStack(spacing: 12) {
            miniStat(icon: "book.fill", color: .blue,
                     title: "今日の勉強", value: SFmt.minutes(store.todayMinutes))
            miniStat(icon: "flame.fill", color: .orange,
                     title: "連続日数", value: "\(store.currentStreak)日")
            miniStat(icon: "gift.fill", color: .purple,
                     title: "ガチャ回数", value: "\(store.state.totalPulls)回")
        }
    }

    private func miniStat(icon: String, color: Color, title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
                .fontWeight(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - クイックアクション

    private var actionRow: some View {
        HStack(spacing: 12) {
            Button {
                router.tab = 1
            } label: {
                Label("勉強を記録", systemImage: "timer")
                    .fontWeight(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
            }
            .buttonStyle(.borderedProminent)

            Button {
                router.tab = 2
            } label: {
                Label("ガチャを回す", systemImage: "sparkles")
                    .fontWeight(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
            }
            .buttonStyle(.bordered)
        }
    }

    // MARK: - 週間グラフ

    private var weekChartCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("最近7日の勉強時間")
                .font(.headline)
            Chart(store.last7Days, id: \.date) { day in
                BarMark(
                    x: .value("曜日", weekdayLabel(day.date)),
                    y: .value("分", day.minutes)
                )
                .foregroundStyle(
                    Calendar.current.isDateInToday(day.date)
                        ? Color(red: 0.95, green: 0.35, blue: 0.62)
                        : Color(red: 0.55, green: 0.30, blue: 0.95))
                .cornerRadius(4)
            }
            .chartYAxisLabel("分")
            .frame(height: 150)
            Text("今日は \(SFmt.minutes(store.todayMinutes)) 勉強しました")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func weekdayLabel(_ d: Date) -> String {
        let wd = Calendar.current.component(.weekday, from: d)
        return SFmt.weekdayNames[wd - 1]
    }

    // MARK: - 科目別

    private var subjectCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("科目別の累計")
                .font(.headline)
            if store.subjectTotals.isEmpty {
                Text("まだ記録がありません。記録タブから勉強を記録してみましょう。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(store.subjectTotals, id: \.subject) { row in
                    subjectRow(row)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func subjectRow(_ row: (subject: String, minutes: Int)) -> some View {
        let maxMinutes = max(store.subjectTotals.first?.minutes ?? 1, 1)
        return VStack(spacing: 4) {
            HStack {
                Circle()
                    .fill(Subjects.color(row.subject))
                    .frame(width: 9, height: 9)
                Text(row.subject)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                Text(SFmt.minutes(row.minutes))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.systemGray5))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Subjects.color(row.subject))
                        .frame(width: geo.size.width * CGFloat(row.minutes) / CGFloat(maxMinutes))
                }
            }
            .frame(height: 6)
        }
    }
}
