//
//  PostOpBadgeView.swift
//  ACLVault
//
//  Top Navigation Bar Post-Op Day & Week Clinical Counter
//

import SwiftUI

public struct PostOpBadgeView: View {
    let daysPostOp: Int
    let weeksPostOp: Int
    var injuredSide: LegSide = .right
    var stage: RehabType = .postOp
    
    public init(
        daysPostOp: Int,
        weeksPostOp: Int,
        injuredSide: LegSide = .right,
        stage: RehabType = .postOp
    ) {
        self.daysPostOp = daysPostOp
        self.weeksPostOp = weeksPostOp
        self.injuredSide = injuredSide
        self.stage = stage
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            // Pulse indicator
            Circle()
                .fill(Color.recoveryTeal)
                .frame(width: 8, height: 8)
                .vaultGlow(color: .recoveryTeal, radius: 4)
            
            Text(badgeTitle)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.vaultTextPrimary)
            
            Text("•")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.vaultTextMuted)
            
            Text(injuredSide.shortCode + " Knee")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.recoveryTeal)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.vaultCardElevated)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.vaultBorder, lineWidth: 1)
        )
    }
    
    private var badgeTitle: String {
        switch stage {
        case .prehab:
            return "Pre-Op Prep"
        case .postOp:
            return "Day \(daysPostOp) • Wk \(weeksPostOp)"
        case .nonSurgical:
            return "Wk \(weeksPostOp) Non-Surgical"
        }
    }
}

