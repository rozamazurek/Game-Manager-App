import Foundation
import SwiftUI

class BowlingViewModel: ObservableObject {
    @ObservedObject var gameViewModel: GameViewModel
    @Published var selectedPlayers: [Player] = []
    @Published var numOfPoints: String = ""
    @Published var numOfGames: String = ""
    @Published var finalPosition: String = ""
    @Published var totalPlayers: String = ""
    
    init(gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
    }
    
    func addBowlingPoints(player: Player) {
        let pointsToAdd = calculatePointsBowling(
            numOfPoints: Int(numOfPoints) ?? 0,
            numOfGames: Int(numOfGames) ?? 0,
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
    
    public func calculatePointsBowling(numOfPoints: Int, numOfGames: Int, finalPosition: Int, totalPlayers: Int) -> Int {
        let basePoints = (totalPlayers - finalPosition + 1) * 10
        let gamePoints = numOfPoints/(numOfGames+1)*10
        let netPoints = gamePoints + basePoints
        return max(netPoints, 0)
    }
    
    func resetForm() {
        numOfPoints = ""
        numOfGames = ""
        finalPosition = ""
        totalPlayers = ""
        selectedPlayers.removeAll()
    }
}
