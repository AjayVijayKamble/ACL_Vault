//
//  AICameraGoniometerView.swift
//  ACLVault
//
//  Vision AI Camera Pose Goniometer with Interactive Draggable Anchor Refinement
//

import SwiftUI
import SwiftData
import AVFoundation

public struct AICameraGoniometerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let profile: UserProfile
    let onSaved: ((ROMMeasurement) -> Void)?
    
    @State private var poseService = PoseDetectionService.shared
    @State private var isFrozen: Bool = false
    @State private var selectedMeasurementType: AngleArcView.MeasurementType = .flexion
    @State private var manualNotes: String = ""
    @State private var showingSavedToast: Bool = false
    
    public init(profile: UserProfile, onSaved: ((ROMMeasurement) -> Void)? = nil) {
        self.profile = profile
        self.onSaved = onSaved
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // 1. Camera Feed / Visual Canvas
            GeometryReader { geometry in
                let viewSize = geometry.size
                
                ZStack {
                    // Camera / Simulator Backdrop
                    cameraBackground(viewSize: viewSize)
                    
                    // Connected Landmark Bones (Hip -> Knee -> Ankle)
                    jointBoneLines(viewSize: viewSize)
                    
                    // Draggable Joint Anchors (Hip, Knee, Ankle)
                    jointAnchorDots(viewSize: viewSize)
                }
            }
            .ignoresSafeArea()
            
            // 2. Overlay HUD Controls
            VStack(spacing: 0) {
                topHUDBar
                
                Spacer()
                
                bottomControlDeck
            }
        }
        .onAppear {
            poseService.trackedSide = profile.injuredSide
            poseService.requestCameraPermission { _ in
                poseService.startSession()
            }
        }
        .onDisappear {
            poseService.stopSession()
        }
        .overlay(alignment: .center) {
            if showingSavedToast {
                savedToastView
            }
        }
    }
    
    // MARK: - Camera Background
    @ViewBuilder
    private func cameraBackground(viewSize: CGSize) -> some View {
        if poseService.cameraPermissionGranted && !poseService.isSimulationMode {
            CameraPreviewView(session: poseService.captureSession)
                .frame(width: viewSize.width, height: viewSize.height)
        } else {
            // Interactive Anatomical Simulation Backdrop
            ZStack {
                Color.vaultBackground
                
                // Subtle anatomical grid
                GridBackground()
                    .opacity(0.15)
                
                VStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.recoveryTeal.opacity(0.2))
                    
                    Text("AI VISION CAMERA SIMULATION")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.recoveryTeal.opacity(0.8))
                        .tracking(2)
                    
                    Text("Drag the 3 glowing joints below to test precision alignment.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.vaultTextMuted)
                }
            }
        }
    }
    
    // MARK: - Bone Lines
    private func jointBoneLines(viewSize: CGSize) -> some View {
        Canvas { context, _ in
            let hip = CGPoint(x: poseService.hipPoint.x * viewSize.width, y: poseService.hipPoint.y * viewSize.height)
            let knee = CGPoint(x: poseService.kneePoint.x * viewSize.width, y: poseService.kneePoint.y * viewSize.height)
            let ankle = CGPoint(x: poseService.anklePoint.x * viewSize.width, y: poseService.anklePoint.y * viewSize.height)
            
            // Thigh bone line (Hip -> Knee)
            var thighPath = Path()
            thighPath.move(to: hip)
            thighPath.addLine(to: knee)
            context.stroke(thighPath, with: .color(Color.recoveryTeal), style: StrokeStyle(lineWidth: 4, lineCap: .round))
            
            // Shin bone line (Knee -> Ankle)
            var shinPath = Path()
            shinPath.move(to: knee)
            shinPath.addLine(to: ankle)
            context.stroke(shinPath, with: .color(Color.athleticEmerald), style: StrokeStyle(lineWidth: 4, lineCap: .round))
        }
    }
    
    // MARK: - Draggable Joint Anchor Dots
    private func jointAnchorDots(viewSize: CGSize) -> some View {
        ZStack {
            // Hip Anchor
            draggableAnchor(
                point: poseService.hipPoint,
                label: "Hip (Greater Trochanter)",
                color: .recoveryTeal,
                target: .hip,
                viewSize: viewSize
            )
            
            // Knee Anchor (Vertex)
            draggableAnchor(
                point: poseService.kneePoint,
                label: "Knee Joint Line (Epicondyle)",
                color: .coralAmber,
                target: .knee,
                viewSize: viewSize
            )
            
            // Ankle Anchor
            draggableAnchor(
                point: poseService.anklePoint,
                label: "Ankle (Lateral Malleolus)",
                color: .athleticEmerald,
                target: .ankle,
                viewSize: viewSize
            )
        }
    }
    
    private func draggableAnchor(
        point: CGPoint,
        label: String,
        color: Color,
        target: PoseDetectionService.JointType,
        viewSize: CGSize
    ) -> some View {
        let screenX = point.x * viewSize.width
        let screenY = point.y * viewSize.height
        
        return ZStack {
            // Pulsing target ring
            Circle()
                .stroke(color, lineWidth: 2)
                .frame(width: 38, height: 38)
                .vaultGlow(color: color, radius: 6)
            
            // Center solid dot
            Circle()
                .fill(color)
                .frame(width: 16, height: 16)
            
            // Label
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.black.opacity(0.75))
                .clipShape(Capsule())
                .offset(y: -28)
        }
        .position(x: screenX, y: screenY)
        .gesture(
            DragGesture()
                .onChanged { value in
                    poseService.nudgePoint(target: target, delta: value.translation, viewSize: viewSize)
                }
        )
    }
    
    // MARK: - Top HUD Bar
    private var topHUDBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.white)
                    .padding(10)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Live Angle Metric Pill
            HStack(spacing: 12) {
                VStack(alignment: .trailing, spacing: 1) {
                    Text("ACTIVE FLEXION")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.recoveryTeal)
                    Text(String(format: "%.1f°", poseService.currentFlexion))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)
                }
                
                Divider().frame(height: 24).background(Color.white.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("EXTENSION")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.athleticEmerald)
                    Text(String(format: "%.1f°", poseService.currentExtension))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.75))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
            
            Spacer()
            
            // Tracking Side Badge
            Text(profile.injuredSide.shortCode + " Knee")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.recoveryTeal)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.6))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
    }
    
    // MARK: - Bottom Control Deck
    private var bottomControlDeck: some View {
        VStack(spacing: 14) {
            // Quick Clinical Angle Presets (Especially helpful for Simulator / rapid calibration)
            HStack(spacing: 8) {
                ForEach([0.0, 45.0, 90.0, 115.0, 135.0], id: \.self) { deg in
                    Button {
                        poseService.applyPresetAngle(targetFlexion: deg)
                    } label: {
                        Text("\(Int(deg))°")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.vaultTextPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.vaultCardElevated)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.vaultBorder, lineWidth: 1))
                    }
                }
            }
            
            // Freeze / Nudge Alignment Guidance Notice
            HStack(spacing: 6) {
                Image(systemName: "hand.draw.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.recoveryTeal)
                Text("Touch and drag any anchor point to achieve 100% precision alignment.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.vaultTextSecondary)
            }
            
            // Save Action Button
            Button {
                saveMeasurement()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                    Text("Lock & Save Measurement (\(String(format: "%.1f°", poseService.currentFlexion)))")
                }
            }
            .buttonStyle(VaultPrimaryButtonStyle(accentColor: .recoveryTeal))
        }
        .padding(20)
        .background(
            Color.vaultBackground.opacity(0.92)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.vaultBorder, lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
    
    private var savedToastView: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.athleticEmerald)
            Text("ROM Logged Successfully!")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white)
        }
        .padding(24)
        .background(Color.vaultCardSurface.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .vaultGlow(color: .athleticEmerald, radius: 12)
        .transition(.scale.combined(with: .opacity))
    }
    
    private func saveMeasurement() {
        let measurement = ROMMeasurement(
            timestamp: Date(),
            flexionDegrees: poseService.currentFlexion,
            extensionDegrees: poseService.currentExtension,
            uninjuredFlexion: 140.0,
            measurementMethod: .aiCamera,
            notes: "AI Camera Pose (\(profile.injuredSide.rawValue))"
        )
        
        modelContext.insert(measurement)
        try? modelContext.save()
        
        HapticManager.gateUnlocked()
        onSaved?(measurement)
        
        withAnimation {
            showingSavedToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showingSavedToast = false
            dismiss()
        }
    }
}

// MARK: - AVCaptureVideoPreviewLayer Wrapper
private struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        if let session = session {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            context.coordinator.previewLayer = previewLayer
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = context.coordinator.previewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

// MARK: - Subtle Grid Background for Camera Simulation
private struct GridBackground: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 30
            for x in stride(from: 0, to: size.width, by: step) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(Color.white.opacity(0.08)), lineWidth: 0.5)
            }
            for y in stride(from: 0, to: size.height, by: step) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(Color.white.opacity(0.08)), lineWidth: 0.5)
            }
        }
    }
}

