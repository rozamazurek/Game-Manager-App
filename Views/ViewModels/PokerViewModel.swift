import Foundation
import SwiftUI
import SwiftData

class PokerViewModel: ObservableObject {
    @ObservedObject var gameViewModel: GameViewModel

    @Published var selectedPlayers: [Player] = []
    @Published var numTokens: String = ""
    @Published var moneyPut: String = ""
    @Published var finalPosition: String = ""
    @Published var totalPlayers: String = ""

    init(gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
    }

    func addPokerPoints(player: Player, context: ModelContext) {
        let pointsToAdd = calculatePointsPoker(
            numTokens: Int(numTokens) ?? 0,
            moneyPut: Int(moneyPut) ?? 0,
            finalPosition: Int(finalPosition) ?? 1,
            totalPlayers: Int(totalPlayers) ?? 1
        )
        addPointsToPlayer(pointsToAdd: pointsToAdd, player: player, context: context)
    }

    private func addPointsToPlayer(pointsToAdd: Int, player: Player, context: ModelContext) {
        // Jeśli player już istnieje w SwiftData, SwiftData śledzi zmiany automatycznie
        
            player.totalPoints += pointsToAdd
            player.gamesPlayed += 1
            // Nie trzeba insert, SwiftData automatycznie zapisze zmiany przy commit (np. w widoku)
        
    }

    func calculatePointsPoker(numTokens: Int, moneyPut: Int, finalPosition: Int, totalPlayers: Int) -> Int {
        let basePoints = (totalPlayers - finalPosition + 1) * 10
        let tokenPoints = numTokens * 2
        let netPoints = tokenPoints - moneyPut + basePoints
        return max(netPoints, 0)
    }

    func resetForm() {
        numTokens = ""
        moneyPut = ""
        finalPosition = ""
        totalPlayers = ""
        selectedPlayers.removeAll()
    }
}

