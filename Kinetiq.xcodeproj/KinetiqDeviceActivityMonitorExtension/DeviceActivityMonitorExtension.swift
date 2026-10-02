import DeviceActivity
import Foundation

final class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let appGroupSuiteName = "group.AVANGER.Kinetiq"
    private let consumedMinutesKey = "ManagedAppsConsumedMinutesToday"
    private let usageDateKey = "ManagedAppsUsageDateKey"
    private let eventPrefix = "minute-threshold-"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupSuiteName)
    }

    override func intervalDidStart(for activity: DeviceActivityName) {
        guard let sharedDefaults else { return }
        sharedDefaults.set(0, forKey: consumedMinutesKey)
        sharedDefaults.set(todayKey(), forKey: usageDateKey)
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        guard let sharedDefaults else { return }

        let minuteValue = parseMinute(from: event.rawValue)
        guard minuteValue > 0 else { return }

        let current = sharedDefaults.integer(forKey: consumedMinutesKey)
        if minuteValue > current {
            sharedDefaults.set(minuteValue, forKey: consumedMinutesKey)
        }

        sharedDefaults.set(todayKey(), forKey: usageDateKey)
    }

    private func parseMinute(from eventName: String) -> Int {
        guard eventName.hasPrefix(eventPrefix) else { return 0 }
        let suffix = eventName.dropFirst(eventPrefix.count)
        return Int(suffix) ?? 0
    }

    private func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
