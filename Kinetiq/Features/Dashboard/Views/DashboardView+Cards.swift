import SwiftUI

extension DashboardView {
    func insightBackCard(
        insight: DashboardInsight,
        horizontalPadding: CGFloat,
        verticalPadding: CGFloat,
        cornerRadius: CGFloat,
        strokeCornerRadius: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(insight.title)
                .font(.system(size: 21, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)

            Text(insight.line1)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)

            if let line2 = insight.line2 {
                Text(line2)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Text(insight.footer)
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(hex: "1F1F1F").opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: strokeCornerRadius, style: .continuous)
                        .stroke(Color(hex: insight.strokeHex).opacity(0.5), lineWidth: 1)
                )
        )
    }

    func rockImage(
        _ rock: DashboardRockLayer,
        canvasWidth: CGFloat,
        canvasHeight: CGFloat
    ) -> some View {
        Image(rock.assetName)
            .resizable()
            .scaledToFit()
            .frame(width: canvasWidth * rock.widthRatio)
            .mask(alignment: .center) {
                if let mask = rock.mask {
                    GeometryReader { proxy in
                        Rectangle()
                            .frame(
                                width: proxy.size.width * mask.widthRatio,
                                height: proxy.size.height * mask.heightRatio
                            )
                            .position(
                                x: proxy.size.width * (0.5 + mask.centerXRatio),
                                y: proxy.size.height * (0.5 + mask.centerYRatio)
                            )
                    }
                } else {
                    Rectangle()
                }
            }
            .offset(
                x: canvasWidth * rock.baseXRatio + motionModel.offset.width * rock.parallaxMultiplier,
                y: canvasHeight * rock.baseYRatio + motionModel.offset.height * rock.parallaxMultiplier
            )
            .rotationEffect(.degrees(motionModel.rotation * rock.parallaxMultiplier))
            .shadow(color: .black.opacity(0.34), radius: 24, x: 0, y: 10)
            .allowsHitTesting(false)
    }

    func allowanceCard(scene: DashboardScene) -> some View {
        let isActive = scene.allowanceEmphasis == .active

        return VStack(alignment: .leading, spacing: 7) {
            Text("Active\nSession")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText.opacity(isActive ? 1.0 : 0))
                .multilineTextAlignment(.trailing)
                .padding(.leading, 60)

            Text("\(scene.appAllowanceMinutes)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AppTheme.accent.opacity(isActive ? 1.0 : 0))
                .contentTransition(.numericText(value: Double(scene.appAllowanceMinutes)))
                .animation(.spring(response: 0.25, dampingFraction: 0.86), value: scene.appAllowanceMinutes)

            Text("Minutes Remaining")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(AppTheme.secondaryText.opacity(isActive ? 1.0 : 0))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 21)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(hex: "1F1F1F").opacity(isActive ? 0.95 : 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color(hex: "#7FAFFF").opacity(isActive ? 0.5 : 0), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 12)
    }

    func sessionCard(scene: DashboardScene) -> some View {
        let isActive = scene.sessionEmphasis == .active

        return VStack(alignment: .leading, spacing: 7) {
            Text("Next\nSession")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText.opacity(isActive ? 1.0 : 0))
                .multilineTextAlignment(.trailing)
                .padding(.leading, 55)

            Text("\(scene.session.current)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Color(hex: "#FF7FAC").opacity(isActive ? 1 : 0))
                .contentTransition(.numericText(value: Double(scene.session.current)))
                .animation(.spring(response: 0.25, dampingFraction: 0.86), value: scene.session.current)

            Text("of \(scene.session.goal) steps")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(AppTheme.secondaryText.opacity(isActive ? 1.0 : 0))
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(hex: "1F1F1F").opacity(isActive ? 0.95 : 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 35, style: .continuous)
                        .stroke(Color(hex: "#FF7FAC").opacity(isActive ? 0.50 : 0), lineWidth: 1)
                )
        )
    }

    func dailySummaryCard(scene: DashboardScene) -> some View {
        let isActive = scene.sessionEmphasis == .active
        let totalSteps = scene.dailySummarySteps ?? 0

        return VStack(alignment: .leading, spacing: 7) {
            Text("Daily\nSummary")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.primaryText.opacity(isActive ? 1.0 : 0))
                .multilineTextAlignment(.trailing)
                .padding(.leading, 48)

            Text("\(totalSteps.formatted())")
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Color(hex: "#FFFFFF").opacity(isActive ? 1 : 0))
                .contentTransition(.numericText(value: Double(totalSteps)))
                .animation(.spring(response: 0.25, dampingFraction: 0.86), value: totalSteps)
                .padding(.top, 20)

            Text("Total steps today")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(AppTheme.secondaryText.opacity(isActive ? 1.0 : 0))
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(hex: "1F1F1F").opacity(isActive ? 0.95 : 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 35, style: .continuous)
                        .stroke(Color(hex: "#FFFFFF").opacity(isActive ? 0.50 : 0), lineWidth: 1)
                )
        )
    }
}
