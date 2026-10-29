//
//  ClinicalPDFPreviewView.swift
//  ACLVault
//
//  Surgeon & Physical Therapist PDF Viewer with Native ShareLink
//

import SwiftUI
import PDFKit

public struct ClinicalPDFPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    let pdfURL: URL
    let profile: UserProfile
    
    public init(pdfURL: URL, profile: UserProfile) {
        self.pdfURL = pdfURL
        self.profile = profile
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vaultBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Info Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("OFFICIAL CLINICAL SUMMARY")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.recoveryTeal)
                                .tracking(1.2)
                            Text("\(profile.name) • Day \(profile.daysPostOp)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.vaultTextPrimary)
                        }
                        
                        Spacer()
                        
                        // Native iOS ShareLink for AirDrop, Print, or Email
                        ShareLink(item: pdfURL) {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share / AirDrop")
                            }
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.recoveryTeal)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.vaultCardSurface)
                    
                    // PDFKit Interactive Document View
                    PDFKitRepresentedView(url: pdfURL)
                        .background(Color(hex: "334155"))
                }
            }
            .navigationTitle("Surgeon & PT Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(Color.vaultTextSecondary)
                }
            }
        }
    }
}

// PDFView Wrapper
private struct PDFKitRepresentedView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document == nil {
            uiView.document = PDFDocument(url: url)
        }
    }
}

