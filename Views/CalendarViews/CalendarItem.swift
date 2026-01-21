import SwiftUI

struct CalendarItem: View {
    let groupedDates: [MonthSection]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 15) {
                Text("KALENDARZ ROZGRYWEK")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Rectangle()
                    .foregroundColor(.blue)
                    .opacity(0.8)
                    .frame(width: 300, height: 410)
                    .cornerRadius(20)
                    .overlay(
                        List {
                            ForEach(groupedDates) { monthSection in
                                Section(header: Text(monthSection.title)
                                    .foregroundColor(.white)
                                    .font(.headline)) {
                                    ForEach(monthSection.dates) { playDate in
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(playDate.gameName)
                                                .foregroundColor(.white)
                                            Text(playDate.venue)
                                                .foregroundColor(.gray)
                                            Text(playDate.date, style: .date)
                                                .foregroundColor(.blue)
                                        }
                                        .padding(.vertical, 2)
                                    }
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .background(Color.clear)
                    )
            }
            .padding()
        }
    }
}
