import Foundation

struct GameExpense: Identifiable, Codable {
    let id: UUID
    let payerId: UUID     // kto zapłacił
    let totalAmount: Double
    let description: String
    let date: Date
    let gameType: String
    let participants: [UUID]  // lista ID graczy którzy uczestniczyli
    let splitAmount: Double   // kwota na osobę
    
    init(id: UUID = UUID(),
         payerId: UUID,
         totalAmount: Double,
         description: String,
         date: Date = Date(),
         gameType: String,
         participants: [UUID]) {
        self.id = id
        self.payerId = payerId
        self.totalAmount = totalAmount
        self.description = description
        self.date = date
        self.gameType = gameType
        self.participants = participants
        self.splitAmount = totalAmount / Double(max(participants.count, 1))
    }
}
