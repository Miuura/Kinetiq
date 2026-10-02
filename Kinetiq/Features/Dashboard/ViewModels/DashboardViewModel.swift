//
//  DashboardViewModel.swift
//  Kinetiq
//
//  Created by Valentino Hartanto on 19/04/26.
//

import SwiftUI
import Observation

struct DashboardRuntimeState {
    var managedAppsConsumedMinutesToday: Int
    var managedAppsHardLocked: Bool
    var unlockedSessionCountToday: Int
    var lockStepBaselineToday: Int
    var totalStepsTodayStored: Int
    var currentSessionIndexToday: Int
    var currentSessionStartConsumedMinutes: Int
    var currentSessionLimitMinutes: Int
}

@MainActor
@Observable
final class DashboardViewModel {
    var mode: DashboardMode

    init(mode: DashboardMode = .goalReached) {
        self.mode = mode
    }

    func scene(
        dailyScreenLimitMinutes: Int,
        sessionLimitMinutes: Int,
        totalPlayedTodayMinutes: Int,
        activeSessionStartConsumedMinutes: Int,
        activeSessionLimitMinutes: Int,
        totalStepsToday: Int,
        currentUnlockSteps: Int,
        unlockGoalSteps: Int
    ) -> DashboardScene {
        let safeDailyLimit = max(0, dailyScreenLimitMinutes)
        let safeSessionLimit = max(1, sessionLimitMinutes)
        let safeTotalPlayedToday = max(0, totalPlayedTodayMinutes)
        let safeActiveSessionLimit = max(1, activeSessionLimitMinutes)
        let safeSessionStartConsumedMinutes = max(0, min(activeSessionStartConsumedMinutes, safeTotalPlayedToday))
        let safeTotalStepsToday = max(0, totalStepsToday)
        let safeUnlockGoalSteps = max(1, unlockGoalSteps)
        let safeCurrentUnlockSteps = min(max(0, currentUnlockSteps), safeUnlockGoalSteps)

        let remainingDailyMinutes = max(0, safeDailyLimit - safeTotalPlayedToday)
        let remainingSessionCharges = remainingDailyMinutes == 0
            ? 0
            : Int((Double(remainingDailyMinutes) / Double(safeSessionLimit)).rounded(.up))
        let consumedInCurrentSession = max(0, safeTotalPlayedToday - safeSessionStartConsumedMinutes)
        let remainingCurrentSessionMinutes = max(0, safeActiveSessionLimit - consumedInCurrentSession)

        switch mode {
        case .goalReached:
            let highlight = "\(remainingSessionCharges)"
            return DashboardScene(
                greetingText: "Hello, There!",
                headlineText: "Session Active.\n\(highlight) charges remaining\ntoday.",
                headlineHighlightText: highlight + " charges",
                insight: DashboardInsight(
                    title: "Screen Insight",
                    line1: "\(safeTotalPlayedToday) Minutes Played Today",
                    line2: "\(remainingSessionCharges) Charges Left",
                    footer: "Use your time wisely.",
                    strokeHex: "#7FAFFF"
                ),
                dailySummarySteps: nil,
                session: SessionProgress(current: 20, goal: 500),
                appAllowanceMinutes: remainingCurrentSessionMinutes,
                sessionEmphasis: .muted,
                allowanceEmphasis: .active,
                glowHex: "#7FAFFF"
            )

        case .dailyTimeReached:
            return DashboardScene(
                greetingText: "Hello, There!",
                headlineText: "Disconnected.\nDaily limit reached.",
                headlineHighlightText: nil,
                insight: DashboardInsight(
                    title: "Daily Summary",
                    line1: "\(safeTotalStepsToday.formatted()) total steps today",
                    line2: "Apps stay locked until tomorrow.",
                    footer: "Great effort today.",
                    strokeHex: "#FFFFFF"
                ),
                dailySummarySteps: safeTotalStepsToday,
                session: SessionProgress(current: 0, goal: 0),
                appAllowanceMinutes: 0,
                sessionEmphasis: .active,
                allowanceEmphasis: .muted,
                glowHex: "#FFFFFF"
            )

        case .appLocked:
            return DashboardScene(
                greetingText: "Hello, There!",
                headlineText: "App Locked.\nTime to move and\nunlock your apps.",
                headlineHighlightText: nil,
                insight: DashboardInsight(
                    title: "Activity Stats",
                    line1: "\(safeCurrentUnlockSteps) / \(safeUnlockGoalSteps) steps",
                    line2: "Walk to unlock next session.",
                    footer: "Keep the momentum.",
                    strokeHex: "#FF7FAC"
                ),
                dailySummarySteps: nil,
                session: SessionProgress(current: safeCurrentUnlockSteps, goal: safeUnlockGoalSteps),
                appAllowanceMinutes: 0,
                sessionEmphasis: .active,
                allowanceEmphasis: .muted,
                glowHex: "#FF7FAC"
            )
        }
    }

