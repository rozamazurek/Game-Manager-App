import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            VStack{
                CalendarItem(groupedDates: viewModel.groupedDates)
                ManageCalendar(viewModel: viewModel)
                Countdown(playDates: viewModel.playDates) // PRZEKAZUJEMY całą tablicę
            }
        }
        .sheet(isPresented: $viewModel.showingEditSheet) {
            if let selectedEvent = viewModel.selectedEvent {
                EditEventSheet(viewModel: viewModel, event: selectedEvent)
            }
        }
    }
}
