import SwiftUI
import SwiftData

struct MyFinancesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @ObservedObject var gameViewModel: GameViewModel
    @ObservedObject var moneyViewModel: MoneyViewModel
    let players: [Player]
    let debts: [Debt]
    let settlements: [Settlement]
    // Aktualny gracz
    var currentPlayer: Player? { players.first }
    
    // MARK: - Computed properties wyciągnięte poza body
    var currentBalance: Double {
        guard let player = currentPlayer else { return 0 }
        return moneyViewModel.calculateNetBalance(for: player.id, debts: debts)
    }
    
    var balanceColor: Color {
        currentBalance >= 0 ? .green : .red
    }
    
    var owedToPlayer: [Debt] {
        guard let player = currentPlayer else { return [] }
        return moneyViewModel.getDebtsForPlayer(playerId: player.id, debts: debts).0
    }
    
    var playerOwes: [Debt] {
        guard let player = currentPlayer else { return [] }
        return moneyViewModel.getDebtsForPlayer(playerId: player.id, debts: debts).1
    }
    
    var mySettlements: [Settlement] {
        guard let player = currentPlayer else { return [] }
        return settlements.filter {
            $0.fromPlayerId == player.id || $0.toPlayerId == player.id
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let player = currentPlayer {
                        // HEADER
                        VStack(spacing: 15) {
                            Image(systemName: player.avatarName)
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                            
                            Text(player.nick)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Saldo: \(String(format: "%.2f", currentBalance)) zł")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(balanceColor)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(balanceColor.opacity(0.1))
                                )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .gray.opacity(0.1), radius: 5)
                        .padding(.horizontal)
                        
                        // Należności
                        if !owedToPlayer.isEmpty {
                            DebtsSectionView(
                                title: "📥 Należności",
                                debts: owedToPlayer,
                                players: players,
                                isOwedToMe: true,
                                onSettle: { debt in
                                    moneyViewModel.settleDebt(debt: debt, context: context)
                                }
                            )
                        }
                        
                        // Moje długi
                        if !playerOwes.isEmpty {
                            DebtsSectionView(
                                title: "📤 Moje długi",
                                debts: playerOwes,
                                players: players,
                                isOwedToMe: false,
                                onSettle: { debt in
                                    moneyViewModel.settleDebt(debt: debt, context: context)
                                }
                            )
                        }
                        
                        // Brak długów
                        if owedToPlayer.isEmpty && playerOwes.isEmpty {
                            EmptyStateView(
                                icon: "checkmark.circle",
                                title: "Brak zaległości",
                                message: "Wszystko jest rozliczone!"
                            )
                        }
                        
                        // Historia rozliczeń
                        if !mySettlements.isEmpty {
                            SettlementHistoryView(
                                settlements: mySettlements,
                                players: players
                            )
                        }
                        
                    } else {
                        // Brak graczy
                        VStack(spacing: 20) {
                            Image(systemName: "person.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("Brak graczy")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("Dodaj graczy w zakładce Gry")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(height: 300)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Moje finanse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Gotowe") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Reszta kodu pozostaje BEZ ZMIAN (DebtsSectionView, DebtDetailRow, SettlementHistoryView, SettlementRow, EmptyStateView)


// MARK: - Debts Section
struct DebtsSectionView: View {
    let title: String
    let debts: [Debt]
    let players: [Player]
    let isOwedToMe: Bool
    let onSettle: (Debt) -> Void
    
    var totalAmount: Double {
        debts.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(totalAmount, specifier: "%.2f") zł")
                        .font(.headline)
                        .foregroundColor(isOwedToMe ? .green : .red)
                    
                    Text("\(debts.count) pozycji")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            ForEach(debts) { debt in
                DebtDetailRow(
                    debt: debt,
                    players: players,
                    isOwedToMe: isOwedToMe,
                    onSettle: { onSettle(debt) }
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

// MARK: - Debt Row
struct DebtDetailRow: View {
    let debt: Debt
    let players: [Player]
    let isOwedToMe: Bool
    let onSettle: () -> Void
    
    var otherPlayer: Player? {
        if isOwedToMe {
            players.first { $0.id == debt.debtorId }
        } else {
            players.first { $0.id == debt.creditorId }
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            if let otherPlayer = otherPlayer {
                Image(systemName: otherPlayer.avatarName)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 40)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let otherPlayer = otherPlayer {
                    HStack(spacing: 5) {
                        if isOwedToMe {
                            Text("\(otherPlayer.nick)").font(.headline)
                            Text("jest mi winien").font(.caption).foregroundColor(.gray)
                        } else {
                            Text("Jestem winien").font(.caption).foregroundColor(.gray)
                            Text("\(otherPlayer.nick)").font(.headline)
                        }
                    }
                }
                Text(debt.debtDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Text(debt.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("\(debt.amount, specifier: "%.2f") zł")
                    .font(.headline)
                    .foregroundColor(isOwedToMe ? .green : .red)
                
                Button(action: onSettle) {
                    Text("Rozlicz")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isOwedToMe ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .foregroundColor(isOwedToMe ? .green : .red)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Settlement History
struct SettlementHistoryView: View {
    let settlements: [Settlement]
    let players: [Player]
    
    var sortedSettlements: [Settlement] {
        settlements.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("📋 Historia rozliczeń")
                    .font(.headline)
                
                Spacer()
                
                Text("\(settlements.count)")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
            }
            
            if sortedSettlements.isEmpty {
                Text("Brak historii rozliczeń")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(sortedSettlements.prefix(5)) { settlement in
                    SettlementRow(settlement: settlement, players: players)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

struct SettlementRow: View {
    let settlement: Settlement
    let players: [Player]
    
    var fromPlayer: Player? { players.first { $0.id == settlement.fromPlayerId } }
    var toPlayer: Player? { players.first { $0.id == settlement.toPlayerId } }
    
    var body: some View {
        HStack(spacing: 15) {
            HStack(spacing: -10) {
                if let fromPlayer = fromPlayer {
                    Image(systemName: fromPlayer.avatarName)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(6)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                
                if let toPlayer = toPlayer {
                    Image(systemName: toPlayer.avatarName)
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(6)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                if let fromPlayer = fromPlayer, let toPlayer = toPlayer {
                    Text("\(fromPlayer.nick) → \(toPlayer.nick)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Text(settlement.settlementDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(settlement.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(settlement.amount, specifier: "%.2f") zł")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text("rozliczone")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

