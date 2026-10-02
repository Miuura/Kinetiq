import SwiftUI
import CoreMotion
import Observation

@MainActor
@Observable
final class MotionParallaxViewModel {
    var offset: CGSize = .zero
    var rotation: Double = 0

    private let manager = CMMotionManager()
    private var fallbackTask: Task<Void, Never>?

    func start() {
        guard !manager.isDeviceMotionActive else { return }

        fallbackTask?.cancel()
        fallbackTask = nil

        guard manager.isDeviceMotionAvailable else {
            startFallbackMotion()
            return
        }

        manager.deviceMotionUpdateInterval = 1.0 / 60.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }

            let roll = motion.attitude.roll
            let pitch = motion.attitude.pitch

            let maxOffset: CGFloat = 34
            let targetX = (CGFloat(-roll) * maxOffset).clamped(to: -maxOffset...maxOffset)
            let targetY = (CGFloat(pitch) * maxOffset).clamped(to: -maxOffset...maxOffset)
            let targetRotation = Double(targetX / 18).clamped(to: -7...7)

            let positionSmoothing: CGFloat = 0.14
            let rotationSmoothing: Double = 0.14

            self.offset = CGSize(
                width: self.offset.width + (targetX - self.offset.width) * positionSmoothing,
                height: self.offset.height + (targetY - self.offset.height) * positionSmoothing
            )
            self.rotation = self.rotation + (targetRotation - self.rotation) * rotationSmoothing
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        fallbackTask?.cancel()
        fallbackTask = nil
    }

    private func startFallbackMotion() {
        fallbackTask = Task { @MainActor [weak self] in
            guard let self else { return }

            var direction: CGFloat = 1
            while !Task.isCancelled {
                withAnimation(.easeInOut(duration: 2.8)) {
                    self.offset = CGSize(width: 10 * direction, height: -8 * direction)
                    self.rotation = Double(2.2 * direction)
                }

                direction *= -1

                do {
                    try await Task.sleep(nanoseconds: 2_800_000_000)
                } catch {
                    return
                }
            }
        }
    }
}

private extension CGFloat {
    func clamped(to limits: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, limits.lowerBound), limits.upperBound)
    }
}

private extension Double {
    func clamped(to limits: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, limits.lowerBound), limits.upperBound)
    }
}
