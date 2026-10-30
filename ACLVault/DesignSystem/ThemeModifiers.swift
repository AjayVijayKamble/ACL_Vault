//
//  ThemeModifiers.swift
//  ACLVault
//
//  Reusable View Modifiers and Button Styles for Clinical Athletic Aesthetic
//

import SwiftUI

// MARK: - Card Surface View Modifier
public struct VaultCardModifier: ViewModifier {
    public var backgroundColor: Color = .vaultCardSurface
    public var borderColor: Color = .vaultBorder
    public var cornerRadius: CGFloat = 16
    public var padding: CGFloat = 16
    
    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}

public extension View {
    func vaultCard(
        backgroundColor: Color = .vaultCardSurface,
        borderColor: Color = .vaultBorder,
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 16
    ) -> some View {
        self.modifier(VaultCardModifier(
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            padding: padding
        ))
    }
    
    func vaultGlow(color: Color, radius: CGFloat = 8) -> some View {
        self.shadow(color: color.opacity(0.35), radius: radius, x: 0, y: 3)
    }
}

// MARK: - Primary Athletic Recovery Button Style
public struct VaultPrimaryButtonStyle: ButtonStyle {
    var accentColor: Color = .recoveryTeal
    var foregroundColor: Color = .black
    var isEnabled: Bool = true
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(accentColor.opacity(configuration.isPressed ? 0.8 : 1.0))
            )
            .vaultGlow(color: accentColor, radius: configuration.isPressed ? 4 : 10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Secondary Outline Button Style
public struct VaultOutlineButtonStyle: ButtonStyle {
    var strokeColor: Color = .vaultBorder
    var textColor: Color = .vaultTextPrimary
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.vaultCardSurface.opacity(configuration.isPressed ? 0.6 : 1.0))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(strokeColor, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

