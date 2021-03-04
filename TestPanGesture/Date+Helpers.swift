import Foundation

public class DatePreferences {
    fileprivate static let shared = DatePreferences()
    public var calendar: Calendar = .current
}

extension Date {
    static var preferences: DatePreferences {
        return .shared
    }
    
    var calendar: Calendar { return Date.preferences.calendar }
    
    var startOfDay: Date? {
        return calendar.date(from: calendar.dateComponents([.day, .year, .month], from: self))
    }
    
    func offset(days: Int) -> Date? {
        return calendar.date(byAdding: .day, value: days, to: self)
    }
    
    var isToday: Bool {
        return calendar.isDateInToday(self)
    }
    
    var dayNumber: Int {
        return calendar.component(.day, from: self)
    }
    
    var weekdayShortName: String {
        let weekday = calendar.component(.weekday, from: self)
        return DateFormatter().shortWeekdaySymbols[weekday - 1]
    }
    
    func weekDays(offset: Int = 0) -> [Date] {
        return self.offset(days: offset * 7)?.daysOfWeek() ?? []
    }
    
    static func datesRange(from: Date, to: Date) -> [Date] {
        // in case of the "from" date is more than "to" date,
        // it should returns an empty array:
        if from > to { return [Date]() }

        var tempDate = from
        var array = [tempDate]

        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }

        return array
    }
    
    func dateComponents(_ components: Set<Calendar.Component>, using calendar: Calendar = .current) -> DateComponents {
        calendar.dateComponents(components, from: self)
    }
    
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.date(from: dateComponents([.yearForWeekOfYear, .weekOfYear], using: calendar))!
    }
    
    var startOfWeek: Date? {
        return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear],
                                                           from: self))
    }
    
    func daysOfWeek(using calendar: Calendar = .current) -> [Date] {
        guard let startOfWeek = self.startOfWeek else { return [] }
        return (0...6).compactMap { startOfWeek.offset(days: $0) }
    }
}
