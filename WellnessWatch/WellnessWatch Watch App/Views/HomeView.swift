// WellnessWatch Watch App/Views/HomeView.swift
import SwiftUI

// MARK: - HomeView

struct HomeView: View {

    @StateObject private var healthKit = HealthKitService()

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {

                // Stress card — visible only when HealthKit authorized (PRD §4.2)
                if healthKit.isAuthorized {
                    stressCard
                        .padding(.bottom, 2)
                }

                // Breathing mode list
                ForEach(BreathingPattern.all) { pattern in
                    NavigationLink {
                        BreathingView(pattern: pattern)
                    } label: {
                        ModeRow(pattern: pattern)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)
        }
        .navigationTitle("呼吸練習")
        .task {
            // Request auth on first use, not on launch (PRD §4.2.1)
            await healthKit.requestAuthorizationIfNeeded()
            if healthKit.isAuthorized {
                healthKit.startHeartRateMonitoring()
                await healthKit.fetchLatestHRV()
            }
        }
    }

    // MARK: Stress Card

    private var stressCard: some View {
        HStack(spacing: 8) {
            Text(healthKit.stressLevel.emoji)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(healthKit.stressLevel.label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    if healthKit.currentHeartRate > 0 {
                        Label(
                            "\(Int(healthKit.currentHeartRate)) bpm",
                            systemImage: "heart.fill"
                        )
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.65))
                        .labelStyle(.titleAndIcon)
                    }
                    if healthKit.currentHRV > 0 {
                        Text("HRV \(Int(healthKit.currentHRV)) ms")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.65))
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            healthKit.stressLevel.color.opacity(0.15),
            in: RoundedRectangle(cornerRadius: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    healthKit.stressLevel.color.opacity(0.35),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - ModeRow

struct ModeRow: View {
    let pattern: BreathingPattern

    var body: some View {
        HStack(spacing: 10) {
            // Accent dot
            Circle()
                .fill(pattern.accentColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 1) {
                Text(pattern.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                Text(pattern.effectLabel)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Text("\(pattern.totalDurationMinutes) min")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView()
    }
}
