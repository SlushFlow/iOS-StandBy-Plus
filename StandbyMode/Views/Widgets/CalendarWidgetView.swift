import SwiftUI

struct CalendarWidgetView: View {
    let size: WidgetSize
    @EnvironmentObject var themeManager: ThemeManager

    @State private var currentDate = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: size == .huge ? 12 : 6) {
            HStack {
                Text(monthString)
                    .font(.system(size: size == .huge ? 18 : 13, weight: .semibold))
                    .foregroundColor(themeManager.colors.primary)
                Spacer()
                Text(yearString)
                    .font(.system(size: size == .huge ? 14 : 11))
                    .foregroundColor(themeManager.colors.textSecondary)
            }
            .padding(.horizontal, 8)

            if size == .huge {
                calendarGrid
            } else {
                compactCalendar
            }
        }
        .padding(12)
        .onReceive(timer) { self.currentDate = $0 }
    }

    private var compactCalendar: some View {
        VStack(spacing: 4) {
            Text(dayNumberString)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(themeManager.colors.textPrimary)

            Text(dayOfWeekString)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(themeManager.colors.textSecondary)
        }
    }

    private var calendarGrid: some View {
        let calendar = Calendar.current
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        let today = calendar.component(.day, from: currentDate)

        return VStack(spacing: 4) {
            HStack(spacing: 0) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(themeManager.colors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 2) {
                ForEach(0..<42, id: \.self) { index in
                    let dayNum = index - firstWeekday + 1
                    if dayNum >= 1 && dayNum <= daysInMonth.count {
                        Text("\(dayNum)")
                            .font(.system(size: 11, weight: dayNum == today ? .bold : .regular))
                            .foregroundColor(dayNum == today ? themeManager.colors.background : themeManager.colors.textPrimary)
                            .frame(width: 22, height: 22)
                            .background(
                                Circle()
                                    .fill(dayNum == today ? themeManager.colors.primary : Color.clear)
                            )
                    } else {
                        Text("")
                            .frame(width: 22, height: 22)
                    }
                }
            }
        }
    }

    private var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        return calendar.date(from: components)!
    }

    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: currentDate)
    }

    private var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: currentDate)
    }

    private var dayNumberString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: currentDate)
    }

    private var dayOfWeekString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: currentDate)
    }
}
