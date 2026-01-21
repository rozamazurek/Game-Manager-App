import SwiftUI
import SwiftData

struct AddGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @ObservedObject var viewModel: CalendarViewModel // ODBIERAMY viewModel
    @State private var gameDate = Date()
    @State private var gameName = ""
    @State private var gameVenue = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Data", selection: $gameDate)
                }
                
                Section {
                    TextField("Gra", text: $gameName)
                }
                
                Section {
                    TextField("Miejsce", text: $gameVenue)
                }
            }
            .navigationTitle("Dodaj rozgrywkę")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dodaj") {
                        addGame()
                    }
                    .disabled(gameName.isEmpty || gameVenue.isEmpty)
                }
            }
        }
    }
    
    private func addGame() {
        guard !gameName.isEmpty, !gameVenue.isEmpty else { return }
        viewModel.addGame(name: gameName, venue: gameVenue, date: gameDate,context: context)
        dismiss()
    }
}