    // Atur posisi batu satu per satu di sini.
    var rockLayers: [DashboardRockLayer] {
        [
            DashboardRockLayer(
                id: "kiri-atas-back",
                assetName: "KananBawahKiriAtas",
                widthRatio: 0.45,
                baseXRatio: -0.48,
                baseYRatio: -0.2,
                parallaxMultiplier: 0.28,
                zIndex: 1,
                mask: nil
            ),
            DashboardRockLayer(
                id: "kanan-bawah-back",
                assetName: "KananBawahKiriAtas",
                widthRatio: 0.48,
                baseXRatio: 0.185,
                baseYRatio: 0.2,
                parallaxMultiplier: 0.28,
                zIndex: 1,
                mask: nil
            ),
            DashboardRockLayer(
                id: "kiri-bawah",
                assetName: "KiriBawah",
                widthRatio: 0.7,
                baseXRatio: -0.49,
                baseYRatio: 0.30,
                parallaxMultiplier: 0.47,
                zIndex: 3,
                mask: nil
            ),
            DashboardRockLayer(
                id: "kanan-atas",
                assetName: "KananAtas",
                widthRatio: 0.75,
                baseXRatio: 0.26,
                baseYRatio: -0.25,
                parallaxMultiplier: 0.47,
                zIndex: 3,
                mask: nil
            ),
            DashboardRockLayer(
                id: "tengah",
                assetName: "Tengah",
                widthRatio: 1.175,
                baseXRatio: -0.09,
                baseYRatio: 0.00,
                parallaxMultiplier: 1.15,
                zIndex: 4,
                mask: nil
            )
        ]
    }

    func currentUnlockStepsForDisplay(state: DashboardRuntimeState) -> Int {
        max(0, state.totalStepsTodayStored - state.lockStepBaselineToday)
    }

    func normalizeConsumedMinutesIfNeeded(
        state: inout DashboardRuntimeState,
        dailyScreenLimitMinutes: Int
    ) {
        let maxAllowedMinutes = max(0, dailyScreenLimitMinutes)
        if state.managedAppsConsumedMinutesToday > maxAllowedMinutes {
            state.managedAppsConsumedMinutesToday = maxAllowedMinutes
        }
    }

    func resetDailyStateIfNeeded(
        state: inout DashboardRuntimeState,
        usageDateKey: inout String,
        sessionLimitMinutes: Int,
        today: Date = Date()
    ) -> Bool {
        let todayKey = DashboardDate.usageDateFormatter.string(from: today)
        guard usageDateKey != todayKey else { return false }

        usageDateKey = todayKey
        state.managedAppsConsumedMinutesToday = 0
        state.managedAppsHardLocked = false
        state.unlockedSessionCountToday = 1
        state.lockStepBaselineToday = 0
        state.totalStepsTodayStored = 0
        state.currentSessionIndexToday = 1
        state.currentSessionStartConsumedMinutes = 0
        state.currentSessionLimitMinutes = max(1, sessionLimitMinutes)
        return true
    }

    func refreshAccessState(
        state: inout DashboardRuntimeState,
        dailyScreenLimitMinutes: Int,
        sessionLimitMinutes: Int,
        stepGoal: Int
    ) {
        if state.unlockedSessionCountToday < 1 {
            state.unlockedSessionCountToday = 1
        }
        ensureCurrentSessionSnapshot(
            state: &state,
            sessionLimitMinutes: sessionLimitMinutes
        )

        let safeDailyLimit = max(1, dailyScreenLimitMinutes)
        let currentSessionUsageThreshold =
            state.currentSessionStartConsumedMinutes + state.currentSessionLimitMinutes
        let activeUsageThreshold = min(safeDailyLimit, currentSessionUsageThreshold)
        if state.managedAppsHardLocked && state.managedAppsConsumedMinutesToday > activeUsageThreshold {
            state.managedAppsConsumedMinutesToday = activeUsageThreshold
        }

        let remainingDailyMinutes = max(0, dailyScreenLimitMinutes - state.managedAppsConsumedMinutesToday)
        let unlockGoal = max(1, stepGoal)

        if remainingDailyMinutes == 0 {
            state.managedAppsHardLocked = true
            mode = .dailyTimeReached
            return
        }

        let isSessionLimitReached = state.managedAppsConsumedMinutesToday >= currentSessionUsageThreshold

        guard isSessionLimitReached else {
            state.managedAppsHardLocked = false
            mode = .goalReached
            return
        }

        if mode != .appLocked {
            state.lockStepBaselineToday = state.totalStepsTodayStored
        }

        state.managedAppsHardLocked = true
        mode = .appLocked

        let unlockSteps = currentUnlockStepsForDisplay(state: state)
        if unlockSteps >= unlockGoal {
            state.unlockedSessionCountToday += 1
            state.lockStepBaselineToday = state.totalStepsTodayStored
            beginNewSessionSnapshot(
                state: &state,
                sessionLimitMinutes: sessionLimitMinutes
            )
            state.managedAppsHardLocked = false
            mode = .goalReached
        }
    }

    private func ensureCurrentSessionSnapshot(
        state: inout DashboardRuntimeState,
        sessionLimitMinutes: Int
    ) {
        if state.currentSessionIndexToday < 1 {
            state.currentSessionIndexToday = 1
        }

        if state.currentSessionIndexToday != state.unlockedSessionCountToday {
            beginNewSessionSnapshot(
                state: &state,
                sessionLimitMinutes: sessionLimitMinutes
            )
            return
        }

        if state.currentSessionStartConsumedMinutes > state.managedAppsConsumedMinutesToday {
            state.currentSessionStartConsumedMinutes = state.managedAppsConsumedMinutesToday
        }

        if state.currentSessionLimitMinutes < 1 {
            state.currentSessionLimitMinutes = max(1, sessionLimitMinutes)
        }

        if state.managedAppsConsumedMinutesToday <= state.currentSessionStartConsumedMinutes {
            state.currentSessionLimitMinutes = max(1, sessionLimitMinutes)
        }
    }

    private func beginNewSessionSnapshot(
        state: inout DashboardRuntimeState,
        sessionLimitMinutes: Int
    ) {
        state.currentSessionIndexToday = max(1, state.unlockedSessionCountToday)
        state.currentSessionStartConsumedMinutes = max(0, state.managedAppsConsumedMinutesToday)
        state.currentSessionLimitMinutes = max(1, sessionLimitMinutes)
    }
}
