import SwiftUI

struct PaywallView: View {
    @Environment(PremiumStore.self) private var premium
    @Environment(\.dismiss) private var dismiss

    private struct Feature: Hashable {
        let icon: String, title: String, text: String
    }

    private let features: [Feature] = [
        Feature(icon: "square.stack.3d.up.fill", title: "Calendarios ilimitados", text: "Uno para la pareja, otro con amigos, otro con los peques."),
        Feature(icon: "dial.medium.fill", title: "Ruleta sin límites", text: "Mete todas las pelis que queráis en la ruleta."),
        Feature(icon: "fork.knife", title: "Tus propios menús", text: "Crea recetas con su tiempo de preparación y avisos."),
        Feature(icon: "heart.fill", title: "Apoyas la app", text: "Sin anuncios y sin suscripción: pagas una vez."),
    ]

    var body: some View {
        ZStack {
            AppBackground()
            MagicSparkles(burst: nil)
            ScrollView {
                VStack(spacing: 22) {
                    Text("👑").font(.system(size: 80)).padding(.top, 50)
                    Text("CineAdviento Premium")
                        .font(Theme.serif(32))
                        .foregroundStyle(LinearGradient(colors: [Theme.cream, Theme.gold], startPoint: .top, endPoint: .bottom))
                    Text("Haz que cada noche de peli sea un evento")
                        .font(.headline)
                        .foregroundStyle(Theme.cream.opacity(0.85))

                    GlassEffectContainer(spacing: 12) {
                        VStack(spacing: 12) {
                            ForEach(features, id: \.self) { feature in
                                HStack(alignment: .top, spacing: 14) {
                                    Image(systemName: feature.icon)
                                        .font(.title3)
                                        .foregroundStyle(Theme.gold)
                                        .frame(width: 30)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(feature.title).font(.headline).foregroundStyle(Theme.cream)
                                        Text(feature.text).font(.subheadline).foregroundStyle(Theme.cream.opacity(0.75))
                                    }
                                    Spacer(minLength: 0)
                                }
                                .padding(16)
                                .glassCard(20)
                            }
                        }
                    }

                    if premium.isPremium {
                        Label("Ya eres Premium", systemImage: "checkmark.seal.fill")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Theme.gold)
                    } else {
                        Button {
                            Task { await premium.purchase() }
                        } label: {
                            Group {
                                if premium.isPurchasing {
                                    ProgressView()
                                } else {
                                    Text("Desbloquear por \(premium.priceText)")
                                }
                            }
                            .font(.title3.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.glassProminent)
                        .disabled(premium.isPurchasing)

                        Button("Restaurar compras") { Task { await premium.restore() } }
                            .buttonStyle(.glass)
                    }

                    if let message = premium.errorMessage {
                        Text(message).font(.footnote).foregroundStyle(Theme.cream.opacity(0.8))
                    }

                    #if DEBUG
                    Button(premium.isPremium ? "DEBUG: quitar Premium" : "DEBUG: activar Premium sin pagar") {
                        premium.debugUnlock(!premium.isPremium)
                    }
                    .font(.footnote)
                    #endif
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: { Image(systemName: "xmark").font(.headline).padding(6) }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .padding(16)
        }
    }
}
