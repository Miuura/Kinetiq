import SwiftUI

// MARK: - Layers
extension DashboardView {
    func dashboardBackground(scene: DashboardScene) -> some View {
        ZStack {
            AppTheme.background

            RadialGradient(
                colors: [
                    Color(hex: scene.glowHex).opacity(0.3),
                    Color(hex: scene.glowHex).opacity(0.12),
                    .clear
                ],
                center: glowCenter(for: scene),
                startRadius: 60,
                endRadius: 450
            )
            .blur(radius: 14)
        }
        .ignoresSafeArea()
    }

    func allowanceLayer(scene: DashboardScene, canvasHeight: CGFloat) -> some View {
        let isAllowanceInteractive =
            scene.allowanceEmphasis == .active &&
            (!isSessionCardFlipped || isAllowanceCardFlipped)

        return VStack {
            Spacer()
            HStack {
                FlippableCard(
                    isFlipped: $isAllowanceCardFlipped,
                    front: AnyView(allowanceCard(scene: scene)),
                    back: AnyView(
                        insightBackCard(
                            insight: scene.insight,
                            horizontalPadding: 24,
                            verticalPadding: 21,
                            cornerRadius: 30,
                            strokeCornerRadius: 30
                        )
                    ),
                    isInteractionEnabled: isAllowanceInteractive
                )
                    .padding(.leading, 36)
                Spacer()
            }
            .padding(.bottom, max(canvasHeight * 0.17, 124))
        }
        .zIndex((viewModel.mode != .appLocked && viewModel.mode != .dailyTimeReached) ? 10 : 0)
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 30)
    }

    func rockLayers(_ rocks: [DashboardRockLayer], canvasSize: CGSize) -> some View {
        ForEach(rocks) { rock in
            rockImage(
                rock,
                canvasWidth: canvasSize.width,
                canvasHeight: canvasSize.height
            )
            .zIndex(rock.zIndex)
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 36)
            .scaleEffect(hasAppeared ? 1 : 1.06)
        }
    }

    func sessionLayer(scene: DashboardScene, canvasSize: CGSize) -> some View {
        let sessionZIndex: Double = {
            if viewModel.mode == .appLocked { return 10 }
            if scene.dailySummarySteps != nil { return 6 }
            return 0
        }()
        let dailySummaryYOffset: CGFloat = scene.dailySummarySteps != nil ? 120 : 0

        let currentCard: AnyView = {
            if scene.dailySummarySteps != nil {
                return AnyView(dailySummaryCard(scene: scene))
            }
            return AnyView(sessionCard(scene: scene))
        }()
        let flippableCard = FlippableCard(
            isFlipped: $isSessionCardFlipped,
            front: currentCard,
            back: AnyView(
                insightBackCard(
                    insight: scene.insight,
                    horizontalPadding: 30,
                    verticalPadding: 18,
                    cornerRadius: 30,
                    strokeCornerRadius: 35
                )
            ),
            isInteractionEnabled:
                scene.sessionEmphasis == .active &&
                (!isAllowanceCardFlipped || isSessionCardFlipped)
        )

        return flippableCard
            .offset(
                x: canvasSize.width * 0.17 + motionModel.offset.width * 0.35 - 30,
                y: -canvasSize.height * 0.09 + motionModel.offset.height * 0.35 + dailySummaryYOffset
            )
            .rotationEffect(.degrees(motionModel.rotation * 0.35))
            .zIndex(sessionZIndex)
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 24)
    }

    func glowCenter(for scene: DashboardScene) -> UnitPoint {
        if scene.sessionEmphasis == .active {
            return UnitPoint(x: 0.67, y: 0.41)
        }

        if scene.allowanceEmphasis == .active {
            return UnitPoint(x: 0.25, y: 0.80)
        }

        return .center
    }
}
