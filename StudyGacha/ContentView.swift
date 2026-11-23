import SwiftUI

/// タブ切り替えを他の画面からも行うためのルーター
final class TabRouter: ObservableObject {
    @Published var tab: Int = 0
}

struct ContentView: View {
    @StateObject private var store = GameStore()
    @StateObject private var router = TabRouter()

    var body: some View {
        TabView(selection: $router.tab) {
            HomeView()
                .tabItem { Label("ホーム", systemImage: "house.fill") }
                .tag(0)
            RecordView()
                .tabItem { Label("記録", systemImage: "timer") }
                .tag(1)
            GachaView()
                .tabItem { Label("ガチャ", systemImage: "gift.fill") }
                .tag(2)
            CollectionView()
                .tabItem { Label("バッジ", systemImage: "medal.fill") }
                .tag(3)
        }
        .environmentObject(store)
        .environmentObject(router)
        .tint(Color(red: 0.55, green: 0.30, blue: 0.95))
    }
}
