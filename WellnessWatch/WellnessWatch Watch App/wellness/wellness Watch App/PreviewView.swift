// WellnessWatch Watch App/Views/PreviewView.swift
import SwiftUI

struct PreviewView: View {

    let pattern: BreathingPattern

    @State private var selectedMinutes: Int

    init(pattern: BreathingPattern) {
        self.pattern = pattern
        _selectedMinutes = State(initialValue: pattern.totalDurationMinutes)
    }

    // MARK: Body

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Mode header
                HStack(spacing: 6) {
                    Circle()
                        .fill(pattern.accentColor)
                        .frame(width: 8, height: 8)
                    Text(pattern.effectLabel)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.55))
                }

                // Phase rhythm row
                rhythmRow

                // Duration picker
                VStack(spacing: 4) {
                    Text("練習時間")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.45))

                    Picker("", selection: $selectedMinutes) {
                        ForEach(availableMinutes, id: \.self) { min in
                            Text("\(min) 分鐘").tag(min)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 80)
                }

                // Start button
                NavigationLink {
                    BreathingView(pattern: adjustedPattern)
                } label: {
                    Text("開始練習")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            pattern.accentColor,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
        }
        .navigationTitle(pattern.name)
    }

    // MARK: Subviews

    private var rhythmRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(pattern.steps.enumerated()), id: \.offset) { _, step in
                VStack(spacing: 2) {
                    Text(step.phase.label)
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.45))
                    Text("\(Int(step.duration))s")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: Helpers

    private var availableMinutes: [Int] { [2, 3, 4, 5, 7, 10, 15, 20] }

    private var adjustedPattern: BreathingPattern {
        BreathingPattern(
            id: pattern.id,
            name: pattern.name,
            steps: pattern.steps,
            totalDurationMinutes: selectedMinutes
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PreviewView(pattern: .box)
    }
}
