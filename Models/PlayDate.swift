import Foundation

struct PlayDate: Identifiable {
    let id = UUID()
    let gameName: String
    let venue: String
    let date: Date
}
