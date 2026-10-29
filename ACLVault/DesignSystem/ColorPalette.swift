//
//  DesignSystem+Colors.swift
//  ACLVault
//
//  Clinical Athletic Design System Colors
//

import SwiftUI

extension Color {
    // Brand Backgrounds
    static let vaultBackground = Color(hex: "0B0F17")
    static let vaultCardSurface = Color(hex: "161C28")
    static let vaultCardElevated = Color(hex: "1E2638")
    static let vaultBorder = Color(hex: "273349")
    
    // Primary Accents
    static let recoveryTeal = Color(hex: "00E5FF")
    static let athleticEmerald = Color(hex: "10B981")
    static let athleticEmeraldMuted = Color(hex: "065F46")
    
    // Warning & Clinical Alerts
    static let coralAmber = Color(hex: "F59E0B")
    static let clinicalCrimson = Color(hex: "EF4444")
    static let clinicalPurple = Color(hex: "8B5CF6")
    
    // Neutral Text & Icons
    static let vaultTextPrimary = Color.white
    static let vaultTextSecondary = Color(hex: "94A3B8")
    static let vaultTextMuted = Color(hex: "64748B")
    
    // Helper Initializer for Hex
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 229, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Linear Gradients for Athletic Clinical Feel
extension LinearGradient {
    static let tealGlow = LinearGradient(
        colors: [Color.recoveryTeal, Color.recoveryTeal.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let emeraldGlow = LinearGradient(
        colors: [Color.athleticEmerald, Color.athleticEmerald.opacity(0.4)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color.vaultCardSurface, Color.vaultCardSurface.opacity(0.85)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let flareUpGradient = LinearGradient(
        colors: [Color.clinicalCrimson.opacity(0.25), Color.vaultCardSurface],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let proGoldGlow = LinearGradient(
        colors: [Color(hex: "F59E0B"), Color(hex: "D97706"), Color(hex: "B45309")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

