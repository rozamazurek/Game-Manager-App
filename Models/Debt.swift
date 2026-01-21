import Foundation
import SwiftData
import SwiftUI

@Model
class Debt: Identifiable {
    @Attribute(.unique) var id: UUID
    var creditorId: UUID
    var debtorId: UUID
    var amount: Double
    var debtDescription: String
    var date: Date
    var isSettled: Bool
    var gameSessionId: UUID?
    
    init(id: UUID = UUID(),
         creditorId: UUID,
         debtorId: UUID,
         amount: Double,
         debtDescription: String,
         date: Date = Date(),
         isSettled: Bool = false,
         gameSessionId: UUID? = nil) {
        self.id = id
        self.creditorId = creditorId
        self.debtorId = debtorId
        self.amount = amount
        self.debtDescription = debtDescription
        self.date = date
        self.isSettled = isSettled
        self.gameSessionId = gameSessionId
    }
}
