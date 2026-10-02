//
//  DashboardView.swift
//  Kinetiq
//
//  Created by Valentino Hartanto on 19/04/26.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct DashboardView: View {
    private let managedSettingsStore = ManagedSettingsStore()
    private static let appGroupSuiteName = "group.AVANGER.Kinetiq"
    private static let sharedDefaults = UserDefaults(suiteName: appGroupSuiteName)

    @State var viewModel: DashboardViewModel
    @State var motionModel = MotionParallaxViewModel()
    @State var stepTracker = StepTrackerViewModel()

    @State var hasAppeared = false
    @State var isSettingsPresented = false

    @State var greetingTypedText = ""
    @State var headlineTypedText = ""
    @State var typingTask: Task<Void, Never>?

    @State var isWalkthroughPresented = false
    @State var walkthroughStepIndex = 0
    @State var walkthroughTask: Task<Void, Never>?
    @State var isAllowanceCardFlipped = false
    @State var isSessionCardFlipped = false
    @State var familyActivitySelection = FamilyActivitySelection()
    @State var isFamilyActivityPickerPresented = false
    @State var familyControlsErrorMessage: String?

    @AppStorage("DailyScreenLimit") private var dailyScreenLimit: Double = 120
    @AppStorage("SessionLimit") private var sessionLimit: Double = 30
    @AppStorage("StepGoal") private var stepGoal: Double = 1000
    @AppStorage("HasSeenDashboardWalkthrough") private var hasSeenDashboardWalkthrough: Bool = false
    @AppStorage("HasPromptedFamilyControlPicker") private var hasPromptedFamilyControlPicker: Bool = false
    @AppStorage("FamilyActivitySelectionData", store: DashboardView.sharedDefaults) private var familyActivitySelectionData: Data = Data()
    // Updated by Screen Time pipeline (for example, a DeviceActivity monitor/report extension).
    @AppStorage("ManagedAppsConsumedMinutesToday", store: DashboardView.sharedDefaults) private var managedAppsConsumedMinutesToday: Int = 0
    @AppStorage("ManagedAppsUsageDateKey", store: DashboardView.sharedDefaults) private var managedAppsUsageDateKey: String = ""
    @AppStorage("ManagedAppsHardLocked", store: DashboardView.sharedDefaults) private var managedAppsHardLocked: Bool = false
    @AppStorage("UnlockedSessionCountToday") private var unlockedSessionCountToday: Int = 1
    @AppStorage("LockStepBaselineToday") private var lockStepBaselineToday: Int = 0
    @AppStorage("TotalStepsToday") private var totalStepsTodayStored: Int = 0
    @AppStorage("CurrentSessionIndexToday", store: DashboardView.sharedDefaults) private var currentSessionIndexToday: Int = 1
    @AppStorage("CurrentSessionStartConsumedMinutes", store: DashboardView.sharedDefaults) private var currentSessionStartConsumedMinutes: Int = 0
    @AppStorage("CurrentSessionLimitMinutes", store: DashboardView.sharedDefaults) private var currentSessionLimitMinutes: Int = 30

    init(mode: DashboardMode = .goalReached) {
        _viewModel = State(initialValue: DashboardViewModel(mode: mode))
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let scene = currentScene
            let rocks = viewModel.rockLayers
            let walkthroughSteps = makeWalkthroughSteps(in: size)

            ZStack {
                dashboardBackground(scene: scene)

                allowanceLayer(scene: scene, canvasHeight: size.height)
                rockLayers(rocks, canvasSize: size)
                sessionLayer(scene: scene, canvasSize: size)
                topGreetingText(scene: scene)

                if isWalkthroughPresented,
                   walkthroughSteps.indices.contains(walkthroughStepIndex) {
                    DashboardWalkthroughOverlay(
                        step: walkthroughSteps[walkthroughStepIndex],
                        stepIndex: walkthroughStepIndex,
                        totalSteps: walkthroughSteps.count,
                        onNext: {
                            if walkthroughStepIndex < walkthroughSteps.count - 1 {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    walkthroughStepIndex += 1
                                }
                            } else {
                                finishWalkthrough()
                            }
                        },
                        onSkip: {
                            finishWalkthrough()
                        }
                    )
                    .zIndex(50)
                    .transition(.opacity)
                }
            }
            .ignoresSafeArea()
            .animation(.spring(response: 0.7, dampingFraction: 0.8), value: viewModel.mode)
            .onAppear {
                handleAppear()
            }
            .onDisappear {
                handleDisappear()
            }
            .onChange(of: viewModel.mode) { _, _ in
                startTypingAnimation(for: currentScene)
                isAllowanceCardFlipped = false
                isSessionCardFlipped = false
                applyManagedAppShieldForCurrentMode()
            }
            .onChange(of: dailyScreenLimit) { _, _ in
                syncMonitoringConfigurationToSharedDefaults()
                handleLimitsDidChange()
                scheduleDeviceActivityMonitoring()
            }
            .onChange(of: sessionLimit) { _, _ in
                syncMonitoringConfigurationToSharedDefaults()
                handleLimitsDidChange()
                scheduleDeviceActivityMonitoring()
            }
            .onChange(of: stepGoal) { _, _ in
                handleLimitsDidChange()
            }
            .onChange(of: managedAppsConsumedMinutesToday) { _, _ in
                normalizeConsumedMinutesIfNeeded()
                refreshAccessState()
                updateHeaderTextWithoutRetyping(for: currentScene)
            }
            .onChange(of: unlockedSessionCountToday) { _, _ in
                syncMonitoringConfigurationToSharedDefaults()
            }
            .onChange(of: stepTracker.totalStepsToday) { _, newValue in
                totalStepsTodayStored = max(0, newValue)
                refreshAccessState()
                updateHeaderTextWithoutRetyping(for: currentScene)
            }
            .sheet(isPresented: $isSettingsPresented) {
                DashboardSettingsSheet(
                    dailyScreenLimit: $dailyScreenLimit,
                    sessionLimit: $sessionLimit,
                    stepGoal: $stepGoal,
                    onEditManagedApps: editManagedAppsFromSettings
                )
            }
            .familyActivityPicker(
                title: "Choose Apps to Manage",
                headerText: "Select apps, websites, and categories",
                footerText: "You can update this anytime in Settings",
                isPresented: $isFamilyActivityPickerPresented,
                selection: $familyActivitySelection
            )
            .onChange(of: familyActivitySelection) { _, _ in
                persistFamilySelection()
                applyManagedAppShieldForCurrentMode()
                scheduleDeviceActivityMonitoring()
            }
            .alert(
                "Family Controls",
                isPresented: Binding(
                    get: { familyControlsErrorMessage != nil },
                    set: { shouldShow in
                        if !shouldShow {
                            familyControlsErrorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(familyControlsErrorMessage ?? "")
            }
        }
    }

    private func handleAppear() {
        hasAppeared = false
        resetDailyStateIfNeeded()
        normalizeConsumedMinutesIfNeeded()
        loadPersistedFamilySelection()
        syncMonitoringConfigurationToSharedDefaults()
        refreshAccessState()
        scheduleDeviceActivityMonitoring()
        motionModel.start()
        stepTracker.start()
        startTypingAnimation(for: currentScene)

        withAnimation(.spring(response: 0.85, dampingFraction: 0.84).delay(0.06)) {
            hasAppeared = true
        }

        scheduleWalkthroughIfNeeded()
        scheduleFirstFamilyPickerIfNeeded()
    }

    private func handleDisappear() {
        motionModel.stop()
        stepTracker.stop()
        hasAppeared = false

        typingTask?.cancel()
        typingTask = nil

        walkthroughTask?.cancel()
        walkthroughTask = nil
    }

    private func scheduleWalkthroughIfNeeded() {
        guard !hasSeenDashboardWalkthrough else { return }

        walkthroughTask?.cancel()
        walkthroughTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 900_000_000)
            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: 0.25)) {
                walkthroughStepIndex = 0
                isWalkthroughPresented = true
            }
        }
    }

    private func finishWalkthrough() {
        walkthroughTask?.cancel()
        walkthroughTask = nil
        hasSeenDashboardWalkthrough = true

        withAnimation(.easeInOut(duration: 0.2)) {
            isWalkthroughPresented = false
        }
    }

    private func scheduleFirstFamilyPickerIfNeeded() {
        guard !hasPromptedFamilyControlPicker else { return }
        hasPromptedFamilyControlPicker = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            await requestFamilyAuthorizationAndPresentPicker()
        }
    }

    private func editManagedAppsFromSettings() {
        isSettingsPresented = false

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            await requestFamilyAuthorizationAndPresentPicker()
        }
    }

    private func requestFamilyAuthorizationAndPresentPicker() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            isFamilyActivityPickerPresented = true
            scheduleDeviceActivityMonitoring()
        } catch {
            familyControlsErrorMessage = "Unable to open Family Controls picker. Please make sure Family Controls capability is enabled for this target."
        }
    }

    private func loadPersistedFamilySelection() {
        guard !familyActivitySelectionData.isEmpty else { return }
        guard let decoded = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: familyActivitySelectionData) else {
            return
        }

        familyActivitySelection = decoded
    }

    private func persistFamilySelection() {
        guard let encoded = try? PropertyListEncoder().encode(familyActivitySelection) else { return }
        familyActivitySelectionData = encoded
        syncMonitoringConfigurationToSharedDefaults()
    }

    private var currentScene: DashboardScene {
        viewModel.scene(
            dailyScreenLimitMinutes: Int(dailyScreenLimit),
            sessionLimitMinutes: Int(sessionLimit),
            totalPlayedTodayMinutes: managedAppsConsumedMinutesToday,
            activeSessionStartConsumedMinutes: currentSessionStartConsumedMinutes,
            activeSessionLimitMinutes: currentSessionLimitMinutes,
            totalStepsToday: totalStepsTodayStored,
            currentUnlockSteps: currentUnlockStepsForDisplay,
            unlockGoalSteps: Int(stepGoal)
        )
    }

    private func handleLimitsDidChange() {
        normalizeConsumedMinutesIfNeeded()
        refreshAccessState()
        updateHeaderTextWithoutRetyping(for: currentScene)
    }

    private func normalizeConsumedMinutesIfNeeded() {
        var runtimeState = makeRuntimeState()
        viewModel.normalizeConsumedMinutesIfNeeded(
            state: &runtimeState,
            dailyScreenLimitMinutes: Int(dailyScreenLimit)
        )
        applyRuntimeState(runtimeState)
    }

    private func resetDailyStateIfNeeded() {
        var runtimeState = makeRuntimeState()
        var usageDateKey = managedAppsUsageDateKey
        let didReset = viewModel.resetDailyStateIfNeeded(
            state: &runtimeState,
            usageDateKey: &usageDateKey,
            sessionLimitMinutes: Int(sessionLimit)
        )

        guard didReset else { return }
        managedAppsUsageDateKey = usageDateKey
        applyRuntimeState(runtimeState)
        syncMonitoringConfigurationToSharedDefaults()
    }

    private var currentUnlockStepsForDisplay: Int {
        viewModel.currentUnlockStepsForDisplay(state: makeRuntimeState())
    }

    private func refreshAccessState() {
        var runtimeState = makeRuntimeState()
        viewModel.refreshAccessState(
            state: &runtimeState,
            dailyScreenLimitMinutes: Int(dailyScreenLimit),
            sessionLimitMinutes: Int(sessionLimit),
            stepGoal: Int(stepGoal)
        )
        applyRuntimeState(runtimeState)
        applyManagedAppShieldForCurrentMode()
    }

    private func applyManagedAppShieldForCurrentMode() {
        guard viewModel.mode == .appLocked || viewModel.mode == .dailyTimeReached else {
            managedSettingsStore.shield.applications = nil
            managedSettingsStore.shield.applicationCategories = nil
            managedSettingsStore.shield.webDomains = nil
            return
        }

        managedSettingsStore.shield.applications = familyActivitySelection.applicationTokens
        managedSettingsStore.shield.applicationCategories = .specific(familyActivitySelection.categoryTokens)
        managedSettingsStore.shield.webDomains = familyActivitySelection.webDomainTokens
    }

    private func scheduleDeviceActivityMonitoring() {
        let safeDailyLimit = max(1, Int(dailyScreenLimit))
        syncMonitoringConfigurationToSharedDefaults()

        Task { @MainActor in
            do {
                try await ScreenTimeMonitorScheduler.scheduleMonitoring(
                    selection: familyActivitySelection,
                    dailyLimitMinutes: safeDailyLimit
                )
            } catch {
                familyControlsErrorMessage = "Unable to start Screen Time monitoring. Please reopen app permissions and try again."
            }
        }
    }

    private func syncMonitoringConfigurationToSharedDefaults() {
        DashboardView.sharedDefaults?.set(Int(dailyScreenLimit), forKey: DashboardStorageKeys.dailyScreenLimit)
        DashboardView.sharedDefaults?.set(Int(sessionLimit), forKey: DashboardStorageKeys.sessionLimit)
        DashboardView.sharedDefaults?.set(
            max(1, unlockedSessionCountToday),
            forKey: DashboardStorageKeys.unlockedSessionCountToday
        )
    }

    private func makeRuntimeState() -> DashboardRuntimeState {
        DashboardRuntimeState(
            managedAppsConsumedMinutesToday: managedAppsConsumedMinutesToday,
            managedAppsHardLocked: managedAppsHardLocked,
            unlockedSessionCountToday: unlockedSessionCountToday,
            lockStepBaselineToday: lockStepBaselineToday,
            totalStepsTodayStored: totalStepsTodayStored,
            currentSessionIndexToday: currentSessionIndexToday,
            currentSessionStartConsumedMinutes: currentSessionStartConsumedMinutes,
            currentSessionLimitMinutes: currentSessionLimitMinutes
        )
    }

    private func applyRuntimeState(_ state: DashboardRuntimeState) {
        managedAppsConsumedMinutesToday = state.managedAppsConsumedMinutesToday
        managedAppsHardLocked = state.managedAppsHardLocked
        unlockedSessionCountToday = state.unlockedSessionCountToday
        lockStepBaselineToday = state.lockStepBaselineToday
        totalStepsTodayStored = state.totalStepsTodayStored
        currentSessionIndexToday = state.currentSessionIndexToday
        currentSessionStartConsumedMinutes = state.currentSessionStartConsumedMinutes
        currentSessionLimitMinutes = state.currentSessionLimitMinutes
    }
}

#Preview("App Unlocked") {
    DashboardView()
}
