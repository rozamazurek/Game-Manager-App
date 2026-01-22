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

    var currentPlayer: Player? { players.first }

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
                                .foregroundColor(.black)

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

                        if !owedToPlayer.isEmpty {
                            DebtsSectionView(
                                title: "Moje należności",
                                debts: owedToPlayer,
                                players: players,
                                isOwedToMe: true,
                                onSettle: { debt in
                                    moneyViewModel.settleDebt(debt: debt, context: context)
                                }
                            )
                        }

                        if !playerOwes.isEmpty {
                            DebtsSectionView(
                                title: "Moje długi",
                                debts: playerOwes,
                                players: players,
                                isOwedToMe: false,
                                onSettle: { debt in
                                    moneyViewModel.settleDebt(debt: debt, context: context)
                                }
                            )
                        }

                        if owedToPlayer.isEmpty && playerOwes.isEmpty {
                            EmptyStateView(
                                icon: "checkmark.circle",
                                title: "Brak zaległości",
                                message: "Wszystko jest rozliczone!"
                            )
                        }

                        if !mySettlements.isEmpty {
                            SettlementHistoryView(
                                settlements: mySettlements,
                                players: players
                            )
                        }

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
    let onSettle: (Debt) -> Void

    var totalAmount: Double {
        debts.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {

            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(totalAmount, specifier: "%.2f") zł")
                        .font(.headline)
                        .foregroundColor(isOwedToMe ? .green : .red)

                    Text("\(debts.count) pozycji")
                        .font(.caption)
                        .foregroundColor(.black)
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

struct DebtDetailRow: View {
    let debt: Debt
    let players: [Player]
    let isOwedToMe: Bool
    let onSettle: () -> Void

    var otherPlayer: Player? {
        isOwedToMe
        ? players.first { $0.id == debt.debtorId }
        : players.first { $0.id == debt.creditorId }
    }

    var body: some View {
        HStack(spacing: 15) {

            if let otherPlayer = otherPlayer {
                Image(systemName: otherPlayer.avatarName)
                    .font(.title3)
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                if let otherPlayer = otherPlayer {
                    Text(otherPlayer.nick)
                        .font(.headline)
                        .foregroundColor(.black)
                }

                Text(debt.debtDescription)
                    .font(.caption)
                    .foregroundColor(.black)

                Text(debt.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.black)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text("\(debt.amount, specifier: "%.2f") zł")
                    .font(.headline)
                    .foregroundColor(isOwedToMe ? .green : .red)

                Button("Rozlicz", action: onSettle)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background((isOwedToMe ? Color.green : Color.red).opacity(0.1))
                    .foregroundColor(isOwedToMe ? .green : .red)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 10)
    }
}

struct SettlementHistoryView: View {
    let settlements: [Settlement]
    let players: [Player]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Historia rozliczeń")
                .font(.headline)
                .foregroundColor(.black)

            ForEach(settlements.sorted { $0.date > $1.date }.prefix(5)) { settlement in
                SettlementRow(settlement: settlement, players: players)
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

    var body: some View {
        HStack {
            Text("\(settlement.amount, specifier: "%.2f") zł")
                .font(.headline)
                .foregroundColor(.blue)

            Spacer()

            Text(settlement.date, style: .date)
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text(title)
                .font(.headline)
                .foregroundColor(.black)

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

