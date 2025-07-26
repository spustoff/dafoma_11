import Foundation

extension DateFormatter {
    static let nutriTrackDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let nutriTrackTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let nutriTrackDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let nutriTrackShortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    static let nutriTrackDayMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }()
    
    static let nutriTrackFullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }()
    
    static let nutriTrackWeekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    static let nutriTrackMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}

extension Date {
    var nutriTrackFormatted: String {
        DateFormatter.nutriTrackDate.string(from: self)
    }
    
    var nutriTrackTimeFormatted: String {
        DateFormatter.nutriTrackTime.string(from: self)
    }
    
    var nutriTrackDateTimeFormatted: String {
        DateFormatter.nutriTrackDateTime.string(from: self)
    }
    
    var nutriTrackShortFormatted: String {
        DateFormatter.nutriTrackShortDate.string(from: self)
    }
    
    var nutriTrackDayMonthFormatted: String {
        DateFormatter.nutriTrackDayMonth.string(from: self)
    }
    
    var nutriTrackFullFormatted: String {
        DateFormatter.nutriTrackFullDate.string(from: self)
    }
    
    var nutriTrackWeekdayFormatted: String {
        DateFormatter.nutriTrackWeekday.string(from: self)
    }
    
    var nutriTrackMonthFormatted: String {
        DateFormatter.nutriTrackMonth.string(from: self)
    }
    
    // Utility functions for date calculations
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    var isThisYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }
    
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var endOfWeek: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? self
    }
    
    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }
    
    func daysFromNow(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func relativeDateString() -> String {
        if isToday {
            return "Today"
        } else if isYesterday {
            return "Yesterday"
        } else if isTomorrow {
            return "Tomorrow"
        } else if isThisWeek {
            return nutriTrackWeekdayFormatted
        } else if isThisYear {
            return nutriTrackShortFormatted
        } else {
            return nutriTrackFormatted
        }
    }
} 