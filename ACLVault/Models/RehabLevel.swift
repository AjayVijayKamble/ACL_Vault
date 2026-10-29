//
//  RehabLevel.swift
//  ACLVault
//
//  10-Level Clinical ACL Progression Hierarchy & Gate Check Criteria
//

import Foundation
import SwiftUI

public struct RehabLevel: Identifiable, Hashable, Sendable {
    public let level: Int
    public let title: String
    public let subtitle: String
    public let timeline: String
    public let clinicalFocus: String
    public let minExtensionTarget: Double // degrees (0.0 or lower is full extension)
    public let minFlexionTarget: Double // degrees
    public let maxAllowedSwelling: SwellingLevel
    public let requiredCompliancePercent: Int
    public let gateCriteria: [String]
    public let primaryExercisesSummary: [String]
    public let iconSymbol: String
    public let badgeColor: Color
    
    public var id: Int { level }
    
    // Status relative to user's current level
    public func status(userLevel: Int) -> LevelStatus {
        if userLevel > level {
            return .completed
        } else if userLevel == level {
            return .inProgress
        } else {
            return .locked
        }
    }
}

public enum LevelStatus: String {
    case completed = "Mastered"
    case inProgress = "Current Focus"
    case locked = "Locked Phase"
    
    public var icon: String {
        switch self {
        case .completed: return "checkmark.seal.fill"
        case .inProgress: return "flame.fill"
        case .locked: return "lock.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .completed: return .athleticEmerald
        case .inProgress: return .recoveryTeal
        case .locked: return .vaultTextMuted
        }
    }
}

