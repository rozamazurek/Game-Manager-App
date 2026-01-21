import Foundation
import SwiftUI
import SwiftData

@Model
class Settlement: Identifiable {
    @Attribute(.unique) var id: UUID
    var fromPlayerId: UUID
    var toPlayerId: UUID
    var amount: Double
    var date: Date
    var settlementDescription: String
    
    init(id: UUID = UUID(),
         fromPlayerId: UUID,
         toPlayerId: UUID,
         amount: Double,
         date: Date = Date(),
         settlementDescription: String = "Rozliczenie") {
        self.id = id
        self.fromPlayerId = fromPlayerId
        self.toPlayerId = toPlayerId
        self.amount = amount
        self.date = date
        self.settlementDescription = settlementDescription
    }
}
