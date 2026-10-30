//
//  PaywallView.swift
//  ACLVault
//
//  High-Converting Freemium Paywall with StoreKit 2 Tiers & Lifetime Pass
//

import SwiftUI
import StoreKit
import SwiftData

public struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    
    @State private var storeKit = StoreKitManager.shared
    @State private var selectedTier: SubscriptionTier = .annual
    @State private var isProcessing: Bool = false
    @State private var showingSuccessAlert: Bool = false
    
    private var profile: UserProfile {
        userProfiles.first ?? UserProfile()
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.vaultBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        // Hero Header
                        heroHeaderSection
                        
                        // Pricing Tier Selection Cards
                        pricingTiersSection
                        
                        // Feature Matrix Comparison
                        PaywallComparisonCard()
                        
                        // Primary CTA Button
                        purchaseActionButton
                        
                        // Demo Unlock Button (For Simulator Testing)
                        demoTestButton
                        
                        // Legal & Restore Footer
                        legalFooterSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.vaultTextSecondary)
                            .padding(8)
                            .background(Color.vaultCardElevated)
                            .clipShape(Circle())
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Restore") {
                        Task {
                            await storeKit.restorePurchases()
                            if storeKit.isProUnlocked {
                                profile.isProSubscriber = true
                                try? modelContext.save()
                                showingSuccessAlert = true
                            }
                        }
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.vaultTextSecondary)
                }
            }
            .alert("Pro Membership Active", isPresented: $showingSuccessAlert) {
                Button("Let's Recover!") {
                    dismiss()
                }
            } message: {
                Text("All 10 return-to-sport levels, AI Camera Goniometer, and PDF clinical reports are now unlocked.")
            }
        }
    }
    
    // MARK: - Hero Header
    private var heroHeaderSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.coralAmber.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "shield.checkered")
                    .font(.system(size: 38))
                    .foregroundStyle(Color.coralAmber)
                    .vaultGlow(color: .coralAmber, radius: 10)
            }
            .padding(.top, 8)
            
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Text("ACL VAULT PRO")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(Color.coralAmber)
                        .tracking(2)
                }
                
                Text("Complete Your Full 12-Month Recovery")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(Color.vaultTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Under-cutting physical therapy apps by 70%. Never pay $200/mo for basic knee rehab tracking.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.vaultTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Pricing Tiers Section
    private var pricingTiersSection: some View {
        VStack(spacing: 10) {
            ForEach(SubscriptionTier.allCases) { tier in
                Button {
                    selectedTier = tier
                    HapticManager.buttonTap()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: selectedTier == tier ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(selectedTier == tier ? Color.coralAmber : Color.vaultBorder)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 8) {
                                Text(tier.title)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.vaultTextPrimary)
                                
                                if tier.isBestValue {
                                    Text("BEST VALUE • SAVE 52%")
                                        .font(.system(size: 9, weight: .black, design: .rounded))
                                        .foregroundStyle(Color.black)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.coralAmber)
                                        .clipShape(Capsule())
                                }
                            }
                            
                            Text(tier.subtitle)
                                .font(.system(size: 11))
                                .foregroundStyle(Color.vaultTextSecondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Text(tier.priceFormatted)
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(selectedTier == tier ? Color.coralAmber : Color.vaultTextPrimary)
                    }
                    .padding(14)
                    .background(selectedTier == tier ? Color.coralAmber.opacity(0.12) : Color.vaultCardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(selectedTier == tier ? Color.coralAmber : Color.vaultBorder, lineWidth: selectedTier == tier ? 2 : 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Primary Action Button
    private var purchaseActionButton: some View {
        Button {
            executePurchase()
        } label: {
            if isProcessing {
                HStack(spacing: 8) {
                    ProgressView().tint(.black)
                    Text("Contacting App Store...")
                }
            } else {
                HStack(spacing: 6) {
                    Text("Unlock ACL Vault Pro")
                    Image(systemName: "arrow.right")
                }
            }
        }
        .buttonStyle(VaultPrimaryButtonStyle(accentColor: .coralAmber, foregroundColor: .black))
        .disabled(isProcessing)
    }
    
    // MARK: - Demo Unlock Button for Simulator Testing
    private var demoTestButton: some View {
        Button {
            storeKit.toggleDemoProAccess(profile: profile)
            try? modelContext.save()
            showingSuccessAlert = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "wrench.and.screwdriver.fill")
                Text("Simulator / Reviewer Instant Pro Unlock")
            }
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.vaultTextMuted)
        }
        .padding(.top, 4)
    }
    
    // MARK: - Legal Footer
    private var legalFooterSection: some View {
        VStack(spacing: 8) {
            Text("Subscription automatically renews unless cancelled at least 24 hours prior to the end of the current billing cycle in your Apple ID Account Settings.")
                .font(.system(size: 10))
                .foregroundStyle(Color.vaultTextMuted)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Link("Terms of Service", destination: URL(string: "https://aclvault.app/terms")!)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.vaultTextMuted)
                
                Text("•").foregroundStyle(Color.vaultTextMuted)
                
                Link("Privacy Policy", destination: URL(string: "https://aclvault.app/privacy")!)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.vaultTextMuted)
            }
        }
        .padding(.top, 8)
    }
    
    private func executePurchase() {
        isProcessing = true
        
        // Find matching product in StoreKit 2
        if let matchedProduct = storeKit.products.first(where: { $0.id == selectedTier.rawValue }) {
            Task {
                let success = await storeKit.purchase(matchedProduct)
                await MainActor.run {
                    isProcessing = false
                    if success {
                        profile.isProSubscriber = true
                        try? modelContext.save()
                        showingSuccessAlert = true
                    }
                }
            }
        } else {
            // Fallback for Simulator without live StoreKit configuration
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.isProcessing = false
                self.profile.isProSubscriber = true
                self.storeKit.isProUnlocked = true
                try? self.modelContext.save()
                self.showingSuccessAlert = true
                HapticManager.gateUnlocked()
            }
        }
    }
}

