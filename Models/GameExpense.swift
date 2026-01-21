import Foundation
import SwiftData
import SwiftUI

@Model
class GameExpense: Identifiable {
    @Attribute(.unique) var id: UUID
    var payerId: UUID
    var totalAmount: Double
    var expenseDescription: String
    var date: Date
    var gameType: String
    var participants: [UUID]
    var splitAmount: Double
    
    init(id: UUID = UUID(),
         payerId: UUID,
         totalAmount: Double,
         expenseDescription: String,
         date: Date = Date(),
         gameType: String,
         participants: [UUID]) {
        self.id = id
        self.payerId = payerId
        self.totalAmount = totalAmount
        self.expenseDescription = expenseDescription
        self.date = date
        self.gameType = gameType
        self.participants = participants
        self.splitAmount = totalAmount / Double(max(participants.count, 1))
    }
}
