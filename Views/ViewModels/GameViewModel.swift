import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var players: [Player] = [
        Player(nick:"Roza" ,totalPoints:0,gamesPlayed: 0,avatarName: "trophy.fill"),
        Player(nick:"Matylda" ,totalPoints:0,gamesPlayed: 0,avatarName: "medal.fill"),
        Player(nick:"Martyna" ,totalPoints:0,gamesPlayed: 0,avatarName: "shield.fill"),
        Player(nick:"Olka" ,totalPoints:0,gamesPlayed: 0,avatarName: "person.fill")
    ]
    func addPlayer(nick: String,totalPoints:Int,gamesPlayed:Int,avatarName:String) {
        let newPlayer = Player(nick: nick, totalPoints:totalPoints, gamesPlayed: gamesPlayed,avatarName: avatarName)
        players.append(newPlayer)
    }
}
