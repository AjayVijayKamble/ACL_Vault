//
//  TodayWorkoutCard.swift
//  ACLVault
//
//  Dashboard Card for Today's Prescribed Rehabilitation Routine
//

import SwiftUI

public struct TodayWorkoutCard: View {
    let currentLevel: RehabLevel
    let isFlareUpMode: Bool
    let exercises: [Exercise]
    let onStartWorkout: () -> Void
    
    public init(
        currentLevel: RehabLevel,
        isFlareUpMode: Bool,
        exercises: [Exercise],
        onStartWorkout: @escaping () -> Void
    ) {
        self.currentLevel = currentLevel
        self.isFlareUpMode = isFlareUpMode
        self.exercises = exercises
        self.onStartWorkout = onStartWorkout
    }
    
    private var totalEstMinutes: Int {
        let totalHoldSeconds = exercises.reduce(0) { $0 + ($1.holdSeconds * $1.defaultReps * $1.defaultSets) }
        let repTime = exercises.reduce(0) { $0 + ($1.isIsometric ? 0 : ($1.defaultReps * $1.defaultSets * 3)) }
        let restTime = exercises.count * 3 * 30 // ~30s rest per set
        return max(12, (totalHoldSeconds + repTime + restTime) / 60)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: isFlareUpMode ? "snowflake" : currentLevel.iconSymbol)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(isFlareUpMode ? Color.coralAmber : currentLevel.badgeColor)
                    
                    Text(isFlareUpMode ? "FLARE-UP ROUTINE" : "TODAY'S PRESCRIBED REHAB")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(isFlareUpMode ? Color.coralAmber : currentLevel.badgeColor)
                        .tracking(1.2)
                }
                
                Spacer()
                
                Text("\(totalEstMinutes) min • \(exercises.count) exercises")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.vaultTextMuted)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(isFlareUpMode ? "Effusion Deload & Terminal 0° Hold" : currentLevel.title)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vaultTextPrimary)
                
                Text(isFlareUpMode ? "Gentle non-weight bearing exercises designed to drain synovial effusion while maintaining full passive knee extension." : currentLevel.clinicalFocus)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.vaultTextSecondary)
                    .lineLimit(2)
            }
            
            // Preview Chips of exercises
            VStack(spacing: 8) {
                ForEach(exercises.prefix(3)) { ex in
                    HStack(spacing: 10) {
                        Image(systemName: ex.category.icon)
                            .font(.system(size: 12))
                            .foregroundStyle(ex.category.accentColor)
                            .frame(width: 20)
                        
                        Text(ex.title)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.vaultTextPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(ex.prescriptionSummary)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.vaultTextMuted)
                    }
                    .padding(8)
                    .background(Color.vaultCardElevated.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            Button(action: onStartWorkout) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("Start Guided Workout")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
            }
            .buttonStyle(VaultPrimaryButtonStyle(accentColor: isFlareUpMode ? .coralAmber : .recoveryTeal))
            .padding(.top, 4)
        }
        .vaultCard()
    }
}

