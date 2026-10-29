//
//  DailyCheckInSheet.swift
//  ACLVault
//
//  Morning Readiness Check-In Modal & AI Decision Trigger
//

import SwiftUI
import SwiftData

public struct DailyCheckInSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let profile: UserProfile
    let onCheckInSaved: (DailyCheckIn) -> Void
    
    @State private var painScore: Double = 2.0
    @State private var swellingLevel: SwellingLevel = .mild
    @State private var painLocation: PainLocation = .anterior
    @State private var isEvaluating: Bool = false
    
    public init(profile: UserProfile, onCheckInSaved: @escaping (DailyCheckIn) -> Void) {
        self.profile = profile
        self.onCheckInSaved = onCheckInSaved
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vaultBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        // Header Guidance
                        VStack(alignment: .leading, spacing: 6) {
                            Text("MORNING READINESS")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.recoveryTeal)
                                .tracking(1.5)
                            
                            Text("Check Your Knee State")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextPrimary)
                            
                            Text("Your AI Physio adjusts today's loading volume and flags inflammatory flares based on these clinical markers.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.vaultTextSecondary)
                        }
                        
                        // 1. Pain Score Slider (0 to 10)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("SUBJECTIVE JOINT PAIN")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextMuted)
                                Spacer()
                                Text("\(Int(painScore)) / 10")
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .foregroundStyle(painScoreColor)
                            }
                            
                            Slider(value: $painScore, in: 0...10, step: 1)
                                .tint(painScoreColor)
                                .onChange(of: painScore) { _, _ in
                                    HapticManager.countdownTick()
                                }
                            
                            HStack {
                                Text("0: Pain Free")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.vaultTextMuted)
                                Spacer()
                                Text("5: Moderate")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.vaultTextMuted)
                                Spacer()
                                Text("10: Severe Disabling")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.vaultTextMuted)
                            }
                        }
                        .vaultCard(borderColor: painScore >= 6 ? Color.clinicalCrimson.opacity(0.4) : Color.vaultBorder)
                        
                        // 2. Swelling / Effusion Sweep Level
                        VStack(alignment: .leading, spacing: 12) {
                            Text("JOINT EFFUSION (SWELLING)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextMuted)
                            
                            VStack(spacing: 8) {
                                ForEach(SwellingLevel.allCases) { level in
                                    Button {
                                        swellingLevel = level
                                        HapticManager.buttonTap()
                                    } label: {
                                        HStack {
                                            Circle()
                                                .fill(level.badgeColor)
                                                .frame(width: 10, height: 10)
                                            
                                            Text(level.rawValue)
                                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                .foregroundStyle(Color.vaultTextPrimary)
                                            
                                            Spacer()
                                            
                                            if swellingLevel == level {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundStyle(Color.recoveryTeal)
                                            }
                                        }
                                        .padding(12)
                                        .background(swellingLevel == level ? Color.vaultCardElevated : Color.vaultCardSurface)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(swellingLevel == level ? Color.recoveryTeal : Color.vaultBorder.opacity(0.5), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .vaultCard()
                        
                        // 3. Primary Pain Location
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PRIMARY SENSATION LOCATION")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextMuted)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(PainLocation.allCases) { loc in
                                    Button {
                                        painLocation = loc
                                        HapticManager.buttonTap()
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: loc.icon)
                                                .font(.system(size: 13))
                                                .foregroundStyle(painLocation == loc ? Color.recoveryTeal : Color.vaultTextMuted)
                                            
                                            Text(loc.rawValue.components(separatedBy: " ").first ?? "")
                                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                .foregroundStyle(Color.vaultTextPrimary)
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 6)
                                        .background(painLocation == loc ? Color.recoveryTeal.opacity(0.12) : Color.vaultCardSurface)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(painLocation == loc ? Color.recoveryTeal : Color.vaultBorder.opacity(0.6), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .vaultCard()
                        
                        // Submit Assessment Button
                        Button {
                            submitCheckIn()
                        } label: {
                            if isEvaluating {
                                HStack(spacing: 8) {
                                    ProgressView().tint(.black)
                                    Text("Analyzing Clinical State...")
                                }
                            } else {
                                Text("Complete Morning Readiness")
                            }
                        }
                        .buttonStyle(VaultPrimaryButtonStyle(accentColor: painScore >= 6 ? .coralAmber : .recoveryTeal))
                        .disabled(isEvaluating)
                        .padding(.top, 8)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Daily Readiness")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.vaultTextSecondary)
                }
            }
        }
    }
    
    private var painScoreColor: Color {
        if painScore <= 2 {
            return .athleticEmerald
        } else if painScore <= 5 {
            return .recoveryTeal
        } else if painScore <= 7 {
            return .coralAmber
        } else {
            return .clinicalCrimson
        }
    }
    
    private func submitCheckIn() {
        isEvaluating = true
        
        let newCheckIn = DailyCheckIn(
            date: Date(),
            painScore: Int(painScore),
            swellingLevel: swellingLevel,
            painLocation: painLocation,
            aiAdjustmentSummary: "",
            recommendedMode: (painScore >= 6 || swellingLevel == .severe) ? "FlareUpRecovery" : "Normal"
        )
        
        Task {
            let assessment = await AIPhysioService.shared.evaluateReadiness(
                profile: profile,
                checkIn: newCheckIn,
                recentROM: nil
            )
            
            await MainActor.run {
                newCheckIn.aiAdjustmentSummary = assessment.coachMessage
                modelContext.insert(newCheckIn)
                try? modelContext.save()
                
                if assessment.isFlareUp {
                    HapticManager.flareUpAlert()
                } else {
                    HapticManager.repCompleted()
                }
                
                onCheckInSaved(newCheckIn)
                dismiss()
            }
        }
    }
}

