import SwiftUI

struct GameGridView: View {
    @EnvironmentObject var library: GameLibrary
    @State private var showAdd = false

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(library.games) { game in
                        NavigationLink(destination: GameDetailView(gameID: game.id)) {
                            GameCard(game: game)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("游戏启动器")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) { AddGameView() }
        }
    }
}

struct GameCard: View {
    let game: Game
    var body: some View {
        VStack(spacing: 6) {
            Text(game.icon)
                .font(.system(size: 42))
            Text(game.name)
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(.primary)
            Text(game.kind == .vm ? (game.vmOS?.rawValue ?? "虚拟机") : "独立App")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
