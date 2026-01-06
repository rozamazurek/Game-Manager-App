import Foundation
import SwiftUI

class BillardViewModel: ObservableObject {
    @ObservedObject var gameViewModel: GameViewModel
    
    @Published var selectedPlayers: [Player] = []
    @Published var gamesWinned: String = ""
    @Published var allGames: String = ""
    
    init(gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
    }
    
    func addBillardPoints(player: Player) {
        let pointsToAdd = calculatePointsBillard(
            gamesWinned: Int(gamesWinned) ?? 0,
            allGames: Int(allGames) ?? 0
        )
        addPointsToPlayer(pointsToAdd: pointsToAdd, player: player)
    }
    
    private func addPointsToPlayer(pointsToAdd: Int, player: Player) {
        if let index = gameViewModel.players.firstIndex(where: { $0.id == player.id }) {
            gameViewModel.players[index].totalPoints += pointsToAdd
            gameViewModel.players[index].gamesPlayed += 1
        }
    }
    
    public func calculatePointsBillard(gamesWinned: Int, allGames: Int) -> Int {
        let basePoints = (gamesWinned%(allGames+1))*10
        return max(basePoints, 0)
    }
    
    func resetForm() {
        gamesWinned = ""
        allGames = ""
        selectedPlayers.removeAll()
    }
}
