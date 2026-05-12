//
//  HomeView.swift
//  Nubi
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: AppViewModel
    @Binding var selectedTab: Int

    @State private var showEmotionLog       = false
    @State private var showSOS              = false
    @State private var showAppointment      = false
    @State private var pulseEffect          = false
    @State private var greeting             = "Buenos días"

    /// Color del botón principal: por defecto Coppel; si hay emoción, color de la emoción
    private var primaryButtonColor: Color {
        if let entry = vm.todayEmotion, let primary = PrimaryEmotion.allCases.first(where: { $0.rawValue == entry.primaryEmotion }) {
            return primary.color
        }
        return .coppelButton
    }

    /// Expresión de Nubi según emoción registrada
    private var nubiExpression: NubiExpression {
        if let entry = vm.todayEmotion, let primary = PrimaryEmotion.allCases.first(where: { $0.rawValue == entry.primaryEmotion }) {
            return primary.nubiExpression
        }
        return .neutral
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.coppelBackground, Color.coppelYellow.opacity(0.5)],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        headerSection
                        bigNubiSection
                        registerEmotionButton
                        if !vm.emotionHistory.isEmpty { weekSummaryCard }
                        appointmentCard
                        Spacer(minLength: 100)
                    }
                }
                .onTapGesture { hideKeyboard() }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showEmotionLog) {
            EmotionLogView().environmentObject(vm)
        }
        .fullScreenCover(isPresented: $showAppointment) {
            AppointmentView().environmentObject(vm)
        }
        .alert("Llamada de Emergencia", isPresented: $showSOS) {
            Button("Llamar a Psicólogo", role: .none) {
                if let url = URL(string: "tel://8001234567") { UIApplication.shared.open(url) }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("¿Estás pasando por un momento muy difícil? Un psicólogo de Coppel está disponible ahora mismo para acompañarte.")
        }
        .onAppear { updateGreeting() }
    }

    // MARK: - Header
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.6))
                Text(vm.userName.isEmpty ? "¿Cómo te sientes hoy?" : "Hola \(vm.userName), ¿cómo te sientes hoy?")
                    .font(NubiFont.heading).foregroundColor(.coppelDeepBlue)
            }
            Spacer()
            Button { showSOS = true } label: {
                ZStack {
                    Circle().fill(Color.red.opacity(0.12)).frame(width: 52, height: 52)
                    Circle().stroke(Color.red, lineWidth: 2).frame(width: 52, height: 52)
                        .scaleEffect(pulseEffect ? 1.2 : 1).opacity(pulseEffect ? 0 : 1)
                    VStack(spacing: 1) {
                        Image(systemName: "phone.fill").font(.system(size: 14, weight: .bold))
                        Text("SOS").font(.system(size: 9, weight: .black, design: .rounded))
                    }
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: false)) {
                    pulseEffect = true
                }
            }
        }
        .padding(.horizontal, 24).padding(.top, 8)
    }

    // MARK: - Nubi grande con expresión dinámica
    var bigNubiSection: some View {
        ZStack {
            // Halo
            Circle()
                .fill(vm.nubiColor.opacity(0.20))
                .frame(width: 240, height: 240).blur(radius: 30)

            VStack(spacing: 12) {
                NubiAvatarView(color: vm.nubiColor, size: 170, expression: nubiExpression)

                if let entry = vm.todayEmotion {
                    let symbol = PrimaryEmotion.allCases.first { $0.rawValue == entry.primaryEmotion }?.sfSymbol ?? "circle.fill"
                    let color  = PrimaryEmotion.allCases.first { $0.rawValue == entry.primaryEmotion }?.color ?? .coppelButton
                    HStack(spacing: 6) {
                        Image(systemName: symbol).foregroundColor(color)
                        Text(entry.primaryEmotion)
                            .font(NubiFont.subheading).foregroundColor(.coppelDeepBlue)
                        Text("·")
                        Text(entry.subEmotion)
                            .font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.65))
                    }
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(20)
                    .shadow(color: .coppelDeepBlue.opacity(0.10), radius: 6)
                } else {
                    Text("Toca el botón para registrar tu emoción")
                        .font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.5))
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Botón emoción (más pequeño cuando ya está registrada)
    var registerEmotionButton: some View {
        Button { showEmotionLog = true } label: {
            if vm.todayEmotion == nil {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill").font(.system(size: 20))
                    Text("¿Cómo me siento ahora?").font(NubiFont.subheading)
                }
                .nubiButton(color: primaryButtonColor)
            } else {
                // Versión más pequeña
                HStack(spacing: 8) {
                    Image(systemName: "pencil.circle.fill").font(.system(size: 16))
                    Text("Actualizar emoción")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18).padding(.vertical, 10)
                .background(LinearGradient(colors: [primaryButtonColor, primaryButtonColor.opacity(0.8)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(Capsule())
                .shadow(color: primaryButtonColor.opacity(0.4), radius: 6, x: 0, y: 3)
            }
        }
        .animation(.spring(response: 0.4), value: primaryButtonColor)
    }

    // MARK: - Week Summary
    var weekSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tu semana emocional")
                .font(NubiFont.subheading).foregroundColor(.coppelDeepBlue)

            HStack(spacing: 6) {
                ForEach(currentWeekDays, id: \.self) { day in
                    let isToday = Calendar.current.isDateInToday(day)
                    let dayEmotions = vm.emotionHistory.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }

                    VStack(spacing: 6) {
                        if dayEmotions.isEmpty {
                            Circle().fill(Color.gray.opacity(0.15)).frame(width: 28, height: 28)
                        } else if let last = dayEmotions.last {
                            let sym   = PrimaryEmotion.allCases.first { $0.rawValue == last.primaryEmotion }?.sfSymbol ?? "circle.fill"
                            let color = PrimaryEmotion.allCases.first { $0.rawValue == last.primaryEmotion }?.color ?? .coppelButton
                            Circle()
                                .fill(color)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Image(systemName: sym).font(.system(size: 12, weight: .semibold)).foregroundColor(.white)
                                )
                        }
                        Text(dayLetter(from: day))
                            .font(.system(size: 11, weight: isToday ? .bold : .medium, design: .rounded))
                            .foregroundColor(isToday ? .coppelDeepBlue : .coppelDeepBlue.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 8)
                    .background(isToday ? Color.coppelButton.opacity(0.08) : Color.clear)
                    .cornerRadius(12)
                }
            }
        }
        .padding(18).nubiCard().padding(.horizontal, 24)
    }

    // MARK: - Appointment card (migrado desde Guides)
    var appointmentCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(primaryButtonColor.opacity(0.15)).frame(width: 56, height: 56)
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .font(.system(size: 26))
                        .foregroundColor(primaryButtonColor)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("¿Necesitas hablar con alguien?")
                        .font(NubiFont.subheading).foregroundColor(.coppelDeepBlue)
                    Text("Agenda con un psicólogo de Coppel")
                        .font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.6))
                }
                Spacer()
            }

            Text("Es gratuito, confidencial y cubierto al 100% como beneficio Coppel.")
                .font(NubiFont.caption)
                .foregroundColor(.coppelDeepBlue.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)

            Button { showAppointment = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                    Text("Agendar cita gratuita")
                }
                .nubiButton(color: primaryButtonColor).frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(Color.coppelYellow)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.coppelButton.opacity(0.3), lineWidth: 1.5))
        .shadow(color: .coppelDeepBlue.opacity(0.10), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 24)
    }

    // MARK: - Helpers
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { greeting = "Buenos días" }
        else if hour < 18 { greeting = "Buenas tardes" }
        else { greeting = "Buenas noches" }
    }

    private func dayLetter(from date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX"); f.dateFormat = "E"
        return String(f.string(from: date).prefix(1)).uppercased()
    }

    private var currentWeekDays: [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let today = calendar.startOfDay(for: Date())
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekInterval.start) }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(0)).environmentObject(AppViewModel())
    }
}
