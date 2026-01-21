import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {

    var body: some View {
        TabView {
            RankingView()
                .tabItem {
                    Label("Ranking", systemImage: "person.3.fill")
                }
            
            PlayView()
                .tabItem {
                    Label("Gry", systemImage: "gamecontroller")
                }
            
            MoneyView()
                .tabItem {
                    Label("Kasa", systemImage: "creditcard.fill")
                }
            
            CalendarView()
                .tabItem {
                    Label("Kalendarz", systemImage: "deskclock.fill")
                }
            
        }
        .accentColor(.red)
    }
}

