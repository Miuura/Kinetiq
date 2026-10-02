import CoreMotion
import Observation

@MainActor
@Observable
final class StepTrackerViewModel {
    var totalStepsToday: Int = 0

    private let pedometer = CMPedometer()

    func start() {
        guard CMPedometer.isStepCountingAvailable() else { return }

        let startOfDay = Calendar.current.startOfDay(for: Date())

        pedometer.queryPedometerData(from: startOfDay, to: Date()) { [weak self] data, _ in
            guard let self else { return }
            let steps = data?.numberOfSteps.intValue ?? 0
            Task { @MainActor in
                self.totalStepsToday = max(0, steps)
            }
        }

        pedometer.startUpdates(from: startOfDay) { [weak self] data, _ in
            guard let self else { return }
            let steps = data?.numberOfSteps.intValue ?? 0
            Task { @MainActor in
                self.totalStepsToday = max(0, steps)
            }
        }
    }

    func stop() {
        pedometer.stopUpdates()
    }
}
