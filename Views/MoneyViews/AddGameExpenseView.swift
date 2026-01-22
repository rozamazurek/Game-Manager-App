import SwiftUI
import SwiftData

struct AddGameExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @ObservedObject var gameViewModel: GameViewModel
    @ObservedObject var moneyViewModel: MoneyViewModel
    let players: [Player] // przekazane z moneyview
    
    @State private var selectedPayerId: UUID?
    @State private var selectedGameType = "Poker"
    @State private var totalAmount = ""
    @State private var expenseDescription = ""
    @State private var selectedParticipantIds: [UUID] = []
    
    let gameTypes = ["Poker", "Bilard", "Kręgle", "Inne"]
    
    var selectedPayer: Player? {
        players.first { $0.id == selectedPayerId }
    }
    
    var splitAmount: Double {
        let amount = Double(totalAmount) ?? 0
        let participantCount = max(selectedParticipantIds.count, 1)
        return amount / Double(participantCount)
    }
    
    var isFormValid: Bool {
        selectedPayerId != nil &&
        !totalAmount.isEmpty &&
        Double(totalAmount) ?? 0 > 0 &&
        !selectedParticipantIds.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kto zapłacił?")) {
                    Picker("Wybierz płatnika", selection: $selectedPayerId) {
                        Text("Wybierz...").tag(nil as UUID?)
                        ForEach(players) { player in
                            PlayerPickerRow(player: player)
                                .tag(player.id as UUID?)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section(header: Text("Szczegóły gry")) {
                    Picker("Typ gry", selection: $selectedGameType) {
                        ForEach(gameTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    
                    HStack {
                        TextField("Całkowita kwota", text: $totalAmount)
                            .keyboardType(.decimalPad)
                        
                        Text("zł")
                            .foregroundColor(.gray)
                    }
                    
                    TextField("Opis (np. Gra w klubie X)", text: $expenseDescription)
                }
                
                Section(header: Text("Uczestnicy")) {
                    ForEach(players) { player in
                        ParticipantRow(
                            player: player,
                            isSelected: selectedParticipantIds.contains(player.id),
                            action: {
                                if selectedParticipantIds.contains(player.id) {
                                    selectedParticipantIds.removeAll { $0 == player.id }
                                } else {
                                    selectedParticipantIds.append(player.id)
                                }
                            }
                        )
                    }
                }
                
                if isFormValid {
                    Section(header: Text("Podsumowanie")) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(selectedParticipantIds.count) uczestników")
                                .font(.headline)
                            
                            Text("Kwota na osobę:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("\(splitAmount, specifier: "%.2f") zł")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            if let payer = selectedPayer {
                                Text("Każdy uczestnik (oprócz \(payer.nick)) będzie winien mu tę kwotę")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.top, 5)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Wydatek gry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dodaj") {
                        if let payerId = selectedPayerId,
                           let amountValue = Double(totalAmount) {
                            
                            moneyViewModel.addGameExpense(
                                payerId: payerId,
                                totalAmount: amountValue,
                                description: expenseDescription.isEmpty ? "Wydatek na \(selectedGameType)" : expenseDescription,
                                gameType: selectedGameType,
                                participants: selectedParticipantIds,
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

struct ParticipantRow: View {
    let player: Player
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: player.avatarName)
                    .foregroundColor(.blue)
                
                Text(player.nick)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .foregroundColor(.primary)
        }
    }
}
