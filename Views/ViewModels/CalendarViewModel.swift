import Foundation
import SwiftUI
import SwiftData

class CalendarViewModel: ObservableObject {
    
    @Published var selectedEvent: PlayDate?
    @Published var showingEditSheet = false

    func groupedDates(from dates: [PlayDate]) -> [MonthSection] {
        groupTourDatesByMonth(dates: dates)
    }

    func addGame(name: String, venue: String, date: Date, context: ModelContext) {
        let newGame = PlayDate(gameName: name, venue: venue, date: date)
        context.insert(newGame)
    }

    func editGame(game: PlayDate, newName: String, newVenue: String, newDate: Date, context: ModelContext) {
        game.gameName = newName
        game.venue = newVenue
        game.date = newDate
    }

    func deleteGame(game: PlayDate, context: ModelContext) {
        context.delete(game)
    }

    func selectEventForEditing(_ event: PlayDate) {
        selectedEvent = event
        showingEditSheet = true
    }
}

