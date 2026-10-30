//
//  ProfileAndReportView.swift
//  ACLVault
//
//  Patient Profile, 1-Click Surgeon Report Generator & Rehab History
//

import SwiftUI
import SwiftData

@MainActor
public struct ProfileAndReportView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query(sort: \ROMMeasurement.timestamp, order: .reverse) private var romMeasurements: [ROMMeasurement]
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    @Query(sort: \WorkoutSessionLog.date, order: .reverse) private var workoutLogs: [WorkoutSessionLog]
    
    @State private var generatedPDFURL: URL? = nil
    @State private var showingPDFPreview: Bool = false
    @State private var isGeneratingPDF: Bool = false
    @State private var showingSettings: Bool = false
    @State private var showingPaywall: Bool = false
    
    private var profile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vaultBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Profile Demographic Card
                        patientProfileHeaderCard
                        
                        // 1-Click Surgeon & PT Report Action Card
                        surgeonReportActionCard
                        
                        // Pro Subscription Status Card
                        subscriptionCard
                        
                        // Workout History & Compliance
                        workoutHistorySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Clinical Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                        HapticManager.buttonTap()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.vaultTextSecondary)
                    }
                }
            }
            .sheet(isPresented: $showingPDFPreview) {
                if let url = generatedPDFURL {
                    ClinicalPDFPreviewView(pdfURL: url, profile: profile)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsSheet(profile: profile)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
    
    // MARK: - Patient Profile Card
    private var patientProfileHeaderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.recoveryTeal.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Text(profile.name.prefix(1).uppercased())
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(Color.recoveryTeal)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(profile.name)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Color.vaultTextPrimary)
                    
                    Text("\(profile.injuredSide.rawValue) • \(profile.graftType.shortName)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.vaultTextSecondary)
                }
                
                Spacer()
                
                Text(profile.postOpBadgeText)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.recoveryTeal)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.vaultCardElevated)
                    .clipShape(Capsule())
            }
            
            Divider().background(Color.vaultBorder)
            
            HStack(spacing: 12) {
                DemographicPill(title: "SURGERY DATE", value: profile.surgeryDate.formatted(date: .abbreviated, time: .omitted))
                DemographicPill(title: "PHASE LEVEL", value: "Level \(profile.currentLevel) of 10")
                DemographicPill(title: "MENISCUS", value: profile.meniscusRepair ? "Sutured" : "Intact")
            }
        }
        .vaultCard()
    }
    
    // MARK: - 1-Click Surgeon Report Generator Card
    private var surgeonReportActionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color(hex: "38BDF8"))
                    
                    Text("SURGEON & PT PROGRESS REPORT")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(Color(hex: "38BDF8"))
                        .tracking(1.5)
                }
                
                Spacer()
                
                Text("1-CLICK PDF")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(hex: "38BDF8"))
                    .clipShape(Capsule())
            }
            
            Text("Generate a comprehensive, printable 1-page clinical summary formatted with 30-day ROM trajectory, average effusion sweep, compliance %, and gate criteria ready for your physician.")
                .font(.system(size: 13))
                .foregroundStyle(Color.vaultTextSecondary)
                .lineSpacing(2)
            
            Button {
                generateClinicalPDF()
            } label: {
                if isGeneratingPDF {
                    HStack(spacing: 8) {
                        ProgressView().tint(.black)
                        Text("Compiling Clinical Charts...")
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "printer.fill")
                        Text("Generate & Share PDF Report")
                    }
                }
            }
            .buttonStyle(VaultPrimaryButtonStyle(accentColor: Color(hex: "38BDF8")))
            .disabled(isGeneratingPDF)
        }
        .vaultCard(borderColor: Color(hex: "38BDF8").opacity(0.3))
    }
    
    // MARK: - Subscription Card
    private var subscriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("MEMBERSHIP TIER")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.vaultTextMuted)
                        .tracking(1.2)
                    
                    Text(profile.isProSubscriber ? "ACL Vault Pro (Unlocked)" : "Free Rehabilitation Tier")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.vaultTextPrimary)
                }
                
                Spacer()
                
                if profile.isProSubscriber {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.athleticEmerald)
                } else {
                    Button("Upgrade") {
                        showingPaywall = true
                        HapticManager.buttonTap()
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.coralAmber)
                    .clipShape(Capsule())
                }
            }
            
            Text(profile.isProSubscriber
                 ? "You have full access to all 10 return-to-sport levels, dual AI Vision & Gyroscope goniometer engines, and unlimited PDF exports."
                 : "Free tier includes Post-Op counter, manual ROM logging, and Level 1 exercises. Upgrade to unlock all 10 recovery levels and AI goniometers."
            )
            .font(.system(size: 12))
            .foregroundStyle(Color.vaultTextSecondary)
        }
        .vaultCard()
    }
    
    // MARK: - Workout History Section
    private var workoutHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("COMPLETED WORKOUT LOG")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vaultTextMuted)
                    .tracking(1.2)
                
                Spacer()
                
                Text("\(workoutLogs.count) sessions")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.vaultTextMuted)
            }
            
            if workoutLogs.isEmpty {
                Text("No logged workouts yet. Complete today's session from the Home tab.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.vaultTextSecondary)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 8) {
                    ForEach(workoutLogs.prefix(10)) { log in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(log.wasFlareUpMode ? Color.coralAmber.opacity(0.15) : Color.athleticEmerald.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: log.wasFlareUpMode ? "snowflake" : "figure.run")
                                    .font(.system(size: 14))
                                    .foregroundStyle(log.wasFlareUpMode ? Color.coralAmber : Color.athleticEmerald)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(log.wasFlareUpMode ? "Flare-Up Deload Routine" : "Level \(log.levelAtCompletion) Rehab Protocol")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextPrimary)
                                
                                Text(log.formattedDate)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.vaultTextSecondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(log.formattedDuration)
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Color.recoveryTeal)
                                Text("RPE: \(log.rpeScore)/10")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.vaultTextMuted)
                            }
                        }
                        .padding(12)
                        .background(Color.vaultCardElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .vaultCard()
    }
    
    private func generateClinicalPDF() {
        isGeneratingPDF = true
        HapticManager.countdownTick()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let fileURL = PDFReportGenerator.generateReport(
                profile: profile,
                romLogs: romMeasurements,
                checkIns: checkIns,
                workoutLogs: workoutLogs
            )
            
            isGeneratingPDF = false
            if let fileURL = fileURL {
                self.generatedPDFURL = fileURL
                self.showingPDFPreview = true
                HapticManager.gateUnlocked()
            }
        }
    }
}

private struct DemographicPill: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.vaultTextMuted)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color.vaultTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.vaultCardElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

