//
//  HapticManager.swift
//  ACLVault
//
//  Clinical Haptic Feedback Engine
//

import UIKit

@MainActor
public enum HapticManager {
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private static let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private static let notificationFeedback = UINotificationFeedbackGenerator()
    
    public static func prepare() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        rigidImpact.prepare()
        notificationFeedback.prepare()
    }
    
    /// Triggered on rep countdown ticks (3, 2, 1)
    public static func countdownTick() {
        lightImpact.impactOccurred(intensity: 0.6)
    }
    
    /// Triggered when an angle or joint position locks in
    public static func angleLocked() {
        rigidImpact.impactOccurred(intensity: 0.9)
    }
    
    /// Triggered when an isometric hold or rep finishes
    public static func repCompleted() {
        mediumImpact.impactOccurred(intensity: 0.8)
    }
    
    /// Triggered when an entire exercise or workout finishes
    public static func workoutSuccess() {
        notificationFeedback.notificationOccurred(.success)
    }
    
    /// Triggered when a level gate check is passed or unlocked
    public static func gateUnlocked() {
        heavyImpact.impactOccurred(intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            notificationFeedback.notificationOccurred(.success)
        }
    }
    
    /// Triggered when pain threshold alert or high swelling is flagged
    public static func flareUpAlert() {
        notificationFeedback.notificationOccurred(.warning)
    }
    
    /// Triggered on tap of interactive buttons
    public static func buttonTap() {
        lightImpact.impactOccurred(intensity: 0.4)
    }
}

