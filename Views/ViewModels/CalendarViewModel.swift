import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var playDates: [PlayDate] = [
        PlayDate(gameName: "Poker", venue: "Walońska", date: DateComponents(calendar: Calendar(identifier: .gregorian), year: 2025, month: 12, day: 7).date!),
        PlayDate(gameName: "Kręgle", venue: "Sky Bowling", date: DateComponents(calendar: Calendar(identifier: .gregorian), year: 2025, month: 12, day: 20).date!),
        PlayDate(gameName: "Bilard", venue: "La Sezam", date: DateComponents(calendar: Calendar(identifier: .gregorian), year: 2025, month: 12, day: 13).date!),
    ]
    
    @Published var selectedEvent: PlayDate?
    @Published var showingEditSheet = false
    
    var groupedDates: [MonthSection] {
        groupTourDatesByMonth(dates: playDates)
    }
    
    func addGame(name: String, venue: String, date: Date) {
        let newGame = PlayDate(gameName: name, venue: venue, date: date)
        playDates.append(newGame)
    }
    
    func editGame(id: UUID, newName: String, newVenue: String, newDate: Date) {
        if let index = playDates.firstIndex(where: { $0.id == id }) {
            playDates[index] = PlayDate(gameName: newName, venue: newVenue, date: newDate)
        }
    }
    
    func deleteGame(id: UUID) {
        playDates.removeAll { $0.id == id }
    }
    
    func selectEventForEditing(_ event: PlayDate) {
        selectedEvent = event
        showingEditSheet = true
    }
}
