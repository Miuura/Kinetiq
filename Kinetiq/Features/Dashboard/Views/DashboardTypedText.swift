import SwiftUI

struct TypedText: View {
    let displayedText: String
    let font: Font
    var fontWeight: Font.Weight? = nil
    let color: Color
    let lineSpacing: CGFloat
    let topPadding: CGFloat
    var highlightedText: String? = nil
    var highlightedColor: Color? = nil

    var body: some View {
        styledText
            .fontWeight(fontWeight)
            .lineSpacing(lineSpacing)
            .padding(.top, topPadding)
    }

    private var styledText: Text {
        guard
            let highlightedText,
            !highlightedText.isEmpty,
            let highlightedColor,
            let range = displayedText.range(of: highlightedText)
        else {
            return Text(displayedText)
                .font(font)
                .foregroundStyle(color)
        }

        let prefix = String(displayedText[..<range.lowerBound])
        let suffix = String(displayedText[range.upperBound...])

        return Text(
            "\(Text(prefix).font(font).foregroundStyle(color))\(Text(highlightedText).font(font).foregroundStyle(highlightedColor))\(Text(suffix).font(font).foregroundStyle(color))"
        )
    }
}
