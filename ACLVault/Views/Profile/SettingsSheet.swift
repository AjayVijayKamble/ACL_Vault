//
//  SettingsSheet.swift
//  ACLVault
//
//  Settings, Clinical Profile Management & Developer Demo Controls
//

import SwiftUI
import SwiftData

public struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var profile: UserProfile
    
    @State private var geminiApiKey: String = ""
    @State private var showingReSeedAlert: Bool = false
    
    public init(profile: UserProfile) {
        self.profile = profile
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vaultBackground.ignoresSafeArea()
                
                Form {
                    // MARK: - Demo & Testing Controls
                    Section {
                        // Level Override Stepper
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Rehab Level Override")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextPrimary)
                                Text("Test any phase (1 to 10) immediately")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.vaultTextMuted)
                            }
                            
                            Spacer()
                            
                            Stepper(
                                "Level \(profile.currentLevel)",
                                value: $profile.currentLevel,
                                in: 1...10
                            )
                            .labelsHidden()
                            
                            Text("Lvl \(profile.currentLevel)")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                                .foregroundStyle(Color.recoveryTeal)
                                .frame(width: 48)
                        }
                        
                        // Simulate Flare-Up
                        Toggle(isOn: $profile.simulateFlareUp) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Simulate Flare-Up Mode")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextPrimary)
                                Text("Triggers acute joint effusion deload routine")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.vaultTextMuted)
                            }
                        }
                        .tint(Color.clinicalCrimson)
                        
                        // Pro Subscription Toggle
                        Toggle(isOn: $profile.isProSubscriber) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("ACL Vault Pro Status")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextPrimary)
                                Text("Toggle freemium paywall unlocked state")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.vaultTextMuted)
                            }
                        }
                        .tint(Color.coralAmber)
                    } header: {
                        Text("SIMULATOR & DEMO CONTROLS")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.recoveryTeal)
                    } footer: {
                        Text("Use these toggles to test different rehab levels, flare-up scenarios, and pro features without waiting months.")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.vaultTextMuted)
                    }
                    .listRowBackground(Color.vaultCardSurface)
                    
                    // MARK: - Clinical Anatomy & Graft
                    Section {
                        TextField("Patient Name", text: $profile.name)
                            .foregroundStyle(Color.vaultTextPrimary)
                        
                        Picker("Injured Limb", selection: Binding(
                            get: { profile.injuredSide },
                            set: { profile.injuredSide = $0 }
                        )) {
                            ForEach(LegSide.allCases) { side in
                                Text(side.rawValue).tag(side)
                            }
                        }
                        
                        Picker("Graft Type", selection: Binding(
                            get: { profile.graftType },
                            set: { profile.graftType = $0 }
                        )) {
                            ForEach(GraftType.allCases) { graft in
                                Text(graft.rawValue).tag(graft)
                            }
                        }
                        
                        Toggle("Meniscus Repair (<90° early protection)", isOn: $profile.meniscusRepair)
                            .tint(Color.coralAmber)
                        
                        DatePicker("Surgery Date", selection: $profile.surgeryDate, in: ...Date(), displayedComponents: .date)
                    } header: {
                        Text("PATIENT SURGICAL PROFILE")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.vaultTextMuted)
                    }
                    .listRowBackground(Color.vaultCardSurface)
                    
                    // MARK: - AI Physio Co-Pilot Configuration
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Gemini API Key (Optional)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.vaultTextPrimary)
                            
                            SecureField("Enter API Key for Live LLM", text: $geminiApiKey)
                                .font(.system(size: 14))
                                .padding(10)
                                .background(Color.vaultCardElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onChange(of: geminiApiKey) { _, newValue in
                                    AIPhysioService.shared.setApiKey(newValue)
                                }
                            
                            Text("When empty, the app runs on its built-in deterministic clinical rule engine offline.")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.vaultTextMuted)
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("AI PHYSIO CO-PILOT CONFIG")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.vaultTextMuted)
                    }
                    .listRowBackground(Color.vaultCardSurface)
                    
                    // MARK: - Data Management
                    Section {
                        Button("Re-Seed 30-Day Historical Data") {
                            showingReSeedAlert = true
                        }
                        .foregroundStyle(Color.recoveryTeal)
                    } header: {
                        Text("DATABASE SEEDING")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.vaultTextMuted)
                    }
                    .listRowBackground(Color.vaultCardSurface)
                    
                    // MARK: - About
                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0 (Swift 6 & SwiftData)")
                                .foregroundStyle(Color.vaultTextMuted)
                        }
                        HStack {
                            Text("Protocol Standard")
                            Spacer()
                            Text("Delaware-Oslo & Melbourne")
                                .foregroundStyle(Color.recoveryTeal)
                        }
                    } header: {
                        Text("ABOUT ACL VAULT")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.vaultTextMuted)
                    }
                    .listRowBackground(Color.vaultCardSurface)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings & Simulator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        try? modelContext.save()
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.recoveryTeal)
                }
            }
            .alert("Re-Seed Database?", isPresented: $showingReSeedAlert) {
                Button("Re-Seed", role: .destructive) {
                    ProtocolSeeder.seedInitialDataIfNeeded(context: modelContext)
                    HapticManager.gateUnlocked()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will ensure all 10 levels, 30+ exercises, and 30-day historical progression logs are present in your SwiftData store.")
            }
        }
    }
}

