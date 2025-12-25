import SwiftUI

struct ContributionGraph: View {
    @Environment(\.theme) private var theme
    let calendar: ContributionCalendar
    
    private let cellSize: CGFloat = 11
    private let cellSpacing: CGFloat = 3
    private let weeksToShow = 52
    
    private var allDays: [ContributionDay] {
        (calendar.weeks ?? []).flatMap { $0.contributionDays }
    }
    
    private var weeks: [ContributionWeek] {
        Array((calendar.weeks ?? []).suffix(weeksToShow))
    }
    
    private var monthLabels: [(index: Int, month: String)] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        var labels: [(index: Int, month: String)] = []
        var lastMonth: Int? = nil
        
        for (index, week) in weeks.enumerated() {
            if let firstDay = week.contributionDays.first,
               let date = firstDay.parsedDate {
                let month = Calendar.current.component(.month, from: date)
                if month != lastMonth {
                    labels.append((index: index, month: dateFormatter.string(from: date)))
                    lastMonth = month
                }
            }
        }
        
        return labels
    }
    
    private var dayLabels: [String] {
        ["Mon", "", "Wed", "", "Fri", "", ""]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            headerView
            graphView
            legendView
        }
        .padding(Spacing.lg)
        .background(theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .stroke(theme.border, lineWidth: 0.5)
        )
    }
    
    private var headerView: some View {
        HStack {
            Text("\(calendar.totalContributions) contributions in the last year")
                .font(Typography.body())
                .foregroundStyle(theme.text)
                .responsiveText()
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            Spacer()
        }
    }
    
    private var graphView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: cellSpacing) {
                monthLabelsView
                contributionGrid
            }
        }
    }
    
    private var monthLabelsView: some View {
        HStack(spacing: 0) {
            Text("")
                .frame(width: 30)
            
            HStack(alignment: .top, spacing: 0) {
                ForEach(Array(weeks.enumerated()), id: \.offset) { weekIndex, week in
                    monthLabelForWeek(weekIndex: weekIndex, week: week)
                }
            }
        }
    }
    
    @ViewBuilder
    private func monthLabelForWeek(weekIndex: Int, week: ContributionWeek) -> some View {
        if let firstDay = week.contributionDays.first,
           let date = firstDay.parsedDate {
            let month = Calendar.current.component(.month, from: date)
            let previousWeek = weekIndex > 0 ? weeks[weekIndex - 1] : nil
            let previousMonth = previousWeek?.contributionDays.first?.parsedDate.flatMap {
                Calendar.current.component(.month, from: $0)
            }
            let isFirstOfMonth = weekIndex == 0 || previousMonth != month
            
            if isFirstOfMonth {
                monthLabelText(for: date)
            } else {
                Spacer()
                    .frame(width: cellSize + cellSpacing)
            }
        } else {
            Spacer()
                .frame(width: cellSize + cellSpacing)
        }
    }
    
    private func monthLabelText(for date: Date) -> some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return Text(dateFormatter.string(from: date))
            .font(.system(size: 10))
            .foregroundStyle(theme.secondaryText)
            .frame(width: cellSize * 7 + cellSpacing * 6, alignment: .leading)
    }
    
    private var contributionGrid: some View {
        HStack(alignment: .top, spacing: cellSpacing) {
            dayLabelsColumn
            weeksColumn
        }
    }
    
    private var dayLabelsColumn: some View {
        VStack(alignment: .trailing, spacing: cellSpacing) {
            ForEach(Array(dayLabels.enumerated()), id: \.offset) { index, day in
                if !day.isEmpty {
                    Text(day)
                        .font(.system(size: 10))
                        .foregroundStyle(theme.secondaryText)
                        .frame(height: cellSize, alignment: .trailing)
                } else {
                    Spacer()
                        .frame(height: cellSize)
                }
            }
        }
        .frame(width: 30)
    }
    
    private var weeksColumn: some View {
        HStack(alignment: .top, spacing: cellSpacing) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { weekIndex, week in
                weekColumn(week: week)
            }
        }
    }
    
    private func weekColumn(week: ContributionWeek) -> some View {
        VStack(spacing: cellSpacing) {
            ForEach(Array(week.contributionDays.enumerated()), id: \.offset) { dayIndex, day in
                ContributionCell(count: day.contributionCount)
                    .frame(width: cellSize, height: cellSize)
            }
        }
    }
    
    private var legendView: some View {
        HStack {
            Text("Learn how we count contributions")
                .font(Typography.caption())
                .foregroundStyle(theme.secondaryText)
                .responsiveText()
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("Less")
                    .font(Typography.caption())
                    .foregroundStyle(theme.secondaryText)
                    .responsiveText()
                
                HStack(spacing: cellSpacing) {
                    ForEach(0..<5) { level in
                        ContributionCell(count: level)
                            .frame(width: cellSize, height: cellSize)
                    }
                }
                
                Text("More")
                    .font(Typography.caption())
                    .foregroundStyle(theme.secondaryText)
                    .responsiveText()
            }
        }
    }
}

private struct ContributionCell: View {
    let count: Int
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(colorForCount(count))
    }
    
    private func colorForCount(_ count: Int) -> Color {
        // GitHub's contribution graph colors (green shades)
        switch count {
        case 0:
            return Color(red: 0.94, green: 0.94, blue: 0.94) // #ebedf0 - lightest gray
        case 1:
            return Color(red: 0.87, green: 0.96, blue: 0.87) // #9be9a8 - light green
        case 2:
            return Color(red: 0.56, green: 0.93, blue: 0.56) // #40c463 - medium green
        case 3:
            return Color(red: 0.31, green: 0.78, blue: 0.47) // #30a14e - darker green
        default:
            return Color(red: 0.13, green: 0.55, blue: 0.13) // #216e39 - darkest green
        }
    }
}
