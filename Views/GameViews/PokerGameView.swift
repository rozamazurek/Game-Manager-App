import SwiftUI

struct PokerGameView: View {
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        self._pokerViewModel = StateObject(wrappedValue: PokerViewModel(gameViewModel: viewModel))
    }
    @ObservedObject var viewModel: GameViewModel
    @StateObject private var pokerViewModel: PokerViewModel
    @State private var showingCreditsAddPlayer = false
    
    var body: some View {
        HStack(spacing: 15) {
            Button("Dodaj punkty za pokera") {
                showingCreditsAddPlayer.toggle()
            }
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(10)
            .padding()
            .sheet(isPresented: $showingCreditsAddPlayer) {
                PokerGamingView(viewModel: viewModel)
            }
        }
    }
}
struct PokerGamingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GameViewModel
    @StateObject private var pokerViewModel: PokerViewModel
    
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        self._pokerViewModel = StateObject(wrappedValue: PokerViewModel(gameViewModel: viewModel))
    }
    
    var body: some View {
        NavigationView {
            Form {
                playerSelectionSection
                gameResultsSection
                summarySection
            }
            .navigationTitle("Poker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Zapisz") {
                        saveGameResults()
                    }
                    .disabled(pokerViewModel.selectedPlayers.isEmpty ||
                             pokerViewModel.numTokens.isEmpty ||
                             pokerViewModel.finalPosition.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Sections as computed properties
    
    private var playerSelectionSection: some View {
        Section(header: Text("Wybór graczy")) {
            ForEach(viewModel.players) { player in
                PlayerSelectionRow(
                    player: player,
                    isSelected: pokerViewModel.selectedPlayers.contains(where: { $0.id == player.id })
                ) {
                    if pokerViewModel.selectedPlayers.contains(where: { $0.id == player.id }) {
                        pokerViewModel.selectedPlayers.removeAll { $0.id == player.id }
                    } else {
                        pokerViewModel.selectedPlayers.append(player)
                    }
                }
            }
        }
    }
    
    private var gameResultsSection: some View {
        Section(header: Text("Wyniki gry")) {
            TextField("Liczba żetonów", text: $pokerViewModel.numTokens)
                .keyboardType(.numberPad)
            
            TextField("Włożone pieniądze", text: $pokerViewModel.moneyPut)
                .keyboardType(.numberPad)
            
            TextField("Końcowa pozycja", text: $pokerViewModel.finalPosition)
                .keyboardType(.numberPad)
            
            TextField("Liczba graczy", text: $pokerViewModel.totalPlayers)
                .keyboardType(.numberPad)
        }
    }
    
    private var summarySection: some View {
        Group {
            if !pokerViewModel.selectedPlayers.isEmpty {
                Section(header: Text("Podsumowanie")) {
                    ForEach(pokerViewModel.selectedPlayers) { player in
                        let points = pokerViewModel.calculatePointsPoker(
                            numTokens: Int(pokerViewModel.numTokens) ?? 0,
                            moneyPut: Int(pokerViewModel.moneyPut) ?? 0,
                            finalPosition: Int(pokerViewModel.finalPosition) ?? 1,
                            totalPlayers: Int(pokerViewModel.totalPlayers) ?? 1
                        )
                        HStack {
                            Text(player.nick)
                            Spacer()
                            Text("+\(points) pkt")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    private func saveGameResults() {
        
        // Dodaj punkty każdemu wybranemu graczowi
        for player in pokerViewModel.selectedPlayers {
            pokerViewModel.addPokerPoints(player: player)
        }
    
        pokerViewModel.resetForm()
        dismiss()
    }
}

struct PlayerSelectionRow: View {
    let player: Player
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(player.nick)
                Spacer()
                Text("\(player.totalPoints) pkt")
                    .foregroundColor(.gray)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
        .foregroundColor(.primary)
    }
}
