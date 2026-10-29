//
//  WorkoutSessionLog.swift
//  ACLVault
//
//  SwiftData Model for Logged Rehab Sessions
//

import Foundation
import SwiftData

@Model
public final class WorkoutSessionLog {
    public var id: UUID = UUID()
    public var date: Date = Date()
    public var completedExerciseIDs: [UUID] = []
    public var durationSeconds: Int = 0
    public var rpeScore: Int = 5 // Rate of Perceived Exertion (1 to 10)
    public var sessionNotes: String = ""
    public var levelAtCompletion: Int = 1
    public var wasFlareUpMode: Bool = false
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        completedExerciseIDs: [UUID] = [],
        durationSeconds: Int = 0,
        rpeScore: Int = 5,
        sessionNotes: String = "",
        levelAtCompletion: Int = 1,
        wasFlareUpMode: Bool = false
    ) {
        self.id = id
        self.date = date
        self.completedExerciseIDs = completedExerciseIDs
        self.durationSeconds = durationSeconds
        self.rpeScore = rpeScore
        self.sessionNotes = sessionNotes
        self.levelAtCompletion = levelAtCompletion
        self.wasFlareUpMode = wasFlareUpMode
    }
    
    public var formattedDuration: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • h:mm a"
        return formatter.string(from: date)
    }
}

