import CoreGraphics
import Foundation

enum DashboardStorageKeys {
    static let dailyScreenLimit = "DailyScreenLimit"
    static let sessionLimit = "SessionLimit"
    static let unlockedSessionCountToday = "UnlockedSessionCountToday"
}

enum DashboardDate {
    static let usageDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

enum DashboardWalkthroughTuning {
    static let horizontalInset: CGFloat = 12
    static let topInset: CGFloat = 56
    static let bottomInset: CGFloat = 36

    static let bubbleHorizontalOffset: CGFloat = -30
    static let bubbleVerticalOffsetBottom: CGFloat = 0
    static let bubbleVerticalOffsetTop: CGFloat = 0

    static func welcomeFocusRect(for size: CGSize) -> CGRect {
        CGRect(x: 28, y: 68, width: size.width * 0.58, height: 120)
    }

    static func settingsGearFocusRect(for size: CGSize) -> CGRect {
        CGRect(x: 335, y: 74, width: 44, height: 44)
    }

    static func allowanceFocusRect(for size: CGSize) -> CGRect {
        CGRect(x: 40, y: size.height * 0.70, width: 198, height: 210)
    }
}
