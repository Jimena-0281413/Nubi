//
//  GuidesView.swift
//  Nubi
//

import SwiftUI

// MARK: - Main Guides View
struct GuidesView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedGuide: Guide?         = nil
    @State private var searchText                    = ""
    @State private var selectedCategory: GuideCategory? = nil
    @State private var showNubiChat                  = false
    @State private var showAppointment               = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.nubiParchment.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        searchBar
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 14)

                        categoryPills.padding(.bottom, 22)

                        // HStack 1 — Soft Skills
                        if selectedCategory == nil || selectedCategory == .softSkill {
                            softSkillsSection.padding(.bottom, 26)
                        }

                        // HStack 2 — Cómo me manejo en...
                        if selectedCategory == nil || selectedCategory == .workSituation {
                            workSituationsSection.padding(.bottom, 26)
                        }

                        // Vertical list — salud mental / herramientas / enciclopedia
                        otherGuidesSection.padding(.bottom, 26)

                        // Agendar cita
                        psychologistCard
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)

                        // Chatbot Nubi
                        nubiChatCard
                            .padding(.horizontal, 20)
                            .padding(.bottom, 110)
                    }
                }
            }
            .navigationTitle("Guías de Bienestar")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedGuide) { guide in
            GuideDetailView(guide: guide)
        }
        .fullScreenCover(isPresented: $showAppointment) {
            AppointmentView()
                .environmentObject(vm)
        }
    }

    // MARK: - Search Bar
    var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundColor(.nubiGlaucous)
            TextField("Buscar guías...", text: $searchText).font(NubiFont.body)
        }
        .padding(14)
        .background(Color.white.opacity(0.85))
        .cornerRadius(16)
        .shadow(color: .nubiGlaucous.opacity(0.1), radius: 4)
    }

    // MARK: - Category Pills
    var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                pillBtn(label: "Todos",       icon: "square.grid.2x2.fill", cat: nil)
                pillBtn(label: "Soft Skills", icon: "brain",                cat: .softSkill)
                pillBtn(label: "Mi trabajo",  icon: "briefcase.fill",       cat: .workSituation)
                pillBtn(label: "Salud Mental",icon: "heart.fill",           cat: .saludMental)
                pillBtn(label: "Herramientas",icon: "wrench.and.screwdriver.fill", cat: .herramientas)
            }
            .padding(.horizontal, 20)
        }
    }

    private func pillBtn(label: String, icon: String, cat: GuideCategory?) -> some View {
        let active = selectedCategory == cat
        return Button {
            withAnimation(.spring(response: 0.3)) { selectedCategory = cat }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 11))
                Text(label).font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .foregroundColor(active ? .white : .nubiGlaucous)
            .padding(.horizontal, 13).padding(.vertical, 9)
            .background(active ? Color.nubiGlaucous : Color.nubiLightBlue.opacity(0.35))
            .cornerRadius(20)
        }
    }

    // MARK: ─────────────────────────────────────────────────
    // HSTACK 1 — Soft Skills
    // ─────────────────────────────────────────────────────
    var softSkillsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Soft Skills")
                        .font(NubiFont.heading).foregroundColor(.nubiDark)
                    Text("Habilidades que cambian todo")
                        .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.5))
                }
                Spacer()
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 22)).foregroundColor(.nubiGlaucous)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(filteredSoftSkills) { guide in
                        Button { selectedGuide = guide } label: { softSkillCard(guide) }
                            .buttonStyle(BounceButtonStyle())
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 4)
            }
        }
    }

    private func softSkillCard(_ g: Guide) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle().fill(g.accentColor.opacity(0.15)).frame(width: 52, height: 52)
                    Image(systemName: g.sfSymbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(g.accentColor)
                }
                Spacer()
                Label(g.readTime, systemImage: "clock")
                    .font(.system(size: 11, design: .rounded)).foregroundColor(g.accentColor)
            }
            Text(g.title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.nubiDark)
                .multilineTextAlignment(.leading).lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            RoundedRectangle(cornerRadius: 2).fill(g.accentColor).frame(width: 32, height: 3)
        }
        .frame(width: 158).padding(16)
        .background(Color.white.opacity(0.92)).cornerRadius(20)
        .shadow(color: g.accentColor.opacity(0.12), radius: 8, x: 0, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(g.accentColor.opacity(0.18), lineWidth: 1))
    }

    // MARK: ─────────────────────────────────────────────────
    // HSTACK 2 — Cómo me manejo en... (personalizado por puesto)
    // ─────────────────────────────────────────────────────
    var workSituationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cómo me manejo en...")
                        .font(NubiFont.heading).foregroundColor(.nubiDark)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").font(.system(size: 10)).foregroundColor(.nubiGlaucous)
                        Text("Para tu día a día en \(vm.userPosition.rawValue)")
                            .font(NubiFont.caption).foregroundColor(.nubiGlaucous)
                    }
                }
                Spacer()
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 22)).foregroundColor(.nubiGlaucous)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(filteredWorkGuides) { guide in
                        Button { selectedGuide = guide } label: { workSituationCard(guide) }
                            .buttonStyle(BounceButtonStyle())
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 4)
            }
        }
    }

    private func workSituationCard(_ g: Guide) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [g.accentColor, g.accentColor.opacity(0.55)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ).frame(height: 82)
                HStack {
                    Image(systemName: g.sfSymbol)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Label(g.readTime, systemImage: "clock")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }.padding(12)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(g.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.nubiDark)
                    .multilineTextAlignment(.leading).lineLimit(2)
                Text("Ver cómo manejarlo →")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(g.accentColor)
            }
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 172).background(Color.white.opacity(0.92)).cornerRadius(20)
        .shadow(color: g.accentColor.opacity(0.2), radius: 8, x: 0, y: 4).clipped()
    }

    // MARK: - Other Guides (vertical list)
    @ViewBuilder
    var otherGuidesSection: some View {
        let guides = filteredOtherGuides
        if !guides.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Más recursos")
                    .font(NubiFont.heading).foregroundColor(.nubiDark)
                    .padding(.horizontal, 20)
                ForEach(guides) { g in
                    Button { selectedGuide = g } label: { listCard(g) }
                        .buttonStyle(BounceButtonStyle())
                        .padding(.horizontal, 20)
                }
            }
        }
    }

    private func listCard(_ g: Guide) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(g.accentColor.opacity(0.12)).frame(width: 52, height: 52)
                Image(systemName: g.sfSymbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(g.accentColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(g.title).font(NubiFont.body).foregroundColor(.nubiDark).multilineTextAlignment(.leading)
                HStack(spacing: 8) {
                    Text(g.category.rawValue).font(NubiFont.caption).foregroundColor(g.accentColor)
                    Text("·").foregroundColor(.nubiDark.opacity(0.3))
                    Text(g.readTime).font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.4))
                }
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 13)).foregroundColor(.nubiGlaucous.opacity(0.4))
        }
        .padding(16).background(Color.white.opacity(0.8)).cornerRadius(18)
        .shadow(color: .nubiGlaucous.opacity(0.07), radius: 6)
    }

    // MARK: - Psychologist Card
    var psychologistCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.nubiGlaucous.opacity(0.12)).frame(width: 50, height: 50)
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .font(.system(size: 22)).foregroundColor(.nubiGlaucous)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("¿Necesitas hablar con alguien?")
                        .font(NubiFont.subheading).foregroundColor(.nubiDark)
                    Text("Agenda con un psicólogo de Coppel")
                        .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.55))
                }
                Spacer()
            }
            Button {
                showAppointment = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                    Text("Agendar cita gratuita")
                }
                .nubiButton(color: Color(hex: "#5C9999")).frame(maxWidth: .infinity)
            }
        }
        .padding(18)
        .background(Color.nubiGlaucous.opacity(0.07)).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.nubiGlaucous.opacity(0.22), lineWidth: 1.5))
    }

    // MARK: - Nubi Chat Card (entry point)
    var nubiChatCard: some View {
        Button { showNubiChat = true } label: {
            HStack(spacing: 16) {
                NubiAvatarView(color: .nubiGlaucous, size: 56, isAnimating: false)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Habla con Nubi")
                        .font(NubiFont.subheading).foregroundColor(.nubiDark)
                    Text("Cuéntame cómo te sientes. Te daré recomendaciones personalizadas para ti.")
                        .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.6))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.system(size: 28)).foregroundColor(.nubiGlaucous)
            }
            .padding(18)
            .background(LinearGradient(colors: [Color.nubiLightBlue.opacity(0.45), Color.nubiParchment],
                                       startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(22)
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.nubiGlaucous.opacity(0.25), lineWidth: 1.5))
            .shadow(color: .nubiGlaucous.opacity(0.1), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(BounceButtonStyle())
    }

    // MARK: - Filtered data
    private var filteredSoftSkills: [Guide] {
        softSkillsGuides.filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    private var filteredWorkGuides: [Guide] {
        workGuidesFor(position: vm.userPosition)
            .filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    private var filteredOtherGuides: [Guide] {
        let catMatch: (Guide) -> Bool = { g in
            guard let cat = selectedCategory else { return true }
            return g.category == cat
        }
        return encyclopediaGuides.filter { catMatch($0) &&
            (searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText)) }
    }
}

