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

/// アイテムのカード（図鑑グリッドとガチャ結果で共用）
struct ItemCardView: View {
    var item: GachaItem
    var ownedCount: Int? = nil     // nilなら所持数を出さない
    var dimmed: Bool = false       // 未所持表示

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(item.rarity.color.opacity(dimmed ? 0.10 : 0.18))
                Image(systemName: dimmed ? "questionmark" : item.symbol)
                    .font(.system(size: 30))
                    .foregroundStyle(dimmed ? Color.secondary : item.rarity.color)
            }
            .frame(height: 64)
            .overlay(alignment: .topLeading) {
                RarityTag(rarity: item.rarity)
                    .padding(5)
                    .opacity(dimmed ? 0.35 : 1)
            }
            .overlay(alignment: .topTrailing) {
                if let count = ownedCount, count > 1 {
                    Text("×\(count)")
                        .font(.caption2)
                        .fontWeight(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemBackground), in: Capsule())
                        .padding(5)
                }
            }

            Text(dimmed ? "？？？" : item.name)
                .font(.caption)
                .fontWeight(.bold)
                .lineLimit(1)
                .foregroundStyle(dimmed ? .secondary : .primary)
        }
        .padding(8)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
