import SwiftUI

struct PlayView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            VStack{
                AddPlayerView(viewModel: viewModel)
                PokerGameView(viewModel:viewModel)
                BowlingGameView(viewModel: viewModel)
                BillardGameView(viewModel: viewModel)
            }
        }
    }
}
