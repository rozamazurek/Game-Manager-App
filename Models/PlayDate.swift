import Foundation
import SwiftData
import SwiftUI

@Model
class PlayDate: Identifiable {
    @Attribute(.unique) var id: UUID
    var gameName: String
    var venue: String
    var date: Date
    
    init(id: UUID = UUID(), gameName: String, venue: String, date: Date) {
        self.id = id
        self.gameName = gameName
        self.venue = venue
        self.date = date
    }
}
