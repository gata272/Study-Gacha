import SwiftUI

enum AppTheme {
    static let gradient = LinearGradient(
        colors: [Color(red: 0.30, green: 0.22, blue: 0.78),
                 Color(red: 0.62, green: 0.27, blue: 0.90),
                 Color(red: 0.95, green: 0.35, blue: 0.62)],
        startPoint: .topLeading, endPoint: .bottomTrailing)

    static let coinGradient = LinearGradient(
        colors: [Color(red: 1.0, green: 0.85, blue: 0.30),
                 Color(red: 0.98, green: 0.62, blue: 0.10)],
        startPoint: .top, endPoint: .bottom)
}

/// 金色のコインアイコン
struct CoinIcon: View {
    var size: CGFloat = 20

    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.coinGradient)
                .overlay(Circle().stroke(Color.orange.opacity(0.6), lineWidth: 1))
            Image(systemName: "star.fill")
                .font(.system(size: size * 0.52, weight: .bold))
                .foregroundStyle(Color(red: 0.85, green: 0.50, blue: 0.05))
        }
        .frame(width: size, height: size)
    }
}

/// コイン残高の表示
struct CoinBadge: View {
    var amount: Int
    var big: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            CoinIcon(size: big ? 26 : 20)
            Text("\(amount)")
                .font(big ? .title3 : .body)
                .fontWeight(.black)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color(.secondarySystemGroupedBackground), in: Capsule())
    }
}

/// ガチャカプセル（上が色、下が白のツートーン）
struct CapsuleView: View {
    var color: Color
    var size: CGFloat = 36

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                color
                Color.white
            }
            Rectangle()
                .fill(Color.black.opacity(0.10))
                .frame(height: max(2, size * 0.05))
            Circle()
                .fill(Color.white)
                .overlay(Circle().stroke(Color.black.opacity(0.15), lineWidth: 1))
                .frame(width: size * 0.26, height: size * 0.26)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.black.opacity(0.12), lineWidth: 1))
        .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
    }
}

/// レアリティの小タグ
struct RarityTag: View {
    var rarity: Rarity

    var body: some View {
        Text(rarity.name)
            .font(.caption2)
            .fontWeight(.black)
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(rarity.color, in: Capsule())
    }
}

/// バッジのメダル表示（ゴールドバッジは金色、標準バッジは銀色のメダル）
struct BadgeMedalView: View {
    var item: GachaItem
    var size: CGFloat = 64
    var dimmed: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    dimmed
                        ? LinearGradient(colors: [Color(.systemGray4), Color(.systemGray5)], startPoint: .top, endPoint: .bottom)
                        : item.isGold
                            ? AppTheme.coinGradient
                            : LinearGradient(colors: [Color(red: 0.92, green: 0.93, blue: 0.96), Color(red: 0.78, green: 0.80, blue: 0.86)], startPoint: .top, endPoint: .bottom)
                )
                .overlay(
                    Circle().stroke(
                        dimmed ? Color(.systemGray3) : item.isGold ? Color.orange.opacity(0.7) : item.rarity.color.opacity(0.65),
                        lineWidth: max(2, size * 0.045))
                )
                .shadow(color: .black.opacity(0.15), radius: 3, y: 2)
            if dimmed {
                Text("？")
                    .font(.system(size: size * 0.42, weight: .black))
                    .foregroundStyle(Color(.systemGray2))
            } else {
                Text(item.emoji)
                    .font(.system(size: size * 0.52))
            }
        }
        .frame(width: size, height: size)
    }
}

/// バッジのカード表示（図鑑グリッドとガチャ結果で共用）
struct ItemCardView: View {
    var item: GachaItem
    var ownedCount: Int? = nil     // nilなら所持数を出さない
    var dimmed: Bool = false       // 未所持表示

    var body: some View {
        VStack(spacing: 5) {
            BadgeMedalView(item: item, size: 56, dimmed: dimmed)
                .overlay(alignment: .topTrailing) {
                    if let count = ownedCount, count > 1 {
                        Text("×\(count)")
                            .font(.caption2)
                            .fontWeight(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.systemBackground), in: Capsule())
                            .offset(x: 10, y: -4)
                    }
                }
            Text(dimmed ? "？？？" : item.name)
                .font(.caption2)
                .fontWeight(.bold)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundStyle(dimmed ? .secondary : .primary)
            RarityTag(rarity: item.rarity)
                .opacity(dimmed ? 0.35 : 1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(item.isGold && !dimmed ? Color.orange.opacity(0.6) : Color.clear, lineWidth: 1.2)
        )
    }
}
