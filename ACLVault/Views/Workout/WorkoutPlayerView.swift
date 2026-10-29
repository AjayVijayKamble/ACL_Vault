//
//  WorkoutPlayerView.swift
//  ACLVault
//
//  Step-by-Step Guided Rehabilitation Player with Animated Circular Timers & Audio Cues
//

import SwiftUI
import SwiftData

public struct WorkoutPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let profile: UserProfile
    let initialExercises: [Exercise]
    let wasFlareUpMode: Bool
    
    @State private var exercises: [Exercise] = []
    @State private var currentExerciseIndex: Int = 0
    @State private var currentSet: Int = 1
    @State private var currentRep: Int = 1
    
    // Timer state
    @State private var isResting: Bool = false
    @State private var isTimerRunning: Bool = false
    @State private var holdSecondsRemaining: Int = 10
    @State private var restSecondsRemaining: Int = 30
    
    // Elapsed workout time
    @State private var elapsedSeconds: Int = 0
    @State private var totalTimer: Timer? = nil
    @State private var activeLoopTimer: Timer? = nil
    
    // Completion & Feedback state
    @State private var isWorkoutComplete: Bool = false
    @State private var rpeScore: Double = 5.0
    @State private var sessionNotes: String = ""
    @State private var completedExerciseIDs: [UUID] = []
    
    // Modals
    @State private var showingFormCues: Bool = false
    @State private var showingPainFlagAlert: Bool = false
    @State private var showingSwapSheet: Bool = false
    
    public init(profile: UserProfile, exercises: [Exercise], wasFlareUpMode: Bool = false) {
        self.profile = profile
        self.initialExercises = exercises
        self.wasFlareUpMode = wasFlareUpMode
    }
    
    private var currentExercise: Exercise? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    private var progressRatio: Double {
        guard !exercises.isEmpty else { return 0 }
        let totalUnits = exercises.reduce(0) { $0 + ($1.defaultSets * $1.defaultReps) }
        let pastExercises = exercises.prefix(currentExerciseIndex).reduce(0) { $0 + ($1.defaultSets * $1.defaultReps) }
        let currentExerciseUnits = ((currentSet - 1) * (currentExercise?.defaultReps ?? 1)) + currentRep
        let completed = pastExercises + currentExerciseUnits
        return min(1.0, max(0.0, Double(completed) / Double(max(1, totalUnits))))
    }
    
    public var body: some View {
        ZStack {
            Color.vaultBackground.ignoresSafeArea()
            
            if isWorkoutComplete {
                completionSummaryView
            } else if let exercise = currentExercise {
                VStack(spacing: 0) {
                    // Top Player Bar
                    topPlayerBar
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Exercise Category Badge & Title
                            VStack(spacing: 6) {
                                HStack(spacing: 8) {
                                    Text(exercise.category.rawValue.uppercased())
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(exercise.category.accentColor)
                                        .tracking(1.5)
                                    
                                    Text("•")
                                        .foregroundStyle(Color.vaultTextMuted)
                                    
                                    Text("Exercise \(currentExerciseIndex + 1) of \(exercises.count)")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.vaultTextSecondary)
                                }
                                
                                Text(exercise.title)
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.vaultTextPrimary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                                
                                Text("Target: \(exercise.targetMuscle)")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.vaultTextMuted)
                            }
                            .padding(.top, 8)
                            
                            // Sets & Reps Pill Indicators
                            HStack(spacing: 24) {
                                VStack(spacing: 2) {
                                    Text("SET")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Color.vaultTextMuted)
                                    Text("\(currentSet) / \(exercise.defaultSets)")
                                        .font(.system(size: 20, weight: .black, design: .rounded))
                                        .foregroundStyle(Color.vaultTextPrimary)
                                }
                                
                                Divider().frame(height: 28).background(Color.vaultBorder)
                                
                                VStack(spacing: 2) {
                                    Text("REP")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Color.vaultTextMuted)
                                    Text("\(currentRep) / \(exercise.defaultReps)")
                                        .font(.system(size: 20, weight: .black, design: .rounded))
                                        .foregroundStyle(Color.vaultTextPrimary)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .background(Color.vaultCardSurface)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.vaultBorder, lineWidth: 1))
                            
                            // Central Interactive Timer / Rep Counter
                            if isResting {
                                CircularProgressTimer(
                                    totalSeconds: 30,
                                    secondsRemaining: $restSecondsRemaining,
                                    isRunning: isTimerRunning,
                                    statusTitle: "REST INTERVAL",
                                    accentColor: .athleticEmerald,
                                    ringDiameter: 220
                                )
                                .padding(.vertical, 12)
                            } else if exercise.isIsometric {
                                CircularProgressTimer(
                                    totalSeconds: exercise.holdSeconds,
                                    secondsRemaining: $holdSecondsRemaining,
                                    isRunning: isTimerRunning,
                                    statusTitle: "HOLD ISOMETRIC",
                                    accentColor: exercise.category.accentColor,
                                    ringDiameter: 220
                                )
                                .padding(.vertical, 12)
                            } else {
                                // Dynamic Movement Display
                                VStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.vaultCardElevated)
                                            .frame(width: 200, height: 200)
                                            .overlay(
                                                Circle().stroke(exercise.category.accentColor, lineWidth: 4)
                                            )
                                        
                                        VStack(spacing: 4) {
                                            Image(systemName: exercise.videoPlaceholderSymbol)
                                                .font(.system(size: 48))
                                                .foregroundStyle(exercise.category.accentColor)
                                            Text("CONTROLLED TEMPO")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundStyle(Color.vaultTextMuted)
                                                .tracking(1.5)
                                        }
                                    }
                                    
                                    Text("Perform rep with 3s eccentric lowering")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.vaultTextSecondary)
                                }
                                .padding(.vertical, 12)
                            }
                            
                            // Active Execution Controls
                            HStack(spacing: 16) {
                                if exercise.isIsometric || isResting {
                                    Button {
                                        togglePlayPause()
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                            Text(isTimerRunning ? "Pause" : (isResting ? "Resume Rest" : "Start Hold"))
                                        }
                                    }
                                    .buttonStyle(VaultPrimaryButtonStyle(accentColor: isResting ? .athleticEmerald : exercise.category.accentColor))
                                }
                                
                                Button {
                                    advanceRepOrSet()
                                } label: {
                                    HStack(spacing: 8) {
                                        Text(isResting ? "Skip Rest" : "Complete Rep")
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .buttonStyle(VaultOutlineButtonStyle(strokeColor: Color.vaultBorder))
                            }
                            .padding(.horizontal, 24)
                            
                            // Quick Action Tools (Cues, Swap, Flag Pain)
                            HStack(spacing: 12) {
                                Button {
                                    showingFormCues = true
                                    HapticManager.buttonTap()
                                } label: {
                                    Label("Form Cues", systemImage: "text.book.closed.fill")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.vaultTextPrimary)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(Color.vaultCardElevated)
                                .clipShape(Capsule())
                                
                                Button {
                                    showingSwapSheet = true
                                    HapticManager.buttonTap()
                                } label: {
                                    Label("Swap", systemImage: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.vaultTextPrimary)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(Color.vaultCardElevated)
                                .clipShape(Capsule())
                                
                                Spacer()
                                
                                Button {
                                    showingPainFlagAlert = true
                                    HapticManager.flareUpAlert()
                                } label: {
                                    Label("Flag Pain", systemImage: "exclamationmark.triangle.fill")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.clinicalCrimson)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(Color.clinicalCrimson.opacity(0.15))
                                .clipShape(Capsule())
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .onAppear {
            setupInitialWorkout()
        }
        .onDisappear {
            stopAllTimers()
        }
        .sheet(isPresented: $showingFormCues) {
            if let exercise = currentExercise {
                ExerciseDetailModal(exercise: exercise)
            }
        }
        .confirmationDialog(
            "Flag Pain or Joint Irritation?",
            isPresented: $showingPainFlagAlert,
            titleVisibility: .visible
        ) {
            Button("Switch to 0° Deload Routine", role: .destructive) {
                switchToFlareUpRoutine()
            }
            Button("Rest Joint & End Session") {
                finishWorkout()
            }
            Button("False Alarm, Continue", role: .cancel) {}
        } message: {
            Text("If you experience sharp joint pain (>4/10) or pinch sensations, clinical protocols recommend immediately swapping for gentle terminal extension and ice.")
        }
        .sheet(isPresented: $showingSwapSheet) {
            swapExerciseModal
        }
    }
    
    // MARK: - Top Player Bar
    private var topPlayerBar: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    stopAllTimers()
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
                
                // Elapsed workout timer
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.recoveryTeal)
                    Text(formattedElapsed)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.vaultTextPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.vaultCardElevated)
                .clipShape(Capsule())
                
                Spacer()
                
                Button {
                    advanceToNextExercise()
                } label: {
                    Text("Skip")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.vaultTextSecondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.vaultBorder)
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(Color.recoveryTeal)
                        .frame(width: geo.size.width * progressRatio, height: 4)
                        .animation(.spring(), value: progressRatio)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Workout Completion Summary View
    private var completionSummaryView: some View {
        ZStack {
            ConfettiView()
            
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.athleticEmerald.opacity(0.15))
                            .frame(width: 90, height: 90)
                        
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 42))
                            .foregroundStyle(Color.athleticEmerald)
                            .vaultGlow(color: .athleticEmerald, radius: 10)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 6) {
                        Text("Session Complete!")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Color.vaultTextPrimary)
                        
                        Text("Every repetition restores your neuromuscular knee stiffness.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.vaultTextSecondary)
                    }
                    
                    // Stats Summary Grid
                    HStack(spacing: 12) {
                        VStack(spacing: 4) {
                            Text("DURATION")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.vaultTextMuted)
                            Text(formattedElapsed)
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(Color.vaultTextPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.vaultCardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(spacing: 4) {
                            Text("EXERCISES")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.vaultTextMuted)
                            Text("\(completedExerciseIDs.count)")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(Color.recoveryTeal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.vaultCardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(spacing: 4) {
                            Text("LEVEL")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.vaultTextMuted)
                            Text("Lvl \(profile.currentLevel)")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(Color.athleticEmerald)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.vaultCardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 20)
                    
                    // Rate of Perceived Exertion (RPE Slider 1-10)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("SESSION INTENSITY (RPE)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextMuted)
                            Spacer()
                            Text("\(Int(rpeScore)) / 10")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundStyle(Color.recoveryTeal)
                        }
                        
                        Slider(value: $rpeScore, in: 1...10, step: 1)
                            .tint(Color.recoveryTeal)
                    }
                    .vaultCard()
                    .padding(.horizontal, 20)
                    
                    // Optional Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CLINICAL NOTES (OPTIONAL)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.vaultTextMuted)
                        
                        TextField("e.g. 0° extension felt crisp, no patellar soreness", text: $sessionNotes)
                            .padding(12)
                            .background(Color.vaultCardSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.vaultBorder, lineWidth: 1))
                    }
                    .padding(.horizontal, 20)
                    
                    // Save Button
                    Button {
                        saveSessionLog()
                    } label: {
                        Text("Save to Clinical Rehab Log")
                    }
                    .buttonStyle(VaultPrimaryButtonStyle(accentColor: .athleticEmerald))
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: - Swap Exercise Modal
    private var swapExerciseModal: some View {
        NavigationStack {
            ZStack {
                Color.vaultBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Alternative Exercise")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.vaultTextPrimary)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        let regressions = [
                            Exercise(
                                title: "Heel Props (Passive Terminal Extension)",
                                levelRequired: 1,
                                category: .extensionFix,
                                defaultSets: 3,
                                defaultReps: 1,
                                holdSeconds: 180,
                                formCues: ["Rest heel on towel roll, let knee sag into 0° extension."],
                                videoPlaceholderSymbol: "arrow.down.to.line.compact",
                                isRegressionExercise: true
                            ),
                            Exercise(
                                title: "Quad Sets (Isometric VMO Contraction)",
                                levelRequired: 1,
                                category: .quadActivation,
                                defaultSets: 3,
                                defaultReps: 15,
                                holdSeconds: 10,
                                formCues: ["Drive back of knee down into mat."],
                                videoPlaceholderSymbol: "bolt.fill",
                                isRegressionExercise: true
                            ),
                            Exercise(
                                title: "Ankle Pumps & Circulatory Flushing",
                                levelRequired: 1,
                                category: .extensionFix,
                                defaultSets: 3,
                                defaultReps: 30,
                                holdSeconds: 0,
                                formCues: ["Pump ankles back and forth."],
                                videoPlaceholderSymbol: "arrow.clockwise.heart",
                                isRegressionExercise: true
                            )
                        ]
                        
                        ForEach(regressions) { reg in
                            Button {
                                if currentExerciseIndex < exercises.count {
                                    exercises[currentExerciseIndex] = reg
                                    resetForCurrentExercise()
                                    showingSwapSheet = false
                                    HapticManager.repCompleted()
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(reg.title)
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.vaultTextPrimary)
                                        Text(reg.prescriptionSummary)
                                            .font(.system(size: 12))
                                            .foregroundStyle(Color.vaultTextSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color.recoveryTeal)
                                }
                                .padding(14)
                                .vaultCard()
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .navigationTitle("Swap Exercise")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Logic & Timer Controls
    private func setupInitialWorkout() {
        self.exercises = initialExercises.isEmpty ? ProtocolLevels.allLevels[0].primaryExercisesSummary.compactMap { title in
            Exercise(
                title: title,
                levelRequired: 1,
                category: .quadActivation,
                defaultSets: 3,
                defaultReps: 10,
                holdSeconds: 10
            )
        } : initialExercises
        
        self.currentExerciseIndex = 0
        self.currentSet = 1
        self.currentRep = 1
        resetForCurrentExercise()
        startElapsedTimer()
    }
    
    private func resetForCurrentExercise() {
        guard let ex = currentExercise else { return }
        self.holdSecondsRemaining = ex.holdSeconds
        self.isResting = false
        self.isTimerRunning = false
        stopActiveLoopTimer()
    }
    
    private func startElapsedTimer() {
        totalTimer?.invalidate()
        totalTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.elapsedSeconds += 1
            }
        }
    }
    
    private func togglePlayPause() {
        isTimerRunning.toggle()
        HapticManager.buttonTap()
        
        if isTimerRunning {
            startLoopTimer()
        } else {
            stopActiveLoopTimer()
        }
    }
    
    private func startLoopTimer() {
        stopActiveLoopTimer()
        activeLoopTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                if self.isResting {
                    if self.restSecondsRemaining > 1 {
                        self.restSecondsRemaining -= 1
                        if self.restSecondsRemaining <= 3 {
                            AudioCueManager.playTick()
                            HapticManager.countdownTick()
                        }
                    } else {
                        // Rest finished
                        self.isResting = false
                        self.restSecondsRemaining = 30
                        self.isTimerRunning = false
                        self.stopActiveLoopTimer()
                        AudioCueManager.playRepBeep()
                        HapticManager.repCompleted()
                    }
                } else if let ex = self.currentExercise, ex.isIsometric {
                    if self.holdSecondsRemaining > 1 {
                        self.holdSecondsRemaining -= 1
                        if self.holdSecondsRemaining <= 3 {
                            AudioCueManager.playTick()
                            HapticManager.countdownTick()
                        }
                    } else {
                        // Isometric rep finished
                        AudioCueManager.playRepBeep()
                        HapticManager.repCompleted()
                        self.advanceRepOrSet()
                    }
                }
            }
        }
    }
    
    private func stopActiveLoopTimer() {
        activeLoopTimer?.invalidate()
        activeLoopTimer = nil
    }
    
    private func stopAllTimers() {
        totalTimer?.invalidate()
        totalTimer = nil
        stopActiveLoopTimer()
    }
    
    private func advanceRepOrSet() {
        guard let ex = currentExercise else { return }
        
        if currentRep < ex.defaultReps {
            currentRep += 1
            holdSecondsRemaining = ex.holdSeconds
            if !ex.isIsometric {
                HapticManager.countdownTick()
            }
        } else {
            // Completed reps for current set
            if currentSet < ex.defaultSets {
                currentSet += 1
                currentRep = 1
                holdSecondsRemaining = ex.holdSeconds
                // Trigger Rest Period
                isResting = true
                restSecondsRemaining = 30
                isTimerRunning = true
                startLoopTimer()
            } else {
                // Completed all sets of exercise!
                if let exId = currentExercise?.id {
                    completedExerciseIDs.append(exId)
                }
                advanceToNextExercise()
            }
        }
    }
    
    private func advanceToNextExercise() {
        if currentExerciseIndex < exercises.count - 1 {
            currentExerciseIndex += 1
            currentSet = 1
            currentRep = 1
            resetForCurrentExercise()
            HapticManager.repCompleted()
        } else {
            finishWorkout()
        }
    }
    
    private func switchToFlareUpRoutine() {
        stopActiveLoopTimer()
        self.exercises = [
            Exercise(
                title: "Ice, Compression & High Elevation Protocol",
                levelRequired: 1,
                category: .extensionFix,
                defaultSets: 1,
                defaultReps: 1,
                holdSeconds: 900,
                formCues: ["Elevate above heart level, apply crushed ice pack for 15 minutes."],
                videoPlaceholderSymbol: "snowflake",
                isRegressionExercise: true
            ),
            Exercise(
                title: "Heel Props (Passive Terminal Extension)",
                levelRequired: 1,
                category: .extensionFix,
                defaultSets: 3,
                defaultReps: 1,
                holdSeconds: 180,
                formCues: ["Rest ankle on folded towel, gravity sinks knee into full extension."],
                videoPlaceholderSymbol: "arrow.down.to.line.compact",
                isRegressionExercise: true
            ),
            Exercise(
                title: "Ankle Pumps & Circulatory Flushing",
                levelRequired: 1,
                category: .extensionFix,
                defaultSets: 3,
                defaultReps: 30,
                holdSeconds: 0,
                formCues: ["Pump feet forward and backward to reduce effusion."],
                videoPlaceholderSymbol: "arrow.clockwise.heart",
                isRegressionExercise: true
            )
        ]
        self.currentExerciseIndex = 0
        self.currentSet = 1
        self.currentRep = 1
        resetForCurrentExercise()
        HapticManager.flareUpAlert()
    }
    
    private func finishWorkout() {
        stopAllTimers()
        isWorkoutComplete = true
        AudioCueManager.playWorkoutComplete()
        HapticManager.gateUnlocked()
    }
    
    private func saveSessionLog() {
        let newLog = WorkoutSessionLog(
            date: Date(),
            completedExerciseIDs: completedExerciseIDs,
            durationSeconds: elapsedSeconds,
            rpeScore: Int(rpeScore),
            sessionNotes: sessionNotes,
            levelAtCompletion: profile.currentLevel,
            wasFlareUpMode: wasFlareUpMode
        )
        
        modelContext.insert(newLog)
        try? modelContext.save()
        HapticManager.repCompleted()
        dismiss()
    }
    
    private var formattedElapsed: String {
        let mins = elapsedSeconds / 60
        let secs = elapsedSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

