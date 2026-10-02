import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

final class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private static let appGroupSuiteName = "group.AVANGER.Kinetiq"
    private static let activityName = DeviceActivityName("kinetiq-daily-activity")
    private static let eventPrefix = "minute-threshold-"

    private static let selectionDataKey = "FamilyActivitySelectionData"
    private static let consumedMinutesKey = "ManagedAppsConsumedMinutesToday"
    private static let usageDateKey = "ManagedAppsUsageDateKey"
    private static let hardLockedKey = "ManagedAppsHardLocked"

    private static let dailyScreenLimitKey = "DailyScreenLimit"
    private static let sessionLimitKey = "SessionLimit"
    private static let currentSessionStartConsumedMinutesKey = "CurrentSessionStartConsumedMinutes"
    private static let currentSessionLimitMinutesKey = "CurrentSessionLimitMinutes"

    private let sharedDefaults = UserDefaults(suiteName: appGroupSuiteName)
    private let managedSettingsStore = ManagedSettingsStore()

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        guard activity == Self.activityName else { return }
        resetUsageIfDateChanged()
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)

        guard activity == Self.activityName else { return }
        guard let consumedMinutes = consumedMinutes(from: event) else { return }

        resetUsageIfDateChanged()

        let thresholds = currentThresholds()
        let cappedConsumedMinutes = min(consumedMinutes, thresholds.active)

        let currentStoredMinutes = sharedDefaults?.integer(forKey: Self.consumedMinutesKey) ?? 0
        if cappedConsumedMinutes != currentStoredMinutes {
            sharedDefaults?.set(cappedConsumedMinutes, forKey: Self.consumedMinutesKey)
        }

        if consumedMinutes >= thresholds.active {
            sharedDefaults?.set(true, forKey: Self.hardLockedKey)
            applyHardShield()
        }
    }

    private func consumedMinutes(from event: DeviceActivityEvent.Name) -> Int? {
        guard event.rawValue.hasPrefix(Self.eventPrefix) else { return nil }
        let value = event.rawValue.dropFirst(Self.eventPrefix.count)
        return Int(value)
    }

    private func currentThresholds() -> (session: Int, daily: Int, active: Int) {
        let dailyLimit = max(1, sharedDefaults?.integer(forKey: Self.dailyScreenLimitKey) ?? 120)
        let sessionStartConsumedMinutes = max(0, sharedDefaults?.integer(forKey: Self.currentSessionStartConsumedMinutesKey) ?? 0)
        let sessionLimit = max(
            1,
            sharedDefaults?.integer(forKey: Self.currentSessionLimitMinutesKey)
                ?? sharedDefaults?.integer(forKey: Self.sessionLimitKey)
                ?? 30
        )

        let sessionThreshold = sessionStartConsumedMinutes + sessionLimit
        let activeThreshold = min(dailyLimit, sessionThreshold)
        return (session: sessionThreshold, daily: dailyLimit, active: activeThreshold)
    }

    private func applyHardShield() {
        guard
            let data = sharedDefaults?.data(forKey: Self.selectionDataKey),
            let selection = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
        else {
            return
        }

        managedSettingsStore.shield.applications = selection.applicationTokens
        managedSettingsStore.shield.applicationCategories = .specific(selection.categoryTokens)
        managedSettingsStore.shield.webDomains = selection.webDomainTokens
    }

    private func resetUsageIfDateChanged() {
        let today = Self.usageDateFormatter.string(from: Date())
        let savedDate = sharedDefaults?.string(forKey: Self.usageDateKey)

        guard savedDate != today else { return }

        sharedDefaults?.set(today, forKey: Self.usageDateKey)
        sharedDefaults?.set(0, forKey: Self.consumedMinutesKey)
        sharedDefaults?.set(false, forKey: Self.hardLockedKey)
        sharedDefaults?.set(0, forKey: Self.currentSessionStartConsumedMinutesKey)
        sharedDefaults?.set(
            max(1, sharedDefaults?.integer(forKey: Self.sessionLimitKey) ?? 30),
            forKey: Self.currentSessionLimitMinutesKey
        )
    }
}

private extension DeviceActivityMonitorExtension {
    static let usageDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
