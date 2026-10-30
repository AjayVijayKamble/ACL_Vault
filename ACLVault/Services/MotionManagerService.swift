//
//  MotionManagerService.swift
//  ACLVault
//
//  CoreMotion Gyroscope Shin-Tap Dual Goniometer Service
//

import Foundation
import CoreMotion
import SwiftUI

@Observable
@MainActor
public final class MotionManagerService {
    public static let shared = MotionManagerService()
    
    private let motionManager = CMMotionManager()
    
    // Live sensor state
    public var currentLivePitch: Double = 0.0
    public var currentLiveRoll: Double = 0.0
    public var isDeviceMotionActive: Bool = false
    public var isHardwareAvailable: Bool = false
    
    // Dual-Step Goniometer State
    public var calibratedThighPitch: Double? = nil
    public var measuredShinPitch: Double? = nil
    public var calculatedKneeFlexion: Double? = nil
    public var calculatedKneeExtension: Double? = nil
    
    // Simulation / Simulator Fallback
    public var isSimulatedMode: Bool = false
    public var simulatedSliderAngle: Double = 90.0
    
    public init() {
        self.isHardwareAvailable = motionManager.isDeviceMotionAvailable
        #if targetEnvironment(simulator)
        self.isSimulatedMode = true
        #endif
    }
    
    public func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            isHardwareAvailable = false
            isSimulatedMode = true
            return
        }
        
        isHardwareAvailable = true
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0 // 30 Hz
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self = self, let motion = motion else { return }
            self.isDeviceMotionActive = true
            // Convert pitch to degrees
            let pitchDegrees = motion.attitude.pitch * 180.0 / .pi
            let rollDegrees = motion.attitude.roll * 180.0 / .pi
            self.currentLivePitch = pitchDegrees
            self.currentLiveRoll = rollDegrees
        }
    }
    
    public func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
        isDeviceMotionActive = false
    }
    
    // MARK: - Dual-Step Goniometer Protocol
    
    /// Step 1: User rests phone flat on top of anterior thigh and taps Calibrate
    public func calibrateThigh() {
        let pitchToUse = isSimulatedMode ? (90.0 - (simulatedSliderAngle * 0.5)) : currentLivePitch
        self.calibratedThighPitch = pitchToUse
        self.measuredShinPitch = nil
        self.calculatedKneeFlexion = nil
        self.calculatedKneeExtension = nil
        HapticManager.angleLocked()
    }
    
    /// Step 2: User rests phone flat along anterior shin bone (tibia) and taps Read Angle
    public func readShin() {
        guard let thighPitch = calibratedThighPitch else { return }
        let shinPitchToUse = isSimulatedMode ? (thighPitch + simulatedSliderAngle) : currentLivePitch
        self.measuredShinPitch = shinPitchToUse
        
        // Calculate delta
        let deltaPitch = abs(shinPitchToUse - thighPitch)
        
        // Normalize: when straight leg, angle delta is ~0°.
        // Flexion = delta degrees.
        let flexion = min(150.0, max(0.0, deltaPitch))
        
        // Extension is deficit from 0° (e.g. 0° is full extension; anything > 0 is deficit)
        let extDeficit = flexion < 5.0 ? 0.0 : max(0.0, 5.0 - flexion)
        
        self.calculatedKneeFlexion = flexion
        self.calculatedKneeExtension = extDeficit
        HapticManager.gateUnlocked()
    }
    
    public func resetCalibration() {
        self.calibratedThighPitch = nil
        self.measuredShinPitch = nil
        self.calculatedKneeFlexion = nil
        self.calculatedKneeExtension = nil
        HapticManager.buttonTap()
    }
}

