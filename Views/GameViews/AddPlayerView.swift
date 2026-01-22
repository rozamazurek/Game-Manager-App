import SwiftUI
import SwiftData

struct AddPlayerView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var showingCreditsAddPlayer = false
    
    var body: some View {
        HStack(spacing: 15) {
            Button("Dodaj gracza do rankingu") {
                showingCreditsAddPlayer.toggle()
            }
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(10)
            .padding()
            .sheet(isPresented: $showingCreditsAddPlayer) {
                AddingPlayerView(viewModel: viewModel)
            }
        }
    }
}
struct AddingPlayerView:View{
        @Environment(\.dismiss) private var dismiss
        @Environment(\.modelContext) private var context
        @ObservedObject var viewModel: GameViewModel
        @State private var playerNick = ""
        @State private var selectedAvatar: String = Avatar.allAvatars[0]
        
        let columns = [
            GridItem(.adaptive(minimum: 50))
        ]
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Dane gracza")) {
                        TextField("Nick gracza", text: $playerNick)

                        
                        HStack {
                            Image(systemName: selectedAvatar)
                                .font(.title)
                                .foregroundColor(.blue)
                            Text("Wybrany avatar")
                        }
                    }
                    
                    Section(header: Text("Wybierz avatar")) {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(Avatar.allAvatars, id: \.self) { avatar in
                                AvatarSelectionButton(
                                    avatarName: avatar,
                                    isSelected: selectedAvatar == avatar,
                                    action: { selectedAvatar = avatar }
                                )
                                .id(avatar)
                            }
                        }
                        .padding(.vertical, 10)
                    }

                }
                .navigationTitle("Nowy gracz")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Anuluj") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Dodaj") {
                            guard !playerNick.isEmpty else { return }
                            viewModel.addPlayer(nick: playerNick,totalPoints: 0,gamesPlayed: 0, avatarName: selectedAvatar,context: context)
                            dismiss()
                        }
                        .disabled(playerNick.isEmpty)
                    }
                }
            }
        }
    }

struct AvatarSelectionButton: View {
    let avatarName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: avatarName)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}





