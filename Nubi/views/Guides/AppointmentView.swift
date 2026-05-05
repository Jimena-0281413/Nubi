//
//  AppointmentView.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 05/05/26.
//

import SwiftUI

// MARK: - Appointment Flow Steps
enum AppointmentStep: Int, CaseIterable {
    case reason = 0
    case psychologist = 1
    case dateTime = 2
    case modality = 3
    case confirmation = 4
    case success = 5
}

struct AppointmentView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: AppViewModel
    @State private var currentStep: AppointmentStep = .reason
    @State private var selectedReason = ""
    @State private var selectedPsychologist: Psychologist? = nil
    @State private var selectedSlot: TimeSlot? = nil
    @State private var selectedModality = ""
    @State private var additionalNotes = ""
    @State private var showSuccess = false
    @State private var appearAnimation = false

    var progressValue: Double {
        Double(currentStep.rawValue) / Double(AppointmentStep.allCases.count - 1)
    }

    var body: some View {
        ZStack {
            Color.nubiParchment.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView
                // Progress
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        switch currentStep {
                        case .reason: reasonStepView
                        case .psychologist: psychologistStepView
                        case .dateTime: dateTimeStepView
                        case .modality: modalityStepView
                        case .confirmation: confirmationStepView
                        case .success: successStepView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }

                // Bottom button
                if currentStep != .success {
                    bottomButton
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appearAnimation = true }
        }
    }

    // MARK: - Header
    var headerView: some View {
        HStack {
            Button { handleBack() } label: {
                Image(systemName: currentStep == .reason ? "xmark" : "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.nubiGlaucous)
                    .frame(width: 40, height: 40)
                    .background(Color.nubiGlaucous.opacity(0.1))
                    .clipShape(Circle())
            }
            Spacer()
            VStack(spacing: 2) {
                Text("Agendar Cita")
                    .font(NubiFont.subheading)
                    .foregroundColor(.nubiDark)
                Text("Paso \(currentStep.rawValue + 1) de \(AppointmentStep.allCases.count - 1)")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiGlaucous)
            }
            Spacer()
            // Nubi mini
            NubiAvatarView(color: .nubiLightBlue, size: 36, isAnimating: false)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Progress Bar
    var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.nubiLightBlue.opacity(0.3))
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(colors: [Color.nubiGlaucous, Color(hex: "#5C9999")],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: geo.size.width * progressValue, height: 6)
                    .animation(.spring(response: 0.5), value: progressValue)
            }
        }
        .frame(height: 6)
    }

    // MARK: - Step 1: Reason
    var reasonStepView: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(sfSymbol: "bubble.left.and.bubble.right.fill", title: "¿Qué te gustaría trabajar?",
                       subtitle: "Esto nos ayuda a conectarte con el psicólogo ideal")

            ForEach(consultationReasons, id: \.label) { reason in
                Button {
                    withAnimation(.spring(response: 0.3)) { selectedReason = reason.label }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: reason.sfSymbol)
                            .font(.system(size: 28))
                            .foregroundColor(.nubiGlaucous)
                        Text(reason.label)
                            .font(NubiFont.body)
                            .foregroundColor(.nubiDark)
                        Spacer()
                        if selectedReason == reason.label {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#5C9999"))
                                .font(.system(size: 22))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(16)
                    .background(selectedReason == reason.label
                                ? Color(hex: "#5C9999").opacity(0.1)
                                : Color.white.opacity(0.8))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedReason == reason.label
                                    ? Color(hex: "#5C9999").opacity(0.5)
                                    : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: .nubiGlaucous.opacity(0.06), radius: 4)
                }
                .buttonStyle(BounceButtonStyle())
            }

            // Additional notes
            VStack(alignment: .leading, spacing: 8) {
                Text("¿Algo más que quieras compartir? (opcional)")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiGlaucous)
                TextEditor(text: $additionalNotes)
                    .font(NubiFont.body)
                    .frame(height: 80)
                    .padding(12)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.nubiGlaucous.opacity(0.15)))
            }
            .padding(.top, 8)

            privacyNote
        }
    }

    // MARK: - Step 2: Psychologist
    var psychologistStepView: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(sfSymbol: "stethoscope.circle.fill", title: "Elige tu psicólogo",
                       subtitle: "Todos son profesionales certificados de Coppel")

            ForEach(samplePsychologists) { psych in
                Button {
                    withAnimation(.spring(response: 0.3)) { selectedPsychologist = psych }
                } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.nubiGlaucous.opacity(0.12))
                                    .frame(width: 56, height: 56)
                                Image(systemName: psych.sfSymbol)
                                    .font(.system(size: 30))
                                    .foregroundColor(.nubiGlaucous)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(psych.name)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.nubiDark)
                                Text(psych.specialty)
                                    .font(NubiFont.caption)
                                    .foregroundColor(.nubiGlaucous)
                            }
                            Spacer()
                            if selectedPsychologist?.id == psych.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "#5C9999"))
                                    .font(.system(size: 22))
                            }
                        }

                        Text(psych.bio)
                            .font(NubiFont.caption)
                            .foregroundColor(.nubiDark.opacity(0.7))
                            .lineSpacing(3)

                        HStack(spacing: 16) {
                            Label("\(psych.yearsExperience) años", systemImage: "briefcase.fill")
                                .font(NubiFont.caption)
                                .foregroundColor(.nubiGlaucous)
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", psych.rating))
                                    .font(NubiFont.caption)
                                    .foregroundColor(.nubiDark.opacity(0.6))
                            }
                        }
                    }
                    .padding(16)
                    .background(selectedPsychologist?.id == psych.id
                                ? Color(hex: "#5C9999").opacity(0.08)
                                : Color.white.opacity(0.8))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(selectedPsychologist?.id == psych.id
                                    ? Color(hex: "#5C9999").opacity(0.5)
                                    : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: .nubiGlaucous.opacity(0.08), radius: 6)
                }
                .buttonStyle(BounceButtonStyle())
            }
        }
    }

    // MARK: - Step 3: Date & Time
    var dateTimeStepView: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(sfSymbol: "calendar.circle.fill", title: "Elige fecha y hora",
                       subtitle: "Horarios disponibles de \(selectedPsychologist?.name ?? "")")

            let grouped = Dictionary(grouping: selectedPsychologist?.availableSlots.filter { $0.isAvailable } ?? [],
                                     by: { $0.dayLabel })
            let sortedKeys = grouped.keys.sorted()

            ForEach(sortedKeys, id: \.self) { day in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.nubiGlaucous)
                            .font(.system(size: 14))
                        Text(day)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.nubiDark)
                    }
                    .padding(.top, 4)

                    // Wrap hours in flow layout
                    let slots = grouped[day] ?? []
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
                        ForEach(slots) { slot in
                            Button {
                                withAnimation(.spring(response: 0.3)) { selectedSlot = slot }
                            } label: {
                                Text(slot.hour)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(selectedSlot?.id == slot.id ? .white : .nubiGlaucous)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedSlot?.id == slot.id
                                                ? Color(hex: "#5C9999")
                                                : Color.nubiLightBlue.opacity(0.3))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(14)
                .background(Color.white.opacity(0.6))
                .cornerRadius(16)
            }
        }
    }

    // MARK: - Step 4: Modality
    var modalityStepView: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(sfSymbol: "display", title: "¿Cómo prefieres tu cita?",
                       subtitle: "Ambas opciones son igual de efectivas")

            let modalities: [(icon: String, label: String, desc: String)] = [
                ("video.fill", "Videollamada", "Conéctate desde donde estés, solo necesitas tu celular"),
                ("building.2.fill", "Presencial", "Visita el consultorio en tu sucursal Coppel más cercana")
            ]

            ForEach(modalities, id: \.label) { mod in
                Button {
                    withAnimation(.spring(response: 0.3)) { selectedModality = mod.label }
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedModality == mod.label
                                      ? Color(hex: "#5C9999").opacity(0.2)
                                      : Color.nubiGlaucous.opacity(0.1))
                                .frame(width: 56, height: 56)
                            Image(systemName: mod.icon)
                                .font(.system(size: 24))
                                .foregroundColor(selectedModality == mod.label
                                                 ? Color(hex: "#5C9999")
                                                 : .nubiGlaucous)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mod.label)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.nubiDark)
                            Text(mod.desc)
                                .font(NubiFont.caption)
                                .foregroundColor(.nubiDark.opacity(0.6))
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        if selectedModality == mod.label {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#5C9999"))
                                .font(.system(size: 22))
                        }
                    }
                    .padding(16)
                    .background(selectedModality == mod.label
                                ? Color(hex: "#5C9999").opacity(0.08)
                                : Color.white.opacity(0.8))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(selectedModality == mod.label
                                    ? Color(hex: "#5C9999").opacity(0.5)
                                    : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: .nubiGlaucous.opacity(0.06), radius: 6)
                }
                .buttonStyle(BounceButtonStyle())
            }

            // Info card
            HStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.nubiGlaucous)
                    .font(.system(size: 20))
                Text("Tu cita es 100% confidencial. Ningún supervisor o jefe tiene acceso a esta información.")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiDark.opacity(0.7))
                    .lineSpacing(3)
            }
            .padding(16)
            .background(Color.nubiLightBlue.opacity(0.15))
            .cornerRadius(16)
            .padding(.top, 8)
        }
    }

    // MARK: - Step 5: Confirmation
    var confirmationStepView: some View {
        VStack(spacing: 20) {
            stepHeader(sfSymbol: "checkmark.seal.fill", title: "Confirma tu cita",
                       subtitle: "Revisa que todo esté correcto")

            VStack(spacing: 0) {
                // Header gradient
                ZStack {
                    LinearGradient(colors: [Color(hex: "#5C9999").opacity(0.3), Color.nubiLightBlue.opacity(0.2)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    NubiAvatarView(color: Color(hex: "#5C9999"), size: 60, isAnimating: true)
                        .padding(.vertical, 12)
                }
                .frame(height: 100)
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))

                VStack(spacing: 14) {
                    confirmRow(icon: "person.fill", label: "Psicólogo", value: selectedPsychologist?.name ?? "")
                    Divider().opacity(0.3)
                    confirmRow(icon: "heart.text.square.fill", label: "Motivo", value: selectedReason)
                    Divider().opacity(0.3)
                    confirmRow(icon: "calendar", label: "Fecha", value: selectedSlot?.dayLabel ?? "")
                    Divider().opacity(0.3)
                    confirmRow(icon: "clock.fill", label: "Hora", value: selectedSlot?.hour ?? "")
                    Divider().opacity(0.3)
                    confirmRow(icon: "display", label: "Modalidad", value: selectedModality)
                    if !additionalNotes.isEmpty {
                        Divider().opacity(0.3)
                        confirmRow(icon: "text.bubble.fill", label: "Notas", value: additionalNotes)
                    }
                }
                .padding(20)
            }
            .background(Color.white.opacity(0.9))
            .cornerRadius(20)
            .shadow(color: .nubiGlaucous.opacity(0.12), radius: 10)

            // Cost info
            HStack(spacing: 10) {
                Image(systemName: "gift.fill")
                    .foregroundColor(Color(hex: "#5C9999"))
                    .font(.system(size: 18))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Servicio gratuito")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.nubiDark)
                    Text("Este beneficio es parte de tu programa de bienestar Coppel")
                        .font(NubiFont.caption)
                        .foregroundColor(.nubiDark.opacity(0.6))
                }
            }
            .padding(16)
            .background(Color(hex: "#5C9999").opacity(0.08))
            .cornerRadius(16)
        }
    }

    // MARK: - Step 6: Success
    var successStepView: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            NubiAvatarView(color: Color(hex: "#5C9999"), size: 110, isAnimating: true)

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundColor(Color(hex: "#5C9999"))

            VStack(spacing: 8) {
                Text("¡Cita agendada!")
                    .font(NubiFont.title)
                    .foregroundColor(.nubiDark)
                Text("Te enviamos un recordatorio.\nEstamos contigo")
                    .font(NubiFont.body)
                    .foregroundColor(.nubiDark.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            // Summary card
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "calendar.badge.checkmark")
                        .foregroundColor(Color(hex: "#5C9999"))
                    Text(selectedSlot?.dayLabel ?? "")
                        .font(NubiFont.subheading)
                        .foregroundColor(.nubiDark)
                    Text("·")
                        .foregroundColor(.nubiDark.opacity(0.3))
                    Text(selectedSlot?.hour ?? "")
                        .font(NubiFont.subheading)
                        .foregroundColor(.nubiDark)
                }
                Text("con \(selectedPsychologist?.name ?? "")")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiGlaucous)
                Text(selectedModality)
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiDark.opacity(0.5))
            }
            .padding(20)
            .background(Color.white.opacity(0.85))
            .cornerRadius(20)
            .shadow(color: .nubiGlaucous.opacity(0.1), radius: 8)

            Button {
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "house.fill")
                    Text("Volver al inicio")
                }
                .nubiButton(color: Color(hex: "#5C9999"))
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(BounceButtonStyle())
            .padding(.top, 8)

            Spacer().frame(height: 40)
        }
    }

    // MARK: - Bottom Button
    var bottomButton: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.2)
            Button {
                handleNext()
            } label: {
                HStack(spacing: 8) {
                    Text(currentStep == .confirmation ? "Confirmar Cita" : "Continuar")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Image(systemName: currentStep == .confirmation ? "checkmark" : "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(colors: canProceed
                                   ? [Color(hex: "#5C9999"), Color.nubiGlaucous]
                                   : [Color.gray.opacity(0.4), Color.gray.opacity(0.3)],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(18)
                .shadow(color: canProceed ? Color(hex: "#5C9999").opacity(0.4) : .clear, radius: 10, y: 4)
            }
            .disabled(!canProceed)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.nubiParchment)
    }

    // MARK: - Helpers
    var canProceed: Bool {
        switch currentStep {
        case .reason: return !selectedReason.isEmpty
        case .psychologist: return selectedPsychologist != nil
        case .dateTime: return selectedSlot != nil
        case .modality: return !selectedModality.isEmpty
        case .confirmation, .success: return true
        }
    }

    func handleNext() {
        guard canProceed else { return }
        withAnimation(.spring(response: 0.4)) {
            if let next = AppointmentStep(rawValue: currentStep.rawValue + 1) {
                currentStep = next
            }
        }
    }

    func handleBack() {
        withAnimation(.spring(response: 0.4)) {
            if currentStep == .reason {
                dismiss()
            } else if let prev = AppointmentStep(rawValue: currentStep.rawValue - 1) {
                currentStep = prev
            }
        }
    }

    func stepHeader(sfSymbol: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: sfSymbol)
                    .font(.system(size: 28))
                    .foregroundColor(.nubiGlaucous)
                Text(title)
                    .font(NubiFont.heading)
                    .foregroundColor(.nubiDark)
            }
            Text(subtitle)
                .font(NubiFont.caption)
                .foregroundColor(.nubiDark.opacity(0.6))
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }

    func confirmRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.nubiGlaucous)
                .font(.system(size: 15))
                .frame(width: 24)
            Text(label)
                .font(NubiFont.caption)
                .foregroundColor(.nubiDark.opacity(0.5))
                .frame(width: 70, alignment: .leading)
            Text(value)
                .font(NubiFont.body)
                .foregroundColor(.nubiDark)
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }

    var privacyNote: some View {
        HStack(spacing: 10) {
            Image(systemName: "shield.checkered")
                .foregroundColor(.nubiGlaucous)
                .font(.system(size: 18))
            Text("Tu información es confidencial y está cifrada. Nadie en tu trabajo tendrá acceso a lo que compartas.")
                .font(NubiFont.caption)
                .foregroundColor(.nubiDark.opacity(0.6))
                .lineSpacing(3)
        }
        .padding(14)
        .background(Color.nubiLightBlue.opacity(0.12))
        .cornerRadius(14)
    }
}
