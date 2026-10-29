//
//  PDFReportGenerator.swift
//  ACLVault
//
//  Surgeon & Physical Therapist 1-Click Clinical PDF Summary Generator
//

import SwiftUI
import PDFKit
import Charts

@MainActor
public enum PDFReportGenerator {
    
    public static func generateReport(
        profile: UserProfile,
        romLogs: [ROMMeasurement],
        checkIns: [DailyCheckIn],
        workoutLogs: [WorkoutSessionLog]
    ) -> URL? {
        let reportView = ClinicalReportDocumentView(
            profile: profile,
            romLogs: romLogs,
            checkIns: checkIns,
            workoutLogs: workoutLogs
        )
        .frame(width: 612, height: 792) // Standard US Letter points (8.5 x 11 in @ 72 dpi)
        
        let renderer = ImageRenderer(content: reportView)
        renderer.scale = 2.0 // High resolution for crisp medical printing
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "ACL_Progress_Report_\(profile.name.replacingOccurrences(of: " ", with: "_"))_Day\(profile.daysPostOp).pdf"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            guard let pdfContext = CGContext(fileURL as CFURL, mediaBox: &box, nil) else {
                return
            }
            pdfContext.beginPDFPage(nil)
            context(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }
        
        return fileURL
    }
}

// MARK: - Clinical Report Document Printable View
public struct ClinicalReportDocumentView: View {
    let profile: UserProfile
    let romLogs: [ROMMeasurement]
    let checkIns: [DailyCheckIn]
    let workoutLogs: [WorkoutSessionLog]
    
    public init(
        profile: UserProfile,
        romLogs: [ROMMeasurement],
        checkIns: [DailyCheckIn],
        workoutLogs: [WorkoutSessionLog]
    ) {
        self.profile = profile
        self.romLogs = romLogs.sorted(by: { $0.timestamp < $1.timestamp })
        self.checkIns = checkIns
        self.workoutLogs = workoutLogs
    }
    
    private var latestROM: ROMMeasurement? {
        romLogs.last
    }
    
    private var averagePain: Double {
        guard !checkIns.isEmpty else { return 0.0 }
        let total = checkIns.reduce(0) { $0 + $1.painScore }
        return Double(total) / Double(checkIns.count)
    }
    
