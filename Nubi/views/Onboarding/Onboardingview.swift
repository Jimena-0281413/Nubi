//
//  Onboardingview.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 04/05/26.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var step: Int = 0
    @State private var nubiColor: Color = .nubiLightBlue
    @State private var animateIn: Bool = false

    var body: some View {
        ZStack {
            // Fondo degradado
            LinearGradient(colors: [Color.nubiParchment, Color.nubiLightBlue.opacity(0.3)],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Nubi avatar en top
                NubiAvatarView(color: nubiColor, size: 100)
                    .padding(.top, 48)
                    .scaleEffect(animateIn ? 1 : 0.5)
                    .opacity(animateIn ? 1 : 0)

                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(i == step ? Color.nubiGlaucous : Color.nubiLightBlue)
                            .frame(width: i == step ? 10 : 7, height: i == step ? 10 : 7)
                            .animation(.spring(), value: step)
                    }
                }
                .padding(.top, 16)

                // Contenido según el paso
                Group {
                    switch step {
                    case 0: welcomeStep
                    case 1: privacyStep
                    case 2: ageStep
                    case 3: positionStep
                    case 4: genderStep
                    default: EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(step) // Forces re-render with transition

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6)) { animateIn = true }
        }
    }

    // MARK: - Step 0: Bienvenida
    var welcomeStep: some View {
        VStack(spacing: 24) {
            Text("Hola 👋")
                .font(NubiFont.title)
                .foregroundColor(.nubiDark)

            Text("Este es tu espacio seguro.\nAquí puedes ser honesto/a sobre cómo te sientes,\nsin miedo y sin juicios.")
                .font(NubiFont.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.nubiDark.opacity(0.75))
                .padding(.horizontal, 32)

            VStack(alignment: .leading, spacing: 12) {
                featureRow(icon: "lock.shield.fill", text: "Tus datos son privados y cifrados")
                featureRow(icon: "eye.slash.fill", text: "Tu jefe NO tiene acceso a lo que sientes aquí")
                featureRow(icon: "heart.fill", text: "Nubi te acompañará en cada turno")
            }
            .padding(20)
            .nubiCard()
            .padding(.horizontal, 24)

            nextButton(label: "Empezar mi viaje ")
        }
        .padding(.top, 28)
    }

    // MARK: - Step 1: Privacidad
    var privacyStep: some View {
        VStack(spacing: 20) {
            Text("Tu privacidad es sagrada")
                .font(NubiFont.heading)
                .foregroundColor(.nubiDark)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.nubiGlaucous.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.nubiGlaucous, lineWidth: 1.5)
                    )

                VStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.nubiGlaucous)

                    Text("\"Tus datos son cifrados de extremo a extremo. Tu jefe no tiene acceso a lo que sientes aquí. Jamás.\"")
                        .font(NubiFont.body)
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.nubiDark)
                        .padding(.horizontal, 16)

                    Divider().padding(.horizontal, 24)

                    Text("Solo tú ves tus emociones. Los reportes empresariales son siempre anónimos y agrupados.")
                        .font(NubiFont.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.nubiDark.opacity(0.6))
                        .padding(.horizontal, 16)
                }
                .padding(24)
            }
            .padding(.horizontal, 24)

            nextButton(label: "Entendido, confío en Nubi ")
        }
        .padding(.top, 28)
    }

    // MARK: - Step 2: Edad
    var ageStep: some View {
        VStack(spacing: 24) {
            Text("¿Cuántos años tienes? ")
                .font(NubiFont.heading)
                .foregroundColor(.nubiDark)

            Text("Esto nos ayuda a personalizar tus guías y recursos")
                .font(NubiFont.body)
                .foregroundColor(.nubiDark.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            TextField("Ej: 25", text: $vm.userAge)
                .keyboardType(.numberPad)
                .font(NubiFont.heading)
                .multilineTextAlignment(.center)
                .padding(18)
                .background(Color.nubiParchment)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.nubiGlaucous, lineWidth: 1.5))
                .padding(.horizontal, 48)

            nextButton(label: "Continuar →", disabled: vm.userAge.isEmpty)
        }
        .padding(.top, 28)
    }

    // MARK: - Step 3: Puesto
    var positionStep: some View {
        VStack(spacing: 20) {
            Text("¿Cuál es tu puesto? 💼")
                .font(NubiFont.heading)
                .foregroundColor(.nubiDark)

            Text("Nubi aprenderá los retos específicos de tu rol")
                .font(NubiFont.caption)
                .foregroundColor(.nubiDark.opacity(0.6))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(WorkPosition.allCases, id: \.self) { pos in
                    Button {
                        vm.userPosition = pos
                        withAnimation(.spring()) { nubiColor = .nubiGlaucous }
                    } label: {
                        Text(pos.rawValue)
                            .font(NubiFont.body)
                            .foregroundColor(vm.userPosition == pos ? .white : .nubiDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(vm.userPosition == pos ? Color.nubiGlaucous : Color.nubiParchment)
                            .cornerRadius(14)
                            .shadow(color: .nubiGlaucous.opacity(vm.userPosition == pos ? 0.35 : 0), radius: 6)
                    }
                    .animation(.spring(), value: vm.userPosition)
                }
            }
            .padding(.horizontal, 24)

            nextButton(label: "Mi puesto está listo ✓")
        }
        .padding(.top, 28)
    }

    // MARK: - Step 4: Género / Ciclo
    var genderStep: some View {
        VStack(spacing: 20) {
            Text("Una última cosa... ✨")
                .font(NubiFont.heading)
                .foregroundColor(.nubiDark)

            Text("¿Cómo te identificas?")
                .font(NubiFont.subheading)
                .foregroundColor(.nubiDark.opacity(0.75))

            HStack(spacing: 14) {
                ForEach(["Hombre 🙋", "Mujer 🙋‍♀️", "Prefiero no decir 🤍"], id: \.self) { g in
                    Button {
                        let key = g.contains("Hombre") ? "hombre" : g.contains("Mujer") ? "mujer" : "otro"
                        vm.userGender = key
                    } label: {
                        Text(g)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(vm.userGender == (g.contains("Hombre") ? "hombre" : g.contains("Mujer") ? "mujer" : "otro") ? .white : .nubiDark)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity)
                            .background(vm.userGender == (g.contains("Hombre") ? "hombre" : g.contains("Mujer") ? "mujer" : "otro") ? Color.nubiGlaucous : Color.nubiParchment)
                            .cornerRadius(14)
                    }
                    .animation(.spring(), value: vm.userGender)
                }
            }
            .padding(.horizontal, 24)

            // Opción ciclo menstrual (solo si es mujer)
            if vm.userGender == "mujer" {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "moon.stars.fill")
                            .foregroundColor(.nubiGlaucous)
                        Text("Sincronizar con mi ciclo menstrual")
                            .font(NubiFont.body)
                            .foregroundColor(.nubiDark)
                        Spacer()
                        Toggle("", isOn: $vm.cycleSyncEnabled)
                            .tint(.nubiGlaucous)
                    }
                    .padding(16)
                    .background(Color.nubiLightBlue.opacity(0.3))
                    .cornerRadius(16)

                    Text("Esto personaliza aún más tu experiencia según tu ciclo. Si no deseas hacerlo, tu reporte semanal no se ve afectado en absoluto. ")
                        .font(NubiFont.caption)
                        .foregroundColor(.nubiDark.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Button {
                withAnimation(.spring()) {
                    vm.completeOnboarding()
                }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("¡Comenzar con Nubi!")
                }
                .nubiButton()
            }
            .disabled(vm.userGender.isEmpty)
            .opacity(vm.userGender.isEmpty ? 0.5 : 1)
            .padding(.top, 8)
        }
        .padding(.top, 20)
        .animation(.spring(), value: vm.userGender)
    }

    // MARK: - Helpers
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(.nubiGlaucous)
                .font(.system(size: 18))
                .frame(width: 24)
            Text(text)
                .font(NubiFont.body)
                .foregroundColor(.nubiDark)
        }
    }

    private func nextButton(label: String, disabled: Bool = false) -> some View {
        Button {
            withAnimation(.spring(response: 0.4)) { step += 1 }
        } label: {
            Text(label)
                .nubiButton()
        }
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
    }
}
