import SwiftUI

struct CalendarItem: View {
    let groupedDates: [MonthSection]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                Text("KALENDARZ ROZGRYWEK")
                    .foregroundColor(.white)
                
                Rectangle()
                    .foregroundColor(.red)
                    .opacity(0.80)
                    .frame(width: 300, height: 410)
                    .cornerRadius(20)
                    .overlay(
                        List(groupedDates) { monthSection in
                            Section(header: Text(monthSection.title)
                                .foregroundColor(.white)
                                .font(.headline)) {
                                    ForEach(monthSection.dates) { playDate in
                                        VStack(alignment: .leading) {
                                            Text(playDate.gameName)
                                                .foregroundColor(.black)
                                            Text(playDate.venue)
                                                .foregroundColor(.gray)
                                            Text(playDate.date, style: .date)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                        .padding()
                    )
            }
        }
    }
}
