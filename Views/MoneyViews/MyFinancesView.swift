import SwiftUI

struct MyFinancesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var gameViewModel: GameViewModel
    @ObservedObject var moneyViewModel: MoneyViewModel
    
    // Zakładam, że aktualny użytkownik to pierwszy gracz
    var currentPlayer: Player? {
        gameViewModel.players.first
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let player = currentPlayer {
                        // Header
                        VStack(spacing: 15) {
                            Image(systemName: player.avatarName)
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                            
                            Text(player.nick)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            let balance = moneyViewModel.calculateNetBalance(for: player.id, players: gameViewModel.players)
                            Text("Saldo: \(balance, specifier: "%.2f") zł")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(balance >= 0 ? .green : .red)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(balance >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: .gray.opacity(0.1), radius: 5)
                        .padding(.horizontal)
                        
                        // Należności (inni są mi winni)
                        let (owedToPlayer, playerOwes) = moneyViewModel.getDebtsForPlayer(
                            playerId: player.id,
                            players: gameViewModel.players
                        )
                        
                        if !owedToPlayer.isEmpty {
                            DebtsSectionView(
                                title: "📥 Należności",
                                debts: owedToPlayer,
                                players: gameViewModel.players,
                                isOwedToMe: true,
                                onSettle: { debtId in
                                    moneyViewModel.settleDebt(debtId: debtId)
                                }
                            )
                            .padding(.horizontal)
                        }
                        
                        // Moje długi (ja jestem winien)
                        if !playerOwes.isEmpty {
                            DebtsSectionView(
                                title: "📤 Moje długi",
                                debts: playerOwes,
                                players: gameViewModel.players,
                                isOwedToMe: false,
                                onSettle: { debtId in
                                    moneyViewModel.settleDebt(debtId: debtId)
                                }
                            )
                            .padding(.horizontal)
                        }
                        
                        if owedToPlayer.isEmpty && playerOwes.isEmpty {
                            EmptyStateView(
                                icon: "checkmark.circle",
                                title: "Brak zaległości",
                                message: "Wszystko jest rozliczone!"
                            )
                            .padding(.horizontal)
                        }
                        
                        // Historia rozliczeń
                        let mySettlements = moneyViewModel.settlements.filter {
                            $0.fromPlayerId == player.id || $0.toPlayerId == player.id
                        }
                        
                        if !mySettlements.isEmpty {
                            SettlementHistoryView(
                                settlements: mySettlements,
                                players: gameViewModel.players
                            )
                            .padding(.horizontal)
                        }
                    } else {
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
                    Button("Gotowe") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DebtsSectionView: View {
    let title: String
    let debts: [Debt]
    let players: [Player]
    let isOwedToMe: Bool
    let onSettle: (UUID) -> Void
    
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
                    onSettle: { onSettle(debt.id) }
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

struct DebtDetailRow: View {
    let debt: Debt
    let players: [Player]
    let isOwedToMe: Bool
    let onSettle: () -> Void
    
    var otherPlayer: Player? {
        if isOwedToMe {
            // Kto mi jest winien
            return players.first { $0.id == debt.debtorId }
        } else {
            // Komu ja jestem winien
            return players.first { $0.id == debt.creditorId }
        }
    }
    
    var arrowDirection: String {
        isOwedToMe ? "←" : "→"
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
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
                            Text("\(otherPlayer.nick)")
                                .font(.headline)
                            Text("jest mi winien")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("Jestem winien")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(otherPlayer.nick)")
                                .font(.headline)
                        }
                    }
                }
                
                Text(debt.description)
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
    
    var fromPlayer: Player? {
        players.first { $0.id == settlement.fromPlayerId }
    }
    
    var toPlayer: Player? {
        players.first { $0.id == settlement.toPlayerId }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatary
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
                
                Text(settlement.description)
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

