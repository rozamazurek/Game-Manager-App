import Foundation
import SwiftUI
import SwiftData

class GameViewModel: ObservableObject {

    func addPlayer(nick: String, totalPoints: Int = 0, gamesPlayed: Int = 0, avatarName: String, context: ModelContext) {
        let newPlayer = Player(
            nick: nick,
            totalPoints: totalPoints,
            gamesPlayed: gamesPlayed,
            avatarName: avatarName
        )
        context.insert(newPlayer)
    }
}

