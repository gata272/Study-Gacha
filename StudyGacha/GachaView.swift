import SwiftUI

struct RevealSession: Identifiable {
    var id = UUID()
    var count: Int
    var results: [PullResult]
}

struct GachaView: View {
    @EnvironmentObject private var store: GameStore
    @EnvironmentObject private var router: TabRouter
    @State private var session: RevealSession?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("所持コイン")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        Spacer()
                        CoinBadge(amount: store.state.coins, big: true)
                    }

                    machineCard

                    pullButtons

                    ratesCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("ガチャ")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $session) { s in
                GachaRevealView(
                    results: s.results,
                    count: s.count,
                    canAgain: store.canPull(s.count),
                    onAgain: {
                        if let results = store.pull(s.count) {
                            session = RevealSession(count: s.count, results: results)
                        }
                    },
                    onClose: { session = nil }
                )
            }
        }
    }

    // MARK: - ガチャマシン風カード

    @State private var bob = false

    private var machineCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(AppTheme.gradient)
            VStack(spacing: 10) {
                ZStack {
                    ForEach(Array(capsuleSpots.enumerated()), id: \.offset) { _, spot in
                        CapsuleView(color: spot.color, size: spot.size)
                            .rotationEffect(.degrees(spot.rotation))
                            .offset(x: spot.x, y: spot.y)
                    }
                }
                .frame(height: 120)
                .offset(y: bob ? -4 : 4)
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("STUDY GACHA")
                        .fontWeight(.black)
                        .tracking(2)
                    Image(systemName: "sparkles")
                }
                .foregroundStyle(.white)
                Text("勉強で貯めたコインで回そう。全\(Catalog.items.count)種類コンプリートを目指せ！")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(18)
        }
        .shadow(color: Color(red: 0.45, green: 0.25, blue: 0.85).opacity(0.35), radius: 12, y: 6)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                bob = true
            }
        }
    }

    private var capsuleSpots: [(color: Color, x: CGFloat, y: CGFloat, size: CGFloat, rotation: Double)] {
        [
            (Rarity.common.color, -110, 10, 40, -20),
            (Rarity.rare.color, -62, -18, 46, 15),
            (Rarity.superRare.color, -8, 12, 42, -8),
            (Rarity.ultraRare.color, 48, -16, 48, 22),
            (Rarity.legend.color, 104, 8, 44, -14),
            (Rarity.rare.color, -84, 34, 34, 30),
            (Rarity.superRare.color, 22, 38, 36, -26),
            (Rarity.common.color, 88, 36, 32, 10),
        ]
    }

    // MARK: - 回すボタン

    private var pullButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                pullCard(count: 1, title: "1回", badge: nil)
                pullCard(count: 10, title: "10連", badge: "SR以上確定")
            }
            if !store.canPull(1) {
                VStack(spacing: 6) {
                    Text("コインが足りません（あと\(GameStore.singleCost - store.state.coins)コイン）")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("勉強を記録してコインを貯める") {
                        router.tab = 1
                    }
                    .font(.subheadline)
                    .fontWeight(.bold)
                }
            } else if !store.canPull(10) {
                Text("10連まで あと\(GameStore.tenCost - store.state.coins)コイン（10連は100コインお得）")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func pullCard(count: Int, title: String, badge: String?) -> some View {
        Button {
            if let results = store.pull(count) {
                session = RevealSession(count: count, results: results)
            }
        } label: {
            VStack(spacing: 6) {
                if let badge {
                    Text(badge)
                        .font(.caption2)
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(red: 0.95, green: 0.35, blue: 0.62), in: Capsule())
                } else {
                    Text(" ")
                        .font(.caption2)
                        .padding(.vertical, 2)
                }
                Text(title)
                    .font(.title3)
                    .fontWeight(.black)
                HStack(spacing: 4) {
                    CoinIcon(size: 16)
                    Text("\(store.cost(for: count))")
                        .fontWeight(.bold)
                }
                .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!store.canPull(count))
    }

    // MARK: - 提供割合

    private var ratesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("提供割合")
                .font(.headline)
            ForEach(Rarity.allCases.reversed(), id: \.rawValue) { rarity in
                HStack(spacing: 8) {
                    Circle()
                        .fill(rarity.color)
                        .frame(width: 10, height: 10)
                    Text(rarity.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Spacer()
                    Text("図鑑 \(store.ownedKinds(rarity: rarity))/\(Catalog.items(rarity: rarity).count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(rarity.weight)%")
                        .font(.subheadline)
                        .fontWeight(.black)
                        .frame(width: 44, alignment: .trailing)
                }
            }
            Text("ダブったアイテムはレアリティに応じてコインに還元されます（コモン5／レア15／SR40／UR120／レジェンド400）。")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - ガチャ演出

struct GachaRevealView: View {
    var results: [PullResult]
    var count: Int
    var canAgain: Bool
    var onAgain: () -> Void
    var onClose: () -> Void

    @State private var burst = false
    @State private var opened = false
    @State private var spin = false

    private var topRarity: Rarity {
        results.map { $0.item.rarity.rawValue }.max().map { Rarity(rawValue: $0) ?? .common } ?? .common
    }

    private var newCount: Int { results.filter { $0.isNew }.count }
    private var totalRefund: Int { results.reduce(0) { $0 + $1.refund } }

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.06, blue: 0.14)
                .ignoresSafeArea()

            if opened {
                Circle()
                    .fill(topRarity.color.opacity(0.30))
                    .frame(width: 420, height: 420)
                    .blur(radius: 90)
            }

            VStack(spacing: 16) {
                if !opened {
                    Spacer()
                    ZStack {
                        ForEach(0..<8, id: \.self) { i in
                            Image(systemName: "star.fill")
                                .foregroundStyle(topRarity.color)
                                .offset(x: burst ? cos(Double(i) * .pi / 4) * 120 : 0,
                                        y: burst ? sin(Double(i) * .pi / 4) * 120 : 0)
                                .opacity(burst ? 0 : 1)
                        }
                        CapsuleView(color: topRarity.color, size: 128)
                            .scaleEffect(burst ? 1.8 : 1)
                            .opacity(burst ? 0 : 1)
                    }
                    Text("タップで開ける")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.85))
                    Spacer()
                } else {
                    header
                    if count == 1, let first = results.first {
                        Spacer()
                        singleResult(first)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(Array(results.enumerated()), id: \.offset) { i, result in
                                    resultCard(result)
                                        .transition(.scale.combined(with: .opacity))
                                        .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(Double(i) * 0.09), value: opened)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    summaryBar
                    actionButtons
                }
            }
            .padding(.vertical)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !opened { openCapsule() }
        }
        .sensoryFeedback(.success, trigger: opened)
    }

    private func openCapsule() {
        withAnimation(.easeIn(duration: 0.28)) {
            burst = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            opened = true
        }
    }

    private var header: some View {
        VStack(spacing: 2) {
            Text(count == 1 ? "ガチャ結果" : "10連ガチャ結果")
                .font(.title2)
                .fontWeight(.black)
                .foregroundStyle(.white)
            if topRarity.rawValue >= Rarity.ultraRare.rawValue {
                Text(topRarity.name + " 出現！")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundStyle(topRarity.color)
            }
        }
    }

    private func singleResult(_ result: PullResult) -> some View {
        ZStack {
            if result.item.rarity.rawValue >= Rarity.ultraRare.rawValue {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 300))
                    .foregroundStyle(topRarity.color.opacity(0.25))
                    .rotationEffect(.degrees(spin ? 360 : 0))
                    .onAppear {
                        withAnimation(.linear(duration: 24).repeatForever(autoreverses: false)) {
                            spin = true
                        }
                    }
            }
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(result.item.rarity.color.opacity(0.22))
                    Image(systemName: result.item.symbol)
                        .font(.system(size: 96))
                        .foregroundStyle(result.item.rarity.color)
                }
                .frame(width: 190, height: 190)
                .shadow(color: result.item.rarity.color.opacity(0.8), radius: 24)
                RarityTag(rarity: result.item.rarity)
                Text(result.item.name)
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundStyle(.white)
                Text(result.item.flavor)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                badge(for: result)
            }
        }
        .transition(.scale.combined(with: .opacity))
    }

    private func resultCard(_ result: PullResult) -> some View {
        VStack(spacing: 2) {
            ItemCardView(item: result.item)
                .shadow(color: result.item.rarity.color.opacity(result.item.rarity.rawValue >= Rarity.superRare.rawValue ? 0.7 : 0), radius: 10)
            badge(for: result)
        }
    }

    @ViewBuilder
    private func badge(for result: PullResult) -> some View {
        if result.isNew {
            Text("NEW!")
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(red: 0.95, green: 0.35, blue: 0.62), in: Capsule())
        } else {
            HStack(spacing: 3) {
                CoinIcon(size: 12)
                Text("+\(result.refund) 還元")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
    }

    private var summaryBar: some View {
        HStack(spacing: 14) {
            Label("新規 \(newCount) 種類", systemImage: "sparkles")
            if totalRefund > 0 {
                HStack(spacing: 4) {
                    CoinIcon(size: 14)
                    Text("還元 +\(totalRefund)")
                }
            }
        }
        .font(.subheadline)
        .fontWeight(.bold)
        .foregroundStyle(.white)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                onClose()
            } label: {
                Text("閉じる")
                    .fontWeight(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .tint(.white)

            Button {
                onAgain()
            } label: {
                Text(count == 1 ? "もう1回" : "もう10連")
                    .fontWeight(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canAgain)
        }
        .padding(.horizontal)
    }
}
