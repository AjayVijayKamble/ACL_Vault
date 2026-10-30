//
//  StoreKitManager.swift
//  ACLVault
//
//  StoreKit 2 Subscription & In-App Purchase Engine
//

import Foundation
import StoreKit
import SwiftUI

public enum SubscriptionTier: String, CaseIterable, Identifiable, Sendable {
    case monthly = "com.aclvault.pro.monthly"
    case annual = "com.aclvault.pro.annual"
    case lifetime = "com.aclvault.pro.lifetime"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .monthly: return "Monthly Pro"
        case .annual: return "Full 12-Month Recovery"
        case .lifetime: return "Lifetime Pass"
        }
    }
    
    public var priceFormatted: String {
        switch self {
        case .monthly: return "$6.99 / mo"
        case .annual: return "$39.99 / yr"
        case .lifetime: return "$59.99 once"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .monthly: return "Cancel anytime. Billed monthly."
        case .annual: return "Just $3.33/mo • Save 52% on your complete 1-year recovery"
        case .lifetime: return "One-time payment. Never pay a recurring fee."
        }
    }
    
    public var isBestValue: Bool {
        return self == .annual
    }
}

@Observable
@MainActor
public final class StoreKitManager {
    public static let shared = StoreKitManager()
    
    public var products: [Product] = []
    public var purchasedProductIDs: Set<String> = []
    public var isProUnlocked: Bool = false
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    private var transactionListenerTask: Task<Void, Never>? = nil
    
    public init() {
        self.transactionListenerTask = Task { [weak self] in
            for await result in StoreKit.Transaction.updates {
                guard let self = self else { break }
                do {
                    let transaction = try Self.checkVerified(result)
                    self.updatePurchasedIdentifiers(transaction)
                    await transaction.finish()
                } catch {
                    // Unverified transaction
                }
            }
        }
        
        Task {
            await self.loadProductsAndPurchases()
        }
    }
    
    // MARK: - Load Products from StoreKit
    public func loadProductsAndPurchases() async {
        self.isLoading = true
        self.errorMessage = nil
        
        let productIdentifiers = SubscriptionTier.allCases.map { $0.rawValue }
        
        do {
            let fetchedProducts = try await Product.products(for: productIdentifiers)
            self.products = fetchedProducts.sorted(by: { $0.price < $1.price })
            await self.updateSubscriptionStatus()
        } catch {
            self.errorMessage = "Unable to connect to App Store: \(error.localizedDescription)"
        }
        
        self.isLoading = false
    }
    
    // MARK: - Purchase Flow
    public func purchase(_ product: Product) async -> Bool {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try Self.checkVerified(verification)
                self.updatePurchasedIdentifiers(transaction)
                await transaction.finish()
                HapticManager.gateUnlocked()
                self.isLoading = false
                return true
                
            case .userCancelled:
                self.isLoading = false
                return false
                
            case .pending:
                self.isLoading = false
                return false
                
            @unknown default:
                self.isLoading = false
                return false
            }
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            return false
        }
    }
    
    // MARK: - Restore Purchases
    public func restorePurchases() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            HapticManager.repCompleted()
        } catch {
            self.errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }
        
        self.isLoading = false
    }
    
    // MARK: - Demo / Simulator Unlock Toggle
    public func toggleDemoProAccess(profile: UserProfile) {
        self.isProUnlocked.toggle()
        profile.isProSubscriber = self.isProUnlocked
        HapticManager.gateUnlocked()
    }
    
    // MARK: - Static Verification Helper
    public static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
    
    public func updatePurchasedIdentifiers(_ transaction: StoreKit.Transaction) {
        if transaction.revocationDate == nil {
            self.purchasedProductIDs.insert(transaction.productID)
            self.isProUnlocked = true
        } else {
            self.purchasedProductIDs.remove(transaction.productID)
            self.isProUnlocked = !self.purchasedProductIDs.isEmpty
        }
    }
    
    public func updateSubscriptionStatus() async {
        var activeIDs: Set<String> = []
        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.revocationDate == nil {
                    activeIDs.insert(transaction.productID)
                }
            }
        }
        self.purchasedProductIDs = activeIDs
        self.isProUnlocked = !activeIDs.isEmpty
    }
}
