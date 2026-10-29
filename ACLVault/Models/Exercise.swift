//
//  Exercise.swift
//  ACLVault
//
//  SwiftData Model for ACL Rehabilitation Exercises
//

import Foundation
import SwiftData

@Model
public final class Exercise {
    public var id: UUID = UUID()
    public var title: String = ""
    public var levelRequired: Int = 1
    public var categoryRaw: String = ExerciseCategory.extensionFix.rawValue
    public var defaultSets: Int = 3
    public var defaultReps: Int = 10
    public var holdSeconds: Int = 0
    public var formCues: [String] = []
    public var videoPlaceholderSymbol: String = "figure.walk"
    public var isRegressionExercise: Bool = false
    public var targetMuscle: String = "Quadriceps"
    public var clinicalRationale: String = ""
    
    public init(
        id: UUID = UUID(),
        title: String,
        levelRequired: Int,
        category: ExerciseCategory,
        defaultSets: Int,
        defaultReps: Int,
        holdSeconds: Int = 0,
        formCues: [String] = [],
        videoPlaceholderSymbol: String = "figure.walk",
        isRegressionExercise: Bool = false,
        targetMuscle: String = "Quadriceps",
        clinicalRationale: String = ""
    ) {
        self.id = id
        self.title = title
        self.levelRequired = levelRequired
        self.categoryRaw = category.rawValue
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.holdSeconds = holdSeconds
        self.formCues = formCues
        self.videoPlaceholderSymbol = videoPlaceholderSymbol
        self.isRegressionExercise = isRegressionExercise
        self.targetMuscle = targetMuscle
        self.clinicalRationale = clinicalRationale
    }
    
    public var category: ExerciseCategory {
        get { ExerciseCategory(rawValue: categoryRaw) ?? .extensionFix }
        set { categoryRaw = newValue.rawValue }
    }
    
    public var isIsometric: Bool {
        return holdSeconds > 0
    }
    
    public var prescriptionSummary: String {
        if isIsometric {
            return "\(defaultSets) sets × \(defaultReps) reps (\(holdSeconds)s hold)"
        } else {
            return "\(defaultSets) sets × \(defaultReps) reps"
        }
    }
}

