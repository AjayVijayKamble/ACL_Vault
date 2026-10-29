//
//  AngleArcView.swift
//  ACLVault
//
//  Goniometer Gauge & Arc Display for Joint Range of Motion
//

import SwiftUI

public struct AngleArcView: View {
    let degrees: Double
    var targetDegrees: Double = 135.0
    var mode: MeasurementType = .flexion
    var accentColor: Color = .recoveryTeal
    
    public enum MeasurementType {
        case flexion
        case extensionDeficit
    }
    
    public init(
        degrees: Double,
        targetDegrees: Double = 135.0,
        mode: MeasurementType = .flexion,
        accentColor: Color = .recoveryTeal
    ) {
        self.degrees = degrees
        self.targetDegrees = targetDegrees
        self.mode = mode
        self.accentColor = accentColor
    }
    
    private var progressRatio: Double {
        let maxVal = mode == .flexion ? 150.0 : 20.0
        return min(1.0, max(0.0, degrees / maxVal))
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background Arc Track
                ArcShape(startAngle: .degrees(150), endAngle: .degrees(390))
                    .stroke(Color.vaultCardElevated, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 170, height: 170)
                
                // Active Value Arc
                ArcShape(
                    startAngle: .degrees(150),
                    endAngle: .degrees(150 + (240 * progressRatio))
                )
                .stroke(
                    LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 170, height: 170)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: degrees)
                .vaultGlow(color: accentColor, radius: 8)
                
                // Centered Value
                VStack(spacing: 2) {
                    Text(String(format: "%.1f°", degrees))
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(Color.vaultTextPrimary)
                    
                    Text(mode == .flexion ? "FLEXION" : "EXTENSION")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.vaultTextSecondary)
                        .tracking(1.5)
                }
            }
            
            // Goal indicator
            HStack(spacing: 4) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(accentColor)
                Text("Target: \(Int(targetDegrees))°")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.vaultTextSecondary)
            }
        }
    }
}

// Custom Arc Shape
private struct ArcShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        return path
    }
}

