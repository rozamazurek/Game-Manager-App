import Foundation

struct Settlement: Identifiable, Codable {
    let id: UUID
    let fromPlayerId: UUID
    let toPlayerId: UUID
    let amount: Double
    let date: Date
    let description: String
    
    init(id: UUID = UUID(),
         fromPlayerId: UUID,
         toPlayerId: UUID,
         amount: Double,
         date: Date = Date(),
         description: String = "Rozliczenie") {
        self.id = id
        self.fromPlayerId = fromPlayerId
        self.toPlayerId = toPlayerId
        self.amount = amount
        self.date = date
        self.description = description
    }
}
