import SwiftUI
import Foundation



struct MoneyView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var moneyViewModel = MoneyViewModel()
    
    @State private var showingAddDebt = false
    @State private var showingAddExpense = false
    @State private var showingMyFinances = false
    @State private var showingSettlement = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Stats
                    if let currentUser = gameViewModel.players.first {
                        QuickStatsView(
                            player: currentUser,
                            moneyViewModel: moneyViewModel,
                            players: gameViewModel.players
                        )
                        .padding(.horizontal)
                    }
                    
                    
                    // Action Buttons
                    ActionButtonsView(
                        showingAddDebt: $showingAddDebt,
                        showingAddExpense: $showingAddExpense,
                        showingMyFinances: $showingMyFinances,
                        showingSettlement: $showingSettlement
                    )
                    .padding(.horizontal)
                    
                    // Recent Debts
                    RecentDebtsView(
                        debts: moneyViewModel.debts.filter { !$0.isSettled },
                        players: gameViewModel.players
                    )
                    .padding(.horizontal)
                    
                    // Recent Expenses
                    RecentExpensesView(
                        expenses: moneyViewModel.gameExpenses,
                        players: gameViewModel.players
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
                    moneyViewModel: moneyViewModel
                )
            }
            .sheet(isPresented: $showingAddExpense) {
                AddGameExpenseView(
                    gameViewModel: gameViewModel,
                    moneyViewModel: moneyViewModel
                )
            }
            .sheet(isPresented: $showingMyFinances) {
                MyFinancesView(
                    gameViewModel: gameViewModel,
                    moneyViewModel: moneyViewModel
                )
            }
            .sheet(isPresented: $showingSettlement) {
                SettlementView(
                    gameViewModel: gameViewModel,
                    moneyViewModel: moneyViewModel
                )
            }
        }
    }
}
struct QuickStatsView: View {
    let player: Player
    let moneyViewModel: MoneyViewModel
    let players: [Player]
    
    var netBalance: Double {
        moneyViewModel.calculateNetBalance(for: player.id, players: players)
    }
    
    var owedCount: Int {
        moneyViewModel.getDebtsForPlayer(playerId: player.id, players: players).owedToPlayer.count
    }
    
    var myDebtsCount: Int {
        moneyViewModel.getDebtsForPlayer(playerId: player.id, players: players).playerOwes.count
    }
    
