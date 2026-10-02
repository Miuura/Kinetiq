import SwiftUI

struct DashboardSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var dailyScreenLimit: Double
    @Binding var sessionLimit: Double
    @Binding var stepGoal: Double
    let onEditManagedApps: () -> Void

    private let cardBackground = Color.white.opacity(0.08)

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .fontWeight(.bold)
                            Text("Swipe down to close")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(AppTheme.secondaryText)
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                    .padding(.bottom, 20)

                VStack(spacing: 20) {
                    SettingSliderCard(
                        warna: "DAE1FF",
                        icon: "clock",
                        warnaIcon: "0050CB",
                        title: "Daily Screen Limit",
                        value: $dailyScreenLimit,
                        range: 60...240,
                        step: 15,
                        unit: "min",
                        backgroundColor: cardBackground,
                        description: "Batas total main per hari."
                    )

                    SettingSliderCard(
                        warna: "FFDBD0",
                        icon: "hourglass",
                        warnaIcon: "A33200",
                        title: "Session Limit",
                        value: $sessionLimit,
                        range: 5...60,
                        step: 5,
                        unit: "min",
                        backgroundColor: cardBackground,
                        description: "Durasi per sesi sebelum lock."
                    )

                    SettingSliderCard(
                        warna: "DAE1FF",
                        icon: "figure.run",
                        warnaIcon: "425CA0",
                        title: "Unlock Your Goal",
                        value: $stepGoal,
                        range: 100...3000,
                        step: 100,
                        unit: "steps",
                        backgroundColor: cardBackground,
                        description: "Step untuk unlock sesi."
                    )

                    Button(action: onEditManagedApps) {
                        HStack(spacing: 12) {
                            Image(systemName: "lock.app.dashed")
                                .font(.headline)
                            Text("Edit Managed Apps")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(AppTheme.primaryText)
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "2C3A59").opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .presentationDetents([.fraction(0.78)])
        .presentationDragIndicator(.visible)
    }
}
