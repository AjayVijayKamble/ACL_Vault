//
//  LevelDetailSheet.swift
//  ACLVault
//
//  Comprehensive Clinical Deep-Dive Sheet for Any Rehab Level
//

import SwiftUI

public struct LevelDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let level: RehabLevel
    let profile: UserProfile
    let onOpenGateCheck: () -> Void
    
    public init(level: RehabLevel, profile: UserProfile, onOpenGateCheck: @escaping () -> Void) {
        self.level = level
        self.profile = profile
        self.onOpenGateCheck = onOpenGateCheck
    }
    
    private var isCurrentLevel: Bool {
        level.level == profile.currentLevel
    }
    
    private var isCompleted: Bool {
        level.level < profile.currentLevel
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vaultBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: level.iconSymbol)
                                    Text("LEVEL \(level.level)")
                                }
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(level.badgeColor)
                                .tracking(1.5)
                                
                                Spacer()
                                
                                Text(level.timeline)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextMuted)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.vaultCardElevated)
                                    .clipShape(Capsule())
                            }
                            
                            Text(level.title)
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundStyle(Color.vaultTextPrimary)
                            
                            Text(level.subtitle)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.recoveryTeal)
                        }
                        
                        // Clinical Focus Card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "stethoscope")
                                    .foregroundStyle(Color.recoveryTeal)
                                Text("CLINICAL OBJECTIVE")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.recoveryTeal)
                            }
                            
                            Text(level.clinicalFocus)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.vaultTextPrimary)
                                .lineSpacing(3)
                        }
                        .vaultCard()
                        
                        // Objective ROM Targets
                        HStack(spacing: 12) {
                            TargetPillBox(
                                title: "FLEXION TARGET",
                                value: "\(Int(level.minFlexionTarget))°",
                                accentColor: .recoveryTeal
                            )
                            TargetPillBox(
                                title: "EXTENSION GOAL",
                                value: "\(Int(level.minExtensionTarget))°",
                                accentColor: .athleticEmerald
                            )
                            TargetPillBox(
                                title: "MAX SWELLING",
                                value: level.maxAllowedSwelling.rawValue.components(separatedBy: " ").first ?? "None",
                                accentColor: level.maxAllowedSwelling.badgeColor
                            )
                        }
                        
                        // Gate Check Criteria
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ADVANCEMENT CRITERIA")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextMuted)
                                .tracking(1.2)
                            
                            VStack(spacing: 8) {
                                ForEach(level.gateCriteria, id: \.self) { crit in
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(isCompleted ? Color.athleticEmerald : Color.recoveryTeal)
                                            .padding(.top, 2)
                                        
                                        Text(crit)
                                            .font(.system(size: 13))
                                            .foregroundStyle(Color.vaultTextPrimary)
                                            .lineSpacing(2)
                                        
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.vaultCardSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.vaultBorder, lineWidth: 1))
                                }
                            }
                        }
                        
                        // Primary Exercises
                        VStack(alignment: .leading, spacing: 10) {
                            Text("KEY MOVEMENTS")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextMuted)
                                .tracking(1.2)
                            
                            ForEach(level.primaryExercisesSummary, id: \.self) { exName in
                                HStack {
                                    Image(systemName: "dumbbell.fill")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.recoveryTeal)
                                    Text(exName)
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.vaultTextPrimary)
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color.vaultCardSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        
                        // Gate Test Button (if current level)
                        if isCurrentLevel {
                            Button {
                                dismiss()
                                onOpenGateCheck()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.seal.fill")
                                    Text("Take Level \(level.level) Gate Test")
                                }
                            }
                            .buttonStyle(VaultPrimaryButtonStyle(accentColor: .athleticEmerald))
                            .padding(.top, 8)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Level \(level.level) Overview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.recoveryTeal)
                }
            }
        }
    }
}

private struct TargetPillBox: View {
    let title: String
    let value: String
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color.vaultTextMuted)
                .lineLimit(1)
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(accentColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(Color.vaultCardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.vaultBorder, lineWidth: 1))
    }
}

