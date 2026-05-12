//
//  AppointmentView.swift
//  Nubi
//
//  Flujo: elegir psicólogo → motivo → modalidad → fecha/hora → confirmación
//  Al final muestra toast "Cita agregada al calendario {fecha}" y regresa al inicio.
//

import SwiftUI

struct AppointmentView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    @State private var step: Step = .selectPsychologist
    @State private var selectedPsychologist: Psychologist? = nil
    @State private var selectedReason: String = ""
    @State private var selectedReasonIcon: String = ""
    @State private var modalidad: String = "Videollamada"
    @State private var selectedSlot: TimeSlot? = nil
    @State private var showToast: Bool = false

    enum Step { case selectPsychologist, reason, modality, schedule, confirmation }

    var body: some View {
        ZStack {
            Color.coppelBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ScrollView(showsIndicators: false) {
                    Group {
                        switch step {
                        case .selectPsychologist: psychologistList
                        case .reason:             reasonList
                        case .modality:           modalitySelection
                        case .schedule:           scheduleSelection
                        case .confirmation:       confirmationView
                        }
                    }
                    .padding(.bottom, 40)
                }
            }

            // TOAST
            if showToast {
                VStack {
                    Spacer()
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.coppelYellow)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cita agregada al calendario")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            if let slot = selectedSlot {
                                Text("\(slot.dayLabel) · \(slot.hour)")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.coppelYellow.opacity(0.9))
                            }
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.coppelDeepBlue)
                    .cornerRadius(16)
                    .shadow(color: .coppelDeepBlue.opacity(0.3), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    // MARK: - Top Bar
    var topBar: some View {
        HStack {
            Button {
                if step == .selectPsychologist { dismiss() }
                else { withAnimation { goBack() } }
            } label: {
                Image(systemName: step == .selectPsychologist ? "xmark.circle.fill" : "chevron.left.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.coppelButton.opacity(0.7))
            }
            Spacer()
            Text(stepTitle)
                .font(NubiFont.subheading)
                .foregroundColor(.coppelDeepBlue)
            Spacer()
            Color.clear.frame(width: 28, height: 28)
        }
        .padding(16)
    }

    private var stepTitle: String {
        switch step {
        case .selectPsychologist: return "Elige tu psicólogo"
        case .reason:             return "Motivo de consulta"
        case .modality:           return "Modalidad"
        case .schedule:           return "Día y hora"
        case .confirmation:       return "Confirma tu cita"
        }
    }

    private func goBack() {
        switch step {
        case .reason:        step = .selectPsychologist
        case .modality:      step = .reason
        case .schedule:      step = .modality
        case .confirmation:  step = .schedule
        default: dismiss()
        }
    }

    // MARK: - Psicólogos
    var psychologistList: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill").foregroundColor(.coppelButton)
                Text("Todas las citas son 100% confidenciales y gratuitas")
                    .font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.65))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .background(Color.coppelYellow.opacity(0.7))
            .cornerRadius(14)
            .padding(.horizontal, 20)

            ForEach(samplePsychologists) { p in
                Button {
                    selectedPsychologist = p
                    withAnimation { step = .reason }
                } label: { psychologistCard(p) }
                    .buttonStyle(BounceButtonStyle())
                    .padding(.horizontal, 20)
            }
        }
    }

    private func psychologistCard(_ p: Psychologist) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.coppelButton.opacity(0.15)).frame(width: 60, height: 60)
                Image(systemName: p.sfSymbol).font(.system(size: 28)).foregroundColor(.coppelButton)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(p.name).font(NubiFont.subheading).foregroundColor(.coppelDeepBlue)
                Text(p.specialty).font(NubiFont.caption).foregroundColor(.coppelButton)
                HStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill").font(.system(size: 10)).foregroundColor(Color(hex: "#FFB703"))
                        Text(String(format: "%.1f", p.rating)).font(.system(size: 11, weight: .semibold, design: .rounded))
                    }
                    Text("·").foregroundColor(.coppelDeepBlue.opacity(0.3))
                    Text("\(p.yearsExperience) años exp.").font(.system(size: 11, design: .rounded)).foregroundColor(.coppelDeepBlue.opacity(0.55))
                }
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.coppelButton.opacity(0.5))
        }
        .padding(16)
        .background(Color.coppelYellow)
        .cornerRadius(18)
        .shadow(color: .coppelDeepBlue.opacity(0.08), radius: 6)
    }

    // MARK: - Razón
    var reasonList: some View {
        VStack(spacing: 12) {
            Text("¿De qué te gustaría hablar?")
                .font(NubiFont.heading).foregroundColor(.coppelDeepBlue)
                .padding(.horizontal, 20).padding(.top, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(consultationReasons, id: \.label) { r in
                    Button {
                        selectedReason = r.label
                        selectedReasonIcon = r.sfSymbol
                        withAnimation { step = .modality }
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle().fill(Color.coppelButton.opacity(0.12)).frame(width: 48, height: 48)
                                Image(systemName: r.sfSymbol).font(.system(size: 22)).foregroundColor(.coppelButton)
                            }
                            Text(r.label)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.coppelDeepBlue)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Color.coppelYellow)
                        .cornerRadius(16)
                        .shadow(color: .coppelDeepBlue.opacity(0.06), radius: 4)
                    }
                    .buttonStyle(BounceButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Modalidad
    var modalitySelection: some View {
        VStack(spacing: 16) {
            Text("¿Cómo prefieres tu sesión?")
                .font(NubiFont.heading).foregroundColor(.coppelDeepBlue)
                .padding(.top, 4)

            ForEach(["Videollamada", "Llamada", "Presencial"], id: \.self) { m in
                Button {
                    modalidad = m
                    withAnimation { step = .schedule }
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().fill(Color.coppelButton.opacity(0.15)).frame(width: 50, height: 50)
                            Image(systemName: m == "Videollamada" ? "video.fill" : (m == "Llamada" ? "phone.fill" : "building.2.fill"))
                                .font(.system(size: 22)).foregroundColor(.coppelButton)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(m).font(NubiFont.subheading).foregroundColor(.coppelDeepBlue)
                            Text(m == "Videollamada" ? "Desde tu celular o computadora" : (m == "Llamada" ? "Te llamaremos a tu celular" : "En consultorio Coppel cercano"))
                                .font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.55))
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.coppelButton.opacity(0.5))
                    }
                    .padding(16)
                    .background(Color.coppelYellow).cornerRadius(18)
                    .shadow(color: .coppelDeepBlue.opacity(0.08), radius: 6)
                }
                .buttonStyle(BounceButtonStyle())
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Schedule
    var scheduleSelection: some View {
        VStack(spacing: 14) {
            Text("Selecciona día y hora")
                .font(NubiFont.heading).foregroundColor(.coppelDeepBlue)
                .padding(.top, 4)

            if let p = selectedPsychologist {
                let groupedByDay = Dictionary(grouping: p.availableSlots, by: { $0.dayLabel })
                let orderedDays = p.availableSlots.map { $0.dayLabel }.reduce(into: [String]()) { acc, d in
                    if !acc.contains(d) { acc.append(d) }
                }

                ForEach(orderedDays, id: \.self) { day in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(day)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.coppelDeepBlue)
                            .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(groupedByDay[day] ?? []) { slot in
                                    Button {
                                        guard slot.isAvailable else { return }
                                        selectedSlot = slot
                                        withAnimation { step = .confirmation }
                                    } label: {
                                        Text(slot.hour)
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(slot.isAvailable ? .coppelDeepBlue : .coppelDeepBlue.opacity(0.3))
                                            .padding(.horizontal, 14).padding(.vertical, 10)
                                            .background(slot.isAvailable ? Color.coppelYellow : Color.gray.opacity(0.1))
                                            .cornerRadius(12)
                                            .overlay(RoundedRectangle(cornerRadius: 12)
                                                .stroke(slot.isAvailable ? Color.coppelButton.opacity(0.4) : Color.clear, lineWidth: 1))
                                    }
                                    .disabled(!slot.isAvailable)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    // MARK: - Confirmation
    var confirmationView: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle().fill(Color.coppelButton.opacity(0.15)).frame(width: 100, height: 100)
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 48)).foregroundColor(.coppelButton)
            }
            .padding(.top, 12)

            Text("Revisa tu cita")
                .font(NubiFont.heading).foregroundColor(.coppelDeepBlue)

            VStack(spacing: 12) {
                summaryRow(icon: "person.fill", label: "Psicólogo", value: selectedPsychologist?.name ?? "")
                summaryRow(icon: selectedReasonIcon.isEmpty ? "tag.fill" : selectedReasonIcon, label: "Motivo", value: selectedReason)
                summaryRow(icon: modalidad == "Videollamada" ? "video.fill" : "building.2.fill", label: "Modalidad", value: modalidad)
                if let s = selectedSlot {
                    summaryRow(icon: "calendar", label: "Día", value: s.dayLabel)
                    summaryRow(icon: "clock.fill", label: "Hora", value: s.hour)
                }
            }
            .padding(20)
            .background(Color.coppelYellow)
            .cornerRadius(20)
            .padding(.horizontal, 20)

            VStack(spacing: 8) {
                Button {
                    confirmAppointment()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                        Text("Agregar a calendario")
                    }
                    .nubiButton(color: .coppelButton).frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)

                Text("Te enviaremos una confirmación a tu número de empleado")
                    .font(NubiFont.caption)
                    .foregroundColor(.coppelDeepBlue.opacity(0.5))
            }
        }
    }

    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.coppelButton)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.55))
                Text(value).font(.system(size: 14, weight: .medium, design: .rounded)).foregroundColor(.coppelDeepBlue)
            }
            Spacer()
        }
    }

    /// Muestra el toast y regresa al inicio
    private func confirmAppointment() {
        withAnimation(.spring()) { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            dismiss()
        }
    }
}
