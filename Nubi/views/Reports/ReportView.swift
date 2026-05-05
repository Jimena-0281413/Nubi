//
//  ReportView.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 05/05/26.
//
import SwiftUI

struct ReportView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showChatbot = false
    @State private var chatInput = ""
    @State private var chatHistory: [(role: String, text: String)] = []
    @State private var isChatLoading = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.nubiParchment, Color.nubiLightBlue.opacity(0.2)],
                               startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header
                        headerSection

                        // Generate button or report
                        if vm.weeklyReport.isEmpty {
                            generateSection
                        } else {
                            reportSection
                            actionPlanSection
                            adjustChatSection
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Mi Reflejo Semanal")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showChatbot) {
            chatbotView
        }
    }

    // MARK: - Header
    var headerSection: some View {
        HStack(spacing: 16) {
            NubiAvatarView(color: vm.nubiColor, size: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text("Tu semana en palabras")
                    .font(NubiFont.subheading)
                    .foregroundColor(.nubiDark)
                Text("Nubi analizó tus emociones y tiene algo que decirte")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiDark.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .nubiCard()
        .padding(.horizontal, 20)
    }

    // MARK: - Generate Section
    var generateSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 52))
                .foregroundColor(.nubiGlaucous)

            Text("¿Listo para ver tu reflejo?")
                .font(NubiFont.heading)
                .foregroundColor(.nubiDark)

            Text("La IA analizará tus emociones de la semana y creará un resumen personalizado con un plan de acción.")
                .font(NubiFont.body)
                .foregroundColor(.nubiDark.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if vm.emotionHistory.isEmpty {
                Text("Aún no tienes registros emocionales. Usa el botón en Inicio para comenzar. ")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiDark.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            } else {
                Button {
                    Task { await vm.generateWeeklyReport() }
                } label: {
                    if vm.isGeneratingReport {
                        HStack(spacing: 10) {
                            ProgressView().tint(.white)
                            Text("Nubi está analizando...")
                        }
                        .nubiButton()
                    } else {
                        Text("✨ Generar mi reporte semanal")
                            .nubiButton()
                    }
                }
                .disabled(vm.isGeneratingReport)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
    }

    // MARK: - Report Section
    var reportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundColor(.nubiGlaucous)
                Text("Tu resumen de la semana")
                    .font(NubiFont.subheading)
                    .foregroundColor(.nubiDark)
                Spacer()
                // Emotion week badges
                HStack(spacing: 4) {
                    ForEach(vm.emotionHistory.suffix(5)) { e in
                        Text(PrimaryEmotion.allCases.first { $0.rawValue == e.primaryEmotion }?.emoji ?? "🫧")
                            .font(.system(size: 16))
                    }
                }
            }

            Text(vm.weeklyReport)
                .font(NubiFont.body)
                .foregroundColor(.nubiDark)
                .lineSpacing(5)
                .padding(18)
                .background(Color.nubiLightBlue.opacity(0.2))
                .cornerRadius(16)

            // Re-generate button
            Button {
                Task {
                    vm.weeklyReport = ""
                    await vm.generateWeeklyReport()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Regenerar reporte")
                }
                .font(NubiFont.caption)
                .foregroundColor(.nubiGlaucous)
            }
        }
        .padding(18)
        .nubiCard()
        .padding(.horizontal, 20)
    }

    // MARK: - Action Plan
    var actionPlanSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.nubiGlaucous)
                Text("Tu plan de fin de semana")
                    .font(NubiFont.subheading)
                    .foregroundColor(.nubiDark)
            }

            ForEach(Array(vm.actionPlan.enumerated()), id: \.offset) { index, task in
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.nubiGlaucous)
                            .frame(width: 28, height: 28)
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Text(task)
                        .font(NubiFont.body)
                        .foregroundColor(.nubiDark)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(14)
                .background(Color.nubiParchment)
                .cornerRadius(14)
                .shadow(color: .nubiGlaucous.opacity(0.08), radius: 4)
            }
        }
        .padding(18)
        .nubiCard()
        .padding(.horizontal, 20)
    }

    // MARK: - Adjust Chat
    var adjustChatSection: some View {
        VStack(spacing: 12) {
            Text("¿Me faltó algo?")
                .font(NubiFont.subheading)
                .foregroundColor(.nubiDark)
            Text("Cuéntame contexto que Nubi no sabía y ajustaré tu reporte.")
                .font(NubiFont.caption)
                .foregroundColor(.nubiDark.opacity(0.6))
                .multilineTextAlignment(.center)
            Button {
                showChatbot = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Abrir chat con Nubi")
                }
                .nubiButton(color: Color(hex: "#7FA8C9"))
            }
        }
        .padding(20)
        .nubiCard()
        .padding(.horizontal, 20)
    }

    // MARK: - Chatbot Sheet
    var chatbotView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                NubiAvatarView(color: .nubiGlaucous, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Chat con Nubi")
                        .font(NubiFont.subheading)
                        .foregroundColor(.nubiDark)
                    Text("Cuéntame qué pasó esta semana")
                        .font(NubiFont.caption)
                        .foregroundColor(.nubiDark.opacity(0.5))
                }
                Spacer()
                Button { showChatbot = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.nubiGlaucous.opacity(0.7))
                }
            }
            .padding(16)
            .background(Color.nubiLightBlue.opacity(0.2))

            Divider()

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Welcome message
                        chatBubble(text: "Hola 👋 ¿Hay algo que no puse en tu reporte? Cuéntame y lo ajusto para que sea más preciso.", isNubi: true)

                        ForEach(chatHistory, id: \.text) { msg in
                            chatBubble(text: msg.text, isNubi: msg.role == "nubi")
                        }

                        if isChatLoading {
                            HStack {
                                ProgressView().tint(.nubiGlaucous)
                                Text("Nubi está pensando...")
                                    .font(NubiFont.caption)
                                    .foregroundColor(.nubiDark.opacity(0.5))
                            }
                            .padding(.leading, 16)
                        }
                    }
                    .padding(16)
                    .id("bottom")
                }
                .onChange(of: chatHistory.count) { _ in
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                }
            }

            // Input
            HStack(spacing: 10) {
                TextField("Ej: Estuve triste por una situación familiar...", text: $chatInput, axis: .vertical)
                    .font(NubiFont.body)
                    .padding(12)
                    .background(Color.nubiParchment)
                    .cornerRadius(16)
                    .lineLimit(1...4)

                Button {
                    sendChat()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(chatInput.isEmpty ? Color.nubiGlaucous.opacity(0.4) : Color.nubiGlaucous)
                        .cornerRadius(14)
                }
                .disabled(chatInput.isEmpty || isChatLoading)
            }
            .padding(16)
            .background(Color.nubiParchment)
        }
        .background(Color.nubiParchment.ignoresSafeArea())
    }

    private func chatBubble(text: String, isNubi: Bool) -> some View {
        HStack {
            if !isNubi { Spacer() }
            Text(text)
                .font(NubiFont.body)
                .foregroundColor(isNubi ? .nubiDark : .white)
                .padding(14)
                .background(isNubi ? Color.nubiLightBlue.opacity(0.35) : Color.nubiGlaucous)
                .cornerRadius(18)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.72, alignment: isNubi ? .leading : .trailing)
            if isNubi { Spacer() }
        }
    }

    private func sendChat() {
        let userMsg = chatInput
        chatInput = ""
        chatHistory.append((role: "user", text: userMsg))
        isChatLoading = true

        let context = vm.weeklyReport
        let prompt = """
        Eres Nubi, un psicólogo empático de la app de bienestar de Coppel. El usuario tiene este reporte semanal:

        \(context)

        El usuario quiere añadir este contexto adicional: "\(userMsg)"

        Responde empáticamente en 2-3 oraciones, reconoce lo que comparten y ajusta tu perspectiva sobre su semana. Sé cálido y conciso.
        """

        Task {
            do {
                let response = try await vm.callGroqAPI(prompt: prompt)
                await MainActor.run {
                    chatHistory.append((role: "nubi", text: response))
                    isChatLoading = false
                }
            } catch {
                await MainActor.run {
                    chatHistory.append((role: "nubi", text: "Lo siento, tuve un problema de conexión. Pero lo que me compartes es muy importante. ¿Lo intentamos de nuevo? "))
                    isChatLoading = false
                }
            }
        }
    }
}