    var settledCount: Int {
        moneyViewModel.settlements.count
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Górny wiersz - Saldo
            HStack {
                Image(systemName: player.avatarName)
                    .font(.title2)
                    .foregroundColor(Color(red: 0, green: 0.3, blue: 0.8)) // Ciemniejszy niebieski
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Moje saldo")
                        .font(.caption)
                        .fontWeight(.semibold) // Dodane
                        .foregroundColor(.black) // Ciemny szary
                    
                    Text("\(netBalance, specifier: "%.2f") zł")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black   // Ciemna czerwień
                        )
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Moje saldo")
                .accessibilityValue("\(String(format: "%.2f", netBalance)) złotych")
                .accessibilityAddTraits(.isStaticText)
                
                Spacer()
                
                // Data - jako osobny element
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Dziś")
                        .font(.caption)
                        .fontWeight(.semibold) // Dodane
                        .foregroundColor((Color(red: 0.7, green: 0, blue: 0))) // Ciemny szary
                    
                    Text(Date(), style: .date)
                        .font(.caption)
                        .fontWeight(.bold) // Dodane
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1)) // Prawie czarny
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Dzisiejsza data")
                .accessibilityValue("\(Date(), style: .date)")
                .accessibilityAddTraits(.isStaticText)
            }
            
            Divider()
                .foregroundColor(Color.gray.opacity(0.3))
                .accessibilityHidden(true)
            
            // Dolny wiersz - statystyki
            HStack {
                // Należności
                StatItemView(
                    title: "Należności",
                    value: owedCount,
                    iconColor: Color(red: 0, green: 0.5, blue: 0), // Ciemna zieleń
                    textColor: Color(red: 0.1, green: 0.1, blue: 0.1) // Ciemny
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Należności")
                .accessibilityValue("\(owedCount) pozycji")
                .accessibilityAddTraits(.isStaticText)
                
                Divider()
                    .frame(height: 30)
                    .foregroundColor(Color.gray.opacity(0.3))
                    .accessibilityHidden(true)
                
                // Moje długi
                StatItemView(
                    title: "Moje długi",
                    value: myDebtsCount,
                    iconColor: Color(red: 0.8, green: 0, blue: 0), // Ciemna czerwień
                    textColor: Color(red: 0.1, green: 0.1, blue: 0.1) // Ciemny
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Moje długi")
                .accessibilityValue("\(myDebtsCount) pozycji")
                .accessibilityAddTraits(.isStaticText)
                
                Divider()
                    .frame(height: 30)
                    .foregroundColor(Color.gray.opacity(0.3))
                    .accessibilityHidden(true)
                
                // Rozliczone
                StatItemView(
                    title: "Rozliczone",
                    value: settledCount,
                    iconColor: Color(red: 0, green: 0.4, blue: 0.8), // Ciemny niebieski
                    textColor: Color(red: 0.1, green: 0.1, blue: 0.1) // Ciemny
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
                .fontWeight(.semibold) // Dodane
                .foregroundColor(iconColor)
                .accessibilityHidden(true)
            
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(textColor)
                .accessibilityHidden(true)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold) // Dodane
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
            // PRZYCISK 1: Dodaj dług - z named actions
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
            .accessibilityAction {
                showingAddDebt = true
            }
            .accessibilityAction(named: Text("Szybkie dodanie")) {
                print("Szybkie dodanie długu")
                // Tu możesz wywołać funkcję do szybkiego dodania
            }
            .accessibilityAction(named: Text("Z szablonu")) {
                print("Dodaj z szablonu")
            }
            .accessibilityAction(named: Text("Powtórz ostatni")) {
                print("Powtórz ostatni dług")
            }
            
            // PRZYCISK 2: Wydatek gry - z named actions
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
            .accessibilityAction {
                showingAddExpense = true
            }
            .accessibilityAction(named: Text("Poker")) {
                print("Dodaj wydatek pokera")
            }
            .accessibilityAction(named: Text("Bilard")) {
                print("Dodaj wydatek bilardu")
            }
            .accessibilityAction(named: Text("Kręgle")) {
                print("Dodaj wydatek kręgli")
            }
            
            // PRZYCISK 3: Moje finanse
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
            .accessibilityAction {
                showingMyFinances = true
            }
            
            // PRZYCISK 4: Rozlicz się
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
            .accessibilityAction {
                showingSettlement = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Panel akcji finansowych")
    }
}

// Oddzielna struktura tylko dla wyglądu przycisku
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

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    let additionalActions: [AdditionalAction]
    
    // Struktura dla dodatkowych akcji
    struct AdditionalAction {
        let name: String
        let description: String
        let action: () -> Void
    }
    
    init(title: String,
         icon: String,
         color: Color,
         action: @escaping () -> Void,
         additionalActions: [AdditionalAction] = []) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
        self.additionalActions = additionalActions
    }
    
    var body: some View {
        Button(action: action) {
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
                    .foregroundColor(.primary)
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
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityHint(getHint(for: title))
        .accessibilityAddTraits(.isButton)
        // Domyślna akcja
        .accessibilityAction {
            action()
        }
        // Dodatkowe named actions
        .accessibilityAction(named: Text("Szybkie dodanie")) {
            print("Szybkie dodanie")
        }
        .accessibilityAction(named: Text("Z szablonu")) {
            print("Z szablonu")
        }
    }
    
    private func getHint(for title: String) -> String {
        let baseHint: String
        switch title {
        case "Dodaj dług":
            baseHint = "Naciśnij dwukrotnie, aby dodać nowy dług"
        case "Wydatek gry":
            baseHint = "Naciśnij dwukrotnie, aby dodać wydatek"
        case "Moje finanse":
            baseHint = "Naciśnij dwukrotnie, aby zobaczyć finanse"
        case "Rozlicz się":
            baseHint = "Naciśnij dwukrotnie, aby się rozliczyć"
        default:
            baseHint = "Naciśnij dwukrotnie, aby wykonać akcję"
        }
        
        if !additionalActions.isEmpty {
            return "\(baseHint). Przesuń w górę lub w dół, aby zobaczyć więcej akcji."
        } else {
            return baseHint
        }
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
                    .fontWeight(.semibold) // Dodane dla lepszego kontrastu
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1)) // Ciemniejszy niż .black
                
                Spacer()
                
                if !debts.isEmpty {
                    Text("\(debts.count)")
                        .font(.caption)
                        .fontWeight(.semibold) // Dodane
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(Color(red: 0.7, green: 0, blue: 0)) // Ciemniejszy czerwony
                        .cornerRadius(10)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Ilość ostatnich długów")
            .accessibilityValue("\(debts.count)")
            .accessibilityAddTraits(.isStaticText)
            
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
                            .fontWeight(.medium) // Dodane
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3)) // Szary zamiast czarnego
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
                        .fontWeight(.semibold) // Dodane
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1)) // Ciemniejszy
                }
                
                Text(debt.description)
                    .font(.caption)
                    .fontWeight(.medium) // Dodane
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4)) // Szary zamiast czarnego
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(debt.amount, specifier: "%.2f") zł")
                    .font(.headline)
                    .fontWeight(.bold) // Dodane
                    .foregroundColor(Color(red: 0.8, green: 0, blue: 0)) // Ciemniejszy czerwony
                
                Text(debt.date, style: .date)
                    .font(.caption2)
                    .fontWeight(.medium) // Dodane
                    .foregroundColor(.black) // Jasny szary
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
                    .fontWeight(.semibold) // Dodane
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1)) // Ciemniejszy
                
                Spacer()
                
                if !expenses.isEmpty {
                    Text("\(expenses.count)")
                        .font(.caption)
                        .fontWeight(.semibold) // Dodane
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(Color(red: 0, green: 0.3, blue: 0.7)) // Ciemniejszy niebieski
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
                        .fontWeight(.semibold) // Dodane
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1)) // Ciemniejszy
                }
                
                if let payer = payer {
                    Text("Zapłacił: \(payer.nick)")
                        .font(.caption)
                        .fontWeight(.medium) // Dodane
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4)) // Szary zamiast czarnego
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(expense.totalAmount, specifier: "%.2f") zł")
                    .font(.headline)
                    .fontWeight(.bold) // Dodane
                    .foregroundColor(Color(red: 0, green: 0.4, blue: 0.8)) // Ciemniejszy niebieski
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(expense.gameType)")
        .accessibilityValue("\(expense.totalAmount, specifier: "%.2f") zł")
        .accessibilityAddTraits(.isStaticText)
    }
    
    private func getGameIcon(_ gameType: String) -> String {
        switch gameType.lowercased() {
        case "poker": return "suit.spade.fill"
        case "bilard": return "circle.circle.fill"
        case "kręgle": return "baseball.fill"
        default: return "gamecontroller.fill"
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
                .font(.system(size: 40))
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6)) // Ciemniejszy szary
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold) // Dodane
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4)) // Ciemniejszy szary
            
            Text(message)
                .font(.caption)
                .fontWeight(.medium) // Dodane
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5)) // Szary
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

struct MoneyView_Previews: PreviewProvider {
    static var previews: some View {
        MoneyView()
    }
}