// MARK: - Guide Detail
struct GuideDetailView: View {
    let guide: Guide
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.nubiParchment.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        LinearGradient(colors: [guide.accentColor.opacity(0.3), Color.nubiParchment],
                                       startPoint: .top, endPoint: .bottom)
                        VStack(spacing: 12) {
                            Image(systemName: guide.sfSymbol)
                                .font(.system(size: 52, weight: .semibold))
                                .foregroundColor(guide.accentColor)
                            Text(guide.title)
                                .font(NubiFont.heading).foregroundColor(.nubiDark).multilineTextAlignment(.center)
                            HStack(spacing: 12) {
                                Label(guide.category.rawValue, systemImage: "tag.fill")
                                    .font(NubiFont.caption).foregroundColor(guide.accentColor)
                                Label(guide.readTime, systemImage: "clock")
                                    .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.45))
                            }
                        }
                        .padding(.vertical, 48).padding(.horizontal, 28)
                    }
                    Rectangle().fill(guide.accentColor).frame(height: 3).padding(.horizontal, 28)
                    Text(guide.content)
                        .font(NubiFont.body).foregroundColor(.nubiDark).lineSpacing(7).padding(28)
                    Spacer(minLength: 80)
                }
            }
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill").font(.system(size: 30))
                    .foregroundColor(.nubiGlaucous.opacity(0.7)).padding(20)
            }
        }
    }
}

