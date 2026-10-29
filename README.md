# ACL Vault — AI-Powered iOS Knee Rehab & ROM Tracker

[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0%2B-blue.svg?style=flat-square)](https://developer.apple.com/ios/)
[![Language](https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat-square)](https://swift.org)
[![Framework](https://img.shields.io/badge/SwiftUI-SwiftData-teal.svg?style=flat-square)](https://developer.apple.com/xcode/swiftdata/)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2F%20MVVM-green.svg?style=flat-square)]()

**ACL Vault** is a native, production-grade iOS application engineered with **Swift 6, SwiftUI, and SwiftData** (targeting iOS 17.0+). Designed for orthopedic patients recovering from Anterior Cruciate Ligament (ACL) reconstruction and conservative rehab, it merges hardware sensor goniometry, Apple Vision AI pose estimation, adaptive clinical AI co-piloting, criterion-based progression gates, 1-click surgeon PDF reporting, and StoreKit 2 freemium subscription architecture.

---

## 1. Design System & UI/UX Aesthetic: "Clinical Athletic"

Inspired by Whoop, Apple Fitness+, and Linear, the application runs in a dark mode aesthetic with high-contrast accessibility:

- **Deep Obsidian Background:** `#0B0F17`
- **Card Surface & Elevated Plates:** `#161C28` / `#1E2638`
- **Electric Recovery Teal:** `#00E5FF` (Active states, flexion progress, primary accents)
- **Athletic Emerald:** `#10B981` (Terminal 0° extension locked, gate milestones achieved)
- **Clinical Alerts & Pain:** Coral Amber (`#F59E0B`) and Crimson (`#EF4444`)
- **Typography & Haptics:** Rounded SF Pro system fonts with `UIImpactFeedbackGenerator` (`.rigid`, `.heavy`, `.light`) and `UINotificationFeedbackGenerator` on countdown ticks, rep completions, angle lock-ins, and gate promotions.

---

## 2. Architecture & Project Structure

```
ACLVault/
├── ACLVaultApp.swift                 # Main App entrypoint with SwiftData container & seed initializer
├── Configuration/
│   ├── Info.plist                   # NSCameraUsageDescription & NSMotionUsageDescription
│   └── Products.storekit            # StoreKit 2 testing configuration with monthly, annual, lifetime
├── Models/
│   ├── Enums.swift                  # RehabType, GraftType, LegSide, SwellingLevel, PainLocation, etc.
│   ├── UserProfile.swift            # Persistent SwiftData model with post-op day/week calculations
│   ├── ROMMeasurement.swift         # Persistent model for Flexion/Extension angle logs & methods
│   ├── DailyCheckIn.swift           # Persistent model for subjective pain, swelling sweep & location
│   ├── Exercise.swift               # Persistent model for 30+ exercises with cues, holds, sets, reps
│   ├── WorkoutSessionLog.swift      # Persistent model for completed sessions, RPE, and durations
│   └── RehabLevel.swift             # Clinical definition for all 10 return-to-sport recovery phases
├── Services/
│   ├── ProtocolSeeder.swift         # Automatically seeds 10 levels, 30+ exercises, and 30-day history
│   ├── AIPhysioService.swift        # Clinical decision engine + extensible LLM Physio Co-Pilot
│   ├── MotionManagerService.swift   # CoreMotion dual-step shin-tap goniometer + simulator mode
│   ├── PoseDetectionService.swift   # Vision VNDetectHumanBodyPoseRequest + atan2 angle calculation
│   ├── StoreKitManager.swift        # StoreKit 2 subscriptions (Monthly, Annual, Lifetime pass)
│   ├── PDFReportGenerator.swift     # ImageRenderer & PDFKit 1-click clinical summary builder
│   ├── HapticManager.swift          # Haptic feedback generator engine
│   └── AudioCueManager.swift        # Auditory sound cue engine for workouts and timer beeps
├── DesignSystem/
│   ├── ColorPalette.swift           # Hex colors and gradients
│   ├── ThemeModifiers.swift         # Reusable card modifiers and athletic button styles
│   └── Components/
│       ├── PostOpBadgeView.swift    # Prominent Day & Week counter badge
│       ├── MetricCard.swift         # Clinical metric card with goals
│       ├── CircularProgressTimer.swift # Animated circular countdown for isometric holds
│       ├── AngleArcView.swift       # Goniometer gauge & arc display
│       └── ConfettiView.swift       # Celebratory particle burst animation
└── Views/
    ├── MainTabView.swift            # 5-tab root container
    ├── Onboarding/
    │   └── OnboardingView.swift     # 5-step interactive clinical onboarding wizard
    ├── Home/
    │   ├── HomeDashboardView.swift  # Main dashboard with badge, readiness card, today's workout
    │   ├── DailyCheckInSheet.swift  # Morning subjective readiness modal
    │   ├── FlareUpAlertCard.swift   # Red caution card with deload routine trigger
    │   └── TodayWorkoutCard.swift   # Scheduled rehab session launcher
    ├── ROMStudio/
    │   ├── ROMStudioView.swift      # Studio home with engine launchers & stats
    │   ├── AICameraGoniometerView.swift # Vision camera pose tracker with draggable nudging
    │   ├── GyroscopeGoniometerView.swift # CoreMotion thigh-to-shin delta goniometer
    │   ├── ManualROMLogSheet.swift  # Direct degree input sheet
    │   └── ROMChartsView.swift      # Swift Charts dual-line trajectory with target rules
    ├── Workout/
    │   ├── WorkoutPlayerView.swift  # Guided workout player with circular timer & rest breaks
    │   ├── ExerciseDetailModal.swift# Biomechanical rationale & form cues modal
    │   └── ExerciseLibraryView.swift# 30+ exercise library with search & category filters
    ├── Progression/
    │   ├── ProgressionMapView.swift # Visual vertical roadmap (Levels 1–10)
    │   ├── GateCheckModalView.swift # Milestone verification modal with celebratory confetti
    │   └── LevelDetailSheet.swift   # Clinical criteria deep-dive modal
    └── Profile/
        ├── ProfileAndReportView.swift# Profile overview, PDF generator, and history
        ├── ClinicalPDFPreviewView.swift # PDFKit preview with native ShareLink
        └── SettingsSheet.swift      # Demo level override, flare-up simulator, API key hook
```

---

## 3. End-to-End Application Modules

### Module 1: Clinical Onboarding & Protocol Seeder
- **Wizard:** Captures patient name, surgery date, rehabilitation track (Post-Op, Prehab, Non-Operative), injured leg side, graft type (BPTB, Hamstring, Quad Tendon, Allograft, None), and meniscus repair status.
- **Top Badge Counter:** Prominently calculates and displays `Day X • Week Y` with an injured leg indicator (e.g. `R Knee`) on the navigation bar.
- **ProtocolSeeder:** On initial launch, automatically loads **all 10 Rehab Levels**, **30 medically accurate exercises** with cues, isometric hold durations, and targets, as well as **30 days of realistic historical ROM and check-in logs** so previews and analytics are immediately populated.

### Module 2: Dual-Engine Digital Goniometer
1. **Vision AI Camera Pose Mode (`PoseDetectionService`):**
   - Leverages `AVCaptureSession` and `VNDetectHumanBodyPoseRequest` to track Hip, Knee, and Ankle landmarks for the patient's operative side.
   - Computes interior joint angle $\Delta\theta$ via $\text{atan2}$ vectors:
     $$\mathbf{v}_1 = P_{\text{hip}} - P_{\text{knee}}, \quad \mathbf{v}_2 = P_{\text{ankle}} - P_{\text{knee}}$$
     $$\text{Flexion} = 180^\circ - \text{InteriorAngle}$$
   - **Crucial Draggable Precision:** After snapping or freezing, users can drag each of the 3 anchor dots (Greater Trochanter, Knee Joint Line, Lateral Malleolus) directly on screen to refine alignment down to single degrees.
   - Built-in simulation fallback mode with anatomical presets (0°, 45°, 90°, 115°, 135°) for instant Xcode Simulator testing.
2. **Gyroscope Shin-Tap Mode (`MotionManagerService`):**
   - Uses `CMMotionManager` device attitude/pitch.
   - **Step 1:** User rests phone flat on anterior femur and taps "Calibrate Thigh".
   - **Step 2:** User moves phone to anterior tibia crest and taps "Read Shin".
   - Calculates joint angle delta $\Delta = |\theta_{\text{shin}} - \theta_{\text{thigh}}|$.
   - Includes interactive slider controls when running on the Simulator.
3. **ROM Analytics Dashboard (`ROMChartsView`):**
   - Dual-line Swift Charts trajectory plotting Flexion (Teal) and Extension deficit (Emerald) over 7D, 30D, and All-Time with dashed milestone target markers based on the patient's current level.

### Module 3: Daily AI Physio Co-Pilot & Workout Player
- **Morning Readiness Check-In:** Pain slider (0–10), joint effusion sweep rating (None, Mild, Moderate, Severe), and pain location picker.
- **AI Decision Engine (`AIPhysioService`):**
  - Clinical heuristic: If `painScore >= 6` or `swellingLevel == .severe`, automatically triggers **"Flare-Up Recovery Mode"**—swapping high-load quad exercises for Quad Sets, 0° Heel Props, Ankle Pumps, and 15-minute Ice/Elevation intervals.
  - Meniscus Rule: Restricts flexion to $\le 90^\circ$ for early post-op weeks if meniscus repair was performed.
  - Graft Precautions: BPTB (anterior patellar tendon protection), Hamstring (resisted flexion cautions), Quad Tendon (overcoming AMI).
  - Extensible `LLMPhysioClient` protocol with deterministic on-device fallback and clean hook for Google Gemini API key.
- **Interactive Workout Player (`WorkoutPlayerView`):**
  - Animated `CircularProgressTimer` for isometric holds (e.g. 10s quad sets) and rest breaks.
  - Audio and haptic ticks on countdown (3, 2, 1) and completion chimes.
  - "Flag Pain" modal to instantly swap into deload mode.
  - "Swap Exercise" modal to pick gentle alternatives.
  - Session completion summary with RPE rating, notes, and SwiftData session logging.

### Module 4: 10-Level Progression Map & Gate Check
- 10 criterion-based phases based on Delaware-Oslo and Melbourne Return to Sport guidelines:
  1. *Quiet the Knee & Terminal Extension* (Weeks 0–2)
  2. *Normal Gait & Kinetic Chain Initiation* (Weeks 2–4)
  3. *Early Closed Chain & Balance* (Weeks 4–8)
  4. *Symmetrical Hypertrophy & Joint Health* (Weeks 8–12)
  5. *Unilateral Strength & Eccentric Control* (Weeks 12–16)
  6. *Introductory Plyometrics & Jogging* (Weeks 16–20)
  7. *Unilateral Power & Hop Battery* (Weeks 20–24)
  8. *Multi-Planar Agility & Deceleration* (Weeks 24–30)
  9. *Sport-Specific Reactive Training* (Weeks 30–36)
  10. *Unrestricted Return to Competition* (Weeks 36–52+)
- Visual vertical roadmap with status nodes (Completed, In Progress, Locked).
- Interactive **"Take Level Gate Test"** modal with clinical checklists and celebratory particle confetti (`ConfettiView`).

### Module 5: 1-Click Surgeon & PT PDF Report Generator
- Built with SwiftUI `ImageRenderer` and `PDFKit`.
- Generates a clinical 1-page summary: Patient demographics, graft type, post-op day/week, 30-day ROM trajectory chart, average pain & swelling scores, compliance %, current level milestones, and PT/Surgeon signature line.
- Native `ShareLink` allows immediate AirDrop, email, or wireless printing during clinic appointments.

### Module 6: StoreKit 2 Paywall
- High-converting freemium pricing:
  - **Monthly Pro:** $6.99/mo
  - **Full 12-Month Recovery (Annual):** $39.99/yr ($3.33/mo, Best Value 52% off)
  - **Lifetime Recovery Pass:** $59.99 one-time payment
- Full StoreKit 2 transaction verification, receipt restoration, feature matrix comparison, and demo unlock toggle.

---

## 4. Simulator & Developer Testing Controls

To test any recovery phase or scenario without waiting weeks:
1. Open the **Profile** tab (or tap the slider icon in the top right of the **Home** tab) to open **Settings & Simulator Controls**.
2. **Rehab Level Stepper:** Shift between Levels 1 through 10 to instantly view changes in today's workout, gate criteria, and chart milestone goals.
3. **Simulate Flare-Up Mode:** Toggle this switch to immediately turn the dashboard into red Flare-Up Deload mode.
4. **ACL Vault Pro Status:** Toggle Pro access on/off to test paywall gating.
5. **Simulated Goniometer Presets:** In the AI Camera or Gyroscope views, tap the degree preset buttons (`0°`, `45°`, `90°`, `115°`, `135°`) or drag the sliders to test hardware reading behavior in the Simulator.

---

## 5. Building & Running in Xcode

1. Open the project in **Xcode 15.0+** (or generate `.xcodeproj` via `xcodegen generate` using `project.yml`).
2. Select target **ACLVault** and choose any iOS 17+ Simulator (e.g., iPhone 15 Pro, iPhone 16).
3. Build and Run (`⌘R`).
4. In Xcode's Scheme Editor, under **Run > Options > StoreKit Configuration**, select `Products.storekit` located in `ACLVault/Configuration/` to test StoreKit 2 in-app purchases locally.

