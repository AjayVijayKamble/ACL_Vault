//
//  ExerciseDetailModal.swift
//  ACLVault
//
//  Clinical Form Cues & Biomechanical Instructions Modal
//

import SwiftUI

public struct ExerciseDetailModal: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise
    
    public init(exercise: Exercise) {
        self.exercise = exercise
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vaultBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title & Category Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(exercise.category.rawValue.uppercased())
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(exercise.category.accentColor)
                                    .tracking(1.5)
                                
                                Spacer()
                                
                                Text("Level \(exercise.levelRequired)")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextMuted)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.vaultCardElevated)
                                    .clipShape(Capsule())
                            }
                            
                            Text(exercise.title)
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundStyle(Color.vaultTextPrimary)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "target")
                                    .font(.system(size: 12))
                                    .foregroundStyle(exercise.category.accentColor)
                                Text("Target: \(exercise.targetMuscle)")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextSecondary)
                            }
                        }
                        
                        // Clinical Prescription
                        HStack(spacing: 12) {
                            PrescriptionBox(title: "SETS", value: "\(exercise.defaultSets)")
                            PrescriptionBox(title: "REPS", value: "\(exercise.defaultReps)")
                            PrescriptionBox(title: "HOLD", value: exercise.isIsometric ? "\(exercise.holdSeconds)s" : "Dynamic")
                        }
                        
                        // Clinical Rationale Card
                        if !exercise.clinicalRationale.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 6) {
                                    Image(systemName: "stethoscope")
                                        .foregroundStyle(Color.recoveryTeal)
                                    Text("CLINICAL RATIONALE")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.recoveryTeal)
                                }
                                Text(exercise.clinicalRationale)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.vaultTextPrimary)
                                    .lineSpacing(2)
                            }
                            .vaultCard(borderColor: Color.recoveryTeal.opacity(0.3))
                        }
                        
                        // Step-by-Step Form Cues
                        VStack(alignment: .leading, spacing: 12) {
                            Text("STEP-BY-STEP FORM CUES")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextMuted)
                                .tracking(1.2)
                            
                            VStack(spacing: 10) {
                                ForEach(Array(exercise.formCues.enumerated()), id: \.offset) { index, cue in
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("\(index + 1)")
                                            .font(.system(size: 12, weight: .black, design: .rounded))
                                            .foregroundStyle(Color.black)
                                            .frame(width: 22, height: 22)
                                            .background(exercise.category.accentColor)
                                            .clipShape(Circle())
                                        
                                        Text(cue)
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.vaultTextPrimary)
                                            .lineSpacing(2)
                                        
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.vaultCardSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.vaultBorder, lineWidth: 1))
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Exercise Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.recoveryTeal)
                }
            }
        }
    }
}

private struct PrescriptionBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Color.vaultTextMuted)
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(Color.vaultTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.vaultCardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.vaultBorder, lineWidth: 1))
    }
}

