//
//  EmotionLongView.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 05/05/26.
//

import SwiftUI

struct EmotionLogView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedPrimary: PrimaryEmotion? = nil
    @State private var selectedSub: SubEmotion? = nil
    @State private var showConfirmation = false
    @State private var animateNubi = false

    var body: some View {
        ZStack {
            Color.nubiParchment.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ZStack {
                    LinearGradient(colors: [Color.nubiLightBlue.opacity(0.4), Color.nubiParchment],
                                   startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 160)

                    VStack(spacing: 6) {
                        Text(selectedPrimary == nil ? "¿Cómo te sientes?" : "Cuéntame más...")
                            .font(NubiFont.heading)
                            .foregroundColor(.nubiDark)
                        Text(selectedPrimary == nil
                             ? "Selecciona tu emoción principal"
                             : "¿Qué describe mejor tu \(selectedPrimary!.rawValue.lowercased())?")
                            .font(NubiFont.caption)
                            .foregroundColor(.nubiDark.opacity(0.6))
                    }
                }
                .frame(height: 90)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Nubi reactivo
                        NubiAvatarView(
                            color: selectedPrimary?.color ?? .nubiLightBlue,
                            size: 100
                        )
                        .scaleEffect(animateNubi ? 1.08 : 1)
                        .animation(.spring(response: 0.3), value: selectedPrimary?.rawValue)

                        if selectedPrimary == nil {
                            // NIVEL 1: Emociones primarias
                            primaryEmotionGrid
                        } else if selectedSub == nil {
                            // NIVEL 2: Sub-emociones
                            subEmotionGrid
                        } else {
                            // Confirmación
                            confirmationView
                        }
                    }
                    .padding(.bottom, 40)
                }
            }

            // Botón cerrar
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.nubiGlaucous.opacity(0.7))
                            .padding(16)
                    }
                }
                Spacer()
            }
        }
    }

    // MARK: - Nivel 1: Emociones primarias
    var primaryEmotionGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(PrimaryEmotion.allCases) { emotion in
                Button {
                    withAnimation(.spring(response: 0.35)) {
                        selectedPrimary = emotion
                        animateNubi = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        animateNubi = false
                    }
                } label: {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(emotion.color.opacity(0.18))
                                .frame(width: 64, height: 64)
                            Image(systemName: emotion.sfSymbol)
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(emotion.color)
                        }
                        Text(emotion.rawValue)
                            .font(NubiFont.subheading)
                            .foregroundColor(.nubiDark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(20)
                    .shadow(color: emotion.color.opacity(0.2), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(emotion.color.opacity(0.3), lineWidth: 1.5)
                    )
                }
                .buttonStyle(BounceButtonStyle())
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Nivel 2: Sub-emociones
    var subEmotionGrid: some View {
        VStack(spacing: 16) {
            // Back button
            Button {
                withAnimation(.spring()) { selectedPrimary = nil }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Volver")
                }
                .font(NubiFont.caption)
                .foregroundColor(.nubiGlaucous)
            }

            // Big emotion badge
            HStack {
                Image(systemName: selectedPrimary!.sfSymbol)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(selectedPrimary!.color)
                Text(selectedPrimary!.rawValue)
                    .font(NubiFont.heading)
                    .foregroundColor(selectedPrimary!.color)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(selectedPrimary!.color.opacity(0.12))
            .cornerRadius(20)

            // Sub-emociones
            VStack(spacing: 12) {
                ForEach(selectedPrimary!.subEmotions) { sub in
                    Button {
                        withAnimation(.spring(response: 0.35)) {
                            selectedSub = sub
                        }
                        animateNubi = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { animateNubi = false }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: sub.sfSymbol)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(selectedPrimary!.color)
                                .frame(width: 32)
                            Text(sub.label)
                                .font(NubiFont.subheading)
                                .foregroundColor(.nubiDark)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(.nubiGlaucous.opacity(0.5))
                        }
                        .padding(18)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(16)
                        .shadow(color: selectedPrimary!.color.opacity(0.12), radius: 6)
                    }
                    .buttonStyle(BounceButtonStyle())
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Confirmación
    var confirmationView: some View {
        VStack(spacing: 24) {
            // Nubi celebrando
            ZStack {
                Circle()
                    .fill(selectedPrimary!.color.opacity(0.15))
                    .frame(width: 160, height: 160)
                NubiAvatarView(color: selectedPrimary!.color, size: 110)
            }

            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.nubiGlaucous)
                    Text("Registrado")
                }
                .font(NubiFont.heading)
                .foregroundColor(.nubiDark)
                HStack(spacing: 6) {
                    Image(systemName: selectedPrimary!.sfSymbol)
                        .foregroundColor(selectedPrimary!.color)
                    Text(selectedPrimary!.rawValue)
                    Text("·")
                    Image(systemName: selectedSub!.sfSymbol)
                        .foregroundColor(selectedPrimary!.color)
                    Text(selectedSub!.label)
                }
                .font(NubiFont.body)
                .foregroundColor(.nubiDark.opacity(0.7))
                .multilineTextAlignment(.center)
            }
            .padding(20)
            .nubiCard()
            .padding(.horizontal, 32)

            Text("Nubi tomó nota de cómo te sientes hoy.\nEsta info enriquecerá tu reporte semanal.")
                .font(NubiFont.caption)
                .foregroundColor(.nubiDark.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                if let primary = selectedPrimary, let sub = selectedSub {
                    vm.registerEmotion(primary: primary, sub: sub)
                }
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("¡Listo, gracias Nubi!")
                }
                .nubiButton(color: selectedPrimary?.color ?? .nubiGlaucous)
            }

            // Botón cambiar
            Button {
                withAnimation(.spring()) {
                    selectedSub = nil
                    selectedPrimary = nil
                }
            } label: {
                Text("Cambiar mi emoción")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiGlaucous)
            }
        }
    }
}

// MARK: - Bounce Button Style
struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .animation(.spring(response: 0.25), value: configuration.isPressed)
    }
}
