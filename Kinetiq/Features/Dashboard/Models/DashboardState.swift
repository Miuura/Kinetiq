//
//  DashboardState.swift
//  Kinetiq
//
//  Created by Valentino Hartanto on 19/04/26.
//

import Foundation
import CoreGraphics

struct SessionProgress {
    let current: Int
    let goal: Int
}

struct DashboardInsight {
    let title: String
    let line1: String
    let line2: String?
    let footer: String
    let strokeHex: String
}

enum DashboardCardEmphasis {
    case active
    case muted
}

struct DashboardScene {
    let greetingText: String
    let headlineText: String
    let headlineHighlightText: String?
    let insight: DashboardInsight
    let dailySummarySteps: Int?
    let session: SessionProgress
    let appAllowanceMinutes: Int
    let sessionEmphasis: DashboardCardEmphasis
    let allowanceEmphasis: DashboardCardEmphasis
    let glowHex: String
}

struct DashboardRockMask {
    let widthRatio: CGFloat
    let heightRatio: CGFloat
    let centerXRatio: CGFloat
    let centerYRatio: CGFloat
}

struct DashboardRockLayer: Identifiable {
    let id: String
    let assetName: String
    let widthRatio: CGFloat
    let baseXRatio: CGFloat
    let baseYRatio: CGFloat
    let parallaxMultiplier: CGFloat
    let zIndex: Double
    let mask: DashboardRockMask?
}

enum DashboardMode: String, CaseIterable, Identifiable {
    case goalReached
    case dailyTimeReached
    case appLocked

    var id: String { rawValue }
}
