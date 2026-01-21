import SwiftUI
import SwiftData

struct AddDebtView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @ObservedObject var gameViewModel: GameViewModel
    @ObservedObject var moneyViewModel: MoneyViewModel
    let players: [Player] // ✅ Przekazane z rodzica, zamiast @Query
    
    @State private var selectedCreditorId: UUID?
    @State private var selectedDebtorId: UUID?
    @State private var amount = ""
    @State private var description = ""
    
    var selectedCreditor: Player? {
        players.first { $0.id == selectedCreditorId }
    }
    
    var selectedDebtor: Player? {
        players.first { $0.id == selectedDebtorId }
    }
    
    var isFormValid: Bool {
        selectedCreditorId != nil &&
        selectedDebtorId != nil &&
        !amount.isEmpty &&
        Double(amount) ?? 0 > 0 &&
        selectedCreditorId != selectedDebtorId
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kto pożyczył?")) {
                    Picker("Wybierz wierzyciela", selection: $selectedCreditorId) {
                        Text("Wybierz...").tag(nil as UUID?)
                        ForEach(players) { player in
                            PlayerPickerRow(player: player)
                                .tag(player.id as UUID?)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section(header: Text("Komu pożyczył?")) {
                    Picker("Wybierz dłużnika", selection: $selectedDebtorId) {
                        Text("Wybierz...").tag(nil as UUID?)
                        ForEach(players.filter { $0.id != selectedCreditorId }) { player in
                            PlayerPickerRow(player: player)
                                .tag(player.id as UUID?)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section(header: Text("Szczegóły długu")) {
                    HStack {
                        TextField("Kwota", text: $amount)
                            .keyboardType(.decimalPad)
                        
                        Text("zł")
                            .foregroundColor(.gray)
                    }
                    
                    TextField("Opis (np. Za piwo)", text: $description)
                }
                
                if let creditor = selectedCreditor, let debtor = selectedDebtor {
                    Section(header: Text("Podsumowanie")) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(debtor.nick) jest winien")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text("\(creditor.nick)")
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Kwota")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text("\(Double(amount) ?? 0, specifier: "%.2f") zł")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nowy dług")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dodaj") {
                        if let creditorId = selectedCreditorId,
                           let debtorId = selectedDebtorId,
                           let amountValue = Double(amount) {
                            
                            moneyViewModel.addDebt(
                                creditorId: creditorId,
                                debtorId: debtorId,
                                amount: amountValue,
                                description: description.isEmpty ? "Dług" : description,
                                context: context
                            )
                            dismiss()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
}

struct PlayerPickerRow: View {
    let player: Player
    
    var body: some View {
        HStack {
            Image(systemName: player.avatarName)
                .foregroundColor(.blue)
            
            Text(player.nick)
            
            Spacer()
            
            Text("\(player.totalPoints) pkt")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