// MARK: - Official 10-Level Protocol Hierarchy
public enum ProtocolLevels {
    public static let allLevels: [RehabLevel] = [
        RehabLevel(
            level: 1,
            title: "Quiet the Knee & Terminal Extension",
            subtitle: "Phase 1: Protection & Early Activation",
            timeline: "Weeks 0–2",
            clinicalFocus: "Eliminate joint effusion, regain 0° passive extension (preventing cyclops lesion), and wake up the inhibited VMO.",
            minExtensionTarget: 0.0,
            minFlexionTarget: 90.0,
            maxAllowedSwelling: .moderate,
            requiredCompliancePercent: 75,
            gateCriteria: [
                "Full passive terminal extension (0° or matched hyperextension)",
                "Flexion >= 90° (unless early meniscus repair protocol specifies otherwise)",
                "No extensor lag during Straight Leg Raise (SLR)",
                "Superior/inferior patellar mobility restored without adhesions"
            ],
            primaryExercisesSummary: ["Prone Hangs", "Quad Sets", "Heel Slides", "Straight Leg Raises"],
            iconSymbol: "cross.vial.fill",
            badgeColor: .recoveryTeal
        ),
        RehabLevel(
            level: 2,
            title: "Normal Gait & Kinetic Chain Initiation",
            subtitle: "Phase 2: Full Weight Bearing & Active Flexion",
            timeline: "Weeks 2–4",
            clinicalFocus: "Wean from crutches with symmetrical heel-strike gait, prevent stiff-knee walking, and advance to 110° flexion.",
            minExtensionTarget: 0.0,
            minFlexionTarget: 110.0,
            maxAllowedSwelling: .mild,
            requiredCompliancePercent: 80,
            gateCriteria: [
                "Symmetrical gait pattern without crutches or antalgic limp",
                "Active flexion >= 110°",
                "Extension maintained at 0° after weight-bearing",
                "Able to perform 20 continuous unassisted straight leg raises"
            ],
            primaryExercisesSummary: ["Stationary Bike Rocking", "Terminal Knee Extensions", "Wall Slides", "Calf Raises"],
            iconSymbol: "figure.walk",
            badgeColor: .athleticEmerald
        ),
        RehabLevel(
            level: 3,
            title: "Early Closed Chain & Balance",
            subtitle: "Phase 3: Neuromuscular Foundations",
            timeline: "Weeks 4–8",
            clinicalFocus: "Re-establish joint position sense, load hips and hamstrings, advance full revolution cycling.",
            minExtensionTarget: 0.0,
            minFlexionTarget: 125.0,
            maxAllowedSwelling: .mild,
            requiredCompliancePercent: 80,
            gateCriteria: [
                "Flexion >= 125°",
                "Continuous 360° revolutions on stationary cycle without elevation",
                "Single leg static stance > 30 seconds with stable pelvis",
                "Trace/Mild effusion only (+1 sweep maximum)"
            ],
            primaryExercisesSummary: ["Bodyweight Squats to 60°", "Single Leg Balance", "Glute Bridges", "Step-Ups"],
            iconSymbol: "figure.gymnastics",
            badgeColor: Color(hex: "38BDF8")
        ),
        RehabLevel(
            level: 4,
            title: "Symmetrical Hypertrophy & Joint Health",
            subtitle: "Phase 4: Bilateral Strength Loading",
            timeline: "Weeks 8–12",
            clinicalFocus: "Build foundational quadriceps and hamstring muscle bulk while protecting graft revascularization stage.",
            minExtensionTarget: 0.0,
            minFlexionTarget: 135.0,
            maxAllowedSwelling: .none,
            requiredCompliancePercent: 85,
            gateCriteria: [
                "Full anatomical flexion matching non-injured limb (>= 135°)",
                "Leg Press strength >= 70% of healthy leg",
                "Y-Balance test anterior reach within 8cm symmetry",
                "Zero swelling flare after 30 minutes of brisk treadmill walking"
            ],
            primaryExercisesSummary: ["Leg Press", "Romanian Deadlifts", "Step-Downs", "Monster Band Walks"],
            iconSymbol: "dumbbell.fill",
            badgeColor: .clinicalPurple
        ),
        RehabLevel(
            level: 5,
            title: "Unilateral Strength & Eccentric Control",
            subtitle: "Phase 5: Single Leg Mastery",
            timeline: "Weeks 12–16",
            clinicalFocus: "Eliminate inter-limb asymmetry through single-leg loaded squats and hamstring eccentrics.",
            minExtensionTarget: 0.0,
            minFlexionTarget: 135.0,
            maxAllowedSwelling: .none,
            requiredCompliancePercent: 85,
            gateCriteria: [
                "Single-Leg Squat to 60° without dynamic knee valgus collapse",
                "Limb Symmetry Index (LSI) >= 75% on quadriceps dynamometer / 1RM",
                "Hamstring to Quad (H:Q) strength ratio > 60%",
                "Pain-free fast walking on 5% incline"
            ],
            primaryExercisesSummary: ["Bulgarian Split Squats", "Nordic Hamstring Curls", "Single Leg Romanian Deadlift"],
            iconSymbol: "scalemass.fill",
            badgeColor: .coralAmber
        ),
        RehabLevel(
            level: 6,
            title: "Introductory Plyometrics & Jogging",
            subtitle: "Phase 6: Impact & Return to Running",
            timeline: "Weeks 16–20",
            clinicalFocus: "Tolerate repeated impact loading. Begin linear jog-walk progression on track or treadmill.",
            minExtensionTarget: 0.0,
            minFlexionTarget: 135.0,
            maxAllowedSwelling: .none,
            requiredCompliancePercent: 85,
            gateCriteria: [
                "Quadriceps Limb Symmetry Index >= 80%",
                "Symmetrical bilateral drop-jump landing mechanics with high damping",
                "Pass 10-minute continuous jog test without joint effusion",
                "Complete 30 continuous single-leg calf raises"
            ],
            primaryExercisesSummary: ["Linear Jog Intervals", "Pogo Hops", "Box Drop Landings", "Treadmill Intervals"],
            iconSymbol: "figure.run",
            badgeColor: Color(hex: "F43F5E")
        ),
        RehabLevel(
            level: 7,
            title: "Unilateral Power & Hop Battery",
            subtitle: "Phase 7: Dynamic Propulsion & Landing",
            timeline: "Weeks 20–24",
            clinicalFocus: "Equalize single-leg elastic power and deceleration absorption across official hop tests.",
            minExtensionTarget: 0.0,
            minFlexionTarget: 135.0,
            maxAllowedSwelling: .none,
            requiredCompliancePercent: 85,
            gateCriteria: [
                "Single Hop for Distance: LSI >= 85%",
                "Triple Hop for Distance: LSI >= 85%",
                "Crossover Hop for Distance: LSI >= 85%",
                "6-Meter Timed Hop: LSI >= 85%"
            ],
            primaryExercisesSummary: ["Single Leg Bound & Stick", "Lateral Skater Hops", "Trap Bar Deadlifts", "Depth Jumps"],
            iconSymbol: "bolt.heart.fill",
            badgeColor: .recoveryTeal
        ),
        RehabLevel(
            level: 8,
            title: "Multi-Planar Agility & Deceleration",
            subtitle: "Phase 8: Controlled Cutting & Shuffling",
            timeline: "Weeks 24–30",
            clinicalFocus: "Train plant-and-cut mechanics, lateral shuffling, and sudden deceleration stopping force.",
            minExtensionTarget: 0.0,
            minFlexionTarget: 135.0,
            maxAllowedSwelling: .none,
            requiredCompliancePercent: 90,
            gateCriteria: [
                "Pro Agility 5-10-5 drill with symmetrical turn times (<0.2s delta)",
                "T-Test completion within clinical age/sport norms",
                "Zero dynamic valgus observed on 90° plant-and-cut maneuvers",
                "No subjective knee instability or 'giving way' sensations"
            ],
            primaryExercisesSummary: ["Pro Agility 5-10-5", "Figure-8 Sprints", "Deceleration Brake Drills", "Medicine Ball Throws"],
            iconSymbol: "arrow.triangle.swap",
            badgeColor: .athleticEmerald
        ),
        RehabLevel(
            level: 9,
            title: "Sport-Specific Reactive Training",
            subtitle: "Phase 9: Unanticipated Drills & Confidence",
            timeline: "Weeks 30–36",
            clinicalFocus: "Transition from pre-planned cuts to chaotic, visual/auditory stimulus-guided evasion and drills.",
            minExtensionTarget: 0.0,
            minFlexionTarget: 135.0,
            maxAllowedSwelling: .none,
            requiredCompliancePercent: 90,
            gateCriteria: [
                "ACL-RSI (Return to Sport Index) psychological readiness score >= 65",
                "Flawless execution of coach/light-prompted reactive cutting drills",
                "Participation in non-contact team/practice drills",
                "Limb Symmetry Index >= 90% across all strength & power tests"
            ],
            primaryExercisesSummary: ["Reactive Light/Callout Cuts", "Sport Ball Handling Drills", "Fatigued Deceleration Sets"],
            iconSymbol: "sportscourt.fill",
            badgeColor: Color(hex: "E11D48")
        ),
        RehabLevel(
            level: 10,
            title: "Unrestricted Return to Competition",
            subtitle: "Phase 10: Clearance & Long-Term Durability",
            timeline: "Weeks 36–52+",
            clinicalFocus: "Full physical and psychological clearance for live game contact competition with re-injury risk reduction.",
            minExtensionTarget: 0.0,
            minFlexionTarget: 135.0,
            maxAllowedSwelling: .none,
            requiredCompliancePercent: 90,
            gateCriteria: [
                "Limb Symmetry Index >= 95% on Isokinetic Quad/Hamstring Dynamometer",
                "Hop test battery LSI >= 95% with pristine biomechanical symmetry",
                "ACL-RSI score >= 75 (psychological readiness)",
                "Formal clearance from Orthopedic Surgeon and Physical Therapist"
            ],
            primaryExercisesSummary: ["Live Scrimmage Simulation", "Full Contact Drills", "Pre-Season Conditioning"],
            iconSymbol: "trophy.fill",
            badgeColor: Color(hex: "F59E0B")
        )
    ]
    
    public static func level(for number: Int) -> RehabLevel {
        return allLevels.first(where: { $0.level == number }) ?? allLevels[0]
    }
}

