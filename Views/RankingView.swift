import SwiftUI

struct RankingView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var currentViewIndex = 0
    @State private var rotationAngle: Double = 0
    @GestureState private var dragOffset = CGSize.zero
    
    let views = ["Podium", "Lista", "Statystyki"]
    
    var sortedPlayers: [Player] {
        gameViewModel.players.sorted { $0.totalPoints > $1.totalPoints }
    }
    
    var topThreePlayers: [Player] {
        Array(sortedPlayers.prefix(3))
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    HeaderView(currentViewIndex: currentViewIndex)
                        .padding(.top)
                        .background(Color(.systemBackground))
                    
                    ZStack {
                        // Podium View
                        if currentViewIndex == 0 {
                            PodiumViewContent(topPlayers: topThreePlayers, sortedPlayers: sortedPlayers)
                                .rotation3DEffect(
                                    .degrees(rotationAngle),
                                    axis: (x: 0, y: 1, 0)
                                    )
                        }
                        
                        // List View
                        if currentViewIndex == 1 {
                            ListViewContent(sortedPlayers: sortedPlayers)
                                .rotation3DEffect(
                                    .degrees(rotationAngle + 360),
                                    axis: (x: 0, y: 1, 0)
                                )
                                .offset(x: dragOffset.width)
                        }
                        
                        // Stats View
                        if currentViewIndex == 2 {
                            StatsViewContent(players: gameViewModel.players)
                                .rotation3DEffect(
                                    .degrees(rotationAngle + 720),
                                    axis: (x: 0, y: 1, 0)
                                )
                                .offset(x: dragOffset.width)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 100
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    if value.translation.width < -threshold {
                                        // w lewo kolejny widok
                                        goToNextView()
                                    } else if value.translation.width > threshold {
                                        // w prawo poprzedni widok
                                        goToPreviousView()
                                    }
                                    rotationAngle += value.translation.width < 0 ? 360 : -360
                                }
                            }
                    )
                    
                    HStack(spacing: 10) {
                        ForEach(0..<views.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentViewIndex ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentViewIndex ? 1.2 : 1.0)
                                .animation(.spring(), value: currentViewIndex)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            gameViewModel.objectWillChange.send()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
    
    private func goToNextView() {
        withAnimation(.spring()) {
            currentViewIndex = (currentViewIndex + 1) % views.count
        }
    }
    
    private func goToPreviousView() {
        withAnimation(.spring()) {
            currentViewIndex = (currentViewIndex - 1 + views.count) % views.count
        }
    }
}
struct HeaderView: View {
    let currentViewIndex: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Text("RANKING")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            // Current view indicator
            Text([" Podium", " Pełna lista", " Statystyki"][currentViewIndex])
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.1))
                )
        }
        .padding(.bottom, 20)
    }
}


struct PodiumViewContent: View {
    let topPlayers: [Player]
    let sortedPlayers: [Player]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !topPlayers.isEmpty {
                    // Podium
                    HStack(alignment: .bottom, spacing: 20) {
                        // 2nd place
                        if topPlayers.count > 1 {
                            PodiumStand(
                                player: topPlayers[1],
                                position: 2,
                                height: 120,
                                color: .gray
                            )
                        }
                        
                        // 1st place
                        if !topPlayers.isEmpty {
                            PodiumStand(
                                player: topPlayers[0],
                                position: 1,
                                height: 150,
                                color: .yellow
                            )
                        }
                        
                        // 3rd place
                        if topPlayers.count > 2 {
                            PodiumStand(
                                player: topPlayers[2],
                                position: 3,
                                height: 90,
                                color: .brown
                            )
                        }
                    }
                    .frame(height: 180)
                    .padding(.horizontal)
                    
                    // TOP 10
                    VStack(alignment: .leading, spacing: 10) {
                        Text("TOP 10")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        ForEach(Array(sortedPlayers.prefix(10).enumerated()), id: \.element.id) { index, player in
                            SimplePlayerRow(
                                player: player,
                                position: index + 1
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.1), radius: 3)
                        .padding(.horizontal)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "trophy")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Brak graczy")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Dodaj graczy w zakładce Gry")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(height: 300)
                }
            }
            .padding(.vertical, 20)
        }
    }
}

struct PodiumStand: View {
    let player: Player
    let position: Int
    let height: CGFloat
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Position
            Text("\(position)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color)
                )
            
            // Avatar
            Image(systemName: player.avatarName)
                .font(.title)
                .foregroundColor(.blue)
            
            // Name
            Text(player.nick)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            // Points
            Text("\(player.totalPoints)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 80, height: height)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 5)
    }
}

struct SimplePlayerRow: View {
    let player: Player
    let position: Int
    
    var body: some View {
        HStack {
            Text("\(position).")
                .font(.headline)
                .foregroundColor(.gray)
                .frame(width: 30)
            
            Image(systemName: player.avatarName)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(player.nick)
                .font(.body)
            
            Spacer()
            
            Text("\(player.totalPoints) pkt")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.1)),
            alignment: .bottom
        )
    }
}

struct ListViewContent: View {
    let sortedPlayers: [Player]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                    DetailedPlayerRow(
                        player: player,
                        position: index + 1
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 20)
        }
    }
}

struct DetailedPlayerRow: View {
    let player: Player
    let position: Int
    
    var body: some View {
        HStack(spacing: 15) {
            // Position
            Text("\(position).")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(position <= 3 ? .yellow : .blue)
                .frame(width: 40)
            
            // Avatar
            Image(systemName: player.avatarName)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(player.nick)
                    .font(.headline)
                
                Text("\(player.gamesPlayed) gier")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Points
            VStack(alignment: .trailing) {
                Text("\(player.totalPoints)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("punktów")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.1), radius: 3)
        .padding(.vertical, 5)
    }
}

struct StatsViewContent: View {
    let players: [Player]
    
    var totalPlayers: Int { players.count }
    var totalPoints: Int { players.reduce(0) { $0 + $1.totalPoints } }
    var totalGames: Int { players.reduce(0) { $0 + $1.gamesPlayed } }
    var avgPoints: Double { totalPlayers > 0 ? Double(totalPoints) / Double(totalPlayers) : 0 }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats Cards
                StatCard(
                    title: "Graczy",
                    value: "\(totalPlayers)",
                    icon: "person.3.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Punkty",
                    value: "\(totalPoints)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Rozegranych gier",
                    value: "\(totalGames)",
                    icon: "gamecontroller.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Średnia na gracza",
                    value: String(format: "%.1f", avgPoints),
                    icon: "chart.bar.fill",
                    color: .purple
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(color)
                .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 5)
    }
}

struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        let mockPlayers = [
            Player(nick: "Janek", totalPoints: 450, gamesPlayed: 12, avatarName: "crown.fill"),
            Player(nick: "Asia", totalPoints: 380, gamesPlayed: 10, avatarName: "star.fill"),
            Player(nick: "Marek", totalPoints: 320, gamesPlayed: 8, avatarName: "bolt.fill"),
        ]
        
        let mockViewModel = GameViewModel()
        
        return RankingView()
            .onAppear {
                mockViewModel.players = mockPlayers
            }
    }
}
