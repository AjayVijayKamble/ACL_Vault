//
//  UserProfile.swift
//  ACLVault
//
//  SwiftData Model for User Clinical Profile
//

import Foundation
import SwiftData

@Model
public final class UserProfile {
    public var id: UUID = UUID()
    public var name: String = "ACL Warrior"
    public var surgeryDate: Date = Date()
    public var rehabStageRaw: String = RehabType.postOp.rawValue
    public var graftTypeRaw: String = GraftType.patellar.rawValue
    public var meniscusRepair: Bool = false
    public var injuredSideRaw: String = LegSide.right.rawValue
    public var currentLevel: Int = 1
    public var isProSubscriber: Bool = false
    public var hasCompletedOnboarding: Bool = false
    public var createdAt: Date = Date()
    
    // Non-persisted simulation flags for demo testing
    @Transient public var simulateFlareUp: Bool = false
    
    public init(
        id: UUID = UUID(),
        name: String = "ACL Warrior",
        surgeryDate: Date = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
        rehabStage: RehabType = .postOp,
        graftType: GraftType = .patellar,
        meniscusRepair: Bool = false,
        injuredSide: LegSide = .right,
        currentLevel: Int = 1,
        isProSubscriber: Bool = false,
        hasCompletedOnboarding: Bool = false
    ) {
        self.id = id
        self.name = name
        self.surgeryDate = surgeryDate
        self.rehabStageRaw = rehabStage.rawValue
        self.graftTypeRaw = graftType.rawValue
        self.meniscusRepair = meniscusRepair
        self.injuredSideRaw = injuredSide.rawValue
        self.currentLevel = currentLevel
        self.isProSubscriber = isProSubscriber
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.createdAt = Date()
    }
    
    // MARK: - Typed Enums
    public var rehabStage: RehabType {
        get { RehabType(rawValue: rehabStageRaw) ?? .postOp }
        set { rehabStageRaw = newValue.rawValue }
    }
    
    public var graftType: GraftType {
        get { GraftType(rawValue: graftTypeRaw) ?? .patellar }
        set { graftTypeRaw = newValue.rawValue }
    }
    
    public var injuredSide: LegSide {
        get { LegSide(rawValue: injuredSideRaw) ?? .right }
        set { injuredSideRaw = newValue.rawValue }
    }
    
    // MARK: - Computed Clinical Metrics
    public var daysPostOp: Int {
        let calendar = Calendar.current
        let startOfSurgery = calendar.startOfDay(for: surgeryDate)
        let startOfToday = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: startOfSurgery, to: startOfToday)
        return max(0, components.day ?? 0)
    }
    
    public var weeksPostOp: Int {
        return (daysPostOp / 7) + 1
    }
    
    public var postOpBadgeText: String {
        switch rehabStage {
        case .prehab:
            return "Pre-Op Prep"
        case .postOp:
            return "Day \(daysPostOp) • Week \(weeksPostOp)"
        case .nonSurgical:
            return "Week \(weeksPostOp) Conservative"
        }
    }
    
    public var safeFlexionLimit: Double? {
        // Clinical rule: Meniscus root/radial repair limits flexion to <= 90° for first 4-6 weeks
        if meniscusRepair && daysPostOp < 42 {
            return 90.0
        }
        return nil
    }
}

