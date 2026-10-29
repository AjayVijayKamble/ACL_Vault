//
//  DailyCheckIn.swift
//  ACLVault
//
//  SwiftData Model for Daily Subjective Readiness & AI Assessment
//

import Foundation
import SwiftData

@Model
public final class DailyCheckIn {
    public var id: UUID = UUID()
    public var date: Date = Date()
    public var painScore: Int = 2 // 0 to 10
    public var swellingLevelRaw: String = SwellingLevel.mild.rawValue
    public var painLocationRaw: String = PainLocation.anterior.rawValue
    public var aiAdjustmentSummary: String = ""
    public var recommendedModeRaw: String = "Normal" // "Normal", "FlareUpRecovery", "ActiveProgression"
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        painScore: Int = 2,
        swellingLevel: SwellingLevel = .mild,
        painLocation: PainLocation = .anterior,
        aiAdjustmentSummary: String = "",
        recommendedMode: String = "Normal"
    ) {
        self.id = id
        self.date = date
        self.painScore = painScore
        self.swellingLevelRaw = swellingLevel.rawValue
        self.painLocationRaw = painLocation.rawValue
        self.aiAdjustmentSummary = aiAdjustmentSummary
        self.recommendedModeRaw = recommendedMode
    }
    
    public var swellingLevel: SwellingLevel {
        get { SwellingLevel(rawValue: swellingLevelRaw) ?? .mild }
        set { swellingLevelRaw = newValue.rawValue }
    }
    
    public var painLocation: PainLocation {
        get { PainLocation(rawValue: painLocationRaw) ?? .anterior }
        set { painLocationRaw = newValue.rawValue }
    }
    
    public var isFlareUp: Bool {
        return painScore >= 6 || swellingLevel == .severe
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}

