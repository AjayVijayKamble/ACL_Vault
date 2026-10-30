//
//  ExerciseLibraryView.swift
//  ACLVault
//
//  Complete 30+ Exercise Protocol Library with Category Filtering & Search
//

import SwiftUI
import SwiftData

@MainActor
public struct ExerciseLibraryView: View {
    @Query(sort: \Exercise.levelRequired, order: .forward) private var allExercises: [Exercise]
    
    @State private var searchKeyword: String = ""
    @State private var selectedCategory: ExerciseCategory? = nil
    @State private var selectedLevelFilter: Int? = nil
    @State private var selectedExerciseForDetail: Exercise? = nil
    
    public init() {}
    
    private var filteredExercises: [Exercise] {
        allExercises.filter { ex in
            let matchesCategory = selectedCategory == nil || ex.category == selectedCategory
            let matchesLevel = selectedLevelFilter == nil || ex.levelRequired == selectedLevelFilter
            let matchesSearch = searchKeyword.isEmpty ||
                ex.title.localizedCaseInsensitiveContains(searchKeyword) ||
                ex.targetMuscle.localizedCaseInsensitiveContains(searchKeyword)
            return matchesCategory && matchesLevel && matchesSearch
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vaultBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Category Filter Scroll View
                    categoryFilterBar
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.vaultTextMuted)
                        TextField("Search exercises, muscles, cues...", text: $searchKeyword)
                            .foregroundStyle(Color.vaultTextPrimary)
                        if !searchKeyword.isEmpty {
                            Button {
                                searchKeyword = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.vaultTextMuted)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.vaultCardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.vaultBorder, lineWidth: 1))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    
                    // Exercise List
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredExercises) { ex in
                                Button {
                                    selectedExerciseForDetail = ex
                                    HapticManager.buttonTap()
                                } label: {
                                    ExerciseCardRow(exercise: ex)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Exercise Library")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedExerciseForDetail) { ex in
                ExerciseDetailModal(exercise: ex)
            }
        }
    }
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All Category
                FilterChip(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    isSelected: selectedCategory == nil,
                    color: .recoveryTeal
                ) {
                    selectedCategory = nil
                    HapticManager.buttonTap()
                }
                
                ForEach(ExerciseCategory.allCases) { cat in
                    FilterChip(
                        title: cat.rawValue,
                        icon: cat.icon,
                        isSelected: selectedCategory == cat,
                        color: cat.accentColor
                    ) {
                        selectedCategory = cat
                        HapticManager.buttonTap()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
}

private struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? color.opacity(0.18) : Color.vaultCardSurface)
            .foregroundStyle(isSelected ? color : Color.vaultTextSecondary)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(isSelected ? color : Color.vaultBorder, lineWidth: 1)
            )
        }
    }
}

private struct ExerciseCardRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(exercise.category.accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: exercise.videoPlaceholderSymbol)
                    .font(.system(size: 18))
                    .foregroundStyle(exercise.category.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(exercise.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.vaultTextPrimary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Text("Level \(exercise.levelRequired)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.recoveryTeal)
                    
                    Text("•").foregroundStyle(Color.vaultTextMuted)
                    
                    Text(exercise.targetMuscle)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.vaultTextSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(exercise.prescriptionSummary)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.vaultTextMuted)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.vaultTextMuted)
            }
        }
        .padding(12)
        .background(Color.vaultCardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.vaultBorder, lineWidth: 1))
    }
}

