import SwiftUI

struct ManageCalendar: View {
    @ObservedObject var viewModel: CalendarViewModel // ODBIERAMY viewModel
    @State private var showingCreditsAddView = false
    @State private var showingCreditsEditView = false
    
    var body: some View {
        HStack(spacing: 15) {
            Button("Dodaj rozgrywke") {
                showingCreditsAddView.toggle()
            }
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(10)
            .padding()
            .sheet(isPresented: $showingCreditsAddView) {
                AddGameView(viewModel: viewModel) // PRZEKAZUJEMY viewModel
                    .presentationDetents([.medium, .large])
            }
            
            Button("Edytuj rozgrywke") {
                showingCreditsEditView.toggle()
            }
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(10)
            .padding()
            .sheet(isPresented: $showingCreditsEditView) {
                EditGameView(viewModel: viewModel) // PRZEKAZUJEMY viewModel
                    .presentationDetents([.medium, .large])
            }
        }
    }
}
