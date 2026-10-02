import Foundation
import DeviceActivity
import FamilyControls

@MainActor
enum ScreenTimeMonitorScheduler {
    static let activityName = DeviceActivityName("kinetiq-daily-activity")
    static let eventPrefix = "minute-threshold-"

    static func scheduleMonitoring(
        selection: FamilyActivitySelection,
        dailyLimitMinutes: Int
    ) async throws {
        let center = DeviceActivityCenter()
        center.stopMonitoring([activityName])

        let hasSelection =
            !selection.applicationTokens.isEmpty ||
            !selection.categoryTokens.isEmpty ||
            !selection.webDomainTokens.isEmpty

        guard hasSelection else {
            return
        }

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        let cappedLimit = min(max(1, dailyLimitMinutes), 1_440)
        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]

        for minute in 1...cappedLimit {
            let eventName = DeviceActivityEvent.Name(eventPrefix + String(minute))
            events[eventName] = DeviceActivityEvent(
                applications: selection.applicationTokens,
                categories: selection.categoryTokens,
                webDomains: selection.webDomainTokens,
                threshold: DateComponents(minute: minute)
            )
        }

        try center.startMonitoring(activityName, during: schedule, events: events)
    }
}
