import Foundation
import SwiftUI
import SwiftData

class BillardViewModel: ObservableObject {
    @ObservedObject var gameViewModel: GameViewModel

    @Published var selectedPlayers: [Player] = []
    @Published var gamesWinned: String = ""
    @Published var allGames: String = ""

    init(gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
    }

    // Dodawanie punktów – teraz gracz przekazywany z widoku
    func addBillardPoints(player: Player, context: ModelContext) {
        let pointsToAdd = calculatePointsBillard(
            gamesWinned: Int(gamesWinned) ?? 0,
            allGames: Int(allGames) ?? 0
        )
        
        // zmiana bezpośrednio w obiekcie Player
        player.totalPoints += pointsToAdd
        player.gamesPlayed += 1
        
        try? context.save() // zapis w SwiftData
    }

    func calculatePointsBillard(
        gamesWinned: Int,
        allGames: Int
    ) -> Int {
        let basePoints = allGames > 0 ? (gamesWinned % (allGames + 1)) * 10 : 0
        return max(basePoints, 0)
    }

    func resetForm() {
        gamesWinned = ""
        allGames = ""
        selectedPlayers.removeAll()
    }
}

