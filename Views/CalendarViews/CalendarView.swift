import SwiftUI
import SwiftData

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @Query(sort: \PlayDate.date) private var playDates: [PlayDate]
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            VStack{
                CalendarItem(groupedDates: viewModel.groupedDates(from: playDates))
                ManageCalendar(viewModel: viewModel)
                Countdown(playDates: playDates)
            }
        }
        .sheet(isPresented: $viewModel.showingEditSheet) {
            if let selectedEvent = viewModel.selectedEvent {
                EditEventSheet(viewModel: viewModel, event: selectedEvent)
            }
        }
    }
}
