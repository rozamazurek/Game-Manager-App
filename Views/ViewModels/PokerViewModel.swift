import Foundation
import SwiftUI

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
    
    func addPokerPoints(player: Player) {
        let pointsToAdd = calculatePointsPoker(
            numTokens: Int(numTokens) ?? 0,
            moneyPut: Int(moneyPut) ?? 0,
            finalPosition: Int(finalPosition) ?? 1,
            totalPlayers: Int(totalPlayers) ?? 1
        )
        addPointsToPlayer(pointsToAdd: pointsToAdd, player: player)
    }
    
    private func addPointsToPlayer(pointsToAdd: Int, player: Player) {
        if let index = gameViewModel.players.firstIndex(where: { $0.id == player.id }) {
            gameViewModel.players[index].totalPoints += pointsToAdd
            gameViewModel.players[index].gamesPlayed += 1
        }
    }
    
    public func calculatePointsPoker(numTokens: Int, moneyPut: Int, finalPosition: Int, totalPlayers: Int) -> Int {
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
