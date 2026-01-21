import Foundation
import SwiftUI
import SwiftData

@Model
class Player: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var nick: String
    var totalPoints: Int
    var gamesPlayed: Int
    var avatarName: String
    
    init(id: UUID = UUID(),nick: String, totalPoints: Int = 0, gamesPlayed: Int = 0, avatarName: String = "person.circle.fill") {
        self.id = id
        self.nick = nick
        self.totalPoints = totalPoints
        self.gamesPlayed = gamesPlayed
        self.avatarName = avatarName
    }
    
    // Hashable
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Player, rhs: Player) -> Bool { lhs.id == rhs.id }
}

// Avatary pozostają bez zmian
struct Avatar {
    static let allAvatars = [
        "person.circle.fill", "person.fill", "person.2.fill",
        "person.3.fill", "person.crop.circle.fill", "person.crop.square.fill",
        "face.smiling.fill", "crown.fill", "star.fill",
        "flame.fill", "bolt.fill", "gamecontroller.fill",
        "suit.spade.fill", "suit.heart.fill", "suit.club.fill",
        "suit.diamond.fill", "dice.fill", "trophy.fill",
        "medal.fill", "shield.fill"
    ]
    static func randomAvatar() -> String { allAvatars.randomElement() ?? "person.circle.fill" }
}
