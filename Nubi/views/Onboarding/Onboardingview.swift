//
//  Onboardingview.swift
//  Nubi
//
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var step: Int = 0
    @State private var nubiColor: Color = .nubiLightBlue
    @State private var animateIn: Bool = false

    private let totalSteps = 10

    /// Los primeros 2 pasos (Coppel ID) usan paleta amarillo/azul Coppel.
    /// Los demás pasos usan la paleta Nubi normal.
    private var isCoppelStep: Bool { step <= 1 }

    var body: some View {
        ZStack {
            backgroundLayer.ignoresSafeArea()

            VStack(spacing: 0) {
                if !isCoppelStep {
                    NubiAvatarView(color: nubiColor, size: 90)
                        .padding(.top, 36)
                        .scaleEffect(animateIn ? 1 : 0.4).opacity(animateIn ? 1 : 0)
                        .animation(.spring(response: 0.55), value: animateIn)
                }

                progressDots.padding(.top, isCoppelStep ? 56 : 14).padding(.bottom, 4)

                if step >= 2 {
                    Text("Paso \(step - 1) de \(totalSteps - 2)")
                        .font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.4))
                        .padding(.bottom, 6)
                }

                Group {
                    switch step {
                    case 0: coppelWelcomeStep
                    case 1: coppelIdStep
                    case 2: privacyStep
                    case 3: nameStep
                    case 4: ageStep
                    case 5: genderStep
                    case 6: positionStep
                    case 7: stressorsStep
                    case 8: familyRoleStep
                    case 9: transportStep
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
        .onTapGesture { hideKeyboard() }
        .onAppear { withAnimation(.spring(response: 0.6)) { animateIn = true } }
    }

    /// Fondo: amarillo/azul Coppel para los primeros pasos, normal para los demás
    @ViewBuilder
    private var backgroundLayer: some View {
        if isCoppelStep {
            LinearGradient(colors: [Color(hex: "#FFF2A1"), Color(hex: "#FFE873")],
                           startPoint: .top, endPoint: .bottom)
        } else {
            LinearGradient(colors: [Color.coppelBackground, Color(hex: "#FFF2A1").opacity(0.6)],
                           startPoint: .top, endPoint: .bottom)
        }
    }

    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { i in
                Capsule()
                    .fill(i <= step
                          ? (isCoppelStep ? Color(hex: "#191942") : Color.coppelButton)
                          : Color.coppelDeepBlue.opacity(0.2))
                    .frame(width: i == step ? 22 : 7, height: 7)
                    .animation(.spring(response: 0.3), value: step)
            }
        }
    }

    // MARK: - STEP 0 — Bienvenida Coppel
    var coppelWelcomeStep: some View {
        VStack(spacing: 28) {
            Spacer().frame(height: 20)

            Image(systemName: "building.2.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "#191942"))

            VStack(spacing: 12) {
                Text("Bienvenido a Nubi")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "#191942"))
                Text("Tu compañero de bienestar emocional en Coppel")
                    .font(NubiFont.body)
                    .foregroundColor(Color(hex: "#191942").opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(alignment: .leading, spacing: 12) {
                coppelFeatureRow(icon: "lock.shield.fill", text: "100% confidencial. Tu jefe NO ve lo que sientes aquí.")
                coppelFeatureRow(icon: "heart.text.square.fill", text: "Apoyo emocional gratuito como beneficio de Coppel.")
                coppelFeatureRow(icon: "person.badge.shield.checkmark.fill", text: "Acceso directo a psicólogos certificados.")
            }
            .padding(20)
            .background(Color.white.opacity(0.6))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "#191942").opacity(0.15), lineWidth: 1))
            .padding(.horizontal, 22)

            coppelNextButton(label: "Empezar")
        }
    }

    private func coppelFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#191942"))
                .font(.system(size: 18))
                .frame(width: 24)
            Text(text)
                .font(NubiFont.body)
                .foregroundColor(Color(hex: "#191942"))
        }
    }

    // MARK: - STEP 1 — Worker Number + CEDI/Tienda
    var coppelIdStep: some View {
        VStack(spacing: 22) {
            Spacer().frame(height: 12)

            ZStack {
                Circle()
                    .fill(Color(hex: "#191942"))
                    .frame(width: 80, height: 80)
                Image(systemName: "person.text.rectangle.fill")
                    .font(.system(size: 38))
                    .foregroundColor(Color(hex: "#FFF2A1"))
            }

            VStack(spacing: 8) {
                Text("Identifícate")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#191942"))
                Text("Necesitamos tu número de trabajador y CEDI o tienda asignada")
                    .font(NubiFont.caption)
                    .foregroundColor(Color(hex: "#191942").opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 14) {
                // Worker number
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "number.circle.fill").foregroundColor(Color(hex: "#191942"))
                        Text("Número de trabajador")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#191942"))
                    }
                    TextField("Ej: 123456", text: $vm.workerNumber)
                        .keyboardType(.numberPad)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#191942").opacity(vm.workerNumber.isEmpty ? 0.2 : 0.6), lineWidth: 1.5))
                }

                // CEDI / Tienda
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "building.2.fill").foregroundColor(Color(hex: "#191942"))
                        Text("CEDI o Tienda")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#191942"))
                    }
                    TextField("Ej: CEDI Toluca, Tienda Centro CDMX...", text: $vm.cediOrStore)
                        .font(.system(size: 16, design: .rounded))
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#191942").opacity(vm.cediOrStore.isEmpty ? 0.2 : 0.6), lineWidth: 1.5))
                }
            }
            .padding(.horizontal, 22)

            HStack(spacing: 6) {
                Image(systemName: "lock.fill").font(.system(size: 11)).foregroundColor(Color(hex: "#191942").opacity(0.5))
                Text("Esta información es confidencial y no se comparte con tu jefe directo.")
                    .font(NubiFont.caption).foregroundColor(Color(hex: "#191942").opacity(0.55)).multilineTextAlignment(.center)
            }
            .padding(.horizontal, 22)

            coppelNextButton(label: "Continuar",
                             disabled: vm.workerNumber.isEmpty || vm.cediOrStore.isEmpty)
        }
    }

    private func coppelNextButton(label: String, disabled: Bool = false) -> some View {
        Button {
            withAnimation(.spring(response: 0.4)) { step += 1 }
        } label: {
            HStack(spacing: 8) {
                Text(label)
                Image(systemName: "arrow.right.circle.fill")
            }
            .foregroundColor(Color(hex: "#FFF2A1"))
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .padding(.horizontal, 32).padding(.vertical, 14)
            .background(LinearGradient(colors: [Color(hex: "#191942"), Color(hex: "#234DB0")],
                                       startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(16)
            .shadow(color: Color(hex: "#191942").opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(disabled).opacity(disabled ? 0.5 : 1)
    }

    // MARK: - STEP 2 — Privacidad
    var privacyStep: some View {
        VStack(spacing: 18) {
            Text("Tu privacidad es sagrada").font(NubiFont.heading).foregroundColor(.coppelDeepBlue)

            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(Color.coppelButton.opacity(0.1))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.coppelButton, lineWidth: 1.5))
                VStack(spacing: 14) {
                    Image(systemName: "lock.shield.fill").font(.system(size: 44)).foregroundColor(.coppelButton)
                    Text("Tus datos son cifrados de extremo a extremo. Tu jefe no tiene acceso a lo que sientes aquí. Jamás.")
                        .font(NubiFont.body).italic().multilineTextAlignment(.center)
                        .foregroundColor(.coppelDeepBlue).padding(.horizontal, 14)
                    Divider().padding(.horizontal, 20)
                    Text("Los reportes empresariales son siempre anónimos y agrupados.")
                        .font(NubiFont.caption).multilineTextAlignment(.center)
                        .foregroundColor(.coppelDeepBlue.opacity(0.6)).padding(.horizontal, 14)
                }
                .padding(22)
            }
            .padding(.horizontal, 22)

            nextButton(label: "Confío en Nubi")
        }
        .padding(.top, 16)
    }

    // MARK: - STEP 3 — Nombre
    var nameStep: some View {
        VStack(spacing: 22) {
            stepHeader(icon: "person.fill", title: "¿Cómo te llamas?",
                       subtitle: "Así Nubi podrá hablarte de manera más personal")
            TextField("Tu nombre", text: $vm.userName)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center).padding(18)
                .background(Color.white).cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.coppelButton.opacity(vm.userName.isEmpty ? 0.3 : 1), lineWidth: 1.5))
                .padding(.horizontal, 40).autocorrectionDisabled()
                .onChange(of: vm.userName) { _ in
                    withAnimation { nubiColor = vm.userName.isEmpty ? .nubiLightBlue : .coppelButton }
                }
            if !vm.userName.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "sun.max.fill").foregroundColor(.coppelButton)
                    Text("Hola, \(vm.userName)").font(NubiFont.subheading).foregroundColor(.coppelButton)
                }
                .transition(.scale.combined(with: .opacity))
            }
            nextButton(label: "Continuar",
                       disabled: vm.userName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.top, 16)
    }

    // MARK: - STEP 4 — Edad
    var ageStep: some View {
        VStack(spacing: 22) {
            stepHeader(icon: "calendar.circle.fill", title: "¿Cuántos años tienes?",
                       subtitle: "Personalizamos guías según tu etapa de vida")
            TextField("Ej: 28", text: $vm.userAge)
                .keyboardType(.numberPad)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .multilineTextAlignment(.center).padding(18)
                .background(Color.white).cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.coppelButton.opacity(vm.userAge.isEmpty ? 0.3 : 1), lineWidth: 1.5))
                .padding(.horizontal, 80)
            nextButton(label: "Continuar", disabled: vm.userAge.isEmpty)
        }
        .padding(.top, 16)
    }

    // MARK: - STEP 5 — Género + Ciclo
    var genderStep: some View {
        VStack(spacing: 18) {
            stepHeader(icon: "person.crop.circle.fill", title: "¿Cómo te identificas?",
                       subtitle: "Esto nos ayuda a darte recomendaciones más personalizadas")
            HStack(spacing: 10) {
                genderChip(label: "Hombre", icon: "person.fill", key: "hombre")
                genderChip(label: "Mujer",  icon: "person.fill", key: "mujer")
                genderChip(label: "No decir", icon: "person.crop.circle", key: "otro")
            }
            .padding(.horizontal, 20)

            if vm.userGender == "mujer" {
                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill").foregroundColor(.coppelButton).font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Seguimiento del ciclo menstrual")
                                .font(NubiFont.body).foregroundColor(.coppelDeepBlue)
                            Text("Optimiza recomendaciones de energía y desbloquea Energía Vital")
                                .font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.55))
                        }
                        Spacer()
                        Toggle("", isOn: $vm.cycleSyncEnabled).tint(.coppelButton)
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle").font(.system(size: 11)).foregroundColor(.coppelDeepBlue.opacity(0.4))
                        Text("Completamente opcional. Tu reporte funciona igual sin activarlo.")
                            .font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.5)).multilineTextAlignment(.leading)
                    }
                }
                .padding(16).background(Color.coppelYellow.opacity(0.6)).cornerRadius(16)
                .padding(.horizontal, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.35), value: vm.userGender)
            }
            nextButton(label: "Continuar", disabled: vm.userGender.isEmpty)
        }
        .padding(.top, 12)
    }

    // MARK: - STEP 6 — Puesto
    var positionStep: some View {
        VStack(spacing: 16) {
            stepHeader(icon: "briefcase.fill", title: "¿Cuál es tu puesto?",
                       subtitle: "Nubi aprenderá los retos específicos de tu rol")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(WorkPosition.allCases, id: \.self) { pos in
                    Button {
                        withAnimation(.spring()) { vm.userPosition = pos }
                    } label: {
                        Text(pos.rawValue)
                            .font(NubiFont.body).multilineTextAlignment(.center)
                            .foregroundColor(vm.userPosition == pos ? .white : .coppelDeepBlue)
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(vm.userPosition == pos ? Color.coppelButton : Color.white.opacity(0.85))
                            .cornerRadius(14)
                            .shadow(color: .coppelButton.opacity(vm.userPosition == pos ? 0.3 : 0.05), radius: 6)
                    }
                    .animation(.spring(), value: vm.userPosition)
                }
            }
            .padding(.horizontal, 22)
            nextButton(label: "Continuar")
        }
        .padding(.top, 12)
    }

    // MARK: - STEP 7 — Estresores
    var stressorsStep: some View {
        VStack(spacing: 14) {
            stepHeader(icon: "exclamationmark.triangle.fill",
                       title: "¿Qué te estresa\nmás en el trabajo?",
                       subtitle: "Selecciona los que apliquen. Nubi lo usará en tu reporte.")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(WorkStressor.allCases) { stressor in
                    Button {
                        withAnimation(.spring(response: 0.25)) {
                            if vm.workStressors.contains(stressor) {
                                vm.workStressors.remove(stressor)
                            } else { vm.workStressors.insert(stressor) }
                        }
                    } label: {
                        let selected = vm.workStressors.contains(stressor)
                        HStack(spacing: 8) {
                            Image(systemName: stressor.sfSymbol).font(.system(size: 14))
                                .foregroundColor(selected ? .white : .coppelButton)
                            Text(stressor.rawValue)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .multilineTextAlignment(.leading)
                                .foregroundColor(selected ? .white : .coppelDeepBlue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12).padding(.horizontal, 12)
                        .background(selected ? Color.coppelButton : Color.white.opacity(0.85))
                        .cornerRadius(14)
                    }
                    .buttonStyle(BounceButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            nextButton(label: vm.workStressors.isEmpty ? "Saltar este paso" : "Continuar")
        }
        .padding(.top, 8)
    }

    // MARK: - STEP 8 — Rol familiar
    var familyRoleStep: some View {
        VStack(spacing: 16) {
            stepHeader(icon: "house.fill", title: "¿Cuál es tu rol\nen la familia?",
                       subtitle: "El contexto familiar influye en cómo gestionamos el estrés")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(FamilyRole.allCases, id: \.self) { role in
                    Button {
                        withAnimation(.spring()) { vm.familyRole = role }
                    } label: {
                        let selected = vm.familyRole == role
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(selected ? Color.white.opacity(0.25) : Color.coppelButton.opacity(0.15))
                                    .frame(width: 46, height: 46)
                                Image(systemName: role.sfSymbol)
                                    .font(.system(size: 22))
                                    .foregroundColor(selected ? .white : .coppelButton)
                            }
                            Text(role.rawValue)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundColor(selected ? .white : .coppelDeepBlue)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(selected ? Color.coppelButton : Color.white.opacity(0.85))
                        .cornerRadius(16)
                    }
                    .buttonStyle(BounceButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            nextButton(label: "Continuar")
        }
        .padding(.top, 10)
    }

    // MARK: - STEP 9 — Transporte (NUEVO)
    var transportStep: some View {
        VStack(spacing: 18) {
            stepHeader(icon: "map.fill",
                       title: "¿Cómo llegas\nal trabajo?",
                       subtitle: "Tu rutina de transporte afecta tu energía diaria")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(TransportType.allCases, id: \.self) { t in
                    Button {
                        withAnimation(.spring()) { vm.transportType = t }
                    } label: {
                        let selected = vm.transportType == t
                        HStack(spacing: 10) {
                            Image(systemName: t.sfSymbol)
                                .font(.system(size: 18))
                                .foregroundColor(selected ? .white : .coppelButton)
                            Text(t.rawValue)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(selected ? .white : .coppelDeepBlue)
                            Spacer()
                        }
                        .padding(.vertical, 14).padding(.horizontal, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(selected ? Color.coppelButton : Color.white.opacity(0.85))
                        .cornerRadius(14)
                    }
                    .buttonStyle(BounceButtonStyle())
                    .animation(.spring(), value: vm.transportType)
                }
            }
            .padding(.horizontal, 20)

            Button {
                withAnimation(.spring(response: 0.4)) { vm.completeOnboarding() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Comenzar con Nubi")
                }
                .nubiButton()
            }
            .padding(.top, 8)
        }
        .padding(.top, 10)
    }

    // MARK: - Helpers
    private func stepHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(Color.coppelButton.opacity(0.12)).frame(width: 64, height: 64)
                Image(systemName: icon).font(.system(size: 30)).foregroundColor(.coppelButton)
            }
            Text(title).font(NubiFont.heading).foregroundColor(.coppelDeepBlue).multilineTextAlignment(.center)
            Text(subtitle).font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.6))
                .multilineTextAlignment(.center).padding(.horizontal, 32)
        }
    }

    private func genderChip(label: String, icon: String, key: String) -> some View {
        Button {
            withAnimation(.spring()) { vm.userGender = key }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 20))
                    .foregroundColor(vm.userGender == key ? .white : .coppelButton)
                Text(label).font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(vm.userGender == key ? .white : .coppelDeepBlue)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(vm.userGender == key ? Color.coppelButton : Color.white.opacity(0.85))
            .cornerRadius(14)
        }
        .animation(.spring(), value: vm.userGender)
    }

    private func nextButton(label: String, disabled: Bool = false) -> some View {
        Button {
            withAnimation(.spring(response: 0.4)) { step += 1 }
        } label: {
            HStack(spacing: 8) {
                Text(label)
                Image(systemName: "arrow.right.circle.fill")
            }
            .nubiButton()
        }
        .disabled(disabled).opacity(disabled ? 0.45 : 1)
    }
}
