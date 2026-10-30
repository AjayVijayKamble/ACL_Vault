//
//  OnboardingView.swift
//  ACLVault
//
//  Multi-Step Clinical Onboarding Wizard
//

import SwiftUI
import SwiftData

@MainActor
public struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    
    @State private var currentStep: Int = 1
    @State private var name: String = ""
    @State private var surgeryDate: Date = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
    @State private var rehabStage: RehabType = .postOp
    @State private var graftType: GraftType = .patellar
    @State private var meniscusRepair: Bool = false
    @State private var injuredSide: LegSide = .right
    @State private var isGenerating: Bool = false
    
    public init() {}
    
    private let totalSteps: Int = 5
    
    public var body: some View {
        ZStack {
            Color.vaultBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                HStack(spacing: 6) {
                    ForEach(1...totalSteps, id: \.self) { step in
                        Capsule()
                            .fill(step <= currentStep ? Color.recoveryTeal : Color.vaultBorder)
                            .frame(height: 4)
                            .animation(.spring(), value: currentStep)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Step Content
                TabView(selection: $currentStep) {
                    welcomeStep.tag(1)
                    timelineAndStageStep.tag(2)
                    anatomyAndSideStep.tag(3)
                    graftAndMeniscusStep.tag(4)
                    protocolSummaryStep.tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
                
                // Bottom Navigation Controls
                bottomControls
            }
        }
    }
    
    // MARK: - Step 1: Welcome
    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.recoveryTeal.opacity(0.12))
                    .frame(width: 130, height: 130)
                
                Image(systemName: "cross.vial.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.recoveryTeal)
                    .vaultGlow(color: .recoveryTeal, radius: 12)
            }
            
            VStack(spacing: 10) {
                Text("ACL VAULT")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(Color.vaultTextPrimary)
                    .tracking(2)
                
                Text("AI-Powered Knee Reconstruction & Return-to-Sport Engine")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.recoveryTeal)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Text("Built on Delaware-Oslo & Melbourne criterion-based protocols. Calibrate your joint, track passive extension, and prevent re-tear with surgical accuracy.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.vaultTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.top, 6)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                FeatureBullet(icon: "camera.viewfinder", title: "AI Vision Goniometer", subtitle: "Snap or film knee angle without plastic tools")
                FeatureBullet(icon: "waveform.path.ecg", title: "Daily Physio Co-Pilot", subtitle: "Instant flare-up protection & deload rules")
                FeatureBullet(icon: "shield.checkered", title: "10-Level Gate System", subtitle: "Clear criteria before running or cutting")
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            Spacer()
        }
    }
    
    // MARK: - Step 2: Timeline & Name
    private var timelineAndStageStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("PATIENT PROFILE")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color.recoveryTeal)
                .tracking(1.5)
            
            Text("When was your surgery?")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Color.vaultTextPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("YOUR NAME")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.vaultTextMuted)
                
                TextField("e.g. Jordan Smith", text: $name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.vaultTextPrimary)
                    .padding(14)
                    .background(Color.vaultCardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.vaultBorder, lineWidth: 1))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("REHABILITATION TRACK")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.vaultTextMuted)
                
                Picker("Stage", selection: $rehabStage) {
                    ForEach(RehabType.allCases) { stage in
                        Text(stage.rawValue).tag(stage)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(rehabStage == .postOp ? "SURGERY DATE" : "INJURY / START DATE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.vaultTextMuted)
                
                DatePicker(
                    "Date",
                    selection: $surgeryDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .colorScheme(.dark)
                .padding(8)
                .background(Color.vaultCardSurface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.vaultBorder, lineWidth: 1))
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
    
    // MARK: - Step 3: Operative Side
    private var anatomyAndSideStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("OPERATIVE ANATOMY")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color.recoveryTeal)
                .tracking(1.5)
            
            Text("Which knee is affected?")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Color.vaultTextPrimary)
            
            Text("Camera pose landmarks and gyroscope shin-tap alignments will automatically configure for your injured side.")
                .font(.system(size: 14))
                .foregroundStyle(Color.vaultTextSecondary)
            
            HStack(spacing: 16) {
                SideSelectCard(
                    side: .left,
                    isSelected: injuredSide == .left
                ) {
                    injuredSide = .left
                    HapticManager.buttonTap()
                }
                
                SideSelectCard(
                    side: .right,
                    isSelected: injuredSide == .right
                ) {
                    injuredSide = .right
                    HapticManager.buttonTap()
                }
            }
            .padding(.top, 16)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }
    
    // MARK: - Step 4: Graft Type & Meniscus
    private var graftAndMeniscusStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("GRAFT & CONCOMITANT PATHOLOGY")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.recoveryTeal)
                    .tracking(1.5)
                
                Text("Select your surgical graft")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vaultTextPrimary)
                
                VStack(spacing: 10) {
                    ForEach(GraftType.allCases) { graft in
                        GraftSelectRow(
                            graft: graft,
                            isSelected: graftType == graft
                        ) {
                            graftType = graft
                            HapticManager.buttonTap()
                        }
                    }
                }
                
                Divider().background(Color.vaultBorder).padding(.vertical, 8)
                
                // Meniscus Repair Toggle
                VStack(alignment: .leading, spacing: 10) {
                    Toggle(isOn: $meniscusRepair) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Meniscus Repair Performed?")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextPrimary)
                            Text("Radial or root tear suturing restricts early flexion to 90° for weeks 0–6.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.vaultTextSecondary)
                        }
                    }
                    .tint(.coralAmber)
                    
                    if meniscusRepair {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.coralAmber)
                            Text("Active flexion protection mode will be enabled automatically.")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.coralAmber)
                        }
                        .padding(10)
                        .background(Color.coralAmber.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(16)
                .background(Color.vaultCardSurface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.vaultBorder, lineWidth: 1))
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Step 5: Protocol Summary
    private var protocolSummaryStep: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.athleticEmerald.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.athleticEmerald)
                    .vaultGlow(color: .athleticEmerald, radius: 10)
            }
            
            VStack(spacing: 8) {
                Text("Protocol Ready")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color.vaultTextPrimary)
                
                Text("Your personalized 10-level recovery trajectory has been calibrated.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.vaultTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 12) {
                SummaryRow(label: "Starting Phase", value: "Level 1: Quiet the Knee & 0° Ext.")
                SummaryRow(label: "Operative Leg", value: injuredSide.rawValue)
                SummaryRow(label: "Graft Type", value: graftType.shortName)
                SummaryRow(label: "Meniscus Status", value: meniscusRepair ? "Protected (<=90°)" : "Unrestricted Flexion")
            }
            .padding(16)
            .background(Color.vaultCardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.vaultBorder, lineWidth: 1))
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // MARK: - Bottom Controls
    private var bottomControls: some View {
        HStack(spacing: 16) {
            if currentStep > 1 {
                Button("Back") {
                    withAnimation {
                        currentStep -= 1
                    }
                    HapticManager.buttonTap()
                }
                .buttonStyle(VaultOutlineButtonStyle())
                .frame(width: 100)
            }
            
            Button {
                if currentStep < totalSteps {
                    withAnimation {
                        currentStep += 1
                    }
                    HapticManager.buttonTap()
                } else {
                    finishOnboarding()
                }
            } label: {
                Text(currentStep == totalSteps ? "Enter ACL Vault" : "Continue")
            }
            .buttonStyle(VaultPrimaryButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .padding(.top, 12)
        .background(Color.vaultBackground)
    }
    
    private func finishOnboarding() {
        let finalName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "ACL Warrior" : name
        
        if let existing = userProfiles.first {
            existing.name = finalName
            existing.surgeryDate = surgeryDate
            existing.rehabStage = rehabStage
            existing.graftType = graftType
            existing.meniscusRepair = meniscusRepair
            existing.injuredSide = injuredSide
            existing.hasCompletedOnboarding = true
        } else {
            let newProfile = UserProfile(
                name: finalName,
                surgeryDate: surgeryDate,
                rehabStage: rehabStage,
                graftType: graftType,
                meniscusRepair: meniscusRepair,
                injuredSide: injuredSide,
                currentLevel: 1,
                isProSubscriber: false,
                hasCompletedOnboarding: true
            )
            modelContext.insert(newProfile)
        }
        
        try? modelContext.save()
        HapticManager.gateUnlocked()
    }
}

// MARK: - Subcomponents
private struct FeatureBullet: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.recoveryTeal)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vaultTextPrimary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.vaultTextSecondary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.vaultCardSurface.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.vaultBorder.opacity(0.6), lineWidth: 1))
    }
}

private struct SideSelectCard: View {
    let side: LegSide
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(isSelected ? Color.recoveryTeal : Color.vaultTextMuted)
                
                Text(side.rawValue)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vaultTextPrimary)
                
                Text(side == .left ? "Left Leg Anterior/Posterior" : "Right Leg Anterior/Posterior")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.vaultTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.recoveryTeal.opacity(0.12) : Color.vaultCardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.recoveryTeal : Color.vaultBorder, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

private struct GraftSelectRow: View {
    let graft: GraftType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isSelected ? Color.recoveryTeal : Color.vaultTextMuted)
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(graft.rawValue)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.vaultTextPrimary)
                    Text(graft.clinicalNotes)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.vaultTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.recoveryTeal.opacity(0.12) : Color.vaultCardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.recoveryTeal : Color.vaultBorder, lineWidth: isSelected ? 1.5 : 1)
            )
        }
    }
}

private struct SummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.vaultTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.vaultTextPrimary)
        }
    }
}

