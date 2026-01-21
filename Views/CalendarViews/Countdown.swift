import SwiftUI

struct Countdown: View {
    let playDates: [PlayDate]
    @State private var now = Date()
    @State private var nearestEvent: PlayDate?
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(playDates: [PlayDate]) {
        self.playDates = playDates
        self._nearestEvent = State(initialValue: Self.findNearestEvent(in: playDates))
    }
    
    var body: some View {
        Group {
            if let playDate = nearestEvent {
                let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: now, to: playDate.date)
                
                VStack(spacing: 10) {
                    Text(playDate.gameName)
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text(playDate.venue)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Pozostało:")
                        .foregroundColor(.white)
                        .font(.headline)
                    Text("\(components.day ?? 0)d \(components.hour ?? 0)h \(components.minute ?? 0)m \(components.second ?? 0)s")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .bold()
                }
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(15)
            } else {
                VStack(spacing: 10) {
                    Text("Brak nadchodzących wydarzeń")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Dodaj nowe wydarzenie w kalendarzu")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(15)
            }
        }
        .onReceive(timer) { input in
            now = input
            nearestEvent = Self.findNearestEvent(in: playDates)
        }
    }
    
    private static func findNearestEvent(in playDates: [PlayDate]) -> PlayDate? {
        let futureEvents = playDates.filter { $0.date > Date() }
        return futureEvents.sorted { $0.date < $1.date }.first
    }
}

