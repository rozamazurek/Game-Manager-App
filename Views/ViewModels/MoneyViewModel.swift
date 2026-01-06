import Foundation
import SwiftUI

class MoneyViewModel:ObservableObject {
    
    
    
    @Published var debts: [Debt] = []
    @Published var gameExpenses: [GameExpense] = []
    @Published var settlements: [Settlement] = []
    
    private let debtsKey = "savedDebts"
    private let expensesKey = "savedGameExpenses"
    private let settlementsKey = "savedSettlements"
    
    init() {
        loadDebts()
        loadGameExpenses()
        loadSettlements()
    }
    
    // MARK: - Debt Management
    
    func addDebt(creditorId: UUID, debtorId: UUID, amount: Double, description: String, gameSessionId: UUID? = nil) {
        let newDebt = Debt(
            creditorId: creditorId,
            debtorId: debtorId,
            amount: amount,
            description: description,
            gameSessionId: gameSessionId
        )
        debts.append(newDebt)
        saveDebts()
    }
    
    func addGameExpense(payerId: UUID, totalAmount: Double, description: String, gameType: String, participants: [UUID]) {
        let expense = GameExpense(
            payerId: payerId,
            totalAmount: totalAmount,
            description: description,
            gameType: gameType,
            participants: participants
        )
        gameExpenses.append(expense)
        saveGameExpenses()
        
        // odrazu długi dla wszystkich uczestników
        for participantId in participants where participantId != payerId {
            addDebt(
                creditorId: payerId,
                debtorId: participantId,
                amount: expense.splitAmount,
                description: "Udział w \(description)",
                gameSessionId: expense.id
            )
        }
    }
    
    func settleDebt(debtId: UUID) {
        if let index = debts.firstIndex(where: { $0.id == debtId }) {
            debts[index] = Debt(
                id: debts[index].id,
                creditorId: debts[index].creditorId,
                debtorId: debts[index].debtorId,
                amount: debts[index].amount,
                description: debts[index].description,
                date: debts[index].date,
                isSettled: true,
                gameSessionId: debts[index].gameSessionId
            )
            saveDebts()
        }
    }
    
    func addSettlement(fromPlayerId: UUID, toPlayerId: UUID, amount: Double, description: String) {
        let settlement = Settlement(
            fromPlayerId: fromPlayerId,
            toPlayerId: toPlayerId,
            amount: amount,
            description: description
        )
        settlements.append(settlement)
        saveSettlements()
    }
    
    // MARK: - Calculations
    
    func calculateNetBalance(for playerId: UUID, players: [Player]) -> Double {
        var balance = 0.0
        
        // ile inni sa winni graczowi
        let owedToMe = debts.filter {
            $0.creditorId == playerId && !$0.isSettled
        }
        balance += owedToMe.reduce(0) { $0 + $1.amount }
        
        // ile gracz jest winnny innym
        let myDebts = debts.filter {
            $0.debtorId == playerId && !$0.isSettled
        }
        balance -= myDebts.reduce(0) { $0 + $1.amount }
        
        return balance
    }
    
    func getDebtsForPlayer(playerId: UUID, players: [Player]) -> (owedToPlayer: [Debt], playerOwes: [Debt]) {
        let owedToPlayer = debts.filter {
            $0.creditorId == playerId && !$0.isSettled
        }
        let playerOwes = debts.filter {
            $0.debtorId == playerId && !$0.isSettled
        }
        
        return (owedToPlayer, playerOwes)
    }
    
    // MARK: - Persistence
    
    private func saveDebts() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(debts)
            UserDefaults.standard.set(encodedData, forKey: debtsKey)
        } catch {
            print("Błąd zapisywania długów: \(error)")
        }
    }
    
    private func loadDebts() {
        guard let savedData = UserDefaults.standard.data(forKey: debtsKey) else { return }
        do {
            let decoder = JSONDecoder()
            debts = try decoder.decode([Debt].self, from: savedData)
        } catch {
            print("Błąd ładowania długów: \(error)")
        }
    }
    
    private func saveGameExpenses() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(gameExpenses)
            UserDefaults.standard.set(encodedData, forKey: expensesKey)
        } catch {
            print("Błąd zapisywania wydatków: \(error)")
        }
    }
    
    private func loadGameExpenses() {
        guard let savedData = UserDefaults.standard.data(forKey: expensesKey) else { return }
        do {
            let decoder = JSONDecoder()
            gameExpenses = try decoder.decode([GameExpense].self, from: savedData)
        } catch {
            print("Błąd ładowania wydatków: \(error)")
        }
    }
    
    private func saveSettlements() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(settlements)
            UserDefaults.standard.set(encodedData, forKey: settlementsKey)
        } catch {
            print("Błąd zapisywania rozliczeń: \(error)")
        }
    }
    
    private func loadSettlements() {
        guard let savedData = UserDefaults.standard.data(forKey: settlementsKey) else { return }
        do {
            let decoder = JSONDecoder()
            settlements = try decoder.decode([Settlement].self, from: savedData)
        } catch {
            print("Błąd ładowania rozliczeń: \(error)")
        }
    }
}
