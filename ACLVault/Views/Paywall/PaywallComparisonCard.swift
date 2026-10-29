//
//  PaywallComparisonCard.swift
//  ACLVault
//
//  Free vs Pro Feature Matrix Comparison Component
//

import SwiftUI

public struct PaywallComparisonCard: View {
    public init() {}
    
    private let comparisonRows: [(feature: String, free: String, pro: String)] = [
        ("Post-Op Day & Week Counter", "checkmark", "checkmark"),
        ("Manual ROM Degree Input", "checkmark", "checkmark"),
        ("Level 1 Foundation Exercises", "checkmark", "checkmark"),
        ("AI Camera Pose Goniometer (Vision)", "xmark", "checkmark"),
        ("Gyroscope Shin-Tap Calibration", "xmark", "checkmark"),
        ("All 10 Progression Phases (Return-to-Sport)", "xmark", "checkmark"),
        ("Daily AI Physio Co-Pilot & Deload Logic", "xmark", "checkmark"),
        ("1-Click PDF Surgeon & PT Clinical Reports", "xmark", "checkmark")
    ]
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("FEATURE COMPARISON")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vaultTextMuted)
                Spacer()
                Text("FREE")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vaultTextMuted)
                    .frame(width: 50)
                Text("PRO")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(Color.coralAmber)
                    .frame(width: 50)
            }
            .padding(.horizontal, 4)
            
            Divider().background(Color.vaultBorder)
            
            // Feature Rows
            VStack(spacing: 8) {
                ForEach(comparisonRows, id: \.feature) { row in
                    HStack {
                        Text(row.feature)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.vaultTextPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: row.free == "checkmark" ? "checkmark" : "minus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(row.free == "checkmark" ? Color.vaultTextMuted : Color.vaultTextMuted.opacity(0.4))
                            .frame(width: 50)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.athleticEmerald)
                            .frame(width: 50)
                    }
                    .padding(.vertical, 3)
                }
            }
        }
        .vaultCard()
    }
}

