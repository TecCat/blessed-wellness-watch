// StatsView.swift — Practice statistics screen
import SwiftUI
import SwiftData
import Charts

struct StatsView: View {

    @Query(sort: \SessionRecord.startedAt, order: .reverse) var records: [SessionRecord]

    private let background  = Color(red: 0.05, green: 0.05, blue: 0.1)
    private let breatheBlue = Color(red: 0.200, green: 0.510, blue: 0.898)

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    summaryCards
                    weekChart
                    favouritePattern
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
            }
        }
        .navigationTitle(L.navTitleStats)
    }

    // MARK: - Section 1: Summary cards

    private var summaryCards: some View {
        HStack(spacing: 6) {
            StatCard(value: "\(records.count)", label: L.statTotalSessions)
            StatCard(value: "\(totalMinutes)", label: L.statTotalMinutes)
            StatCard(value: "\(currentStreak)", label: L.statStreak)
        }
    }

    private var totalMinutes: Int {
        Int(records.reduce(0) { $0 + $1.elapsedSeconds } / 60)
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDay = today

        while true {
            let hasPractice = records.contains {
                calendar.isDate($0.startedAt, inSameDayAs: checkDay)
            }
            guard hasPractice else { break }
            streak += 1
            checkDay = calendar.date(byAdding: .day, value: -1, to: checkDay)!
        }
        return streak
    }

    // MARK: - Section 2: 7-day chart

    private var weekChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L.last7Days)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))

            Chart(last7Days, id: \.label) { day in
                BarMark(
                    x: .value("日期", day.label),
                    y: .value("分鐘", day.minutes)
                )
                .foregroundStyle(
                    Calendar.current.isDateInToday(day.date)
                        ? breatheBlue.opacity(1.0)
                        : breatheBlue.opacity(0.55)
                )
                .cornerRadius(3)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine().foregroundStyle(.white.opacity(0.1))
                    AxisValueLabel()
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .frame(height: 90)
        }
        .padding(10)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))
    }

    private var last7Days: [(date: Date, label: String, minutes: Double)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"

        return (0..<7).reversed().map { offset -> (date: Date, label: String, minutes: Double) in
            let date = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: Date()))!
            let mins = records
                .filter { calendar.isDate($0.startedAt, inSameDayAs: date) }
                .reduce(0.0) { $0 + $1.elapsedSeconds / 60 }
            return (date: date, label: formatter.string(from: date), minutes: mins)
        }
    }

    // MARK: - Section 3: Favourite pattern

    private var favouritePattern: some View {
        Group {
            if let fav = favouritePatternName {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.yellow.opacity(0.8))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L.favouritePattern)
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.5))
                        Text(fav)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var favouritePatternName: String? {
        guard !records.isEmpty else { return nil }
        let counts = Dictionary(grouping: records, by: \.patternID)
            .mapValues(\.count)
        guard let topID = counts.max(by: { $0.value < $1.value })?.key else { return nil }
        return records.first { $0.patternID == topID }?.patternName
    }
}

// MARK: - StatCard

private struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(
        for: SessionRecord.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let ctx = container.mainContext
    let now = Date()
    let samples: [(Double, String, String, Int)] = [
        (-86400 * 0, "box",   "Box Breathing",  300),
        (-86400 * 1, "4-7-8", "4-7-8 呼吸",      480),
        (-86400 * 2, "box",   "Box Breathing",  240),
        (-86400 * 3, "478",   "4-7-8 呼吸",      360),
        (-86400 * 5, "box",   "Box Breathing",  180),
        (-86400 * 6, "calm",  "平靜呼吸",         420),
    ]
    for (offset, id, name, secs) in samples {
        ctx.insert(SessionRecord(
            patternID: id, patternName: name,
            startedAt: now.addingTimeInterval(offset),
            elapsedSeconds: Double(secs),
            completedCycles: 5, totalCycles: 8,
            wasCompleted: true, paceLabel: "標準"
        ))
    }
    return NavigationStack {
        StatsView()
    }
    .modelContainer(container)
    .environmentObject(AppNav())
}
