// WellnessWatch Watch App/Views/HistoryView.swift
import SwiftUI
import SwiftData

// MARK: - HistoryView

struct HistoryView: View {

    @Query(sort: \SessionRecord.startedAt, order: .reverse) var records: [SessionRecord]
    @Environment(\.modelContext) private var modelContext

    @State private var showClearConfirm = false

    private let background = Color(red: 0.05, green: 0.05, blue: 0.1)

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            if records.isEmpty {
                emptyState
            } else {
                recordsList
            }
        }
        .navigationTitle("練習紀錄")
        .confirmationDialog("確定清除所有紀錄？", isPresented: $showClearConfirm) {
            Button("清除全部", role: .destructive) {
                for record in records {
                    modelContext.delete(record)
                }
            }
            Button("取消", role: .cancel) { }
        }
    }

    // MARK: Subviews

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("🌙")
                .font(.system(size: 40))
            Text("尚無練習紀錄")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var recordsList: some View {
        List {
            ForEach(records) { record in
                HistoryRow(record: record)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 3, leading: 4, bottom: 3, trailing: 4))
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(records[index])
                }
            }

            // Clear All button
            Button {
                showClearConfirm = true
            } label: {
                Text("清除全部")
                    .font(.system(size: 12))
                    .foregroundStyle(.red.opacity(0.75))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - HistoryRow

struct HistoryRow: View {
    let record: SessionRecord

    var body: some View {
        HStack(spacing: 8) {
            Text(record.wasCompleted ? "✅" : "⏹️")
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(record.patternName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer()
                    Text(elapsedFormatted)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.85))
                }
                HStack(spacing: 4) {
                    Text(dateFormatted)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.45))
                    Text(record.paceLabel)
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.35))
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))
    }

    private var elapsedFormatted: String {
        let mins = Int(record.elapsedSeconds) / 60
        let secs = Int(record.elapsedSeconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d HH:mm"
        return formatter.string(from: record.startedAt)
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(for: SessionRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let ctx = container.mainContext
    ctx.insert(SessionRecord(
        patternID: "box",
        patternName: "Box Breathing",
        startedAt: Date().addingTimeInterval(-3600),
        elapsedSeconds: 300,
        completedCycles: 8,
        totalCycles: 8,
        wasCompleted: true,
        paceLabel: "標準"
    ))
    ctx.insert(SessionRecord(
        patternID: "4-7-8",
        patternName: "4-7-8 呼吸",
        startedAt: Date().addingTimeInterval(-7200),
        elapsedSeconds: 87,
        completedCycles: 3,
        totalCycles: 10,
        wasCompleted: false,
        paceLabel: "慢"
    ))
    return NavigationStack {
        HistoryView()
    }
    .modelContainer(container)
}
