import SwiftUI

struct BillardGameView: View {
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        self._billardViewModel = StateObject(wrappedValue: BillardViewModel(gameViewModel: viewModel))
    }
    @ObservedObject var viewModel: GameViewModel
    @StateObject private var billardViewModel: BillardViewModel
    @State private var showingCreditsAddPlayer = false
    
    var body: some View {
        HStack(spacing: 15) {
            Button("Dodaj punkty za grę billarda") {
                showingCreditsAddPlayer.toggle()
            }
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(10)
            .padding()
            .sheet(isPresented: $showingCreditsAddPlayer) {
                BillardGamingView(viewModel: viewModel)
            }
        }
    }
}
struct BillardGamingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GameViewModel
    @StateObject private var billardViewModel: BillardViewModel
    
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        self._billardViewModel = StateObject(wrappedValue: BillardViewModel(gameViewModel: viewModel))
    }
    
    var body: some View {
        NavigationView {
            Form {
                playerSelectionSection
                gameResultsSection
                summarySection
            }
            .navigationTitle("Billard")
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
                    .disabled(billardViewModel.selectedPlayers.isEmpty ||
                             billardViewModel.gamesWinned.isEmpty ||
                             billardViewModel.allGames.isEmpty)
                }
            }
        }
    }
    
    
    private var playerSelectionSection: some View {
        Section(header: Text("Wybór graczy")) {
            ForEach(viewModel.players) { player in
                PlayerSelectionRow(
                    player: player,
                    isSelected: billardViewModel.selectedPlayers.contains(where: { $0.id == player.id })
                ) {
                    if billardViewModel.selectedPlayers.contains(where: { $0.id == player.id }) {
                        billardViewModel.selectedPlayers.removeAll { $0.id == player.id }
                    } else {
                        billardViewModel.selectedPlayers.append(player)
                    }
                }
            }
        }
    }
    
    private var gameResultsSection: some View {
        Section(header: Text("Wyniki gry")) {
            TextField("Liczba wygranych gier", text: $billardViewModel.gamesWinned)
                .keyboardType(.numberPad)
            
            TextField("Liczba wszystkich gier", text: $billardViewModel.allGames)
                .keyboardType(.numberPad)
            
        }
    }
    
    private var summarySection: some View {
        Group {
            if !billardViewModel.selectedPlayers.isEmpty {
                Section(header: Text("Podsumowanie")) {
                    ForEach(billardViewModel.selectedPlayers) { player in
                        let points = billardViewModel.calculatePointsBillard(
                            gamesWinned: Int(billardViewModel.gamesWinned) ?? 0,
                            allGames: Int(billardViewModel.allGames) ?? 0
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
    
    
    private func saveGameResults() {
        
        // Dodaj punkty każdemu wybranemu graczowi
        for player in billardViewModel.selectedPlayers {
            billardViewModel.addBillardPoints(player: player)
        }
    
        billardViewModel.resetForm()
        dismiss()
    }
}


