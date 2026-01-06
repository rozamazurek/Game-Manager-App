import SwiftUI

struct Countdown: View {
    let playDates: [PlayDate] // DODAJEMY całą tablicę
    @State private var now = Date()
    @State private var nearestEvent: PlayDate? // SZUKAMY najbliższego wydarzenia
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Inicjalizator który znajduje najbliższe wydarzenie
    init(playDates: [PlayDate]) {
        self.playDates = playDates
        self._nearestEvent = State(initialValue: Self.findNearestEvent(in: playDates))
    }
    
    var body: some View {
        if let playDate = nearestEvent {
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.day, .hour, .minute, .second], from: now, to: playDate.date)
            
            VStack(spacing: 20) {
                Text(playDate.gameName)
                    .font(.title2)
                    .foregroundColor(.red)
                
                Text(playDate.venue)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Pozostało:")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Text("\(components.day ?? 0)d \(components.hour ?? 0)h \(components.minute ?? 0)m \(components.second ?? 0)s")
                    .font(.title2)
                    .foregroundColor(.red)
                    .bold()
                    .onReceive(timer) { input in
                        now = input
                        // Aktualizujemy najbliższe wydarzenie co sekundę
                        nearestEvent = Self.findNearestEvent(in: playDates)
                    }
            }
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(15)
        } else {
            // Fallback gdy nie ma żadnych wydarzeń
            VStack(spacing: 20) {
                Text("Brak nadchodzących wydarzeń")
                    .font(.title2)
                    .foregroundColor(.red)
                
                Text("Dodaj nowe wydarzenie w kalendarzu")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(15)
        }
    }
    
    // Funkcja która znajduje najbliższe wydarzenie w czasie
    private static func findNearestEvent(in playDates: [PlayDate]) -> PlayDate? {
        let now = Date()
        let futureEvents = playDates.filter { $0.date > now } // Tylko przyszłe wydarzenia
        return futureEvents.sorted { $0.date < $1.date }.first // Najbliższe w czasie
    }
}
