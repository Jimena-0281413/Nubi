//
//  HomeView.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 04/05/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: AppViewModel
    
    // 1. AQUI AGREGAMOS EL "CABLE" PARA CONECTAR LOS TABS
    @Binding var selectedTab: Int
    
    @State private var showEmotionLog = false
    @State private var showSOS = false
    @State private var showBreathing = false // 2. Variable para la alerta de respiración
    @State private var pulseEffect = false
    @State private var greeting = "Buenos días"

    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                LinearGradient(colors: [Color.nubiParchment, Color.nubiLightBlue.opacity(0.25)],
                               startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // MARK: Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(greeting)
                                    .font(NubiFont.caption)
                                    .foregroundColor(.nubiDark.opacity(0.6))
                                Text("¿Cómo te sientes hoy? ")
                                    .font(NubiFont.heading)
                                    .foregroundColor(.nubiDark)
                            }
                            Spacer()
                            // SOS Button
                            Button {
                                showSOS = true
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.red.opacity(0.12))
                                        .frame(width: 52, height: 52)
                                    Circle()
                                        .stroke(Color.red, lineWidth: 2)
                                        .frame(width: 52, height: 52)
                                        .scaleEffect(pulseEffect ? 1.2 : 1)
                                        .opacity(pulseEffect ? 0 : 1)
                                    VStack(spacing: 1) {
                                        Image(systemName: "phone.fill")
                                            .font(.system(size: 14, weight: .bold))
                                        Text("SOS")
                                            .font(.system(size: 9, weight: .black, design: .rounded))
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
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                        // MARK: Nubi Avatar
                        ZStack {
                            // Halo de color de fondo
                            Circle()
                                .fill(vm.nubiColor.opacity(0.12))
                                .frame(width: 180, height: 180)
                                .blur(radius: 20)

                            VStack(spacing: 8) {
                                NubiAvatarView(color: vm.nubiColor, size: 120)

                                if let entry = vm.todayEmotion {
                                    let symbol = PrimaryEmotion.allCases.first { $0.rawValue == entry.primaryEmotion }?.sfSymbol ?? "circle.fill"
                                    let color  = PrimaryEmotion.allCases.first { $0.rawValue == entry.primaryEmotion }?.color ?? .nubiGlaucous
                                    HStack(spacing: 6) {
                                        Image(systemName: symbol)
                                            .foregroundColor(color)
                                        Text(entry.primaryEmotion)
                                            .font(NubiFont.subheading)
                                            .foregroundColor(.nubiDark)
                                        Text("·")
                                        Text(entry.subEmotion)
                                            .font(NubiFont.caption)
                                            .foregroundColor(.nubiDark.opacity(0.65))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.nubiParchment.opacity(0.9))
                                    .cornerRadius(20)
                                    .shadow(color: .nubiGlaucous.opacity(0.1), radius: 6)
                                } else {
                                    Text("Toca para registrar tu emoción")
                                        .font(NubiFont.caption)
                                        .foregroundColor(.nubiDark.opacity(0.5))
                                }
                            }
                        }

                        // MARK: Register Emotion Button
                        Button {
                            showEmotionLog = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: vm.todayEmotion == nil ? "plus.circle.fill" : "pencil.circle.fill")
                                    .font(.system(size: 20))
                                Text(vm.todayEmotion == nil ? "¿Cómo me siento ahora?" : "Actualizar mi emoción")
                                    .font(NubiFont.subheading)
                            }
                            .nubiButton()
                        }

                        // MARK: Emotion History Mini Card
                        if !vm.emotionHistory.isEmpty {
                            weekSummaryCard
                        }

                        // MARK: Quick Access Cards
                        quickAccessGrid

                        Spacer(minLength: 100) // Para el tab bar
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showEmotionLog) {
            EmotionLogView()
                .environmentObject(vm)
        }
        // Alerta de SOS
        .alert("Llamada de Emergencia", isPresented: $showSOS) {
            Button("Llamar a Psicólogo", role: .none) {
                if let url = URL(string: "tel://8001234567") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("¿Estás pasando por un momento muy difícil? Un psicólogo de Coppel está disponible ahora mismo para acompañarte. Estás en manos seguras.")
        }
        // Alerta de Técnica de Respiración
        .alert("Técnica 4-4-4", isPresented: $showBreathing) {
            Button("Entendido", role: .cancel) {}
        } message: {
            Text("Inhala profundamente por 4 segundos, sostén el aire por 4 segundos y exhala lentamente por 4 segundos. Repite hasta sentir calma.")
        }
        .onAppear { updateGreeting() }
    }

    // MARK: - Week Summary Card
    var weekSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tu semana emocional")
                .font(NubiFont.subheading)
                .foregroundColor(.nubiDark)

            HStack(spacing: 8) {
                ForEach(vm.emotionHistory.suffix(7)) { entry in
                    let sym   = PrimaryEmotion.allCases.first { $0.rawValue == entry.primaryEmotion }?.sfSymbol ?? "circle.fill"
                    let color = PrimaryEmotion.allCases.first { $0.rawValue == entry.primaryEmotion }?.color ?? .nubiGlaucous
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: entry.nubiColor))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: sym)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                        Text(dayLetter(from: entry.date))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.nubiDark.opacity(0.5))
                    }
                }
                Spacer()
            }
        }
        .padding(18)
        .nubiCard()
        .padding(.horizontal, 24)
    }

    // MARK: - Quick Access Grid
    var quickAccessGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            quickCard(icon: "doc.text.fill", label: "Mi Reporte\nSemanal", color: .nubiGlaucous, tab: 1)
            quickCard(icon: "book.fill", label: "Guías para\nmi bienestar", color: Color(hex: "#7FA8C9"), tab: 2)
            quickCard(icon: "gamecontroller.fill", label: "Juegos de\ndescompresión", color: Color(hex: "#5C9999"), tab: 3)
            quickCard(icon: "moon.stars.fill", label: "Técnica de\nrespiración", color: Color(hex: "#9B8EC4"), tab: nil)
        }
        .padding(.horizontal, 24)
    }

    private func quickCard(icon: String, label: String, color: Color, tab: Int?) -> some View {
        Button {
            // 3. AQUI ESTA LA MAGIA QUE CAMBIA DE PANTALLA
            if let tabNumber = tab {
                selectedTab = tabNumber // Cambia a Reporte, Guías o Juegos
            } else {
                showBreathing = true // Muestra la alerta de respiración
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(color)
                Text(label)
                    .font(NubiFont.body)
                    .foregroundColor(.nubiDark)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .nubiCard()
        }
    }

    // MARK: - Helpers
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { greeting = "Buenos días" }
        else if hour < 18 { greeting = "Buenas tardes" }
        else { greeting = "Buenas noches" }
    }

    private func dayLetter(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1)).uppercased()
    }
}

// 4. ESTO EVITA QUE XCODE MARQUE ERROR EN LA VISTA PREVIA
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(0))
            .environmentObject(AppViewModel())
    }
}
