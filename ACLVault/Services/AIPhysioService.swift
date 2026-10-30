//
//  AIPhysioService.swift
//  ACLVault
//
//  Clinical Decision Engine & Extensible LLM Physio Co-Pilot
//

import Foundation
import SwiftUI

// MARK: - Assessment Result
public struct PhysioAssessmentResult: Sendable {
    public let isFlareUp: Bool
    public let statusTitle: String
    public let coachMessage: String
    public let primaryAdjustment: String
    public let precautions: [String]
    public let targetFlexion: Double
    public let targetExtension: Double
    public let recommendedExerciseTitles: [String]
    public let bannerColor: Color
}

// MARK: - LLM Client Protocol
public protocol LLMPhysioClient: Sendable {
    func generateCoachingInsight(
        profile: UserProfile,
        checkIn: DailyCheckIn,
        recentROM: ROMMeasurement?
    ) async -> String
}

// MARK: - Deterministic On-Device Rule Engine
public struct DeterministicPhysioEngine: LLMPhysioClient {
    public init() {}
    
    public func generateCoachingInsight(
        profile: UserProfile,
        checkIn: DailyCheckIn,
        recentROM: ROMMeasurement?
    ) async -> String {
        let isFlareUp = checkIn.painScore >= 6 || checkIn.swellingLevel == .severe
        let days = profile.daysPostOp
        let graft = profile.graftType.shortName
        
        if isFlareUp {
            return "Flare-Up Alert: Your pain score (\(checkIn.painScore)/10) or joint effusion (\(checkIn.swellingLevel.rawValue)) triggers our deload protocol. Today's high-load strength exercises are swapped for gentle terminal extension heel props, isometric quad sets, ankle pumps, and 15-minute ice/elevation intervals. Do not force flexion past resistance."
        }
        
        if profile.meniscusRepair && days < 42 {
            return "Post-Op Day \(days) (\(graft)): Notice your meniscus repair protocol is active. Keep flexion strictly at or below 90° to protect circumferential collagen stitches. Focus on active terminal knee extension and gentle VMO activation."
        }
        
        if checkIn.painScore <= 2 && (checkIn.swellingLevel == .none || checkIn.swellingLevel == .mild) {
            return "Knee Readiness High: Effusion is minimal and pain is well-controlled. You are cleared for your prescribed Level \(profile.currentLevel) protocol. Focus on strict form cues and controlled eccentric tempo."
        }
        
        return "Day \(days) Check-In: Mild anterior sensitivity reported. Prioritize warm-up bike rocking and terminal knee extensions before initiating closed-chain loading. Stop any movement that creates sharp pain > 4/10."
    }
}

// MARK: - Cloud Gemini API Client Implementation
public struct GeminiPhysioClient: LLMPhysioClient {
    public let apiKey: String
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func generateCoachingInsight(
        profile: UserProfile,
        checkIn: DailyCheckIn,
        recentROM: ROMMeasurement?
    ) async -> String {
        guard !apiKey.isEmpty else {
            return await DeterministicPhysioEngine().generateCoachingInsight(
                profile: profile,
                checkIn: checkIn,
                recentROM: recentROM
            )
        }
        
        let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: endpoint) else {
            return await DeterministicPhysioEngine().generateCoachingInsight(
                profile: profile,
                checkIn: checkIn,
                recentROM: recentROM
            )
        }
        
        let promptText = """
        You are an expert orthopedic physical therapist specialized in ACL rehabilitation.
        Patient info:
        - Post-Op Day: \(profile.daysPostOp) (Week \(profile.weeksPostOp))
        - Graft: \(profile.graftType.rawValue)
        - Meniscus Repair: \(profile.meniscusRepair ? "Yes (limit flexion <= 90° for 6 weeks)" : "No")
        - Today's Pain: \(checkIn.painScore)/10 at \(checkIn.painLocation.rawValue)
        - Joint Swelling: \(checkIn.swellingLevel.rawValue)
        - Current Level: \(profile.currentLevel)
        Provide a concise 2-sentence clinical recommendation, instructing them if they should deload or proceed, with specific graft precautions.
        """
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": promptText]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.3,
                "maxOutputTokens": 150
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return await DeterministicPhysioEngine().generateCoachingInsight(
                    profile: profile,
                    checkIn: checkIn,
                    recentROM: recentROM
                )
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let text = parts.first?["text"] as? String {
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            // Fallback cleanly to on-device engine
        }
        
