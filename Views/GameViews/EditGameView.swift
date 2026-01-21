import SwiftUI
import SwiftData

struct EditGameView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CalendarViewModel
    @Query(sort: \PlayDate.date) private var playDates: [PlayDate]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.groupedDates(from: playDates)) { monthSection in
                    Section(header: Text(monthSection.title)
                        .foregroundColor(.black)
                        .font(.headline)) {
                            ForEach(monthSection.dates) { playDate in
                                EventRow(playDate: playDate)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        viewModel.selectEventForEditing(playDate)
                                        dismiss() 
                                    }
                            }
                        }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Wybierz wydarzenie")
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

struct EventRow: View {
    let playDate: PlayDate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(playDate.gameName)
                .font(.headline)
                .foregroundColor(.black)
            
            Text(playDate.venue)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(playDate.date, style: .date)
                .font(.caption)
                .foregroundColor(.red)
        }
        .padding(.vertical, 8)
    }
}

struct EditEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @ObservedObject var viewModel: CalendarViewModel
    let event: PlayDate
    
    @State private var gameName: String
    @State private var gameVenue: String
    @State private var gameDate: Date
    
    init(viewModel: CalendarViewModel, event: PlayDate) {
        self.viewModel = viewModel
        self.event = event
        self._gameName = State(initialValue: event.gameName)
        self._gameVenue = State(initialValue: event.venue)
        self._gameDate = State(initialValue: event.date)
    }
    
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
                
                Section {
                    Button("Usuń wydarzenie") {
                        viewModel.deleteGame(game: event,context: context)
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Edytuj wydarzenie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Zapisz") {
                        viewModel.editGame(
                            game: event,
                            newName: gameName,
                            newVenue: gameVenue,
                            newDate: gameDate,
                            context: context
                        )
                        dismiss()
                    }
                    .disabled(gameName.isEmpty || gameVenue.isEmpty)
                }
            }
        }
    }
}
