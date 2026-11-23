import SwiftUI

struct CollectionView: View {
    @EnvironmentObject private var store: GameStore
    @State private var kindFilter: Int = 0   // 0=すべて 1=ゴールド 2=標準
    @State private var rarityFilter: Rarity? = nil
    @State private var selected: GachaItem?

    private var shownItems: [GachaItem] {
        Catalog.items.filter { item in
            (kindFilter == 0 || (kindFilter == 1) == item.isGold) &&
            (rarityFilter == nil || item.rarity == rarityFilter)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    progressCard
                    filterRows
                    if shownItems.isEmpty {
                        Text("この条件のバッジはありません。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 24)
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(shownItems) { item in
                                let count = store.ownedCount(itemID: item.id)
                                Button {
                                    if count > 0 { selected = item }
                                } label: {
                                    ItemCardView(item: item, ownedCount: count, dimmed: count == 0)
                                }
                                .buttonStyle(.plain)
                                .disabled(count == 0)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("バッジ図鑑")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selected) { item in
                ItemDetailSheet(item: item, count: store.ownedCount(itemID: item.id))
            }
        }
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(store.ownedKinds)")
                    .font(.system(size: 34, weight: .black))
                Text("取得バッジ数（全\(Catalog.items.count)種類中）")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.1f%%", store.completionRate * 100))
                    .font(.title3)
                    .fontWeight(.black)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppTheme.gradient)
                        .frame(width: geo.size.width * CGFloat(store.completionRate))
                }
            }
            .frame(height: 12)
            HStack(spacing: 16) {
                HStack(spacing: 5) {
                    CoinIcon(size: 14)
                    Text("ゴールドバッジ \(store.ownedGoldKinds)/\(Catalog.goldItems.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                HStack(spacing: 5) {
                    Image(systemName: "medal.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    Text("標準バッジ \(store.ownedStandardKinds)/\(Catalog.standardItems.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                Spacer()
            }
            HStack {
                ForEach(Rarity.allCases, id: \.rawValue) { rarity in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(rarity.color)
                            .frame(width: 8, height: 8)
                        Text("\(rarity.shortName) \(store.ownedKinds(rarity: rarity))/\(Catalog.items(rarity: rarity).count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if rarity != Rarity.allCases.last {
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private var filterRows: some View {
        VStack(spacing: 8) {
            Picker("バッジの種類", selection: $kindFilter) {
                Text("すべて").tag(0)
                Text("ゴールド").tag(1)
                Text("標準").tag(2)
            }
            .pickerStyle(.segmented)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip(label: "全レアリティ", active: rarityFilter == nil) { rarityFilter = nil }
                    ForEach(Rarity.allCases, id: \.rawValue) { rarity in
                        chip(label: rarity.name, active: rarityFilter == rarity) { rarityFilter = rarity }
                    }
                }
                .padding(.vertical, 1)
            }
        }
    }

    private func chip(label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.horizontal, 13)
                .padding(.vertical, 7)
                .background(active ? Color(red: 0.55, green: 0.30, blue: 0.95) : Color(.systemGray5), in: Capsule())
                .foregroundStyle(active ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

/// バッジ詳細シート
struct ItemDetailSheet: View {
    var item: GachaItem
    var count: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            BadgeMedalView(item: item, size: 150)
                .shadow(color: item.rarity.color.opacity(0.5), radius: 16)
            HStack(spacing: 6) {
                if item.isGold {
                    Text("ゴールドバッジ")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(Color(red: 0.45, green: 0.28, blue: 0.0))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(AppTheme.coinGradient, in: Capsule())
                } else {
                    Text("標準バッジ")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Color(.systemGray), in: Capsule())
                }
                RarityTag(rarity: item.rarity)
            }
            Text(item.name)
                .font(.title2)
                .fontWeight(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Label("所持数 ×\(count)", systemImage: "square.stack.3d.up.fill")
                .font(.headline)
                .foregroundStyle(.secondary)
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
    }
}
