import SwiftUI
import Foundation
import SwiftData

struct MoneyView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var moneyViewModel = MoneyViewModel()
    
    @State private var showingAddDebt = false
    @State private var showingAddExpense = false
    @State private var showingMyFinances = false
    @State private var showingSettlement = false
    @Query(sort: \Player.nick) private var players: [Player]
    @Query private var debts: [Debt]
    @Query private var gameExpenses: [GameExpense]
    @Query private var settlements: [Settlement]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let currentUser = players.first {
                        QuickStatsView(
                            player: currentUser,
                            moneyViewModel: moneyViewModel,
                            players: players,
                            debts: debts,
                            gameExpenses: gameExpenses,
                            settlements: settlements
                        )
                        .padding(.horizontal)
                    }
                    
                    ActionButtonsView(
                        showingAddDebt: $showingAddDebt,
                        showingAddExpense: $showingAddExpense,
                        showingMyFinances: $showingMyFinances,
                        showingSettlement: $showingSettlement
                    )
                    .padding(.horizontal)
                    
                    RecentDebtsView(
                        debts: debts.filter { !$0.isSettled },
                        players: players
                    )
                    .padding(.horizontal)
                    
                    RecentExpensesView(
                        expenses: gameExpenses,
                        players: players
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Kasa")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingAddDebt) {
                AddDebtView(
                    gameViewModel: gameViewModel,
                    moneyViewModel: moneyViewModel, players:players
                )
            }
            .sheet(isPresented: $showingAddExpense) {
                AddGameExpenseView(
                    gameViewModel: gameViewModel,
                    moneyViewModel: moneyViewModel,players:players
                )
            }
            .sheet(isPresented: $showingMyFinances) {
                MyFinancesView(
                    gameViewModel: gameViewModel,
                    moneyViewModel: moneyViewModel,players:players, debts: debts, settlements: settlements
                )
            }
            .sheet(isPresented: $showingSettlement) {
                SettlementView(
                    gameViewModel: gameViewModel,
                    moneyViewModel: moneyViewModel,players:players, debts: debts
                )
            }
        }
    }
}

struct QuickStatsView: View {
    let player: Player
    let moneyViewModel: MoneyViewModel
    let players: [Player]
    let debts: [Debt]
    let gameExpenses: [GameExpense]
    let settlements: [Settlement]
    
    var netBalance: Double {
        moneyViewModel.calculateNetBalance(for: player.id, debts: debts)
    }
    
    var owedCount: Int {
        moneyViewModel.getDebtsForPlayer(playerId: player.id, debts: debts).owedToPlayer.count
    }
    
    var myDebtsCount: Int {
        moneyViewModel.getDebtsForPlayer(playerId: player.id, debts: debts).playerOwes.count
    }
    
