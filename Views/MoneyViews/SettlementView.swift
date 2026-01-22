import SwiftUI
import SwiftData

struct SettlementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @ObservedObject var gameViewModel: GameViewModel
    @ObservedObject var moneyViewModel: MoneyViewModel
    let players: [Player] // przekazane z moneyview
    let debts: [Debt]     // przekazane z moneyview
    
    @State private var selectedFromPlayerId: UUID?
    @State private var selectedToPlayerId: UUID?
    @State private var amount = ""
    @State private var description = "Rozliczenie"
    
    var selectedFromPlayer: Player? {
        players.first { $0.id == selectedFromPlayerId }
    }
    
    var selectedToPlayer: Player? {
        players.first { $0.id == selectedToPlayerId }
    }
    
    var isFormValid: Bool {
        selectedFromPlayerId != nil &&
        selectedToPlayerId != nil &&
        !amount.isEmpty &&
        Double(amount) ?? 0 > 0 &&
        selectedFromPlayerId != selectedToPlayerId
    }
    
    // Pobierz sugerowane rozliczenia na podstawie długów
    var suggestedSettlements: [SuggestedSettlement] {
        var suggestions: [SuggestedSettlement] = []
        
        for player1 in players {
            for player2 in players where player1.id != player2.id {
                let balance1 = moneyViewModel.calculateNetBalance(for: player1.id, debts: debts)
                let balance2 = moneyViewModel.calculateNetBalance(for: player2.id, debts: debts)
                
                if balance1 > 0 && balance2 < 0 {
                    let amount = min(balance1, abs(balance2))
                    if amount > 0 {
                        let reason = "Saldo: \(player2.nick): \(String(format: "%.2f", balance2)) zł, \(player1.nick): \(String(format: "%.2f", balance1)) zł"
                        
                        suggestions.append(
                            SuggestedSettlement(
                                fromPlayer: player2,
                                toPlayer: player1,
                                amount: amount,
                                reason: reason
                            )
                        )
                    }
                }
            }
        }
        
        return suggestions
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rozliczenie")) {
                    Picker("Od kogo", selection: $selectedFromPlayerId) {
                        Text("Wybierz...").tag(nil as UUID?)
                        ForEach(players) { player in
                            PlayerPickerRow(player: player)
                                .tag(player.id as UUID?)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Picker("Do kogo", selection: $selectedToPlayerId) {
                        Text("Wybierz...").tag(nil as UUID?)
                        ForEach(players.filter { $0.id != selectedFromPlayerId }) { player in
                            PlayerPickerRow(player: player)
                                .tag(player.id as UUID?)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    HStack {
                        TextField("Kwota", text: $amount)
                            .keyboardType(.decimalPad)
                        Text("zł")
                            .foregroundColor(.gray)
                    }
                    
                    TextField("Opis", text: $description)
                }
                
                if let fromPlayer = selectedFromPlayer, let toPlayer = selectedToPlayer {
                    Section(header: Text("Podsumowanie")) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("\(fromPlayer.nick)")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                Text("→")
                                    .foregroundColor(.gray)
                                Text("\(toPlayer.nick)")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Kwota:")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(Double(amount) ?? 0, specifier: "%.2f") zł")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                // Sugerowane rozliczenia
                if !suggestedSettlements.isEmpty {
                    Section(header: Text("💡 Sugerowane rozliczenia")) {
                        ForEach(suggestedSettlements.prefix(3)) { suggestion in
                            SuggestedSettlementRow(
                                suggestion: suggestion,
                                onSelect: {
                                    selectedFromPlayerId = suggestion.fromPlayer.id
                                    selectedToPlayerId = suggestion.toPlayer.id
                                    amount = String(format: "%.2f", suggestion.amount)
                                    description = "Automatyczne rozliczenie"
                                }
                            )
                        }
                    }
                }
                
                // Aktywne długi między wybranymi graczami
                if let fromId = selectedFromPlayerId, let toId = selectedToPlayerId {
                    let debtsBetween = debts.filter { debt in
                        (debt.creditorId == toId && debt.debtorId == fromId && !debt.isSettled) ||
                        (debt.creditorId == fromId && debt.debtorId == toId && !debt.isSettled)
                    }
                    
                    if !debtsBetween.isEmpty {
                        Section(header: Text(" Aktywne długi")) {
                            ForEach(debtsBetween) { debt in
                                DebtSettlementRow(debt: debt, players: players)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Rozliczenie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anuluj") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Zapisz") {
                        if let fromId = selectedFromPlayerId,
                           let toId = selectedToPlayerId,
                           let amountValue = Double(amount) {
                            
                            moneyViewModel.addSettlement(
                                fromPlayerId: fromId,
                                toPlayerId: toId,
                                amount: amountValue,
                                description: description,
                                context: context
                            )
                            
                            // Automatycznie oznaczeenie odpowiednich długow
                            let debtsToSettle = debts.filter { debt in
                                debt.creditorId == toId &&
                                debt.debtorId == fromId &&
                                !debt.isSettled &&
                                debt.amount <= amountValue
                            }
                            for debt in debtsToSettle {
                                moneyViewModel.settleDebt(debt: debt, context: context)
                            }
                            
                            dismiss()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
}

// MARK: - Suggested Settlement
struct SuggestedSettlement: Identifiable {
    let id = UUID()
    let fromPlayer: Player
    let toPlayer: Player
    let amount: Double
    let reason: String
}

struct SuggestedSettlementRow: View {
    let suggestion: SuggestedSettlement
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                HStack(spacing: -5) {
                    Image(systemName: suggestion.fromPlayer.avatarName)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(5)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                    
                    Image(systemName: suggestion.toPlayer.avatarName)
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(5)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(suggestion.fromPlayer.nick) → \(suggestion.toPlayer.nick)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("\(suggestion.amount, specifier: "%.2f") zł")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(suggestion.reason)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 5)
        }
        .foregroundColor(.primary)
    }
}

// MARK: - Debt Settlement Row
struct DebtSettlementRow: View {
    let debt: Debt
    let players: [Player]
    
    var creditor: Player? {
        players.first { $0.id == debt.creditorId }
    }
    
    var debtor: Player? {
        players.first { $0.id == debt.debtorId }
    }
    
    var body: some View {
        HStack {
            if let creditor = creditor, let debtor = debtor {
                Text("\(debtor.nick) → \(creditor.nick)")
                    .font(.caption)
                Spacer()
                Text("\(debt.amount, specifier: "%.2f") zł")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 5)
    }
}

