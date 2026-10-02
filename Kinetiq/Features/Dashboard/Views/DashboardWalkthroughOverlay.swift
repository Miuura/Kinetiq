import SwiftUI

struct DashboardWalkthroughStep {
    let title: String
    let message: String
    let focusRect: CGRect
    let bubblePosition: DashboardWalkthroughBubblePosition
}

enum DashboardWalkthroughBubblePosition: Equatable {
    case top
    case bottom
}

struct DashboardWalkthroughOverlay: View {
    let step: DashboardWalkthroughStep
    let stepIndex: Int
    let totalSteps: Int
    let onNext: () -> Void
    let onSkip: () -> Void

    private let bubbleHorizontalOffset: CGFloat = -30
    private let bubbleVerticalOffsetBottom: CGFloat = 0
    private let bubbleVerticalOffsetTop: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let bubbleWidth = min(proxy.size.width - 32, 360)
            let bubbleHalf = bubbleWidth / 2
            let bubbleX = (proxy.size.width / 2 + bubbleHorizontalOffset)
                .clampedOverlay(to: (bubbleHalf + 16)...(proxy.size.width - bubbleHalf - 16))
            let bubbleY: CGFloat = {
                if step.bubblePosition == .bottom {
                    return (step.focusRect.maxY + 120 + bubbleVerticalOffsetBottom)
                        .clampedOverlay(to: 140...(proxy.size.height - 140))
                }

                return (step.focusRect.minY - 110 + bubbleVerticalOffsetTop)
                    .clampedOverlay(to: 140...(proxy.size.height - 140))
            }()

            ZStack {
                Path { path in
                    path.addRect(CGRect(origin: .zero, size: proxy.size))
                    path.addRoundedRect(
                        in: step.focusRect.insetBy(dx: -6, dy: -6),
                        cornerSize: CGSize(width: 24, height: 24)
                    )
                }
                .fill(.black.opacity(0.72), style: FillStyle(eoFill: true))

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.92), lineWidth: 1.4)
                    .frame(width: step.focusRect.width + 12, height: step.focusRect.height + 12)
                    .position(x: step.focusRect.midX, y: step.focusRect.midY)

                VStack(alignment: .leading, spacing: 12) {
                    Text(step.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.primaryText)

                    Text(step.message)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineSpacing(2)

                    HStack(spacing: 6) {
                        ForEach(0..<totalSteps, id: \.self) { index in
                            Capsule()
                                .fill(index == stepIndex ? AppTheme.primaryText : AppTheme.secondaryText.opacity(0.35))
                                .frame(width: index == stepIndex ? 18 : 8, height: 8)
                        }
                    }

                    HStack {
                        Button("Skip") {
                            onSkip()
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.secondaryText)

                        Spacer()

                        Button(stepIndex == totalSteps - 1 ? "Done" : "Next") {
                            onNext()
                        }
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.primaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Capsule())
                    }
                }
                .padding(16)
                .frame(width: bubbleWidth, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(hex: "1A1A1A").opacity(0.94))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
                .position(x: bubbleX, y: bubbleY)
            }
        }
        .contentShape(Rectangle())
    }
}

private extension CGFloat {
    func clampedOverlay(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
