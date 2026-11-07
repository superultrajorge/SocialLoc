import Foundation
import Observation
import StoreKit

/// Compra única "CineAdviento Premium" con StoreKit 2.
/// Crea el producto con este ID en App Store Connect antes de publicar.
@MainActor
@Observable
final class PremiumStore {
    static let productID = "com.cineadviento.premium"

    var product: Product?
    var isPremium = UserDefaults.standard.bool(forKey: "premium")
    var isPurchasing = false
    var errorMessage: String?

    private var updates: Task<Void, Never>?

    init() {
        updates = Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    self?.refresh(transaction)
                }
            }
        }
    }

    var priceText: String { product?.displayPrice ?? "4,99 €" }

    func load() async {
        product = try? await Product.products(for: [Self.productID]).first
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result { refresh(transaction) }
        }
    }

    func purchase() async {
        guard let product else {
            errorMessage = "La tienda no está disponible todavía. Prueba más tarde."
            return
        }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            if case .success(let verification) = result, case .verified(let transaction) = verification {
                await transaction.finish()
                refresh(transaction)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await load()
    }

    /// Solo para pruebas desde Xcode.
    func debugUnlock(_ value: Bool) { setPremium(value) }

    private func refresh(_ transaction: Transaction) {
        if transaction.productID == Self.productID { setPremium(transaction.revocationDate == nil) }
    }

    private func setPremium(_ value: Bool) {
        isPremium = value
        UserDefaults.standard.set(value, forKey: "premium")
    }
}
