//
//  CircularProgressTimer.swift
//  ACLVault
//
//  Animated Circular Countdown Timer for Isometric Holds & Rest Intervals
//

import SwiftUI

public struct CircularProgressTimer: View {
    let totalSeconds: Int
    @Binding var secondsRemaining: Int
    let isRunning: Bool
    var statusTitle: String = "HOLD"
    var accentColor: Color = .recoveryTeal
    var ringDiameter: CGFloat = 200
    
    public init(
        totalSeconds: Int,
        secondsRemaining: Binding<Int>,
        isRunning: Bool,
        statusTitle: String = "HOLD",
        accentColor: Color = .recoveryTeal,
        ringDiameter: CGFloat = 200
    ) {
        self.totalSeconds = max(1, totalSeconds)
        self._secondsRemaining = secondsRemaining
        self.isRunning = isRunning
        self.statusTitle = statusTitle
        self.accentColor = accentColor
        self.ringDiameter = ringDiameter
    }
    
    private var progressFraction: Double {
        let elapsed = Double(totalSeconds - secondsRemaining)
        return min(1.0, max(0.0, elapsed / Double(totalSeconds)))
    }
    
    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.vaultCardElevated, lineWidth: 14)
                .frame(width: ringDiameter, height: ringDiameter)
            
            // Progress Ring
            Circle()
                .trim(from: 0.0, to: CGFloat(1.0 - progressFraction))
                .stroke(
                    LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: ringDiameter, height: ringDiameter)
                .animation(.linear(duration: 0.25), value: secondsRemaining)
                .vaultGlow(color: accentColor, radius: isRunning ? 10 : 2)
            
            // Interior Countdown Display
            VStack(spacing: 4) {
                Text(statusTitle)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(accentColor)
                    .tracking(2)
                
                Text("\(secondsRemaining)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(Color.vaultTextPrimary)
                    .contentTransition(.numericText())
                
                Text("SEC REMAINING")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.vaultTextMuted)
            }
        }
    }
}

