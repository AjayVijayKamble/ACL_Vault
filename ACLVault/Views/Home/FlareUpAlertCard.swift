//
//  FlareUpAlertCard.swift
//  ACLVault
//
//  Prominent Clinical Alert Card Triggered on Joint Effusion / Pain Spike
//

import SwiftUI

public struct FlareUpAlertCard: View {
    let summary: String
    let onStartDeloadWorkout: () -> Void
    
    public init(summary: String, onStartDeloadWorkout: @escaping () -> Void) {
        self.summary = summary
        self.onStartDeloadWorkout = onStartDeloadWorkout
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.clinicalCrimson)
                
                Text("FLARE-UP RECOVERY ACTIVE")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(Color.clinicalCrimson)
                    .tracking(1.5)
                
                Spacer()
                
                Text("DELOAD MODE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.coralAmber)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.coralAmber.opacity(0.15))
                    .clipShape(Capsule())
            }
            
            Text(summary.isEmpty ? "Acute joint effusion or pain threshold exceeded. Today's program is automatically modified to protect your graft and eliminate swelling." : summary)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.vaultTextPrimary)
                .lineSpacing(2)
            
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "snowflake")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.recoveryTeal)
                    Text("Ice/Elevation")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.vaultTextSecondary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.to.line.compact")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.athleticEmerald)
                    Text("0° Heel Props")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.vaultTextSecondary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.coralAmber)
                    Text("VMO Quad Sets")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.vaultTextSecondary)
                }
            }
            .padding(.vertical, 2)
            
            Button(action: onStartDeloadWorkout) {
                HStack {
                    Text("Begin 15-Min Deload Routine")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .buttonStyle(VaultPrimaryButtonStyle(accentColor: .coralAmber, foregroundColor: .black))
        }
        .vaultCard(
            backgroundColor: Color.vaultCardSurface,
            borderColor: Color.clinicalCrimson.opacity(0.4),
            padding: 16
        )
    }
}

