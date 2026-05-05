//
//  OnboardingView.swift
//  Nubi
//
//  Created by Max Lozano on 5/5/26.
//


//
//  Onboardingview.swift
//  Nubi
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var step: Int      = 0
    @State private var nubiColor: Color = .nubiLightBlue
    @State private var animateIn: Bool  = false

    // Total de pasos: 0=Bienvenida, 1=Privacidad, 2=Nombre, 3=Edad,
    //                 4=Género(+ciclo), 5=Puesto, 6=Estresores, 7=Rol familiar
    private let totalSteps = 8

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.nubiParchment, Color.nubiLightBlue.opacity(0.35)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Nubi avatar ──────────────────────────────────────
                NubiAvatarView(color: nubiColor, size: 90)
                    .padding(.top, 44)
                    .scaleEffect(animateIn ? 1 : 0.4)
                    .opacity(animateIn ? 1 : 0)
                    .animation(.spring(response: 0.55), value: animateIn)

                // ── Progress dots ─────────────────────────────────────
                HStack(spacing: 6) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        Capsule()
                            .fill(i <= step ? Color.nubiGlaucous : Color.nubiLightBlue)
                            .frame(width: i == step ? 22 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: step)
                    }
                }
                .padding(.top, 14)
                .padding(.bottom, 4)

                // Etiqueta de paso
                Text("Paso \(max(step - 1, 1)) de \(totalSteps - 2)")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiDark.opacity(0.4))
                    .opacity(step >= 2 ? 1 : 0)
                    .padding(.bottom, 6)

                // ── Contenido por paso ────────────────────────────────
                Group {
                    switch step {
                    case 0: welcomeStep
                    case 1: privacyStep
                    case 2: nameStep
                    case 3: ageStep
                    case 4: genderStep
                    case 5: positionStep
                    case 6: stressorsStep
                    case 7: familyRoleStep
                    default: EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
                .id(step)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6)) { animateIn = true }
        }
    }

    // ════════════════════════════════════════════════
    // MARK: STEP 0 – Bienvenida
    // ════════════════════════════════════════════════
    var welcomeStep: some View {
        VStack(spacing: 22) {
            Text("Hola 👋")
                .font(NubiFont.title)
                .foregroundColor(.nubiDark)

            Text("Este es tu espacio seguro.\nAquí puedes ser honesto/a\nsobre cómo te sientes,\nsin miedo y sin juicios.")
                .font(NubiFont.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.nubiDark.opacity(0.75))
                .padding(.horizontal, 28)

            VStack(alignment: .leading, spacing: 14) {
                featureRow(icon: "lock.shield.fill",  text: "Tus datos son privados y cifrados")
                featureRow(icon: "eye.slash.fill",    text: "Tu jefe NO ve lo que sientes aquí")
                featureRow(icon: "heart.fill",        text: "Nubi te acompaña en cada turno")
            }
            .padding(18)
            .nubiCard()
            .padding(.horizontal, 24)

            nextButton(label: "Empezar mi viaje")
        }
        .padding(.top, 20)
    }

    // ════════════════════════════════════════════════
    // MARK: STEP 1 – Privacidad
    // ════════════════════════════════════════════════
    var privacyStep: some View {
        VStack(spacing: 20) {
            Text("Tu privacidad es sagrada")
                .font(NubiFont.heading)
                .foregroundColor(.nubiDark)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.nubiGlaucous.opacity(0.1))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.nubiGlaucous, lineWidth: 1.5))

                VStack(spacing: 14) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.nubiGlaucous)

                    Text("Tus datos son cifrados de extremo a extremo. Tu jefe no tiene acceso a lo que sientes aquí. Jamás.")
                        .font(NubiFont.body)
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.nubiDark)
                        .padding(.horizontal, 14)

                    Divider().padding(.horizontal, 20)

                    Text("Los reportes empresariales son siempre anónimos y agrupados. Nubi solo trabaja para ti.")
                        .font(NubiFont.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.nubiDark.opacity(0.6))
                        .padding(.horizontal, 14)
                }
                .padding(22)
            }
            .padding(.horizontal, 24)

            nextButton(label: "Entendido, confío en Nubi")
        }
        .padding(.top, 20)
    }

    // ════════════════════════════════════════════════
    // MARK: STEP 2 – Nombre
    // ════════════════════════════════════════════════
    var nameStep: some View {
        VStack(spacing: 24) {
            stepHeader(
                sfSymbol: "person.fill",
                title: "¿Cómo te llamas?",
                subtitle: "Así Nubi podrá hablarte de manera más personal"
            )

            TextField("Tu nombre", text: $vm.userName)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(18)
                .background(Color.white.opacity(0.8))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.nubiGlaucous.opacity(vm.userName.isEmpty ? 0.3 : 1), lineWidth: 1.5))
                .padding(.horizontal, 40)
                .autocorrectionDisabled()
                .onChange(of: vm.userName) { _ in
                    withAnimation { nubiColor = vm.userName.isEmpty ? .nubiLightBlue : .nubiGlaucous }
                }

            if !vm.userName.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "sun.min.fill")
                        .foregroundColor(.nubiGlaucous)
                    Text("¡Hola, \(vm.userName)!")
                }
                .font(NubiFont.subheading)
                .foregroundColor(.nubiGlaucous)
                .transition(.scale.combined(with: .opacity))
            }

            nextButton(label: "Ese es mi nombre →",
                       disabled: vm.userName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.top, 20)
    }

    // ════════════════════════════════════════════════
    // MARK: STEP 3 – Edad
    // ════════════════════════════════════════════════
    var ageStep: some View {
        VStack(spacing: 24) {
            stepHeader(
                sfSymbol: "birthday.cake.fill",
                title: "¿Cuántos años tienes?",
                subtitle: "Personalizamos guías y recomendaciones según tu etapa de vida"
            )

            TextField("Ej: 28", text: $vm.userAge)
                .keyboardType(.numberPad)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(18)
                .background(Color.white.opacity(0.8))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.nubiGlaucous.opacity(vm.userAge.isEmpty ? 0.3 : 1), lineWidth: 1.5))
                .padding(.horizontal, 80)

            Text("Tus datos nunca se compartirán con tu empresa")
                .font(NubiFont.caption)
                .foregroundColor(.nubiDark.opacity(0.45))

            nextButton(label: "Continuar →",
                       disabled: vm.userAge.isEmpty)
        }
        .padding(.top, 20)
    }

    // ════════════════════════════════════════════════
    // MARK: STEP 4 – Género + Ciclo
    // ════════════════════════════════════════════════
    var genderStep: some View {
        VStack(spacing: 20) {
            stepHeader(
                sfSymbol: "person.and.background.striped.horizontal",
                title: "¿Cómo te identificas?",
                subtitle: "Esto nos ayuda a darte recomendaciones más personalizadas"
            )

            HStack(spacing: 12) {
                genderChip(label: "Hombre", key: "hombre")
                genderChip(label: "Mujer", key: "mujer")
                genderChip(label: "Prefiero\nno decir", key: "otro")
            }
            .padding(.horizontal, 20)

            // Opción ciclo menstrual (solo si es mujer)
            if vm.userGender == "mujer" {
                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .foregroundColor(.nubiGlaucous)
                            .font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Seguimiento del ciclo menstrual")
                                .font(NubiFont.body)
                                .foregroundColor(.nubiDark)
                            Text("Optimiza recomendaciones de energía")
                                .font(NubiFont.caption)
                                .foregroundColor(.nubiDark.opacity(0.55))
                        }
                        Spacer()
                        Toggle("", isOn: $vm.cycleSyncEnabled)
                            .tint(.nubiGlaucous)
                    }

                    Text("Completamente opcional. Si no lo activas, tu reporte semanal funciona igual de bien.")
                        .font(NubiFont.caption)
                        .foregroundColor(.nubiDark.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(16)
                .background(Color.nubiLightBlue.opacity(0.25))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.35), value: vm.userGender)
            }

            nextButton(label: "Así es como me identifico →",
                       disabled: vm.userGender.isEmpty)
        }
        .padding(.top, 16)
    }

    // ════════════════════════════════════════════════
    // MARK: STEP 5 – Puesto de trabajo
    // ════════════════════════════════════════════════
    var positionStep: some View {
        VStack(spacing: 18) {
            stepHeader(
                sfSymbol: "briefcase.fill",
                title: "¿Cuál es tu puesto?",
                subtitle: "Nubi aprenderá los retos específicos de tu rol en Coppel"
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(WorkPosition.allCases, id: \.self) { pos in
                    Button {
                        withAnimation(.spring()) { vm.userPosition = pos }
                    } label: {
                        Text(pos.rawValue)
                            .font(NubiFont.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(vm.userPosition == pos ? .white : .nubiDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(vm.userPosition == pos
                                        ? Color.nubiGlaucous
                                        : Color.white.opacity(0.7))
                            .cornerRadius(14)
                            .shadow(color: .nubiGlaucous.opacity(vm.userPosition == pos ? 0.35 : 0.05),
                                    radius: 6)
                    }
                    .animation(.spring(), value: vm.userPosition)
                }
            }
            .padding(.horizontal, 22)

            nextButton(label: "Este es mi puesto ✓")
        }
        .padding(.top, 16)
    }

    // ════════════════════════════════════════════════
    // MARK: STEP 6 – Estresores laborales (multi-select)
    // ════════════════════════════════════════════════
    var stressorsStep: some View {
        VStack(spacing: 16) {
            stepHeader(
                sfSymbol: "figure.mind.and.body",
                title: "¿Qué te estresa\nmás en el trabajo?",
                subtitle: "Selecciona todos los que apliquen. Nubi lo usará en tu reporte."
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(WorkStressor.allCases) { stressor in
                    Button {
                        withAnimation(.spring(response: 0.25)) {
                            if vm.workStressors.contains(stressor) {
                                vm.workStressors.remove(stressor)
                            } else {
                                vm.workStressors.insert(stressor)
                            }
                        }
                    } label: {
                        let selected = vm.workStressors.contains(stressor)
                        HStack(spacing: 6) {
                            Image(systemName: stressor.sfSymbol)
                                .font(.system(size: 14))
                                .foregroundColor(selected ? .white : .nubiGlaucous)
                            Text(stressor.rawValue)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .multilineTextAlignment(.leading)
                                .foregroundColor(selected ? .white : .nubiDark)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(selected ? Color.nubiGlaucous : Color.white.opacity(0.75))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selected ? Color.nubiGlaucous : Color.nubiLightBlue, lineWidth: 1.5)
                        )
                        .shadow(color: Color.nubiGlaucous.opacity(selected ? 0.25 : 0.05), radius: 4)
                    }
                    .buttonStyle(BounceButtonStyle())
                }
            }
            .padding(.horizontal, 20)

            if !vm.workStressors.isEmpty {
                Text("Seleccionaste \(vm.workStressors.count) \(vm.workStressors.count == 1 ? "estresor" : "estresores")")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiGlaucous)
            }

            nextButton(label: vm.workStressors.isEmpty ? "Saltar este paso →" : "Listo, continuar →")
        }
        .padding(.top, 12)
    }

    // ════════════════════════════════════════════════
    // MARK: STEP 7 – Rol familiar
    // ════════════════════════════════════════════════
    var familyRoleStep: some View {
        VStack(spacing: 18) {
            stepHeader(
                sfSymbol: "house.fill",
                title: "¿Cuál es tu rol\nen la familia?",
                subtitle: "El contexto familiar influye mucho en cómo gestionamos el estrés"
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(FamilyRole.allCases, id: \.self) { role in
                    Button {
                        withAnimation(.spring()) { vm.familyRole = role }
                    } label: {
                        let selected = vm.familyRole == role
                        VStack(spacing: 6) {
                            Image(systemName: role.sfSymbol)
                                .font(.system(size: 26))
                                .foregroundColor(selected ? .white : .nubiGlaucous)
                            Text(role.rawValue)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundColor(selected ? .white : .nubiDark)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(selected ? Color.nubiGlaucous : Color.white.opacity(0.75))
                        .cornerRadius(16)
                        .shadow(color: Color.nubiGlaucous.opacity(selected ? 0.35 : 0.05), radius: 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selected ? Color.nubiGlaucous : Color.nubiLightBlue.opacity(0.6),
                                        lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(BounceButtonStyle())
                    .animation(.spring(), value: vm.familyRole)
                }
            }
            .padding(.horizontal, 20)

            // Botón final
            Button {
                withAnimation(.spring(response: 0.4)) {
                    vm.completeOnboarding()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                    Text("¡Comenzar con Nubi!")
                }
                .nubiButton()
            }
            .padding(.top, 4)
        }
        .padding(.top, 14)
    }

    // ════════════════════════════════════════════════
    // MARK: - Helpers & Sub-components
    // ════════════════════════════════════════════════

    private func stepHeader(sfSymbol: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: sfSymbol)
                .font(.system(size: 44, weight: .semibold))
                .foregroundColor(.nubiGlaucous)
            Text(title)
                .font(NubiFont.heading)
                .foregroundColor(.nubiDark)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(NubiFont.caption)
                .foregroundColor(.nubiDark.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private func genderChip(label: String, key: String) -> some View {
        Button {
            withAnimation(.spring()) { vm.userGender = key }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(vm.userGender == key ? .white : .nubiDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(vm.userGender == key ? Color.nubiGlaucous : Color.white.opacity(0.75))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(vm.userGender == key ? Color.nubiGlaucous : Color.nubiLightBlue,
                                lineWidth: 1.5)
                )
        }
        .animation(.spring(), value: vm.userGender)
    }

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
        .opacity(disabled ? 0.45 : 1)
    }
}