    var settledCount: Int {
        settlements.count
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: player.avatarName)
                    .font(.title2)
                    .foregroundColor(Color(red: 0, green: 0.3, blue: 0.8))
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Moje saldo")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Text("\(netBalance, specifier: "%.2f") zł")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Moje saldo")
                .accessibilityValue("\(String(format: "%.2f", netBalance)) złotych")
                .accessibilityAddTraits(.isStaticText)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Dziś")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.7, green: 0, blue: 0))
                    
                    Text(Date(), style: .date)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Dzisiejsza data")
                .accessibilityValue("\(Date(), style: .date)")
                .accessibilityAddTraits(.isStaticText)
            }
            
            Divider()
                .foregroundColor(Color.gray.opacity(0.3))
                .accessibilityHidden(true)
            
            HStack {
                StatItemView(
                    title: "Należności",
                    value: owedCount,
                    iconColor: Color(red: 0, green: 0.5, blue: 0),
                    textColor: Color(red: 0.1, green: 0.1, blue: 0.1)
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Należności")
                .accessibilityValue("\(owedCount) pozycji")
                .accessibilityAddTraits(.isStaticText)
                
                Divider()
                    .frame(height: 30)
                    .foregroundColor(Color.gray.opacity(0.3))
                    .accessibilityHidden(true)
                
                StatItemView(
                    title: "Moje długi",
                    value: myDebtsCount,
                    iconColor: Color(red: 0.8, green: 0, blue: 0),
                    textColor: Color(red: 0.1, green: 0.1, blue: 0.1)
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Moje długi")
                .accessibilityValue("\(myDebtsCount) pozycji")
                .accessibilityAddTraits(.isStaticText)
                
                Divider()
                    .frame(height: 30)
                    .foregroundColor(Color.gray.opacity(0.3))
                    .accessibilityHidden(true)
                
                StatItemView(
                    title: "Rozliczone",
                    value: settledCount,
                    iconColor: Color(red: 0, green: 0.4, blue: 0.8),
                    textColor: Color(red: 0.1, green: 0.1, blue: 0.1)
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Rozliczone transakcje")
                .accessibilityValue("\(settledCount)")
                .accessibilityAddTraits(.isStaticText)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Podsumowanie finansowe")
    }
}

struct StatItemView: View {
    let title: String
    let value: Int
    let iconColor: Color
    let textColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: getIcon(for: title))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(iconColor)
                .accessibilityHidden(true)
            
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(textColor)
                .accessibilityHidden(true)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(textColor.opacity(0.8))
                .accessibilityHidden(true)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func getIcon(for title: String) -> String {
        switch title {
        case "Należności": return "arrow.down.circle.fill"
        case "Moje długi": return "arrow.up.circle.fill"
        case "Rozliczone": return "checkmark.circle.fill"
        default: return "circle.fill"
        }
    }
}

struct ActionButtonsView: View {
    @Binding var showingAddDebt: Bool
    @Binding var showingAddExpense: Bool
    @Binding var showingMyFinances: Bool
    @Binding var showingSettlement: Bool
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            Button(action: { showingAddDebt = true }) {
                ActionButtonContent(
                    title: "Dodaj dług",
                    icon: "plus.circle.fill",
                    color: .red
                )
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Dodaj dług")
            .accessibilityHint("Naciśnij dwukrotnie, aby dodać nowy dług. Przesuń w górę lub w dół, aby zobaczyć więcej akcji.")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { showingAddDebt = true }
            
            Button(action: { showingAddExpense = true }) {
                ActionButtonContent(
                    title: "Wydatek gry",
                    icon: "gamecontroller.fill",
                    color: .blue
                )
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Wydatek gry")
            .accessibilityHint("Naciśnij dwukrotnie, aby dodać wydatek gry. Przesuń w górę lub w dół, aby zobaczyć więcej akcji.")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { showingAddExpense = true }
            
            Button(action: { showingMyFinances = true }) {
                ActionButtonContent(
                    title: "Moje finanse",
                    icon: "creditcard.fill",
                    color: .green
                )
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Moje finanse")
            .accessibilityHint("Naciśnij dwukrotnie, aby zobaczyć swoje finanse")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { showingMyFinances = true }
            
            Button(action: { showingSettlement = true }) {
                ActionButtonContent(
                    title: "Rozlicz się",
                    icon: "checkmark.circle.fill",
                    color: .orange
                )
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Rozlicz się")
            .accessibilityHint("Naciśnij dwukrotnie, aby się rozliczyć")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { showingSettlement = true }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Panel akcji finansowych")
    }
}

struct ActionButtonContent: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color)
                )
                .accessibilityHidden(true)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 3)
    }
}

// MARK: - Recent Debts
struct RecentDebtsView: View {
    let debts: [Debt]
    let players: [Player]
    
    var sortedDebts: [Debt] {
        debts.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Ostatnie długi")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                
                Spacer()
                
                if !debts.isEmpty {
                    Text("\(debts.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(Color(red: 0.7, green: 0, blue: 0))
                        .cornerRadius(10)
                }
            }
            
            if sortedDebts.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle",
                    title: "Brak długów",
                    message: "Wszystko rozliczone!"
                )
            } else {
                ForEach(sortedDebts.prefix(3)) { debt in
                    DebtRow(debt: debt, players: players)
                }
                
                if debts.count > 3 {
                    HStack {
                        Spacer()
                        Text("i \(debts.count - 3) więcej...")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

struct DebtRow: View {
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
            VStack(alignment: .leading, spacing: 4) {
                if let debtor = debtor, let creditor = creditor {
                    Text("\(debtor.nick) → \(creditor.nick)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                }
                
                Text(debt.debtDescription)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(debt.amount, specifier: "%.2f") zł")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.8, green: 0, blue: 0))
                
                Text(debt.date, style: .date)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Recent Expenses
struct RecentExpensesView: View {
    let expenses: [GameExpense]
    let players: [Player]
    
    var sortedExpenses: [GameExpense] {
        expenses.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Ostatnie wydatki")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                
                Spacer()
                
                if !expenses.isEmpty {
                    Text("\(expenses.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(Color(red: 0, green: 0.3, blue: 0.7))
                        .cornerRadius(10)
                }
            }
            
            if sortedExpenses.isEmpty {
                EmptyStateView(
                    icon: "gamecontroller",
                    title: "Brak wydatków",
                    message: "Dodaj pierwszy wydatek gry"
                )
            } else {
                ForEach(sortedExpenses.prefix(3)) { expense in
                    ExpenseRow(expense: expense, players: players)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

struct ExpenseRow: View {
    let expense: GameExpense
    let players: [Player]
    
    var payer: Player? {
        players.first { $0.id == expense.payerId }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(expense.gameType)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                }
                
                if let payer = payer {
                    Text("Zapłacił: \(payer.nick)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(expense.totalAmount, specifier: "%.2f") zł")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0, green: 0.4, blue: 0.8))
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(expense.gameType)")
        .accessibilityValue("\(expense.totalAmount, specifier: "%.2f") zł")
        .accessibilityAddTraits(.isStaticText)
    }
}


struct MoneyView_Previews: PreviewProvider {
    static var previews: some View {
        MoneyView()
    }
}

