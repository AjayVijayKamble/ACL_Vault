//
//  PoseDetectionService.swift
//  ACLVault
//
//  Vision Framework Human Body Pose Detection & Angle Calculation Engine
//

import Foundation
import Vision
import CoreGraphics
import AVFoundation
import SwiftUI

// MARK: - Joint Anchor Landmark
public struct JointPoint: Identifiable, Sendable {
    public let id: String
    public var position: CGPoint // Normalized (0.0 to 1.0)
    public var confidence: Float
    
    public init(id: String, position: CGPoint, confidence: Float = 1.0) {
        self.id = id
        self.position = position
        self.confidence = confidence
    }
}

// MARK: - Computed ROM Result
public struct PoseKneeAngleResult: Sendable {
    public let interiorJointAngle: Double // e.g. 180° for straight, 90° for right angle
    public let flexionDegrees: Double     // 0° for straight, 90° for bent, 135° for deep bend
    public let extensionDegrees: Double   // 0° for straight, >0° for deficit, <0° for hyperextension
    public let isConfident: Bool
}

@Observable
public final class PoseDetectionService: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    public static let shared = PoseDetectionService()
    
    // Live Camera capture
    public var captureSession: AVCaptureSession?
    public var isCameraRunning: Bool = false
    public var cameraPermissionGranted: Bool = false
    public var isSimulationMode: Bool = false
    
    // Joint Landmarks (Normalized 0.0 to 1.0 in view coordinates)
    public var hipPoint: CGPoint = CGPoint(x: 0.35, y: 0.25)
    public var kneePoint: CGPoint = CGPoint(x: 0.50, y: 0.50)
    public var anklePoint: CGPoint = CGPoint(x: 0.65, y: 0.80)
    
    // Detected or Refined Knee Angle
    public var currentFlexion: Double = 90.0
    public var currentExtension: Double = 0.0
    public var confidenceScore: Float = 0.95
    public var isFreezeFrame: Bool = false
    public var capturedImage: UIImage? = nil
    
    // Selected side to track
    public var trackedSide: LegSide = .right
    
    private let videoOutputQueue = DispatchQueue(label: "com.aclvault.pose.videoQueue", qos: .userInitiated)
    private var bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    
    public override init() {
        super.init()
        #if targetEnvironment(simulator)
        self.isSimulationMode = true
        #endif
        self.updateAngleFromPoints()
    }
    
    // MARK: - AVCaptureSession Lifecycle
    public func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        #if targetEnvironment(simulator)
        self.cameraPermissionGranted = true
        self.isSimulationMode = true
        completion(true)
        return
        #endif
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.cameraPermissionGranted = true
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.cameraPermissionGranted = granted
                    self?.isSimulationMode = !granted
                    completion(granted)
                }
            }
        default:
            self.cameraPermissionGranted = false
            self.isSimulationMode = true
            completion(false)
        }
    }
    
    public func startSession() {
        #if targetEnvironment(simulator)
        self.isSimulationMode = true
        self.isCameraRunning = true
        return
        #endif
        
        guard cameraPermissionGranted else {
            self.isSimulationMode = true
            return
        }
        
        if captureSession == nil {
            setupCaptureSession()
        }
        
        videoOutputQueue.async { [weak self] in
            guard let self = self, let session = self.captureSession, !session.isRunning else { return }
            session.startRunning()
            DispatchQueue.main.async {
                self.isCameraRunning = true
            }
        }
    }
    
    public func stopSession() {
        videoOutputQueue.async { [weak self] in
            guard let self = self, let session = self.captureSession, session.isRunning else { return }
            session.stopRunning()
            DispatchQueue.main.async {
                self.isCameraRunning = false
            }
        }
    }
    
    private func setupCaptureSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            self.isSimulationMode = true
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        self.captureSession = session
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard !isFreezeFrame else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([bodyPoseRequest])
            guard let observation = bodyPoseRequest.results?.first else { return }
            processObservation(observation)
        } catch {
            // Keep existing landmarks
        }
    }
    
    private func processObservation(_ observation: VNHumanBodyPoseObservation) {
        let hipJoint: VNHumanBodyPoseObservation.JointName = (trackedSide == .right) ? .rightHip : .leftHip
        let kneeJoint: VNHumanBodyPoseObservation.JointName = (trackedSide == .right) ? .rightKnee : .leftKnee
        let ankleJoint: VNHumanBodyPoseObservation.JointName = (trackedSide == .right) ? .rightAnkle : .leftAnkle
        
        guard let hip = try? observation.recognizedPoint(hipJoint),
              let knee = try? observation.recognizedPoint(kneeJoint),
              let ankle = try? observation.recognizedPoint(ankleJoint),
              hip.confidence > 0.3, knee.confidence > 0.3, ankle.confidence > 0.3 else {
            return
        }
        
        DispatchQueue.main.async {
            // Convert Vision coordinate (origin at bottom-left) to SwiftUI (origin top-left)
            self.hipPoint = CGPoint(x: hip.location.x, y: 1.0 - hip.location.y)
            self.kneePoint = CGPoint(x: knee.location.x, y: 1.0 - knee.location.y)
            self.anklePoint = CGPoint(x: ankle.location.x, y: 1.0 - ankle.location.y)
            self.confidenceScore = (hip.confidence + knee.confidence + ankle.confidence) / 3.0
            self.updateAngleFromPoints()
        }
    }
    
    // MARK: - Joint Angle Geometry via atan2 & Law of Cosines
    public func updateAngleFromPoints() {
        let result = Self.calculateAngle(hip: hipPoint, knee: kneePoint, ankle: anklePoint)
        self.currentFlexion = result.flexionDegrees
        self.currentExtension = result.extensionDegrees
    }
    
    public static func calculateAngle(hip: CGPoint, knee: CGPoint, ankle: CGPoint) -> PoseKneeAngleResult {
        // Vector from Knee to Hip
        let v1 = CGPoint(x: hip.x - knee.x, y: hip.y - knee.y)
        // Vector from Knee to Ankle
        let v2 = CGPoint(x: ankle.x - knee.x, y: ankle.y - knee.y)
        
        let angle1 = atan2(v1.y, v1.x)
        let angle2 = atan2(v2.y, v2.x)
        
        var diffRadians = abs(angle1 - angle2)
        if diffRadians > .pi {
            diffRadians = (2.0 * .pi) - diffRadians
        }
        
        let interiorAngleDegrees = diffRadians * 180.0 / .pi
        
        // Anatomical knee angle translation:
        // Straight leg = interior angle 180° -> Flexion 0°, Extension 0°
        // Knee bent at right angle = interior angle 90° -> Flexion 90°
        // Fully bent = interior angle 40° -> Flexion 140°
        let flexion = max(0.0, min(160.0, 180.0 - interiorAngleDegrees))
        
        // Extension deficit: if interior angle is 175°, deficit is 5°.
        // If interior angle is 185° (hyperextension), extension is -5°.
        let extensionAngle = 180.0 - interiorAngleDegrees
        
        return PoseKneeAngleResult(
            interiorJointAngle: interiorAngleDegrees,
            flexionDegrees: flexion,
            extensionDegrees: max(-10.0, min(30.0, extensionAngle)),
            isConfident: true
        )
    }
    
    // MARK: - Drag / Nudge Anchor Precision Adjustment
    public func nudgePoint(target: JointType, delta: CGSize, viewSize: CGSize) {
        guard viewSize.width > 0, viewSize.height > 0 else { return }
        let normDeltaX = delta.width / viewSize.width
        let normDeltaY = delta.height / viewSize.height
        
        switch target {
        case .hip:
            hipPoint.x = min(1.0, max(0.0, hipPoint.x + normDeltaX))
            hipPoint.y = min(1.0, max(0.0, hipPoint.y + normDeltaY))
        case .knee:
            kneePoint.x = min(1.0, max(0.0, kneePoint.x + normDeltaX))
            kneePoint.y = min(1.0, max(0.0, kneePoint.y + normDeltaY))
        case .ankle:
            anklePoint.x = min(1.0, max(0.0, anklePoint.x + normDeltaX))
            anklePoint.y = min(1.0, max(0.0, anklePoint.y + normDeltaY))
        }
        
        updateAngleFromPoints()
        HapticManager.countdownTick()
    }
    
    // MARK: - Simulation Presets for Testing
    public func applyPresetAngle(targetFlexion: Double) {
        // Center knee at (0.5, 0.5)
        kneePoint = CGPoint(x: 0.5, y: 0.5)
        // Hip remains at (0.35, 0.25)
        hipPoint = CGPoint(x: 0.40, y: 0.20)
        
        // Interior angle is 180 - targetFlexion
        let interiorAngle = (180.0 - targetFlexion) * .pi / 180.0
        
        // Hip vector angle
        let hipAngle = atan2(hipPoint.y - kneePoint.y, hipPoint.x - kneePoint.x)
        // Ankle angle is hipAngle + interiorAngle
        let ankleAngle = hipAngle + interiorAngle
        
        let length: CGFloat = 0.35
        anklePoint = CGPoint(
            x: min(0.95, max(0.05, kneePoint.x + (cos(ankleAngle) * length))),
            y: min(0.95, max(0.05, kneePoint.y + (sin(ankleAngle) * length)))
        )
        
        updateAngleFromPoints()
        HapticManager.angleLocked()
    }
    
    public enum JointType: String, CaseIterable {
        case hip = "Hip"
        case knee = "Knee"
        case ankle = "Ankle"
    }
}

