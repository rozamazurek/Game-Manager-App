import Foundation
import SwiftUI
import SwiftData


class MoneyViewModel: ObservableObject {


    func addDebt(creditorId: UUID, debtorId: UUID, amount: Double, description: String, gameSessionId: UUID? = nil, context: ModelContext) {
        let newDebt = Debt(
            creditorId: creditorId,
            debtorId: debtorId,
            amount: amount,
            debtDescription: description,
            gameSessionId: gameSessionId
        )
        context.insert(newDebt)
    }

    func addGameExpense(payerId: UUID, totalAmount: Double, description: String, gameType: String, participants: [UUID], context: ModelContext) {
        let expense = GameExpense(
            payerId: payerId,
            totalAmount: totalAmount,
            expenseDescription: description,
            gameType: gameType,
            participants: participants
        )
        context.insert(expense)

        // długi dla wszystkich uczestników
        for participantId in participants where participantId != payerId {
            addDebt(
                creditorId: payerId,
                debtorId: participantId,
                amount: expense.splitAmount,
                description: "Udział w \(description)",
                gameSessionId: expense.id,
                context: context
            )
        }

        try? context.save()
    }

    func settleDebt(debt: Debt, context: ModelContext) {
        debt.isSettled = true
    }

    func addSettlement(fromPlayerId: UUID, toPlayerId: UUID, amount: Double, description: String, context: ModelContext) {
        let settlement = Settlement(
            fromPlayerId: fromPlayerId,
            toPlayerId: toPlayerId,
            amount: amount,
            settlementDescription: description
        )
        context.insert(settlement)
    }


    func calculateNetBalance(for playerId: UUID, debts: [Debt]) -> Double {
        let owedToMe = debts.filter { $0.creditorId == playerId && !$0.isSettled }
        let myDebts = debts.filter { $0.debtorId == playerId && !$0.isSettled }
        return owedToMe.reduce(0) { $0 + $1.amount } - myDebts.reduce(0) { $0 + $1.amount }
    }

    func getDebtsForPlayer(playerId: UUID, debts: [Debt]) -> (owedToPlayer: [Debt], playerOwes: [Debt]) {
        let owedToPlayer = debts.filter { $0.creditorId == playerId && !$0.isSettled }
        let playerOwes = debts.filter { $0.debtorId == playerId && !$0.isSettled }
        return (owedToPlayer, playerOwes)
    }


    func calculateTotals(debts: [Debt], gameExpenses: [GameExpense], settlements: [Settlement]) -> (totalDebt: Double, totalExpenses: Double, totalSettled: Double) {
        let totalDebt = debts.filter { !$0.isSettled }.reduce(0) { $0 + $1.amount }
        let totalExpenses = gameExpenses.reduce(0) { $0 + $1.totalAmount }
        let totalSettled = settlements.reduce(0) { $0 + $1.amount }
        return (totalDebt, totalExpenses, totalSettled)
    }
}

