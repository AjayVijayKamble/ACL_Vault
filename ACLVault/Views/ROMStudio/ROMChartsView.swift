//
//  ROMChartsView.swift
//  ACLVault
//
//  Interactive Swift Charts Dual-Line Trajectory for Flexion & Extension
//

import SwiftUI
import Charts

public struct ROMChartsView: View {
    let measurements: [ROMMeasurement]
    let currentLevel: RehabLevel
    
    @State private var selectedTimeframe: Timeframe = .thirtyDays
    @State private var selectedMeasurement: ROMMeasurement? = nil
    
    public enum Timeframe: String, CaseIterable, Identifiable {
        case sevenDays = "7D"
        case thirtyDays = "30D"
        case allTime = "All"
        
        public var id: String { rawValue }
    }
    
    public init(measurements: [ROMMeasurement], currentLevel: RehabLevel) {
        self.measurements = measurements
        self.currentLevel = currentLevel
    }
    
    private var filteredMeasurements: [ROMMeasurement] {
        let sorted = measurements.sorted(by: { $0.timestamp < $1.timestamp })
        guard !sorted.isEmpty else { return [] }
        
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedTimeframe {
        case .sevenDays:
            guard let limit = calendar.date(byAdding: .day, value: -7, to: now) else { return sorted }
            return sorted.filter { $0.timestamp >= limit }
        case .thirtyDays:
            guard let limit = calendar.date(byAdding: .day, value: -30, to: now) else { return sorted }
            return sorted.filter { $0.timestamp >= limit }
        case .allTime:
            return sorted
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with Timeframe Picker
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TRAJECTORY ANALYTICS")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.recoveryTeal)
                        .tracking(1.2)
                    Text("Recovery Curve")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.vaultTextPrimary)
                }
                
                Spacer()
                
                // Segmented Picker
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(Timeframe.allCases) { tf in
                        Text(tf.rawValue).tag(tf)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }
            
            // Interactive Chart Canvas
            if filteredMeasurements.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.vaultTextMuted)
                    Text("No measurements recorded in this timeframe.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.vaultTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            } else {
                Chart {
                    // Flexion Curve
                    ForEach(filteredMeasurements) { item in
                        LineMark(
                            x: .value("Date", item.timestamp),
                            y: .value("Flexion", item.flexionDegrees)
                        )
                        .foregroundStyle(Color.recoveryTeal)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", item.timestamp),
                            y: .value("Flexion", item.flexionDegrees)
                        )
                        .foregroundStyle(Color.recoveryTeal)
                        .symbolSize(40)
                    }
                    
                    // Extension Curve
                    ForEach(filteredMeasurements) { item in
                        LineMark(
                            x: .value("Date", item.timestamp),
                            y: .value("Extension", item.extensionDegrees)
                        )
                        .foregroundStyle(Color.athleticEmerald)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", item.timestamp),
                            y: .value("Extension", item.extensionDegrees)
                        )
                        .foregroundStyle(Color.athleticEmerald)
                        .symbolSize(40)
                    }
                    
                    // Target Milestone Rules
                    RuleMark(y: .value("Target Flexion", currentLevel.minFlexionTarget))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                        .foregroundStyle(Color.recoveryTeal.opacity(0.6))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Goal: \(Int(currentLevel.minFlexionTarget))°")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.recoveryTeal)
                                .padding(2)
                                .background(Color.vaultCardElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    
                    RuleMark(y: .value("Terminal Extension", 0.0))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                        .foregroundStyle(Color.athleticEmerald.opacity(0.6))
                        .annotation(position: .bottom, alignment: .trailing) {
                            Text("Goal: 0°")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.athleticEmerald)
                                .padding(2)
                                .background(Color.vaultCardElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 30, 60, 90, 115, 135, 150]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                            .foregroundStyle(Color.vaultBorder)
                        AxisValueLabel {
                            if let deg = value.as(Double.self) {
                                Text("\(Int(deg))°")
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextMuted)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                        AxisGridLine().foregroundStyle(Color.vaultBorder.opacity(0.3))
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            .foregroundStyle(Color.vaultTextMuted)
                            .font(.system(size: 10, weight: .semibold))
                    }
                }
                .frame(height: 220)
                .padding(.vertical, 8)
            }
            
            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Circle().fill(Color.recoveryTeal).frame(width: 8, height: 8)
                    Text("Active Flexion")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.vaultTextPrimary)
                }
                
                HStack(spacing: 6) {
                    Circle().fill(Color.athleticEmerald).frame(width: 8, height: 8)
                    Text("Extension Deficit (0° = Neutral)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.vaultTextPrimary)
                }
            }
            .padding(.top, 4)
        }
        .vaultCard()
    }
}

