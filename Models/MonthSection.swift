import Foundation
import SwiftData
import SwiftUI

struct MonthSection: Identifiable {
    let id: String
    let title: String
    let dates: [PlayDate]
}

func groupTourDatesByMonth(dates: [PlayDate]) -> [MonthSection] {
    let grouped = Dictionary(grouping: dates) { play in
        let comps = Calendar(identifier: .gregorian).dateComponents([.year, .month], from: play.date)
        return "\(comps.year!)-\(comps.month!)"
    }
    
    let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
    
    return grouped.map { key, datesInMonth in
        let parts = key.split(separator: "-").map(String.init)
        let year = Int(parts[0])!
        let month = Int(parts[1])!
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: 1))!
        let title = monthFormatter.string(from: date)
        
        return MonthSection(id: key, title: title, dates: datesInMonth.sorted { $0.date < $1.date })
    }.sorted { $0.id < $1.id }
}
