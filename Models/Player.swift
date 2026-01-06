import Foundation
import SwiftUI


struct Player :Identifiable,Hashable{
    let id: UUID
    let nick: String
    var totalPoints: Int
    var gamesPlayed: Int
    var avatarName: String
    
    init(id: UUID = UUID(), nick: String, totalPoints: Int = 0, gamesPlayed: Int = 0, avatarName: String = "person.circle.fill") {
        self.id = id
        self.nick = nick
        self.totalPoints = totalPoints
        self.gamesPlayed = gamesPlayed
        self.avatarName = avatarName
    }
    // Hashable wymaga implementacji hash(into:)
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
    // Equatable (część Hashable)
        static func == (lhs: Player, rhs: Player) -> Bool {
            lhs.id == rhs.id
        }
}

// Dostępne avatary
struct Avatar {
    static let allAvatars = [
        "person.circle.fill",
        "person.fill",
        "person.2.fill",
        "person.3.fill",
        "person.crop.circle.fill",
        "person.crop.square.fill",
        "face.smiling.fill",
        "crown.fill",
        "star.fill",
        "flame.fill",
        "bolt.fill",
        "gamecontroller.fill",
        "suit.spade.fill",
        "suit.heart.fill",
        "suit.club.fill",
        "suit.diamond.fill",
        "dice.fill",
        "trophy.fill",
        "medal.fill",
        "shield.fill"
    ]
    
    static func randomAvatar() -> String {
        return allAvatars.randomElement() ?? "person.circle.fill"
    }
}
