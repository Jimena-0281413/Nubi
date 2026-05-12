//  ReportView.swift — Nubi (SF Symbols)
import SwiftUI

struct ReportView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showChatbot  = false
    @State private var chatInput    = ""
    @State private var chatHistory  : [(role: String, text: String)] = []
    @State private var isChatLoading = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.coppelBackground, Color.coppelYellow.opacity(0.5)],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        userProfileCard
                        if vm.weeklyReport.isEmpty { generateSection }
                        else { reportSection; actionPlanSection; adjustChatSection }
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
                .onTapGesture { hideKeyboard() }
            }
            .navigationTitle("Mi Reflejo Semanal")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showChatbot) { chatbotView }
    }

    var userProfileCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color.coppelButton.opacity(0.15)).frame(width: 56, height: 56)
                    Image(systemName: "person.crop.circle.badge.checkmark").font(.system(size: 26)).foregroundColor(.coppelButton)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.userName.isEmpty ? "Perfil Coppel" : vm.userName).font(NubiFont.subheading).foregroundColor(.coppelDeepBlue)
                    Text(vm.userPosition.rawValue).font(NubiFont.caption).foregroundColor(.coppelButton)
                }
                Spacer()
                Image(systemName: "building.2.crop.circle.fill").font(.system(size: 32)).foregroundColor(.coppelDeepBlue.opacity(0.2))
            }
            
            Divider().background(Color.coppelDeepBlue.opacity(0.1))
            
            VStack(spacing: 12) {
                profileRow(icon: "building.2.fill", text: vm.cediOrStore.isEmpty ? "CEDI / Tienda no especificada" : vm.cediOrStore)
                profileRow(icon: "person.text.rectangle", text: "Edad: \(vm.userAge.isEmpty ? "N/D" : vm.userAge) | \(vm.userGender.capitalized)")
                profileRow(icon: vm.familyRole.sfSymbol, text: vm.familyRole.rawValue)
                profileRow(icon: vm.transportType.sfSymbol, text: "Transporte: \(vm.transportType.rawValue)")
            }
            
            if !vm.emotionHistory.isEmpty {
                Divider().background(Color.coppelDeepBlue.opacity(0.1))
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "chart.xyaxis.line").font(.system(size: 16)).foregroundColor(.coppelButton)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tendencia Emocional").font(.system(size: 13, weight: .semibold, design: .rounded)).foregroundColor(.coppelDeepBlue)
                        let primaryCounts = Dictionary(grouping: vm.emotionHistory, by: { $0.primaryEmotion }).mapValues { $0.count }
                        if let topEmotion = primaryCounts.max(by: { $0.value < $1.value })?.key {
                            Text("Tu emoción más frecuente ha sido: \(topEmotion). Nubi toma en cuenta este contexto para tus recomendaciones.")
                                .font(.system(size: 12, design: .rounded)).foregroundColor(.coppelDeepBlue.opacity(0.65))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            
            if vm.userGender.lowercased() == "mujer" || vm.familyRole == .madre {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill").foregroundColor(Color(hex: "#EF476F"))
                    Text("Nubi ajusta su apoyo considerando tu rol y carga emocional.")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.coppelDeepBlue)
                }
                .padding(12).background(Color(hex: "#EF476F").opacity(0.15)).cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.coppelYellow)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.coppelButton.opacity(0.3), lineWidth: 1.5))
        .shadow(color: .coppelDeepBlue.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }

    private func profileRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(.coppelDeepBlue.opacity(0.6)).frame(width: 20)
            Text(text).font(.system(size: 14, design: .rounded)).foregroundColor(.coppelDeepBlue.opacity(0.8))
            Spacer()
        }
    }

    var generateSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles").font(.system(size: 52)).foregroundColor(.nubiGlaucous)
            Text("Listo para ver tu reflejo?").font(NubiFont.heading).foregroundColor(.nubiDark)
            Text("La IA analizara tus emociones de la semana y creara un resumen personalizado con un plan de accion.")
                .font(NubiFont.body).foregroundColor(.nubiDark.opacity(0.65))
                .multilineTextAlignment(.center).padding(.horizontal, 32)

            if vm.emotionHistory.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle").foregroundColor(.nubiGlaucous)
                    Text("Registra al menos una emocion desde Inicio para generar tu reporte.")
                        .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.5))
                }
                .padding(14).background(Color.nubiLightBlue.opacity(0.25)).cornerRadius(12).padding(.horizontal, 32)
            } else {
                // Emotion preview chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(vm.emotionHistory.suffix(7)) { entry in
                            HStack(spacing: 5) {
                                Image(systemName: primaryIcon(entry.primaryEmotion))
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: entry.nubiColor))
                                Text(entry.primaryEmotion)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.nubiDark)
                            }
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color(hex: entry.nubiColor).opacity(0.15)).cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 32)
                }
                Button {
                    Task { await vm.generateWeeklyReport() }
                } label: {
                    if vm.isGeneratingReport {
                        HStack(spacing: 10) {
                            ProgressView().tint(.white)
                            Text("Nubi esta analizando...")
                        }
                        .nubiButton()
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                            Text("Generar mi reporte semanal")
                        }
                        .nubiButton()
                    }
                }
                .disabled(vm.isGeneratingReport)
            }
        }
        .padding(.vertical, 32).padding(.horizontal, 20)
    }

    var reportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass").foregroundColor(.nubiGlaucous)
                Text("Tu resumen de la semana").font(NubiFont.subheading).foregroundColor(.nubiDark)
                Spacer()
                HStack(spacing: 4) {
                    ForEach(vm.emotionHistory.suffix(5)) { e in
                        Image(systemName: primaryIcon(e.primaryEmotion))
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: e.nubiColor))
                    }
                }
            }
            Text((try? AttributedString(markdown: vm.weeklyReport)) ?? AttributedString(vm.weeklyReport))
                .font(NubiFont.body).foregroundColor(.nubiDark)
                .lineSpacing(5).padding(18).background(Color.nubiLightBlue.opacity(0.2)).cornerRadius(16)
            Button {
                Task { vm.weeklyReport = ""; vm.actionPlan = []; await vm.generateWeeklyReport() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Regenerar reporte")
                }
                .font(NubiFont.caption).foregroundColor(.nubiGlaucous)
            }
        }
        .padding(18).nubiCard().padding(.horizontal, 20)
    }

    var actionPlanSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill").foregroundColor(.nubiGlaucous)
                Text("Tu plan de fin de semana").font(NubiFont.subheading).foregroundColor(.nubiDark)
            }
            ForEach(Array(vm.actionPlan.enumerated()), id: \.offset) { index, task in
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle().fill(Color.nubiGlaucous).frame(width: 28, height: 28)
                        Text("\(index + 1)").font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(.white)
                    }
                    Text(task).font(NubiFont.body).foregroundColor(.nubiDark).fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(14).background(Color.nubiParchment).cornerRadius(14)
                .shadow(color: .nubiGlaucous.opacity(0.08), radius: 4)
            }
        }
        .padding(18).nubiCard().padding(.horizontal, 20)
    }

    var adjustChatSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.bubble.fill").foregroundColor(.nubiGlaucous)
                Text("Me falto algo?").font(NubiFont.subheading).foregroundColor(.nubiDark)
            }
            Text("Cuentame contexto que Nubi no sabia y ajustare tu reporte.")
                .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.6)).multilineTextAlignment(.center)
            Button { showChatbot = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Abrir chat con Nubi")
                }
                .nubiButton(color: Color(hex: "#7FA8C9"))
            }
        }
        .padding(20).nubiCard().padding(.horizontal, 20)
    }

    // MARK: - Chatbot Sheet
    var chatbotView: some View {
        VStack(spacing: 0) {
            HStack {
                NubiAvatarView(color: .nubiGlaucous, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Chat con Nubi").font(NubiFont.subheading).foregroundColor(.nubiDark)
                    Text("Cuentame que paso esta semana").font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.5))
                }
                Spacer()
                Button { showChatbot = false } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 26)).foregroundColor(.nubiGlaucous.opacity(0.7))
                }
            }
            .padding(16).background(Color.nubiLightBlue.opacity(0.2))
            Divider()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        chatBubble(text: "Hola. Hay algo que no puse en tu reporte? Cuentame y lo ajusto para que sea mas preciso.", isNubi: true)
                        ForEach(chatHistory, id: \.text) { msg in chatBubble(text: msg.text, isNubi: msg.role == "nubi") }
                        if isChatLoading {
                            HStack(spacing: 8) {
                                ProgressView().tint(.nubiGlaucous)
                                Text("Nubi esta pensando...").font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.5))
                            }
                            .padding(.leading, 16)
                        }
                    }
                    .padding(16).id("bottom")
                }
                .onChange(of: chatHistory.count) { _ in withAnimation { proxy.scrollTo("bottom", anchor: .bottom) } }
                .onTapGesture { hideKeyboard() }
            }
            HStack(spacing: 10) {
                TextField("Ej: Estuve triste por una situacion familiar...", text: $chatInput, axis: .vertical)
                    .font(NubiFont.body).padding(12).background(Color.nubiParchment).cornerRadius(16).lineLimit(1...4)
                Button { vm.toggleRecording { text in chatInput = text } } label: {
                    Image(systemName: vm.isRecording ? "mic.fill.badge.xmark" : "mic.fill")
                        .font(.system(size: 20))
                        .foregroundColor(vm.isRecording ? .red : .coppelButton)
                        .scaleEffect(vm.isRecording ? 1.1 : 1.0)
                }
                Button { sendChat() } label: {
                    Image(systemName: "paperplane.fill").font(.system(size: 20)).foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(chatInput.isEmpty ? Color.nubiGlaucous.opacity(0.4) : Color.nubiGlaucous)
                        .cornerRadius(14)
                }
                .disabled(chatInput.isEmpty || isChatLoading)
            }
            .padding(16).background(Color.nubiParchment)
            Text("Nubi es un modelo de IA preentrenado. Si necesitas ayuda o acompañamiento clínico, por favor acércate a un profesional desde la sección de Guías.")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.nubiDark.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
        }
        .background(Color.nubiParchment.ignoresSafeArea())
    }

    private func chatBubble(text: String, isNubi: Bool) -> some View {
        HStack {
            if !isNubi { Spacer() }
            VStack(alignment: isNubi ? .leading : .trailing, spacing: 4) {
                Text((try? AttributedString(markdown: text)) ?? AttributedString(text)).font(NubiFont.body)
                    .foregroundColor(isNubi ? .nubiDark : .white)
                if isNubi {
                    Button { vm.speak(text: text) } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("Escuchar")
                        }
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.nubiDark.opacity(0.6))
                    }
                    .padding(.top, 2)
                }
            }
            .padding(14)
            .background(isNubi ? Color.nubiLightBlue.opacity(0.35) : Color.nubiGlaucous)
            .cornerRadius(18)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.72, alignment: isNubi ? .leading : .trailing)
            if isNubi { Spacer() }
        }
    }

    private func sendChat() {
        let userMsg = chatInput; chatInput = ""
        chatHistory.append((role: "user", text: userMsg))
        isChatLoading = true
        let prompt = "Eres Nubi, un psicologo empatico de la app de bienestar de Coppel. El usuario tiene este reporte semanal:\n\(vm.weeklyReport)\n\nEl usuario quiere anadir este contexto adicional: \"\(userMsg)\"\n\nResponde empaticamente en 2-3 oraciones. Se calido y conciso."
        Task {
            do {
                let response = try await vm.callGroqAPI(prompt: prompt)
                await MainActor.run { 
                    chatHistory.append((role: "nubi", text: response))
                    isChatLoading = false 
                }
            } catch {
                await MainActor.run {
                    let err = "Lo siento, tuve un problema de conexion. Lo intentamos de nuevo?"
                    chatHistory.append((role: "nubi", text: err))
                    isChatLoading = false
                }
            }
        }
    }

    private func primaryIcon(_ name: String) -> String {
        PrimaryEmotion.allCases.first { $0.rawValue == name }?.sfSymbol ?? "circle.fill"
    }
}
