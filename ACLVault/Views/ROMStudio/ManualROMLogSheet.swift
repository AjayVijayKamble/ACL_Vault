//
//  ManualROMLogSheet.swift
//  ACLVault
//
//  Direct Manual Range of Motion Input Modal
//

import SwiftUI
import SwiftData

@MainActor
public struct ManualROMLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let profile: UserProfile
    let onSaved: ((ROMMeasurement) -> Void)?
    
    @State private var flexionDegrees: Double = 110.0
    @State private var extensionDegrees: Double = 0.0
    @State private var uninjuredFlexion: Double = 140.0
    @State private var notes: String = ""
    
    public init(profile: UserProfile, onSaved: ((ROMMeasurement) -> Void)? = nil) {
        self.profile = profile
        self.onSaved = onSaved
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vaultBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("MANUAL ROM LOG")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.recoveryTeal)
                                .tracking(1.5)
                            
                            Text("Record Clinical Angle")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextPrimary)
                            
                            Text("Enter measurements taken with a physical clinic goniometer or inclinometer.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.vaultTextSecondary)
                        }
                        
                        // Active Flexion Slider
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("ACTIVE KNEE FLEXION")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextMuted)
                                Spacer()
                                Text(String(format: "%.1f°", flexionDegrees))
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.recoveryTeal)
                            }
                            
                            Slider(value: $flexionDegrees, in: 0...155, step: 0.5)
                                .tint(Color.recoveryTeal)
                            
                            HStack {
                                Text("0° (Straight)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.vaultTextMuted)
                                Spacer()
                                Text("90° (Right Angle)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.vaultTextMuted)
                                Spacer()
                                Text("140°+ (Heel to Buttock)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.vaultTextMuted)
                            }
                        }
                        .vaultCard()
                        
                        // Active Extension Slider
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("ACTIVE EXTENSION (0° = Neutral)")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextMuted)
                                Spacer()
                                Text(String(format: "%.1f°", extensionDegrees))
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundStyle(extensionDegrees <= 0 ? Color.athleticEmerald : Color.coralAmber)
                            }
                            
                            Slider(value: $extensionDegrees, in: -10...25, step: 0.5)
                                .tint(extensionDegrees <= 0 ? Color.athleticEmerald : Color.coralAmber)
                            
                            HStack {
                                Text("-10° (Hyperextension)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.vaultTextMuted)
                                Spacer()
                                Text("0° (Terminal)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.athleticEmerald)
                                Spacer()
                                Text("+25° (Severe Lag)")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.vaultTextMuted)
                            }
                        }
                        .vaultCard()
                        
                        // Uninjured Reference
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("UNINJURED CONTRALATERAL FLEXION")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextMuted)
                                Spacer()
                                Text("\(Int(uninjuredFlexion))°")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextPrimary)
                            }
                            
                            Slider(value: $uninjuredFlexion, in: 120...160, step: 1)
                                .tint(Color.vaultTextSecondary)
                        }
                        .vaultCard()
                        
                        // Clinical Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CLINICAL CONTEXT / NOTES")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextMuted)
                            
                            TextField("e.g. Measured supine after 10 min warm-up cycling", text: $notes)
                                .padding(12)
                                .background(Color.vaultCardSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.vaultBorder, lineWidth: 1))
                        }
                        .vaultCard()
                        
                        // Save Button
                        Button {
                            saveManualROM()
                        } label: {
                            Text("Save Manual Measurement")
                        }
                        .buttonStyle(VaultPrimaryButtonStyle(accentColor: .recoveryTeal))
                        .padding(.top, 4)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Manual Log")
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
    
    private func saveManualROM() {
        let measurement = ROMMeasurement(
            timestamp: Date(),
            flexionDegrees: flexionDegrees,
            extensionDegrees: extensionDegrees,
            uninjuredFlexion: uninjuredFlexion,
            measurementMethod: .manual,
            notes: notes.isEmpty ? "Manual goniometer log" : notes
        )
        
        modelContext.insert(measurement)
        try? modelContext.save()
        
        HapticManager.gateUnlocked()
        onSaved?(measurement)
        dismiss()
    }
}