    private var compliancePercent: Int {
        let expectedSessions = max(1, profile.daysPostOp / 2)
        let completed = workoutLogs.count
        return min(100, Int((Double(completed) / Double(expectedSessions)) * 100.0))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color(hex: "0284C7"))
                        Text("ACL VAULT CLINICAL SUMMARY")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(Color(hex: "0F172A"))
                    }
                    Text("Official Post-Operative Knee Rehabilitation Progress Log")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(hex: "64748B"))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Generated: \(Date().formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color(hex: "64748B"))
                    Text("Protocol Phase: Level \(profile.currentLevel)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(hex: "0284C7"))
                }
            }
            .padding(.bottom, 6)
            
            Divider()
            
            // Patient Demographics & Surgical Summary Grid
            HStack(spacing: 12) {
                DemographicBox(label: "PATIENT NAME", value: profile.name)
                DemographicBox(label: "OPERATIVE LIMB", value: profile.injuredSide.rawValue)
                DemographicBox(label: "GRAFT TYPE", value: profile.graftType.shortName)
                DemographicBox(label: "POST-OP TIMELINE", value: "Day \(profile.daysPostOp) (Wk \(profile.weeksPostOp))")
                DemographicBox(label: "MENISCUS REPAIR", value: profile.meniscusRepair ? "Yes (Protected)" : "None")
            }
            
            // Key Objective Metrics Cards
            HStack(spacing: 12) {
                ClinicalMetricBox(
                    title: "ACTIVE EXTENSION",
                    value: latestROM != nil ? String(format: "%.1f°", latestROM!.extensionDegrees) : "0.0°",
                    target: "Target: 0° / Hyperext.",
                    statusColor: Color(hex: "10B981")
                )
                ClinicalMetricBox(
                    title: "ACTIVE FLEXION",
                    value: latestROM != nil ? String(format: "%.1f°", latestROM!.flexionDegrees) : "120.0°",
                    target: "Target: 135°+",
                    statusColor: Color(hex: "0284C7")
                )
                ClinicalMetricBox(
                    title: "7-DAY AVG PAIN",
                    value: String(format: "%.1f / 10", averagePain),
                    target: "Tolerance: < 4 / 10",
                    statusColor: averagePain > 4 ? Color(hex: "EF4444") : Color(hex: "10B981")
                )
                ClinicalMetricBox(
                    title: "REHAB COMPLIANCE",
                    value: "\(compliancePercent)%",
                    target: "Target: > 80%",
                    statusColor: Color(hex: "10B981")
                )
            }
            
            // 30-Day Range of Motion Trajectory Chart
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("30-DAY RANGE OF MOTION TRAJECTORY")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(hex: "0F172A"))
                    Spacer()
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Circle().fill(Color(hex: "0284C7")).frame(width: 8, height: 8)
                            Text("Flexion (°)").font(.system(size: 9, weight: .semibold)).foregroundStyle(Color(hex: "475569"))
                        }
                        HStack(spacing: 4) {
                            Circle().fill(Color(hex: "10B981")).frame(width: 8, height: 8)
                            Text("Extension Deficit (°)").font(.system(size: 9, weight: .semibold)).foregroundStyle(Color(hex: "475569"))
                        }
                    }
                }
                
                Chart {
                    ForEach(romLogs) { log in
                        LineMark(
                            x: .value("Date", log.timestamp),
                            y: .value("Degrees", log.flexionDegrees)
                        )
                        .foregroundStyle(Color(hex: "0284C7"))
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", log.timestamp),
                            y: .value("Degrees", log.flexionDegrees)
                        )
                        .foregroundStyle(Color(hex: "0284C7"))
                        .symbolSize(30)
                        
                        LineMark(
                            x: .value("Date", log.timestamp),
                            y: .value("Degrees", log.extensionDegrees)
                        )
                        .foregroundStyle(Color(hex: "10B981"))
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", log.timestamp),
                            y: .value("Degrees", log.extensionDegrees)
                        )
                        .foregroundStyle(Color(hex: "10B981"))
                        .symbolSize(30)
                    }
                    
                    RuleMark(y: .value("Flexion Goal", 135.0))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(Color(hex: "94A3B8"))
                    
                    RuleMark(y: .value("Full Extension", 0.0))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(Color(hex: "10B981").opacity(0.7))
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 30, 60, 90, 120, 135, 150])
                }
                .frame(height: 180)
                .padding(8)
                .background(Color(hex: "F8FAFC"))
                .cornerRadius(8)
            }
            
            // Current Rehab Phase Milestone Status
            VStack(alignment: .leading, spacing: 6) {
                let currentLevel = ProtocolLevels.level(for: profile.currentLevel)
                Text("CURRENT CLINICAL PHASE: LEVEL \(currentLevel.level) - \(currentLevel.title.uppercased())")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(hex: "0F172A"))
                
                Text(currentLevel.clinicalFocus)
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "475569"))
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(currentLevel.gateCriteria, id: \.self) { criterion in
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color(hex: "10B981"))
                            Text(criterion)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(Color(hex: "1E293B"))
                        }
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "F1F5F9"))
                .cornerRadius(6)
            }
            
            Spacer()
            
            // Clinical Sign-Off Box
            VStack(alignment: .leading, spacing: 10) {
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PHYSICAL THERAPIST / ORTHOPEDIC SIGN-OFF")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(Color(hex: "64748B"))
                        Text("Signature: _________________________________________")
                            .font(.system(size: 9))
                            .foregroundStyle(Color(hex: "334155"))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("DATE OF REVIEW")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(Color(hex: "64748B"))
                        Text("Date: _____ / _____ / 202___")
                            .font(.system(size: 9))
                            .foregroundStyle(Color(hex: "334155"))
                    }
                }
                Text("Report automatically generated by ACL Vault native digital goniometry & clinical adherence tracking.")
                    .font(.system(size: 7, weight: .regular))
                    .foregroundStyle(Color(hex: "94A3B8"))
            }
        }
        .padding(24)
        .background(Color.white)
    }
}

// Subcomponents for Clean Medical Document Layout
private struct DemographicBox: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(Color(hex: "64748B"))
            Text(value)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color(hex: "0F172A"))
                .lineLimit(1)
        }
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "F8FAFC"))
        .cornerRadius(6)
    }
}

private struct ClinicalMetricBox: View {
    let title: String
    let value: String
    let target: String
    let statusColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(Color(hex: "64748B"))
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(statusColor)
            Text(target)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(Color(hex: "64748B"))
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "F8FAFC"))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(hex: "E2E8F0"), lineWidth: 1)
        )
    }
}

