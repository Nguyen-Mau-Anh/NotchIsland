//
//  CustomWidgetView.swift
//  NotchIsland
//
//  Customizable widget area for future expansion
//

import SwiftUI

struct CustomWidgetView: View {
    @State private var customWidgets: [CustomWidget] = []
    @Environment(\.notchTheme) private var theme

    var body: some View {
        VStack(spacing: 12) {
            if customWidgets.isEmpty {
                // Placeholder for custom widgets
                VStack(spacing: 8) {
                    Image(systemName: "square.grid.3x3")
                        .font(.system(size: 32))
                        .foregroundColor(theme.tertiaryText)

                    Text("Customize Your Widgets")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(theme.secondaryText)

                    Text("Add custom widgets in Settings")
                        .font(.system(size: 11))
                        .foregroundColor(theme.tertiaryText)
                }
            } else {
                // Display custom widgets
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(customWidgets) { widget in
                            CustomWidgetCard(widget: widget)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CustomWidget: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let content: String
}

struct CustomWidgetCard: View {
    let widget: CustomWidget
    @Environment(\.notchTheme) private var theme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: widget.icon)
                .font(.system(size: 20))
                .foregroundColor(theme.primaryText)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(theme.selectedTabBackground)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(widget.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.primaryText)

                Text(widget.content)
                    .font(.system(size: 11))
                    .foregroundColor(theme.secondaryText)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(theme.cardBackground)
        )
    }
}

#Preview {
    CustomWidgetView()
        .environment(\.notchTheme, .dark)
        .frame(width: 400, height: 150)
        .background(Color.black.opacity(0.5))
}
