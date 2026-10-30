//
//  GateCheckModalView.swift
//  ACLVault
//
//  Interactive Clinical Milestone Gate Check Modal for Advancing Rehab Levels
//

import SwiftUI
import SwiftData

@MainActor
public struct GateCheckModalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let level: RehabLevel
    let profile: UserProfile
    let onLevelAdvanced: () -> Void
    
    @State private var checkedCriteria: Set<String> = []
    @State private var isShowingCelebration: Bool = false
    @State private var selfReportLagClear: Bool = false
    @State private var therapistAgrees: Bool = true
    
    public init(level: RehabLevel, profile: UserProfile, onLevelAdvanced: @escaping () -> Void) {
        self.level = level
        self.profile = profile
        self.onLevelAdvanced = onLevelAdvanced
    }
    
    private var allCriteriaPassed: Bool {
        return checkedCriteria.count == level.gateCriteria.count && therapistAgrees
    }
    
    public var body: some View {
        ZStack {
            Color.vaultBackground.ignoresSafeArea()
            
            if isShowingCelebration {
                celebrationView
            } else {
                VStack(spacing: 0) {
                    // Modal Header
                    modalHeader
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Phase Summary Card
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("GATE ASSESSMENT")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.recoveryTeal)
                                        .tracking(1.5)
                                    Spacer()
                                    Text(level.timeline)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.vaultTextMuted)
                                }
                                
                                Text("Unlock Level \(level.level + 1)")
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.vaultTextPrimary)
                                
                                Text("In ACL rehabilitation, advancing prematurely before biological graft integration or dynamic stability is achieved increases secondary re-tear risk. Verify all criteria below.")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.vaultTextSecondary)
                                    .lineSpacing(2)
                            }
                            .vaultCard()
                            
                            // Clinical Gate Checklist
                            VStack(alignment: .leading, spacing: 12) {
                                Text("CRITERION-BASED MILESTONES")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextMuted)
                                    .tracking(1.2)
                                
                                VStack(spacing: 10) {
                                    ForEach(level.gateCriteria, id: \.self) { criterion in
                                        let isChecked = checkedCriteria.contains(criterion)
                                        
                                        Button {
                                            toggleCriterion(criterion)
                                        } label: {
                                            HStack(alignment: .top, spacing: 12) {
                                                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundStyle(isChecked ? Color.athleticEmerald : Color.vaultBorder)
                                                    .padding(.top, 2)
                                                
                                                Text(criterion)
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundStyle(isChecked ? Color.vaultTextPrimary : Color.vaultTextSecondary)
                                                    .multilineTextAlignment(.leading)
                                                    .lineSpacing(2)
                                                
                                                Spacer()
                                            }
                                            .padding(14)
                                            .background(isChecked ? Color.athleticEmerald.opacity(0.12) : Color.vaultCardSurface)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(isChecked ? Color.athleticEmerald : Color.vaultBorder, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                            
                            // PT Concurrence Confirmation
                            Toggle(isOn: $therapistAgrees) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Clinician / PT Concurrence")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.vaultTextPrimary)
                                    Text("I confirm my physical therapist or surgeon has evaluated these milestones.")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.vaultTextSecondary)
                                }
                            }
                            .tint(Color.athleticEmerald)
                            .padding(14)
                            .vaultCard()
                            
                            // Advance Level Button
                            Button {
                                advanceLevel()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.seal.fill")
                                    Text("Pass Gate Check & Unlock Level \(level.level + 1)")
                                }
                            }
                            .buttonStyle(VaultPrimaryButtonStyle(accentColor: allCriteriaPassed ? .athleticEmerald : Color.vaultCardElevated, foregroundColor: allCriteriaPassed ? .black : Color.vaultTextMuted))
                            .disabled(!allCriteriaPassed)
                            .padding(.top, 8)
                            .padding(.bottom, 24)
                        }
                        .padding(20)
                    }
                }
            }
        }
    }
    
    // MARK: - Modal Header
    private var modalHeader: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.vaultTextSecondary)
                    .padding(8)
                    .background(Color.vaultCardElevated)
                    .clipShape(Circle())
            }
            Spacer()
            Text("LEVEL GATE CHECK")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color.vaultTextMuted)
                .tracking(1.5)
            Spacer()
            // Placeholder for symmetry
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Celebration View
    private var celebrationView: some View {
        ZStack {
            ConfettiView()
            
            VStack(spacing: 24) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.athleticEmerald.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(Color.athleticEmerald)
                        .vaultGlow(color: .athleticEmerald, radius: 14)
                }
                
                VStack(spacing: 8) {
                    Text("Phase Unlocked!")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(Color.vaultTextPrimary)
                    
                    Text("You have officially advanced to:")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.vaultTextSecondary)
                    
                    Text("Level \(profile.currentLevel): \(ProtocolLevels.level(for: profile.currentLevel).title)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.recoveryTeal)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                Button {
                    onLevelAdvanced()
                    dismiss()
                } label: {
                    Text("Begin New Phase Protocol")
                }
                .buttonStyle(VaultPrimaryButtonStyle(accentColor: .athleticEmerald))
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func toggleCriterion(_ criterion: String) {
        if checkedCriteria.contains(criterion) {
            checkedCriteria.remove(criterion)
        } else {
            checkedCriteria.insert(criterion)
            HapticManager.countdownTick()
        }
    }
    
    private func advanceLevel() {
        guard allCriteriaPassed else { return }
        profile.currentLevel = min(10, profile.currentLevel + 1)
        try? modelContext.save()
        
        HapticManager.gateUnlocked()
        AudioCueManager.playWorkoutComplete()
        
        withAnimation {
            isShowingCelebration = true
        }
    }
}

