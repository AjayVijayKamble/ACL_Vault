//
//  Enums.swift
//  ACLVault
//
//  Domain Enums for ACL Rehab Protocol
//

import Foundation
import SwiftUI

// MARK: - Rehab Stage / Type
public enum RehabType: String, Codable, CaseIterable, Identifiable {
    case prehab = "Prehab (Pre-Op)"
    case postOp = "Post-Surgical"
    case nonSurgical = "Non-Operative"
    
    public var id: String { rawValue }
    
    public var description: String {
        switch self {
        case .prehab:
            return "Pre-surgery strengthening & swelling reduction"
        case .postOp:
            return "Post-operative ligament reconstruction recovery"
        case .nonSurgical:
            return "Conservative non-operative physical therapy track"
        }
    }
}

// MARK: - Graft Type
public enum GraftType: String, Codable, CaseIterable, Identifiable {
    case patellar = "Bone-Patellar Tendon-Bone (BPTB)"
    case hamstring = "Hamstring Autograft"
    case quad = "Quadriceps Tendon Autograft"
    case allograft = "Donor Allograft"
    case none = "None / Conservative"
    
    public var id: String { rawValue }
    
    public var shortName: String {
        switch self {
        case .patellar: return "BPTB"
        case .hamstring: return "Hamstring"
        case .quad: return "Quad Tendon"
        case .allograft: return "Allograft"
        case .none: return "No Graft"
        }
    }
    
    public var clinicalNotes: String {
        switch self {
        case .patellar:
            return "High donor site anterior knee sensitivity. Avoid heavy loaded patellar tendon contact until week 8+."
        case .hamstring:
            return "Hamstrings harvesting site vulnerable to strain. Avoid aggressive active hamstring curls before week 6."
        case .quad:
            return "Significant quad inhibition early. Aggressive quadriceps re-activation and electrical stimulation recommended."
        case .allograft:
            return "Longer biological incorporation window. Slower cellular remodelling—strict compliance required."
        case .none:
            return "Conservative management targeting neuromuscular stabilization and dynamic valgus prevention."
        }
    }
}

// MARK: - Injured Leg Side
public enum LegSide: String, Codable, CaseIterable, Identifiable {
    case left = "Left Knee"
    case right = "Right Knee"
    
    public var id: String { rawValue }
    
    public var shortCode: String {
        switch self {
        case .left: return "L"
        case .right: return "R"
        }
    }
}

// MARK: - Swelling Level
public enum SwellingLevel: String, Codable, CaseIterable, Identifiable, Comparable {
    case none = "None (Trace)"
    case mild = "Mild (+1 Sweep)"
    case moderate = "Moderate (+2 Sweep)"
    case severe = "Severe (+3 Tense Joint)"
    
    public var id: String { rawValue }
    
    public var severityScore: Int {
        switch self {
        case .none: return 0
        case .mild: return 1
        case .moderate: return 2
        case .severe: return 3
        }
    }
    
    public static func < (lhs: SwellingLevel, rhs: SwellingLevel) -> Bool {
        lhs.severityScore < rhs.severityScore
    }
    
    public var badgeColor: Color {
        switch self {
        case .none: return .athleticEmerald
        case .mild: return .recoveryTeal
        case .moderate: return .coralAmber
        case .severe: return .clinicalCrimson
        }
    }
}

// MARK: - Pain Location
public enum PainLocation: String, Codable, CaseIterable, Identifiable {
    case anterior = "Anterior (Front/Patella)"
    case medial = "Medial (Inside Joint Line)"
    case lateral = "Lateral (Outside Joint Line)"
    case posterior = "Posterior (Back of Knee/Popliteal)"
    case graftSite = "Graft Harvest Site"
    case generalized = "Generalized Joint Ache"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .anterior: return "circle.circle.fill"
        case .medial: return "arrow.left.circle.fill"
        case .lateral: return "arrow.right.circle.fill"
        case .posterior: return "arrow.down.circle.fill"
        case .graftSite: return "cross.case.fill"
        case .generalized: return "waveform.path.ecg"
        }
    }
}

// MARK: - Measurement Method
public enum MeasurementMethod: String, Codable, CaseIterable, Identifiable {
    case aiCamera = "AI Camera Pose"
    case gyroscope = "Gyroscope Shin-Tap"
    case manual = "Manual Input"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .aiCamera: return "camera.viewfinder"
        case .gyroscope: return "gyroscope"
        case .manual: return "hand.tap"
        }
    }
}

// MARK: - Exercise Category
public enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case extensionFix = "Extension"
    case flexionGain = "Flexion"
    case quadActivation = "Quad Activation"
    case strength = "Strength"
    case balance = "Balance & Neuromuscular"
    case plyometrics = "Plyometrics & Agility"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .extensionFix: return "arrow.left.and.right"
        case .flexionGain: return "arrow.up.and.down"
        case .quadActivation: return "bolt.fill"
        case .strength: return "dumbbell.fill"
        case .balance: return "figure.gymnastics"
        case .plyometrics: return "figure.run"
        }
    }
    
    public var accentColor: Color {
        switch self {
        case .extensionFix: return .athleticEmerald
        case .flexionGain: return .recoveryTeal
        case .quadActivation: return .coralAmber
        case .strength: return Color(hex: "38BDF8")
        case .balance: return .clinicalPurple
        case .plyometrics: return Color(hex: "F43F5E")
        }
    }
}

