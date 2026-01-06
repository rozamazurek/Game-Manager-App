import Foundation

struct Debt: Identifiable, Codable {
    let id: UUID
    let creditorId: UUID  // kto pożyczył
    let debtorId: UUID    // kto jest winien
    let amount: Double
    let description: String
    let date: Date
    let isSettled: Bool
    let gameSessionId: UUID?  
    
    init(id: UUID = UUID(),
         creditorId: UUID,
         debtorId: UUID,
         amount: Double,
         description: String,
         date: Date = Date(),
         isSettled: Bool = false,
         gameSessionId: UUID? = nil) {
        self.id = id
        self.creditorId = creditorId
        self.debtorId = debtorId
        self.amount = amount
        self.description = description
        self.date = date
        self.isSettled = isSettled
        self.gameSessionId = gameSessionId
    }
}
