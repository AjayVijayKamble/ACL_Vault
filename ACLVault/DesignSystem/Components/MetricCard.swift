//
//  MetricCard.swift
//  ACLVault
//
//  Clinical Athletic Reusable Metric Card
//

import SwiftUI

public struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let iconName: String
    var accentColor: Color = .recoveryTeal
    var targetGoal: String? = nil
    
    public init(
        title: String,
        value: String,
        subtitle: String,
        iconName: String,
        accentColor: Color = .recoveryTeal,
        targetGoal: String? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.iconName = iconName
        self.accentColor = accentColor
        self.targetGoal = targetGoal
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vaultTextSecondary)
                
                Spacer()
                
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(accentColor)
            }
            
            Text(value)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(Color.vaultTextPrimary)
                .contentTransition(.numericText())
            
            HStack(spacing: 4) {
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.vaultTextMuted)
                
                if let target = targetGoal {
                    Spacer()
                    Text(target)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(accentColor)
                }
            }
        }
        .vaultCard(borderColor: accentColor.opacity(0.2))
    }
}

