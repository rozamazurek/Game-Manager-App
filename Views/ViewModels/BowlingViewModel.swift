import Foundation
import SwiftUI
import SwiftData

class BowlingViewModel: ObservableObject {
    @ObservedObject var gameViewModel: GameViewModel

    @Published var selectedPlayers: [Player] = []
    @Published var numOfPoints = ""
    @Published var numOfGames = ""
    @Published var finalPosition = ""
    @Published var totalPlayers = ""

    init(gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
    }

    // Dodawanie punktów do pojedynczego gracza
    func addBowlingPoints(player: Player, context: ModelContext) {
        let pointsToAdd = calculatePointsBowling(
            numOfPoints: Int(numOfPoints) ?? 0,
            numOfGames: Int(numOfGames) ?? 0,
            finalPosition: Int(finalPosition) ?? 1,
            totalPlayers: Int(totalPlayers) ?? 1
        )

        // teraz gracz przekazywany jest bezpośrednio z widoku
        player.totalPoints += pointsToAdd
        player.gamesPlayed += 1
        // zapis w SwiftData
        try? context.save()
    }

    func calculatePointsBowling(
        numOfPoints: Int,
        numOfGames: Int,
        finalPosition: Int,
        totalPlayers: Int
    ) -> Int {
        let basePoints = (totalPlayers - finalPosition + 1) * 10
        let gamePoints = numOfGames > 0 ? (numOfPoints / (numOfGames + 1)) * 10 : 0
        return max(gamePoints + basePoints, 0)
    }

    func resetForm() {
        numOfPoints = ""
        numOfGames = ""
        finalPosition = ""
        totalPlayers = ""
        selectedPlayers.removeAll()
    }
}
