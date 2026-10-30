//
//  ROMStudioView.swift
//  ACLVault
//
//  Dual-Engine Digital Goniometer Measurement Studio Tab
//

import SwiftUI
import SwiftData

@MainActor
public struct ROMStudioView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query(sort: \ROMMeasurement.timestamp, order: .reverse) private var romMeasurements: [ROMMeasurement]
    
    @State private var showingAICamera: Bool = false
    @State private var showingGyroscope: Bool = false
    @State private var showingManualLog: Bool = false
    
    private var profile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    private var currentLevel: RehabLevel {
        ProtocolLevels.level(for: profile.currentLevel)
    }
    
    private var latestMeasurement: ROMMeasurement? {
        romMeasurements.first
    }
    
    private var sevenDayFlexionGain: Double {
        guard romMeasurements.count >= 2 else { return 0.0 }
        let now = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        let recentLogs = romMeasurements.filter { $0.timestamp >= sevenDaysAgo }
        if let newest = recentLogs.first, let oldest = recentLogs.last, newest.id != oldest.id {
            return newest.flexionDegrees - oldest.flexionDegrees
        }
        return 0.0
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vaultBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header
                        headerSection
                        
                        // Dual-Engine Measurement Mode Launchers
                        measurementLaunchersSection
                        
                        // Current Stats Grid
                        statsSummaryGrid
                        
                        // Interactive Swift Charts Trajectory
                        ROMChartsView(measurements: romMeasurements, currentLevel: currentLevel)
                        
                        // Measurement History Log
                        measurementHistorySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("ROM Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingManualLog = true
                        HapticManager.buttonTap()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.recoveryTeal)
                    }
                }
            }
            .fullScreenCover(isPresented: $showingAICamera) {
                AICameraGoniometerView(profile: profile)
            }
            .fullScreenCover(isPresented: $showingGyroscope) {
                GyroscopeGoniometerView(profile: profile)
            }
            .sheet(isPresented: $showingManualLog) {
                ManualROMLogSheet(profile: profile)
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("DIGITAL GONIOMETER")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.recoveryTeal)
                    .tracking(1.5)
                Text("Joint Range of Motion")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(Color.vaultTextPrimary)
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                Circle().fill(Color.athleticEmerald).frame(width: 8, height: 8)
                Text(profile.injuredSide.rawValue)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vaultTextPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.vaultCardElevated)
            .clipShape(Capsule())
        }
    }
    
    // MARK: - Measurement Mode Launchers
    private var measurementLaunchersSection: some View {
        VStack(spacing: 12) {
            // Engine 1: AI Camera Pose Mode
            Button {
                showingAICamera = true
                HapticManager.buttonTap()
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.recoveryTeal.opacity(0.15))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.recoveryTeal)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("AI Camera Pose Goniometer")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextPrimary)
                            Spacer()
                            Text("VISION")
                                .font(.system(size: 9, weight: .black, design: .rounded))
                                .foregroundStyle(Color.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.recoveryTeal)
                                .clipShape(Capsule())
                        }
                        
                        Text("Auto-detects Hip, Knee & Ankle landmarks with manual precision refinement.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.vaultTextSecondary)
                            .lineLimit(2)
                    }
                }
                .padding(14)
                .vaultCard(borderColor: Color.recoveryTeal.opacity(0.3))
            }
            
            // Engine 2: Gyroscope Shin-Tap
            Button {
                showingGyroscope = true
                HapticManager.buttonTap()
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.athleticEmerald.opacity(0.15))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "gyroscope")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.athleticEmerald)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Gyroscope Shin-Tap Mode")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextPrimary)
                            Spacer()
                            Text("CORE MOTION")
                                .font(.system(size: 9, weight: .black, design: .rounded))
                                .foregroundStyle(Color.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.athleticEmerald)
                                .clipShape(Capsule())
                        }
                        
                        Text("Place phone on thigh, tap calibrate, then rest on shin for precise angle delta.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.vaultTextSecondary)
                            .lineLimit(2)
                    }
                }
                .padding(14)
                .vaultCard(borderColor: Color.athleticEmerald.opacity(0.3))
            }
        }
    }
    
    // MARK: - Current Stats Grid
    private var statsSummaryGrid: some View {
        HStack(spacing: 12) {
            MetricCard(
                title: "FLEXION",
                value: latestMeasurement != nil ? latestMeasurement!.formattedFlexion : "120.0°",
                subtitle: sevenDayFlexionGain != 0 ? "\(sevenDayFlexionGain > 0 ? "+" : "")\(String(format: "%.1f°", sevenDayFlexionGain)) in 7D" : "On Track",
                iconName: "arrow.up.and.down",
                accentColor: .recoveryTeal,
                targetGoal: "Goal: \(Int(currentLevel.minFlexionTarget))°"
            )
            
            MetricCard(
                title: "EXTENSION",
                value: latestMeasurement != nil ? latestMeasurement!.formattedExtension : "0.0°",
                subtitle: latestMeasurement?.extensionDegrees == 0 ? "Terminal 0° Locked" : "Deficit present",
                iconName: "arrow.left.and.right",
                accentColor: .athleticEmerald,
                targetGoal: "Goal: 0°"
            )
        }
    }
    
    // MARK: - Measurement History List
    private var measurementHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("MEASUREMENT HISTORY")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vaultTextMuted)
                    .tracking(1.2)
                Spacer()
                Text("\(romMeasurements.count) records")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.vaultTextMuted)
            }
            
            if romMeasurements.isEmpty {
                Text("No measurements logged yet. Use the AI Camera or Gyroscope above.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.vaultTextSecondary)
                    .padding(.vertical, 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(romMeasurements.prefix(8)) { log in
                        HStack(spacing: 12) {
                            Image(systemName: log.measurementMethod.icon)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.recoveryTeal)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(log.measurementMethod.rawValue)
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.vaultTextPrimary)
                                    
                                    Text("•")
                                        .foregroundStyle(Color.vaultTextMuted)
                                    
                                    Text(log.formattedDate)
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color.vaultTextSecondary)
                                }
                                
                                if !log.notes.isEmpty {
                                    Text(log.notes)
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color.vaultTextMuted)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(log.formattedFlexion)
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.recoveryTeal)
                                Text("Ext: \(log.formattedExtension)")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.athleticEmerald)
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
}

