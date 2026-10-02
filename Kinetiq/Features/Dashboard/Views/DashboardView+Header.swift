import SwiftUI

// MARK: - Header
extension DashboardView {
    func topGreetingText(scene: DashboardScene) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    TypedText(
                        displayedText: greetingTypedText,
                        font: .headline,
                        fontWeight: .light,
                        color: AppTheme.secondaryText.opacity(0.88),
                        lineSpacing: 0,
                        topPadding: 10
                    )
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: greetingTypedText)

                    TypedText(
                        displayedText: headlineTypedText,
                        font: .headline,
                        fontWeight: .semibold,
                        color: AppTheme.primaryText,
                        lineSpacing: 1,
                        topPadding: 0,
                        highlightedText: scene.headlineHighlightText,
                        highlightedColor: AppTheme.accent
                    )
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: headlineTypedText)
                }

                Spacer()

                Button {
                    isSettingsPresented = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.primaryText)
                        .opacity(0.8)
                }
                .padding(.trailing, 64)
                .padding(.top, 10)
            }
            .padding(.horizontal, 36)
            .padding(.top, 68)

            Spacer()
        }
        .zIndex(5)
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : -14)
    }

    func startTypingAnimation(for scene: DashboardScene) {
        typingTask?.cancel()
        greetingTypedText = ""
        headlineTypedText = ""

        typingTask = Task { @MainActor in
            for character in scene.greetingText {
                if Task.isCancelled { return }
                greetingTypedText.append(character)
                try? await Task.sleep(nanoseconds: 45_000_000)
            }

            try? await Task.sleep(nanoseconds: 180_000_000)

            for character in scene.headlineText {
                if Task.isCancelled { return }
                headlineTypedText.append(character)
                try? await Task.sleep(nanoseconds: 35_000_000)
            }
        }
    }

    func updateHeaderTextWithoutRetyping(for scene: DashboardScene) {
        typingTask?.cancel()
        typingTask = nil

        withAnimation(.easeInOut(duration: 0.22)) {
            greetingTypedText = scene.greetingText
            headlineTypedText = scene.headlineText
        }
    }
}
