import SwiftUI

struct BowlingGameView: View {
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        self._bowlingViewModel = StateObject(wrappedValue: BowlingViewModel(gameViewModel: viewModel))
    }
    @ObservedObject var viewModel: GameViewModel
    @StateObject private var bowlingViewModel: BowlingViewModel
    @State private var showingCreditsAddPlayer = false
    
    var body: some View {
        HStack(spacing: 15) {
            Button("Dodaj punkty za grę w kręgle") {
                showingCreditsAddPlayer.toggle()
            }
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(10)
            .padding()
            .sheet(isPresented: $showingCreditsAddPlayer) {
                BowlingGamingView(viewModel: viewModel)
            }
        }
    }
}
struct BowlingGamingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GameViewModel
    @StateObject private var bowlingViewModel: BowlingViewModel
    
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        self._bowlingViewModel = StateObject(wrappedValue: BowlingViewModel(gameViewModel: viewModel))
    }
    
    var body: some View {
        NavigationView {
            Form {
                playerSelectionSection
                gameResultsSection
                summarySection
            }
            .navigationTitle("Kręgle")
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
                    .disabled(bowlingViewModel.selectedPlayers.isEmpty ||
                             bowlingViewModel.numOfPoints.isEmpty ||
                             bowlingViewModel.finalPosition.isEmpty ||
                              bowlingViewModel.numOfGames.isEmpty ||
                              bowlingViewModel.totalPlayers.isEmpty)
                }
            }
        }
    }
    
    
    private var playerSelectionSection: some View {
        Section(header: Text("Wybór graczy")) {
            ForEach(viewModel.players) { player in
                PlayerSelectionRow(
                    player: player,
                    isSelected: bowlingViewModel.selectedPlayers.contains(where: { $0.id == player.id })
                ) {
                    if bowlingViewModel.selectedPlayers.contains(where: { $0.id == player.id }) {
                        bowlingViewModel.selectedPlayers.removeAll { $0.id == player.id }
                    } else {
                        bowlingViewModel.selectedPlayers.append(player)
                    }
                }
            }
        }
    }
    
    private var gameResultsSection: some View {
        Section(header: Text("Wyniki gry")) {
            TextField("Liczba końcowych punktów", text: $bowlingViewModel.numOfPoints)
                .keyboardType(.numberPad)
            
            TextField("Liczba rozegranych rund", text: $bowlingViewModel.numOfGames)
                .keyboardType(.numberPad)
            
            TextField("Końcowa pozycja", text: $bowlingViewModel.finalPosition)
                .keyboardType(.numberPad)
            
            TextField("Liczba graczy", text: $bowlingViewModel.totalPlayers)
                .keyboardType(.numberPad)
        }
    }
    
    private var summarySection: some View {
        Group {
            if !bowlingViewModel.selectedPlayers.isEmpty {
                Section(header: Text("Podsumowanie")) {
                    ForEach(bowlingViewModel.selectedPlayers) { player in
                        let points = bowlingViewModel.calculatePointsBowling(
                            numOfPoints: Int(bowlingViewModel.numOfPoints) ?? 0,
                            numOfGames: Int(bowlingViewModel.numOfGames) ?? 0,
                            finalPosition: Int(bowlingViewModel.finalPosition) ?? 1,
                            totalPlayers: Int(bowlingViewModel.totalPlayers) ?? 1
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
        for player in bowlingViewModel.selectedPlayers {
            bowlingViewModel.addBowlingPoints(player: player)
        }
    
        bowlingViewModel.resetForm()
        dismiss()
    }
}

