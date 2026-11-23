import SwiftUI

struct CollectionView: View {
    @EnvironmentObject private var store: GameStore
    @State private var filter: Rarity? = nil   // nil = すべて
    @State private var selected: GachaItem?

    private var shownItems: [GachaItem] {
        if let filter {
            return Catalog.items(rarity: filter)
        }
        return Catalog.items
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    progressCard
                    filterRow
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
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("図鑑")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selected) { item in
                ItemDetailSheet(item: item, count: store.ownedCount(itemID: item.id))
            }
        }
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("コンプリート率")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(store.ownedKinds) / \(Catalog.items.count) 種類")
                    .font(.headline)
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

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "すべて", rarity: nil)
                ForEach(Rarity.allCases, id: \.rawValue) { rarity in
                    filterChip(label: rarity.name, rarity: rarity)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func filterChip(label: String, rarity: Rarity?) -> some View {
        let isActive = filter == rarity
        return Button {
            filter = rarity
        } label: {
            Text(label)
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.horizontal, 13)
                .padding(.vertical, 7)
                .background(isActive ? (rarity?.color ?? Color(red: 0.55, green: 0.30, blue: 0.95)) : Color(.systemGray5), in: Capsule())
                .foregroundStyle(isActive ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

/// アイテム詳細シート
struct ItemDetailSheet: View {
    var item: GachaItem
    var count: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(item.rarity.color.opacity(0.20))
                Image(systemName: item.symbol)
                    .font(.system(size: 84))
                    .foregroundStyle(item.rarity.color)
            }
            .frame(width: 170, height: 170)
            .shadow(color: item.rarity.color.opacity(0.5), radius: 16)

            RarityTag(rarity: item.rarity)
            Text(item.name)
                .font(.title)
                .fontWeight(.black)
            Text(item.flavor)
                .font(.subheadline)
                .foregroundStyle(.secondary)
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
