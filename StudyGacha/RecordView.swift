import SwiftUI

struct RecordView: View {
    @EnvironmentObject private var store: GameStore
    @State private var mode: Int = 0   // 0=タイマー 1=手入力
    @State private var manualMinutes: Int = 30
    @State private var manualSubject: String = "数学"
    @State private var manualDate: Date = Date()
    @State private var earn: EarnResult?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("記録方法", selection: $mode) {
                        Text("タイマー").tag(0)
                        Text("手入力").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                if mode == 0 {
                    timerSection
                } else {
                    manualSection
                }

                historySection
            }
            .navigationTitle("勉強を記録")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $earn) { result in
                EarnSheet(result: result)
            }
        }
    }

    // MARK: - 科目チップ

    private func subjectChips(selection: Binding<String>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Subjects.all, id: \.self) { subject in
                    Button {
                        selection.wrappedValue = subject
                    } label: {
                        Text(subject)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 7)
                            .background(
                                selection.wrappedValue == subject
                                    ? Subjects.color(subject)
                                    : Color(.systemGray5),
                                in: Capsule())
                            .foregroundStyle(selection.wrappedValue == subject ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - タイマー

    private var timerSection: some View {
        Section("タイマーで計る") {
            subjectChips(selection: $store.timerSubject)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            TimelineView(.periodic(from: Date(), by: 1)) { context in
                Text(SFmt.clock(seconds: store.timerElapsed(now: context.date)))
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))

            HStack(spacing: 10) {
                if store.timerRunning {
                    Button {
                        store.timerPause()
                    } label: {
                        Label("一時停止", systemImage: "pause.fill")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button {
                        store.timerStart()
                    } label: {
                        Label(store.timerElapsed(now: Date()) > 0 ? "再開" : "スタート", systemImage: "play.fill")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                }
                Button(role: .destructive) {
                    store.timerReset()
                } label: {
                    Label("リセット", systemImage: "arrow.counterclockwise")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.bordered)
                .disabled(store.timerElapsed(now: Date()) == 0)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            Button {
                if let result = store.timerFinish(subject: store.timerSubject) {
                    earn = result
                }
            } label: {
                Label("勉強を終えて記録する", systemImage: "checkmark.circle.fill")
                    .fontWeight(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(store.timerElapsed(now: Date()) < 60)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16))

            Text("1分以上計ると記録できます。タイマーは他のタブに移っても進み続けます（アプリを終了するとリセットされます）。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - 手入力

    private var manualSection: some View {
        Section("時間を選んで記録") {
            subjectChips(selection: $manualSubject)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            HStack {
                Text("勉強時間")
                    .fontWeight(.bold)
                Spacer()
                Text(SFmt.minutes(manualMinutes))
                    .font(.title3)
                    .fontWeight(.black)
            }
            Stepper("5分単位で調整", value: $manualMinutes, in: 5...600, step: 5)
                .font(.subheadline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach([15, 30, 45, 60, 90, 120], id: \.self) { m in
                        Button("\(m)分") {
                            manualMinutes = m
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .tint(manualMinutes == m ? .purple : .gray)
                    }
                }
                .padding(.vertical, 2)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            DatePicker("日付", selection: $manualDate, in: ...Date(), displayedComponents: .date)

            Button {
                earn = store.addRecord(minutes: manualMinutes, subject: manualSubject, date: manualDate)
            } label: {
                Label("この内容で記録する", systemImage: "plus.circle.fill")
                    .fontWeight(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16))

            Text("コインは 1分 = 1コイン。30分以上で +10、60分以上で +20、120分以上で +50 の長時間ボーナス、その日最初の記録には連続日数ボーナス（最大+50）が付きます。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - 履歴

    private var sortedRecords: [StudyRecord] {
        store.state.records.sorted { $0.date > $1.date }
    }

    private var historySection: some View {
        Section("最近の記録") {
            if sortedRecords.isEmpty {
                Text("まだ記録がありません。")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(sortedRecords.prefix(50))) { record in
                    RecordRowView(record: record)
                }
                .onDelete { offsets in
                    let visible = Array(sortedRecords.prefix(50))
                    for idx in offsets {
                        store.deleteRecord(visible[idx])
                    }
                }
            }
        }
    }
}

/// 履歴の1行
struct RecordRowView: View {
    var record: StudyRecord

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Subjects.color(record.subject))
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 1) {
                Text(record.subject)
                    .fontWeight(.bold)
                Text(dateLabel(record.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text(SFmt.minutes(record.minutes))
                    .fontWeight(.black)
                HStack(spacing: 3) {
                    CoinIcon(size: 12)
                    Text("+\(record.coinsEarned)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }

    private func dateLabel(_ d: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(d) { return "今日" }
        if cal.isDateInYesterday(d) { return "昨日" }
        let c = cal.dateComponents([.year, .month, .day], from: d)
        return "\(c.year ?? 0)/\(c.month ?? 0)/\(c.day ?? 0)"
    }
}

/// 記録完了の祝福シート
struct EarnSheet: View {
    var result: EarnResult
    @Environment(\.dismiss) private var dismiss
    @State private var showCoin = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            CoinIcon(size: 84)
                .scaleEffect(showCoin ? 1 : 0.3)
                .opacity(showCoin ? 1 : 0)
            Text("おつかれさま！")
                .font(.title)
                .fontWeight(.black)
            Text("\(result.subject) を \(SFmt.minutes(result.minutes)) 勉強しました")
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                earnRow(title: "基本（\(result.minutes)分）", value: result.base)
                if result.sessionBonus > 0 {
                    earnRow(title: "長時間ボーナス", value: result.sessionBonus)
                }
                if result.streakBonus > 0 {
                    earnRow(title: "連続\(result.streakDays)日ボーナス", value: result.streakBonus)
                }
                Divider()
                HStack {
                    Text("合計")
                        .fontWeight(.black)
                    Spacer()
                    HStack(spacing: 5) {
                        CoinIcon(size: 18)
                        Text("+\(result.total)")
                            .font(.title3)
                            .fontWeight(.black)
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)

            Button {
                dismiss()
            } label: {
                Text("閉じる")
                    .fontWeight(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            Spacer()
        }
        .presentationDetents([.medium])
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.55)) {
                showCoin = true
            }
        }
    }

    private func earnRow(title: String, value: Int) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("+\(value)")
                .fontWeight(.bold)
        }
    }
}
