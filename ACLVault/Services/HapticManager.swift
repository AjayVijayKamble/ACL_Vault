//
//  HapticManager.swift
//  ACLVault
//
//  Clinical Haptic Feedback Engine
//

import UIKit

public enum HapticManager {
    public static func prepare() {
        DispatchQueue.main.async {
            let lightImpact = UIImpactFeedbackGenerator(style: .light)
            lightImpact.prepare()
        }
    }
    
    /// Triggered on rep countdown ticks (3, 2, 1)
    public static func countdownTick() {
        DispatchQueue.main.async {
            let lightImpact = UIImpactFeedbackGenerator(style: .light)
            lightImpact.impactOccurred(intensity: 0.6)
        }
    }
    
    /// Triggered when an angle or joint position locks in
    public static func angleLocked() {
        DispatchQueue.main.async {
            let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
            rigidImpact.impactOccurred(intensity: 0.9)
        }
    }
    
    /// Triggered when an isometric hold or rep finishes
    public static func repCompleted() {
        DispatchQueue.main.async {
            let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
            mediumImpact.impactOccurred(intensity: 0.8)
        }
    }
    
    /// Triggered when an entire exercise or workout finishes
    public static func workoutSuccess() {
        DispatchQueue.main.async {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        }
    }
    
    /// Triggered when a level gate check is passed or unlocked
    public static func gateUnlocked() {
        DispatchQueue.main.async {
            let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
            heavyImpact.impactOccurred(intensity: 1.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
            }
        }
    }
    
    /// Triggered when pain threshold alert or high swelling is flagged
    public static func flareUpAlert() {
        DispatchQueue.main.async {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.warning)
        }
    }
    
    /// Triggered on tap of interactive buttons
    public static func buttonTap() {
        DispatchQueue.main.async {
            let lightImpact = UIImpactFeedbackGenerator(style: .light)
            lightImpact.impactOccurred(intensity: 0.4)
        }
    }
}
