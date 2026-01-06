import SwiftUI

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
            
            AccountView()
                .tabItem {
                    Label("Konto", systemImage: "person.fill")
                }
        }
        .accentColor(.red)
    }
}


struct Platform_View: View{
    var body: some View{
        HStack{
            Text("1").foregroundStyle(Color.white)
            Text("2").foregroundStyle(Color.white)
            Text("3").foregroundStyle(Color.white)
        }.background(Color.blue).frame(width: 800,height: 800)
    }
}



struct AccountView: View {
    var body: some View {
        HStack{
            Text("Ekran użytkownika")
        }
    }
}

#Preview {
    MainTabView()
}
