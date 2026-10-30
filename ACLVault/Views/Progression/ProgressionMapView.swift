//
//  ProgressionMapView.swift
//  ACLVault
//
//  Visual 10-Level Clinical Vertical Progression Map & Gate Check Engine
//

import SwiftUI
import SwiftData

@MainActor
public struct ProgressionMapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    
    @State private var selectedLevelForDetail: RehabLevel? = nil
    @State private var levelForGateTest: RehabLevel? = nil
    
    private var profile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vaultBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header Banner
                        headerBanner
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                        
                        // 10-Level Vertical Roadmap
                        VStack(spacing: 0) {
                            ForEach(ProtocolLevels.allLevels) { lvl in
                                LevelMapNodeRow(
                                    level: lvl,
                                    userLevel: profile.currentLevel,
                                    isLast: lvl.level == ProtocolLevels.allLevels.count,
                                    onSelectLevel: {
                                        selectedLevelForDetail = lvl
                                        HapticManager.buttonTap()
                                    },
                                    onTakeGateTest: {
                                        levelForGateTest = lvl
                                        HapticManager.buttonTap()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("10-Phase Progression")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedLevelForDetail) { lvl in
                LevelDetailSheet(
                    level: lvl,
                    profile: profile,
                    onOpenGateCheck: {
                        levelForGateTest = lvl
                    }
                )
            }
            .fullScreenCover(item: $levelForGateTest) { lvl in
                GateCheckModalView(
                    level: lvl,
                    profile: profile,
                    onLevelAdvanced: {
                        // State automatically reflected via @Query
                    }
                )
            }
        }
    }
    
    // MARK: - Header Banner
    private var headerBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("CLINICAL PROTOCOL ROADMAP")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.recoveryTeal)
                    .tracking(1.5)
                Spacer()
                Text("Current: Level \(profile.currentLevel) / 10")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.athleticEmerald)
            }
            
            Text("Criterion-Based Return to Sport")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(Color.vaultTextPrimary)
            
            Text("Time alone does not heal ligaments. Progress is unlocked strictly by passing objective joint range, swelling limits, and neuromuscular gate criteria.")
                .font(.system(size: 13))
                .foregroundStyle(Color.vaultTextSecondary)
                .lineSpacing(2)
            
            // Overall completion progress bar
            let progress = Double(profile.currentLevel - 1) / 9.0
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.vaultCardElevated).frame(height: 6)
                    Capsule().fill(LinearGradient.tealGlow).frame(width: geo.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
            .padding(.top, 4)
        }
        .vaultCard()
    }
}

// MARK: - Single Node Row on the Vertical Map
private struct LevelMapNodeRow: View {
    let level: RehabLevel
    let userLevel: Int
    let isLast: Bool
    let onSelectLevel: () -> Void
    let onTakeGateTest: () -> Void
    
    private var status: LevelStatus {
        level.status(userLevel: userLevel)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Left Node & Vertical Connector Line
            VStack(spacing: 0) {
                // Circle Node
                Button(action: onSelectLevel) {
                    ZStack {
                        Circle()
                            .fill(nodeBackgroundColor)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle().stroke(nodeBorderColor, lineWidth: status == .inProgress ? 3 : 1.5)
                            )
                            .vaultGlow(color: status == .inProgress ? Color.recoveryTeal : Color.clear, radius: 8)
                        
                        if status == .completed {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .black))
                                .foregroundStyle(Color.black)
                        } else if status == .inProgress {
                            Text("\(level.level)")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(Color.black)
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.vaultTextMuted)
                        }
                    }
                }
                
                // Connector line to next node
                if !isLast {
                    Rectangle()
                        .fill(connectorLineColor)
                        .frame(width: 3)
                        .frame(minHeight: 110)
                }
            }
            
            // Right Level Information Card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(level.timeline.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(status == .inProgress ? Color.recoveryTeal : Color.vaultTextMuted)
                        
                        Text("Level \(level.level): \(level.title)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.vaultTextPrimary)
                    }
                    
                    Spacer()
                    
                    Text(status.rawValue)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(status.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(status.color.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Text(level.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.vaultTextSecondary)
                    .lineLimit(2)
                
                // Clinical Targets Snippet
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.and.down")
                            .font(.system(size: 10))
                        Text("Flex: \(Int(level.minFlexionTarget))°")
                    }
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.recoveryTeal)
                    
                    Text("•").foregroundStyle(Color.vaultTextMuted)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left.and.right")
                            .font(.system(size: 10))
                        Text("Ext: 0°")
                    }
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.athleticEmerald)
                }
                
                // If this is the active in-progress level: show "Take Gate Test" action
                if status == .inProgress {
                    Button(action: onTakeGateTest) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Take Level \(level.level) Gate Test")
                        }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .buttonStyle(VaultPrimaryButtonStyle(accentColor: .athleticEmerald))
                    .padding(.top, 4)
                }
            }
            .padding(14)
            .background(status == .inProgress ? Color.vaultCardElevated : Color.vaultCardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(status == .inProgress ? Color.recoveryTeal : Color.vaultBorder.opacity(0.6), lineWidth: 1)
            )
            .onTapGesture(perform: onSelectLevel)
            .padding(.bottom, isLast ? 0 : 20)
        }
    }
    
    private var nodeBackgroundColor: Color {
        switch status {
        case .completed:
            return .athleticEmerald
        case .inProgress:
            return .recoveryTeal
        case .locked:
            return .vaultCardElevated
        }
    }
    
    private var nodeBorderColor: Color {
        switch status {
        case .completed:
            return .athleticEmerald
        case .inProgress:
            return .recoveryTeal
        case .locked:
            return .vaultBorder
        }
    }
    
    private var connectorLineColor: Color {
        if userLevel > level.level {
            return .athleticEmerald
        } else if userLevel == level.level {
            return .recoveryTeal.opacity(0.6)
        } else {
            return .vaultBorder.opacity(0.4)
        }
    }
}

