import SwiftUI

struct ManageCalendar: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var showingAddView = false
    @State private var showingEditView = false
    
    var body: some View {
        HStack(spacing: 15) {
            Button("Dodaj rozgrywkę") {
                showingAddView.toggle()
            }
            .buttonStyle(.bordered).foregroundColor(.blue).tint(.gray)
            .sheet(isPresented: $showingAddView) {
                AddGameView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
            
            Button("Edytuj rozgrywkę") {
                showingEditView.toggle()
            }
            .buttonStyle(.bordered).foregroundColor(.blue).tint(.gray)
            .sheet(isPresented: $showingEditView) {
                EditGameView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
        }
        .padding()
    }
}