// MARK: ════════════════════════════════════════════════
// GUIDES CHATBOT — Personalized with full user profile
// ════════════════════════════════════════════════════
struct GuidesChatbotView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    @State private var history: [[String: Any]]                             = []
    @State private var messages: [(id: UUID, role: String, text: String)]   = []
    @State private var input                                                = ""
    @State private var isLoading                                            = false
    @State private var showQuickTips                                        = true

    private let quickTips = [
        "¿Cómo manejo el estrés hoy?",
        "Dame un ejercicio de respiración",
        "¿Qué guía me recomiendas?",
        "Me siento agotado/a",
        "Tuve un cliente difícil",
    ]

    var body: some View {
        VStack(spacing: 0) {
            chatHeader
            Divider()
            messageList
            if showQuickTips && messages.count <= 1 { quickTipsRow }
            Divider()
            inputBar
        }
        .background(Color.nubiParchment.ignoresSafeArea())
        .onAppear { addWelcome() }
    }

    // MARK: - Header
    var chatHeader: some View {
        ZStack {
            LinearGradient(colors: [Color.nubiLightBlue.opacity(0.5), Color.nubiParchment],
                           startPoint: .top, endPoint: .bottom)
            HStack(spacing: 12) {
                NubiAvatarView(color: .nubiGlaucous, size: 44, isAnimating: false)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Nubi").font(NubiFont.subheading).foregroundColor(.nubiDark)
                    HStack(spacing: 5) {
                        Circle().fill(Color.green).frame(width: 7, height: 7)
                        Text("Respuestas personalizadas para ti")
                            .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.55))
                    }
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 26))
                        .foregroundColor(.nubiGlaucous.opacity(0.7))
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .frame(height: 72)
    }

    // MARK: - Messages
    var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(messages, id: \.id) { m in
                        bubble(text: m.text, isNubi: m.role == "assistant").id(m.id)
                    }
                    if isLoading { typingDots }
                }
                .padding(.horizontal, 16).padding(.vertical, 14).id("bottom")
            }
            .onChange(of: messages.count) { _ in withAnimation { proxy.scrollTo("bottom", anchor: .bottom) } }
            .onChange(of: isLoading) { _ in withAnimation { proxy.scrollTo("bottom", anchor: .bottom) } }
        }
    }

    // MARK: - Quick Tips
    var quickTipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(quickTips, id: \.self) { tip in
                    Button {
                        input = tip; sendMessage()
                        withAnimation { showQuickTips = false }
                    } label: {
                        Text(tip)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.nubiGlaucous)
                            .padding(.horizontal, 14).padding(.vertical, 9)
                            .background(Color.nubiLightBlue.opacity(0.3)).cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.nubiGlaucous.opacity(0.3), lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
        }
        .background(Color.nubiParchment)
    }

    // MARK: - Input Bar
    var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Escríbele a Nubi...", text: $input, axis: .vertical)
                .font(NubiFont.body).padding(12)
                .background(Color.white.opacity(0.85)).cornerRadius(16).lineLimit(1...4)
            Button { sendMessage() } label: {
                Image(systemName: "paperplane.fill").font(.system(size: 18)).foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(input.trimmingCharacters(in: .whitespaces).isEmpty || isLoading
                                ? Color.nubiGlaucous.opacity(0.35) : Color.nubiGlaucous)
                    .cornerRadius(14)
            }
            .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
        }
        .padding(.horizontal, 16).padding(.vertical, 12).background(Color.nubiParchment)
    }

    // MARK: - Bubble
    private func bubble(text: String, isNubi: Bool) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isNubi {
                ZStack {
                    Circle().fill(Color.nubiGlaucous.opacity(0.15)).frame(width: 28, height: 28)
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.nubiGlaucous)
                }
            }
            if !isNubi { Spacer(minLength: 50) }
            Text(text)
                .font(NubiFont.body)
                .foregroundColor(isNubi ? .nubiDark : .white)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(isNubi ? Color.nubiLightBlue.opacity(0.38) : Color.nubiGlaucous)
                .cornerRadius(20)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.72,
                       alignment: isNubi ? .leading : .trailing)
            if isNubi { Spacer(minLength: 50) }
            if !isNubi {
                ZStack {
                    Circle().fill(Color.nubiGlaucous.opacity(0.15)).frame(width: 28, height: 28)
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.nubiGlaucous)
                }
            }
        }
    }

    // MARK: - Typing dots
    var typingDots: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle().fill(Color.nubiGlaucous.opacity(0.15)).frame(width: 28, height: 28)
                Image(systemName: "cloud.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.nubiGlaucous)
            }
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle().fill(Color.nubiGlaucous).frame(width: 8, height: 8).opacity(0.5)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(Color.nubiLightBlue.opacity(0.35)).cornerRadius(20)
            Spacer()
        }
    }

    // MARK: - Welcome
    private func addWelcome() {
        let name   = vm.userName.isEmpty ? "" : ", \(vm.userName)"
        let puesto = vm.userPosition.rawValue
        let text   = "Hola\(name). Soy Nubi, tu compañero de bienestar. Sé que trabajas en \(puesto) y que no siempre es fácil. Estoy aquí para escucharte y darte recomendaciones hechas a tu medida. ¿Qué tal estuvo tu día?"
        messages.append((id: UUID(), role: "assistant", text: text))
    }

    // MARK: - Send
    private func sendMessage() {
        let text = input.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        input = ""; showQuickTips = false
        messages.append((id: UUID(), role: "user", text: text))
        history.append(["role": "user", "content": text])
        isLoading = true

        Task {
            do {
                let resp = try await vm.callGroqAPIWithHistory(
                    messages: history, systemPrompt: buildPrompt()
                )
                history.append(["role": "assistant", "content": resp])
                messages.append((id: UUID(), role: "assistant", text: resp))
            } catch {
                messages.append((id: UUID(), role: "assistant",
                                 text: "Lo siento, tuve un problema de conexión. ¿Lo intentamos de nuevo?"))
            }
            isLoading = false
        }
    }

    // MARK: - System Prompt
    private func buildPrompt() -> String {
        let emotionCtx = vm.todayEmotion.map {
            "Emoción de hoy: \($0.primaryEmotion) → \($0.subEmotion)."
        } ?? "No ha registrado emoción hoy."

        let stressors = vm.workStressors.isEmpty
            ? "No especificados"
            : vm.workStressors.map { $0.rawValue }.joined(separator: ", ")

        return """
        Eres Nubi, el compañero de bienestar emocional de los colaboradores de Coppel. \
        Empático, cálido, directo. Español mexicano. Usa "tú". Sin jerga clínica. \
        Máximo 4 oraciones. Termina siempre con una acción concreta o una pregunta de apoyo.

        PERFIL DEL COLABORADOR:
        - Nombre: \(vm.userName.isEmpty ? "No especificado" : vm.userName)
        - Edad: \(vm.userAge.isEmpty ? "No especificada" : "\(vm.userAge) años")
        - Género: \(vm.userGender.isEmpty ? "No especificado" : vm.userGender)
        - Puesto en Coppel: \(vm.userPosition.rawValue)
        - Estresores laborales principales: \(stressors)
        - Rol familiar: \(vm.familyRole.rawValue)
        - \(emotionCtx)

        INSTRUCCIONES CLAVE:
        - Personaliza SIEMPRE la respuesta usando su puesto, estresores y rol familiar cuando aplique.
        - Si mencionan clientes difíciles en \(vm.userPosition.rawValue), da estrategia específica para ese puesto.
        - Si recomiendas una guía, nómbrala por su título exacto (ej. "Cómo me manejo con un cliente que grita").
        - Si detectas crisis emocional severa, pide con calma que use el botón SOS de la app.
        """
    }
}
