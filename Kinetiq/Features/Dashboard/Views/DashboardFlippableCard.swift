import SwiftUI

struct FlippableCard: View {
    @Binding var isFlipped: Bool
    let front: AnyView
    let back: AnyView
    var isInteractionEnabled: Bool = true

    var body: some View {
        front
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .overlay {
                back
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 0 : -180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
            .contentShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .onTapGesture {
                guard isInteractionEnabled else { return }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                    isFlipped.toggle()
                }
            }
    }
}
