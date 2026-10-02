import SwiftUI

// MARK: - Walkthrough
extension DashboardView {
    func makeWalkthroughSteps(in size: CGSize) -> [DashboardWalkthroughStep] {
        let steps = [
            DashboardWalkthroughStep(
                title: "Welcome to Your Dashboard",
                message: "Di sini kamu bisa lihat progress harian dan status target unlock app kamu.",
                focusRect: DashboardWalkthroughTuning.welcomeFocusRect(for: size),
                bubblePosition: .bottom
            ),
            DashboardWalkthroughStep(
                title: "Open Settings Anytime",
                message: "Tap icon gear untuk ubah limits, goal steps, atau switch mode development.",
                focusRect: DashboardWalkthroughTuning.settingsGearFocusRect(for: size),
                bubblePosition: .bottom
            ),
            DashboardWalkthroughStep(
                title: "Track Limits and Session",
                message: "Bagian ini menunjukkan APP Allowance dan Session Progress yang tersisa untuk setiap sesinya.",
                focusRect: DashboardWalkthroughTuning.allowanceFocusRect(for: size),
                bubblePosition: .top
            )
        ]

        return steps.map { step in
            DashboardWalkthroughStep(
                title: step.title,
                message: step.message,
                focusRect: clampedWalkthroughRect(step.focusRect, in: size),
                bubblePosition: step.bubblePosition
            )
        }
    }

    func clampedWalkthroughRect(_ rect: CGRect, in size: CGSize) -> CGRect {
        let maxWidth = max(40, size.width - (DashboardWalkthroughTuning.horizontalInset * 2))
        let maxHeight = max(40, size.height - DashboardWalkthroughTuning.topInset - DashboardWalkthroughTuning.bottomInset)

        let clampedWidth = min(rect.width, maxWidth)
        let clampedHeight = min(rect.height, maxHeight)

        let minX = DashboardWalkthroughTuning.horizontalInset
        let maxX = size.width - DashboardWalkthroughTuning.horizontalInset - clampedWidth
        let minY = DashboardWalkthroughTuning.topInset
        let maxY = size.height - DashboardWalkthroughTuning.bottomInset - clampedHeight

        let x = min(max(rect.minX, minX), maxX)
        let y = min(max(rect.minY, minY), maxY)

        return CGRect(x: x, y: y, width: clampedWidth, height: clampedHeight)
    }
}
