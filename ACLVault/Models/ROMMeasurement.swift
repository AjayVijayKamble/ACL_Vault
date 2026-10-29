//
//  ROMMeasurement.swift
//  ACLVault
//
//  SwiftData Model for Range of Motion (ROM) Logs
//

import Foundation
import SwiftData

@Model
public final class ROMMeasurement {
    public var id: UUID = UUID()
    public var timestamp: Date = Date()
    public var flexionDegrees: Double = 90.0
    public var extensionDegrees: Double = 0.0
    public var uninjuredFlexion: Double? = 140.0
    public var measurementMethodRaw: String = MeasurementMethod.aiCamera.rawValue
    public var notes: String = ""
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        flexionDegrees: Double,
        extensionDegrees: Double,
        uninjuredFlexion: Double? = 140.0,
        measurementMethod: MeasurementMethod = .aiCamera,
        notes: String = ""
    ) {
        self.id = id
        self.timestamp = timestamp
        self.flexionDegrees = flexionDegrees
        self.extensionDegrees = extensionDegrees
        self.uninjuredFlexion = uninjuredFlexion
        self.measurementMethodRaw = measurementMethod.rawValue
        self.notes = notes
    }
    
    public var measurementMethod: MeasurementMethod {
        get { MeasurementMethod(rawValue: measurementMethodRaw) ?? .aiCamera }
        set { measurementMethodRaw = newValue.rawValue }
    }
    
    // Extension deficit: 0° is neutral full extension. Values > 0 indicate an extension deficit (knee bent).
    // Hyperextension is represented by negative values (e.g. -2° or -5°).
    public var extensionDeficit: Double {
        return max(0, extensionDegrees)
    }
    
    // Target flexion is typically 135°+ or matched to uninjured leg
    public var flexionProgressPercent: Double {
        let target = uninjuredFlexion ?? 135.0
        return min(1.0, max(0.0, flexionDegrees / target))
    }
    
    public var formattedFlexion: String {
        return String(format: "%.1f°", flexionDegrees)
    }
    
    public var formattedExtension: String {
        return String(format: "%.1f°", extensionDegrees)
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: timestamp)
    }
}

