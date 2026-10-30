//
//  GyroscopeGoniometerView.swift
//  ACLVault
//
//  CoreMotion Gyroscope Shin-Tap Dual-Step Goniometer Studio
//

import SwiftUI
import SwiftData

@MainActor
public struct GyroscopeGoniometerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let profile: UserProfile
    let onSaved: ((ROMMeasurement) -> Void)?
    
    @State private var motionService = MotionManagerService.shared
    @State private var currentStep: GoniometerStep = .thighCalibration
    @State private var showingSavedToast: Bool = false
    
    public enum GoniometerStep {
        case thighCalibration
        case shinMeasurement
        case reviewAndSave
    }
    
    public init(profile: UserProfile, onSaved: ((ROMMeasurement) -> Void)? = nil) {
        self.profile = profile
        self.onSaved = onSaved
    }
    
    public var body: some View {
        ZStack {
            Color.vaultBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                topNavBar
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Step Progress Pill
                        stepProgressBar
                        
                        // Live Pitch Gauge & Joint Graphic
                        gaugeDisplaySection
                        
                        // Step-by-Step Clinical Instruction Card
                        instructionCard
                        
                        // Simulator Slider Controls (Available on simulator or toggle)
                        if motionService.isSimulatedMode {
                            simulatorSliderSection
                        }
                        
                        // Action Buttons
                        actionButtonsSection
                    }
                    .padding(20)
                }
            }
            
            if showingSavedToast {
                savedToastOverlay
            }
        }
        .onAppear {
            motionService.startMotionUpdates()
        }
        .onDisappear {
            motionService.stopMotionUpdates()
        }
    }
    
    // MARK: - Top Nav Bar
    private var topNavBar: some View {
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
            
            Text("GYROSCOPE SHIN-TAP")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(Color.recoveryTeal)
                .tracking(1.5)
            
            Spacer()
            
            Button("Reset") {
                motionService.resetCalibration()
                currentStep = .thighCalibration
            }
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.vaultTextMuted)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Step Progress Bar
    private var stepProgressBar: some View {
        HStack(spacing: 8) {
            StepChip(
                stepNumber: 1,
                title: "Thigh Calibration",
                isActive: currentStep == .thighCalibration,
                isCompleted: motionService.calibratedThighPitch != nil
            )
            
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.vaultTextMuted)
            
            StepChip(
                stepNumber: 2,
                title: "Shin Read",
                isActive: currentStep == .shinMeasurement,
                isCompleted: motionService.calculatedKneeFlexion != nil
            )
        }
    }
    
    // MARK: - Gauge Display Section
    private var gaugeDisplaySection: some View {
        VStack(spacing: 12) {
            ZStack {
                // Arc Gauge
                if let flexion = motionService.calculatedKneeFlexion {
                    AngleArcView(
                        degrees: flexion,
                        targetDegrees: 135.0,
                        mode: .flexion,
                        accentColor: .recoveryTeal
                    )
                } else {
                    // Live Pitch Readout
                    VStack(spacing: 4) {
                        Image(systemName: "gyroscope")
                            .font(.system(size: 38))
                            .foregroundStyle(Color.recoveryTeal)
                            .vaultGlow(color: .recoveryTeal, radius: 8)
                            .rotationEffect(.degrees(motionService.currentLivePitch))
                            .animation(.easeOut(duration: 0.1), value: motionService.currentLivePitch)
                            .padding(.bottom, 8)
                        
                        Text(String(format: "%.1f°", motionService.currentLivePitch))
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(Color.vaultTextPrimary)
                        
                        Text(currentStep == .thighCalibration ? "LIVE THIGH PITCH" : "LIVE SHIN PITCH")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.vaultTextMuted)
                            .tracking(1.5)
                    }
                    .frame(height: 170)
                }
            }
            .frame(height: 180)
            
            // Calibrated Status Values
            HStack(spacing: 16) {
                VStack(spacing: 2) {
                    Text("THIGH ANGLE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.vaultTextMuted)
                    Text(motionService.calibratedThighPitch != nil ? String(format: "%.1f°", motionService.calibratedThighPitch!) : "--")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(Color.recoveryTeal)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color.vaultCardElevated)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(spacing: 2) {
                    Text("SHIN ANGLE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.vaultTextMuted)
                    Text(motionService.measuredShinPitch != nil ? String(format: "%.1f°", motionService.measuredShinPitch!) : "--")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(Color.athleticEmerald)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color.vaultCardElevated)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(spacing: 2) {
                    Text("DELTA (FLEXION)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.vaultTextMuted)
                    Text(motionService.calculatedKneeFlexion != nil ? String(format: "%.1f°", motionService.calculatedKneeFlexion!) : "--")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(Color.coralAmber)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color.vaultCardElevated)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .vaultCard()
    }
    
    // MARK: - Instruction Card
    private var instructionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: currentStep == .thighCalibration ? "1.circle.fill" : "2.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.recoveryTeal)
                
                Text(currentStep == .thighCalibration ? "Step 1: Calibrate Thigh (Femur)" : "Step 2: Read Shin (Tibia)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vaultTextPrimary)
            }
            
            Text(currentStep == .thighCalibration
                 ? "Rest the back of your iPhone flat against the top of your anterior thigh (femur) parallel to your leg. Hold still and tap 'Calibrate Thigh'."
                 : "Now move your iPhone down and rest it flat along the crest of your shin bone (anterior tibia). Keep your knee at desired flexion and tap 'Read Knee Angle'."
            )
            .font(.system(size: 13))
            .foregroundStyle(Color.vaultTextSecondary)
            .lineSpacing(2)
        }
        .vaultCard()
    }
    
    // MARK: - Simulator Fallback Slider Section
    private var simulatorSliderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("SIMULATOR SENSOR SLIDER")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.coralAmber)
                Spacer()
                Text("\(Int(motionService.simulatedSliderAngle))°")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Color.coralAmber)
            }
            
            Slider(value: $motionService.simulatedSliderAngle, in: 0...150, step: 1)
                .tint(Color.coralAmber)
            
            Text("Adjust knee joint flexion angle to simulate device attitude.")
                .font(.system(size: 11))
                .foregroundStyle(Color.vaultTextMuted)
        }
        .vaultCard(borderColor: Color.coralAmber.opacity(0.3))
    }
    
    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if currentStep == .thighCalibration {
                Button {
                    motionService.calibrateThigh()
                    currentStep = .shinMeasurement
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "scope")
                        Text("Calibrate Thigh Reference")
                    }
                }
                .buttonStyle(VaultPrimaryButtonStyle(accentColor: .recoveryTeal))
            } else if currentStep == .shinMeasurement {
                Button {
                    motionService.readShin()
                    currentStep = .reviewAndSave
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "ruler.fill")
                        Text("Read Shin & Compute Flexion")
                    }
                }
                .buttonStyle(VaultPrimaryButtonStyle(accentColor: .athleticEmerald))
            } else {
                Button {
                    saveMeasurement()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Measurement (\(String(format: "%.1f°", motionService.calculatedKneeFlexion ?? 90.0)))")
                    }
                }
                .buttonStyle(VaultPrimaryButtonStyle(accentColor: .recoveryTeal))
                
                Button("Measure Again") {
                    motionService.resetCalibration()
                    currentStep = .thighCalibration
                }
                .buttonStyle(VaultOutlineButtonStyle())
            }
        }
    }
    
    private var savedToastOverlay: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.athleticEmerald)
            Text("Gyroscope ROM Logged!")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
        }
        .padding(24)
        .background(Color.vaultCardSurface.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .vaultGlow(color: .athleticEmerald, radius: 12)
    }
    
    private func saveMeasurement() {
        let flexion = motionService.calculatedKneeFlexion ?? 90.0
        let ext = motionService.calculatedKneeExtension ?? 0.0
        
        let newROM = ROMMeasurement(
            timestamp: Date(),
            flexionDegrees: flexion,
            extensionDegrees: ext,
            uninjuredFlexion: 140.0,
            measurementMethod: .gyroscope,
            notes: "Gyroscope Shin-Tap (\(profile.injuredSide.rawValue))"
        )
        
        modelContext.insert(newROM)
        try? modelContext.save()
        
        HapticManager.gateUnlocked()
        onSaved?(newROM)
        
        withAnimation {
            showingSavedToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showingSavedToast = false
            dismiss()
        }
    }
}

private struct StepChip: View {
    let stepNumber: Int
    let title: String
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.athleticEmerald : (isActive ? Color.recoveryTeal : Color.vaultCardElevated))
                    .frame(width: 20, height: 20)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.black)
                } else {
                    Text("\(stepNumber)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(isActive ? Color.black : Color.vaultTextMuted)
                }
            }
            
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(isActive ? Color.vaultTextPrimary : Color.vaultTextMuted)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isActive ? Color.vaultCardElevated : Color.clear)
        .clipShape(Capsule())
    }
}

