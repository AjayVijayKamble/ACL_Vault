//
//  AudioCueManager.swift
//  ACLVault
//
//  Auditory Cue Engine for Guided Workout Timers & Angle Lock-ins
//

import Foundation
import AudioToolbox

public enum AudioCueManager {
    // Standard iOS system audio sound IDs
    private enum SoundID: SystemSoundID {
        case tick = 1057        // Soft click
        case beepHigh = 1052    // Beep cue
        case successChime = 1025// Upbeat chime
        case alertLow = 1053    // Warning cue
    }
    
    private static var isMuted: Bool = false
    
    public static func toggleMute() {
        isMuted.toggle()
    }
    
    public static func getIsMuted() -> Bool {
        return isMuted
    }
    
    public static func playTick() {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(SoundID.tick.rawValue)
    }
    
    public static func playRepBeep() {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(SoundID.beepHigh.rawValue)
    }
    
    public static func playWorkoutComplete() {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(SoundID.successChime.rawValue)
    }
    
    public static func playWarning() {
        guard !isMuted else { return }
        AudioServicesPlaySystemSound(SoundID.alertLow.rawValue)
    }
}
