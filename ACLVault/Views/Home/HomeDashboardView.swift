//
//  HomeDashboardView.swift
//  ACLVault
//
//  Main Command Center: Post-Op Counter, Readiness AI, Today's Workout & ROM Snapshot
//

import SwiftUI
import SwiftData

public struct HomeDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    @Query(sort: \ROMMeasurement.timestamp, order: .reverse) private var romMeasurements: [ROMMeasurement]
    @Query private var exercises: [Exercise]
    @Query(sort: \WorkoutSessionLog.date, order: .reverse) private var workoutLogs: [WorkoutSessionLog]
    
    @State private var showingCheckInSheet: Bool = false
    @State private var showingWorkoutPlayer: Bool = false
    @State private var showingPaywall: Bool = false
    @State private var showingSettings: Bool = false
    
    private var profile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    private var latestCheckIn: DailyCheckIn? {
        checkIns.first
    }
    
    private var latestROM: ROMMeasurement? {
        romMeasurements.first
    }
    
    private var isCheckedInToday: Bool {
        guard let checkIn = latestCheckIn else { return false }
        return Calendar.current.isDateInToday(checkIn.date)
    }
    
    private var isFlareUpActive: Bool {
        if profile.simulateFlareUp { return true }
        guard let checkIn = latestCheckIn else { return false }
        return checkIn.isFlareUp
    }
    
    private var currentLevel: RehabLevel {
        ProtocolLevels.level(for: profile.currentLevel)
    }
    
    private var todayExercises: [Exercise] {
        if isFlareUpActive {
            let regressions = exercises.filter { $0.isRegressionExercise }
            if !regressions.isEmpty { return regressions }
        }
        
        let levelExercises = exercises.filter { $0.levelRequired == profile.currentLevel && !$0.isRegressionExercise }
        return levelExercises.isEmpty ? Array(exercises.prefix(4)) : levelExercises
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vaultBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Top Header & Post-Op Badge
                        topHeaderSection
                        
                        // Flare-Up Alert (If active)
                        if isFlareUpActive {
                            FlareUpAlertCard(
                                summary: latestCheckIn?.aiAdjustmentSummary ?? "High pain or swelling triggered deload protocol.",
                                onStartDeloadWorkout: {
                                    showingWorkoutPlayer = true
                                }
                            )
                        }
                        
                        // Morning Readiness Card
                        readinessCard
                        
                        // Today's Prescribed Workout
                        TodayWorkoutCard(
                            currentLevel: currentLevel,
                            isFlareUpMode: isFlareUpActive,
                            exercises: todayExercises,
                            onStartWorkout: {
                                showingWorkoutPlayer = true
                            }
                        )
                        
                        // Quick ROM Snapshot
                        quickROMSnapshotCard
                        
                        // Level Phase Gate Progress Card
                        currentPhaseCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    PostOpBadgeView(
                        daysPostOp: profile.daysPostOp,
                        weeksPostOp: profile.weeksPostOp,
                        injuredSide: profile.injuredSide,
                        stage: profile.rehabStage
                    )
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        if !profile.isProSubscriber {
                            Button {
                                showingPaywall = true
                                HapticManager.buttonTap()
                            } label: {
                                Text("PRO")
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.coralAmber)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        Button {
                            showingSettings = true
                            HapticManager.buttonTap()
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.vaultTextSecondary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCheckInSheet) {
                DailyCheckInSheet(profile: profile) { _ in
                    // Saved
                }
            }
            .fullScreenCover(isPresented: $showingWorkoutPlayer) {
                WorkoutPlayerView(
                    profile: profile,
                    exercises: todayExercises,
                    wasFlareUpMode: isFlareUpActive
                )
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsSheet(profile: profile)
            }
        }
    }
    
    // MARK: - Top Header Section
    private var topHeaderSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back,")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.vaultTextMuted)
                
                Text(profile.name)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(Color.vaultTextPrimary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(profile.graftType.shortName)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.recoveryTeal)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.recoveryTeal.opacity(0.12))
                    .clipShape(Capsule())
                
                if profile.meniscusRepair {
                    Text("Meniscus Protected")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.coralAmber)
                }
            }
        }
    }
    
    // MARK: - Readiness Check-In Card
    private var readinessCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.recoveryTeal)
                    Text("DAILY AI READINESS")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.recoveryTeal)
                        .tracking(1.2)
                }
                
                Spacer()
                
                if isCheckedInToday {
                    Text("Checked In")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.athleticEmerald)
                }
            }
            
            if let checkIn = latestCheckIn, isCheckedInToday {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PAIN SCORE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.vaultTextMuted)
                            Text("\(checkIn.painScore) / 10")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundStyle(checkIn.painScore >= 6 ? Color.clinicalCrimson : Color.athleticEmerald)
                        }
                        
                        Divider().frame(height: 24).background(Color.vaultBorder)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("EFFUSION")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.vaultTextMuted)
                            Text(checkIn.swellingLevel.rawValue.components(separatedBy: " ").first ?? "None")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundStyle(checkIn.swellingLevel.badgeColor)
                        }
                        
                        Divider().frame(height: 24).background(Color.vaultBorder)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("LOCATION")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.vaultTextMuted)
                            Text(checkIn.painLocation.rawValue.components(separatedBy: " ").first ?? "Anterior")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextPrimary)
                                .lineLimit(1)
                        }
                    }
                    
                    if !checkIn.aiAdjustmentSummary.isEmpty {
                        Text(checkIn.aiAdjustmentSummary)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.vaultTextSecondary)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.vaultCardElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Button {
                        showingCheckInSheet = true
                    } label: {
                        Text("Update Today's Status")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.vaultTextMuted)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("How is your knee responding this morning?")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.vaultTextPrimary)
                    
                    Text("Rate your resting effusion and donor site pain to prevent micro-trauma flares.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.vaultTextSecondary)
                    
                    Button {
                        showingCheckInSheet = true
                        HapticManager.buttonTap()
                    } label: {
                        HStack {
                            Text("Start Morning Check-In")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .buttonStyle(VaultOutlineButtonStyle(strokeColor: Color.recoveryTeal.opacity(0.5), textColor: Color.recoveryTeal))
                }
            }
        }
        .vaultCard()
    }
    
    // MARK: - Quick ROM Snapshot Card
    private var quickROMSnapshotCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "ruler.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.recoveryTeal)
                    Text("RANGE OF MOTION")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.vaultTextMuted)
                        .tracking(1.2)
                }
                
                Spacer()
                
                NavigationLink(destination: ROMStudioView()) {
                    HStack(spacing: 4) {
                        Text("Open Studio")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.recoveryTeal)
                }
            }
            
            HStack(spacing: 14) {
                // Flexion
                VStack(alignment: .leading, spacing: 4) {
                    Text("ACTIVE FLEXION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.vaultTextMuted)
                    Text(latestROM != nil ? String(format: "%.1f°", latestROM!.flexionDegrees) : "120.0°")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.recoveryTeal)
                    Text("Target: \(Int(currentLevel.minFlexionTarget))°")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.vaultTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.vaultCardElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Extension
                VStack(alignment: .leading, spacing: 4) {
                    Text("EXTENSION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.vaultTextMuted)
                    Text(latestROM != nil ? String(format: "%.1f°", latestROM!.extensionDegrees) : "0.0°")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.athleticEmerald)
                    Text("Target: 0° Terminal")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.vaultTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.vaultCardElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .vaultCard()
    }
    
    // MARK: - Current Phase & Gate Milestone Card
    private var currentPhaseCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("CURRENT PHASE")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vaultTextMuted)
                    .tracking(1.2)
                Spacer()
                NavigationLink(destination: ProgressionMapView()) {
                    HStack(spacing: 4) {
                        Text("10-Level Map")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.athleticEmerald)
                }
            }
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(currentLevel.badgeColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: currentLevel.iconSymbol)
                        .font(.system(size: 20))
                        .foregroundStyle(currentLevel.badgeColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Level \(currentLevel.level): \(currentLevel.title)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.vaultTextPrimary)
                    Text(currentLevel.timeline)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.vaultTextSecondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("GATE TEST CRITERIA")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.vaultTextMuted)
                
                ForEach(currentLevel.gateCriteria.prefix(2), id: \.self) { criterion in
                    HStack(spacing: 6) {
                        Image(systemName: "circle")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.recoveryTeal)
                        Text(criterion)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.vaultTextSecondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.vaultCardElevated)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .vaultCard()
    }
}