        return await DeterministicPhysioEngine().generateCoachingInsight(
            profile: profile,
            checkIn: checkIn,
            recentROM: recentROM
        )
    }
}

// MARK: - Main AI Physio Service
@MainActor
public final class AIPhysioService {
    public static let shared = AIPhysioService()
    
    private var llmClient: LLMPhysioClient
    
    public init(llmClient: LLMPhysioClient? = nil) {
        self.llmClient = llmClient ?? DeterministicPhysioEngine()
    }
    
    public func setApiKey(_ key: String) {
        if key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.llmClient = DeterministicPhysioEngine()
        } else {
            self.llmClient = GeminiPhysioClient(apiKey: key)
        }
    }
    
    public func evaluateReadiness(
        profile: UserProfile,
        checkIn: DailyCheckIn,
        recentROM: ROMMeasurement?
    ) async -> PhysioAssessmentResult {
        let isFlareUp = profile.simulateFlareUp || checkIn.painScore >= 6 || checkIn.swellingLevel == .severe
        
        let coachMessage = await llmClient.generateCoachingInsight(
            profile: profile,
            checkIn: checkIn,
            recentROM: recentROM
        )
        
        var precautions: [String] = []
        
        if profile.meniscusRepair && profile.daysPostOp < 42 {
            precautions.append("Meniscus Stitch Protection: Do not flex past 90° until Week 6.")
            precautions.append("Avoid active hamstring loaded curls.")
        }
        
        switch profile.graftType {
        case .patellar:
            precautions.append("Patellar Tendon Autograft: Avoid resisted open-chain extension (45°-0°) to protect donor site.")
        case .hamstring:
            precautions.append("Hamstring Autograft: Avoid deep aggressive hamstring stretches and loaded resisted curls.")
        case .quad:
            precautions.append("Quad Tendon Autograft: Watch for extensor lag; emphasize sustained isometric VMO holds.")
        default:
            break
        }
        
        if isFlareUp {
            precautions.append("Acute Effusion: Avoid heavy impact and deep squats. Maintain 0° extension.")
            
            return PhysioAssessmentResult(
                isFlareUp: true,
                statusTitle: "Flare-Up Recovery Mode Active",
                coachMessage: coachMessage,
                primaryAdjustment: "High-load exercises swapped for passive extension & circulatory deloading.",
                precautions: precautions,
                targetFlexion: min(90.0, recentROM?.flexionDegrees ?? 90.0),
                targetExtension: 0.0,
                recommendedExerciseTitles: [
                    "Ice, Compression & High Elevation Protocol",
                    "Heel Props (Passive Terminal Extension)",
                    "Quad Sets (Isometric VMO Contraction)",
                    "Ankle Pumps & Circulatory Flushing",
                    "Patellar Mobilizations (Multidirectional)"
                ],
                bannerColor: .clinicalCrimson
            )
        } else {
            let currentRehabLevel = ProtocolLevels.level(for: profile.currentLevel)
            let targetFlex = profile.meniscusRepair && profile.daysPostOp < 42 ? 90.0 : currentRehabLevel.minFlexionTarget
            
            return PhysioAssessmentResult(
                isFlareUp: false,
                statusTitle: "Cleared for Level \(profile.currentLevel) Protocol",
                coachMessage: coachMessage,
                primaryAdjustment: "Optimal readiness. Proceed with full prescribed volume and tempo.",
                precautions: precautions,
                targetFlexion: targetFlex,
                targetExtension: 0.0,
                recommendedExerciseTitles: currentRehabLevel.primaryExercisesSummary,
                bannerColor: .athleticEmerald
            )
        }
    }
}
