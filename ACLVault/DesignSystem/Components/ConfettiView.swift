//
//  ConfettiView.swift
//  ACLVault
//
//  Celebratory Particle Burst Animation for Gate Check Pass & Milestones
//

import SwiftUI

public struct ConfettiView: View {
    @State private var animate = false
    
    private let colors: [Color] = [
        .recoveryTeal,
        .athleticEmerald,
        Color(hex: "38BDF8"),
        .coralAmber,
        .white
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack {
            ForEach(0..<45, id: \.self) { index in
                ConfettiParticle(
                    color: colors[index % colors.count],
                    index: index,
                    animate: animate
                )
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2.2)) {
                animate = true
            }
        }
    }
}

private struct ConfettiParticle: View {
    let color: Color
    let index: Int
    let animate: Bool
    
    private var randomX: CGFloat {
        CGFloat.random(in: -180...180)
    }
    
    private var randomY: CGFloat {
        CGFloat.random(in: -280...120)
    }
    
    private var randomScale: CGFloat {
        CGFloat.random(in: 0.6...1.4)
    }
    
    private var randomRotation: Double {
        Double.random(in: 0...720)
    }
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 6...12))
            .scaleEffect(animate ? randomScale : 0.1)
            .rotationEffect(.degrees(animate ? randomRotation : 0))
            .offset(x: animate ? randomX : 0, y: animate ? randomY : 0)
            .opacity(animate ? 0.0 : 1.0)
    }
}

