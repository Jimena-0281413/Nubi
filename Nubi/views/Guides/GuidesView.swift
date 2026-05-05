//
//  GuidesView.swift
//  Nubi
//

import SwiftUI

struct GuidesView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedGuide: Guide?            = nil
    @State private var selectedCert: Certification?     = nil
    @State private var selectedTool: WellnessTool?      = nil
    @State private var searchText                       = ""
    @State private var selectedCategory: GuideCategory? = nil
    @State private var showNubiChat                     = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.nubiParchment.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        searchBar.padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 14)
                        categoryPills.padding(.bottom, 22)

                        // ── HSTACK 1: SOFT SKILLS (CERTIFICACIONES) ──
                        if selectedCategory == nil || selectedCategory == .softSkill {
                            softSkillsCertificationsSection.padding(.bottom, 26)
                        }

                        // ── HSTACK 2: CÓMO ME MANEJO EN... ──
                        if selectedCategory == nil || selectedCategory == .workSituation {
                            workSituationsSection.padding(.bottom, 26)
                        }

                        // ── HERRAMIENTAS GUIADAS ──
                        if selectedCategory == nil || selectedCategory == .herramientas {
                            toolsSection.padding(.bottom, 26)
                        }

                        // ── ENCICLOPEDIA / SALUD MENTAL ──
                        otherGuidesSection.padding(.bottom, 26)

                        psychologistCard.padding(.horizontal, 20).padding(.bottom, 20)
                        nubiChatCard.padding(.horizontal, 20).padding(.bottom, 110)
                    }
                }
            }
            .navigationTitle("Guías de Bienestar")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedGuide) { GuideDetailView(guide: $0) }
        .fullScreenCover(item: $selectedCert) { cert in
            CertificationOverviewView(certification: cert)
        }
        .fullScreenCover(item: $selectedTool) { tool in
            ToolView(tool: tool)
        }
        .fullScreenCover(isPresented: $showNubiChat) {
            GuidesChatbotView().environmentObject(vm)
        }
    }

    // MARK: - Search
    var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundColor(.nubiGlaucous)
            TextField("Buscar guías...", text: $searchText).font(NubiFont.body)
        }
        .padding(14).background(Color.white.opacity(0.85)).cornerRadius(16)
        .shadow(color: .nubiGlaucous.opacity(0.1), radius: 4)
    }

    // MARK: - Category Pills
    var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                pillBtn(label: "Todos",        icon: "square.grid.2x2.fill",            cat: nil)
                pillBtn(label: "Soft Skills",  icon: "brain.head.profile",              cat: .softSkill)
                pillBtn(label: "Mi trabajo",   icon: "briefcase.fill",                  cat: .workSituation)
                pillBtn(label: "Salud Mental", icon: "heart.fill",                      cat: .saludMental)
                pillBtn(label: "Herramientas", icon: "wrench.and.screwdriver.fill",     cat: .herramientas)
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

    // MARK: ─────────────────────────────────────────
    // HSTACK 1: SOFT SKILLS (Certificaciones extensas)
    // ───────────────────────────────────────────────
    var softSkillsCertificationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Soft Skills")
                            .font(NubiFont.heading).foregroundColor(.nubiDark)
                        // BADGE NEW
                        HStack(spacing: 3) {
                            Image(systemName: "rosette").font(.system(size: 9))
                            Text("CERTIFICACIONES")
                                .font(.system(size: 9, weight: .heavy, design: .rounded))
                                .tracking(0.8)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.nubiGlaucous)
                        .cornerRadius(10)
                    }
                    Text("Cursos cortos con módulos y mini-tests")
                        .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.55))
                }
                Spacer()
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 22)).foregroundColor(.nubiGlaucous)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(allCertifications) { cert in
                        Button { selectedCert = cert } label: { certificationCard(cert) }
                            .buttonStyle(BounceButtonStyle())
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 4)
            }
        }
    }

    private func certificationCard(_ cert: Certification) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header con gradiente y rosette
            ZStack(alignment: .topTrailing) {
                LinearGradient(colors: [cert.accentColor, cert.accentColor.opacity(0.7)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 110)
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "rosette")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(10)
                    }
                    Spacer()
                    HStack {
                        Image(systemName: cert.sfSymbol)
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.leading, 14)
                            .padding(.bottom, 12)
                        Spacer()
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(cert.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.nubiDark)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    Label("\(cert.modules.count) módulos", systemImage: "square.stack.3d.up.fill")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(cert.accentColor)
                    Label(cert.estimatedTime, systemImage: "clock")
                        .font(.system(size: 10))
                        .foregroundColor(.nubiDark.opacity(0.45))
                }

                HStack(spacing: 4) {
                    Text("Comenzar curso")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(cert.accentColor)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(cert.accentColor)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 200)
        .background(Color.white.opacity(0.92))
        .cornerRadius(20)
        .shadow(color: cert.accentColor.opacity(0.25), radius: 10, x: 0, y: 4)
        .clipped()
    }

    // MARK: ─────────────────────────────────────────
    // HSTACK 2: CÓMO ME MANEJO EN...
    // ───────────────────────────────────────────────
    var workSituationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cómo me manejo en...").font(NubiFont.heading).foregroundColor(.nubiDark)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").font(.system(size: 10)).foregroundColor(.nubiGlaucous)
                        Text("Para tu día a día en \(vm.userPosition.rawValue)")
                            .font(NubiFont.caption).foregroundColor(.nubiGlaucous)
                    }
                }
                Spacer()
                Image(systemName: "briefcase.fill").font(.system(size: 22)).foregroundColor(.nubiGlaucous)
            }
            .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(filteredWorkGuides) { g in
                        Button { selectedGuide = g } label: { workSituationCard(g) }
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
                LinearGradient(colors: [g.accentColor, g.accentColor.opacity(0.55)],
                               startPoint: .topLeading, endPoint: .bottomTrailing).frame(height: 82)
                HStack {
                    Image(systemName: g.sfSymbol).font(.system(size: 26, weight: .semibold)).foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "clock").font(.system(size: 9)).foregroundColor(.white.opacity(0.8))
                        Text(g.readTime).font(.system(size: 10, weight: .medium, design: .rounded)).foregroundColor(.white.opacity(0.85))
                    }
                }
                .padding(12)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(g.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.nubiDark).multilineTextAlignment(.leading).lineLimit(2)
                HStack(spacing: 4) {
                    Text("Ver cómo manejarlo")
                        .font(.system(size: 11, weight: .medium, design: .rounded)).foregroundColor(g.accentColor)
                    Image(systemName: "arrow.right").font(.system(size: 9)).foregroundColor(g.accentColor)
                }
            }
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 172).background(Color.white.opacity(0.92)).cornerRadius(20)
        .shadow(color: g.accentColor.opacity(0.2), radius: 8, x: 0, y: 4).clipped()
    }

    // MARK: ─────────────────────────────────────────
    // HERRAMIENTAS GUIADAS
    // ───────────────────────────────────────────────
    var toolsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Herramientas").font(NubiFont.heading).foregroundColor(.nubiDark)
                    Text("Ejercicios guiados con temporizador")
                        .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.55))
                }
                Spacer()
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 22)).foregroundColor(.nubiGlaucous)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(allTools) { tool in
                        Button { selectedTool = tool } label: { toolCard(tool) }
                            .buttonStyle(BounceButtonStyle())
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 4)
            }
        }
    }

    private func toolCard(_ tool: WellnessTool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle().fill(tool.accentColor.opacity(0.2)).frame(width: 50, height: 50)
                    Image(systemName: tool.sfSymbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(tool.accentColor)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "play.circle.fill").font(.system(size: 16))
                    Text(tool.estimatedTime).font(.system(size: 11, weight: .medium, design: .rounded))
                }
                .foregroundColor(tool.accentColor)
            }
            Text(tool.title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.nubiDark)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Text(tool.subtitle)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.nubiDark.opacity(0.6))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                Text("Comenzar")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                Image(systemName: "arrow.right").font(.system(size: 9, weight: .bold))
            }
            .foregroundColor(tool.accentColor)
        }
        .frame(width: 175, height: 175, alignment: .topLeading)
        .padding(14)
        .background(Color.white.opacity(0.92))
        .cornerRadius(20)
        .shadow(color: tool.accentColor.opacity(0.18), radius: 8, x: 0, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(tool.accentColor.opacity(0.25), lineWidth: 1))
    }

    // MARK: - Other guides (encyclopedia/health)
    @ViewBuilder
    var otherGuidesSection: some View {
        let guides = filteredOtherGuides
        if !guides.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Más recursos").font(NubiFont.heading).foregroundColor(.nubiDark).padding(.horizontal, 20)
                ForEach(guides) { g in
                    Button { selectedGuide = g } label: { listCard(g) }
                        .buttonStyle(BounceButtonStyle()).padding(.horizontal, 20)
                }
            }
        }
    }

    private func listCard(_ g: Guide) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(g.accentColor.opacity(0.12)).frame(width: 52, height: 52)
                Image(systemName: g.sfSymbol).font(.system(size: 22)).foregroundColor(g.accentColor)
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

    // MARK: - Psychologist card
    var psychologistCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.nubiGlaucous.opacity(0.12)).frame(width: 50, height: 50)
                    Image(systemName: "person.badge.shield.checkmark.fill").font(.system(size: 22)).foregroundColor(.nubiGlaucous)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("¿Necesitas hablar con alguien?").font(NubiFont.subheading).foregroundColor(.nubiDark)
                    Text("Agenda con un psicólogo de Coppel").font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.55))
                }
                Spacer()
            }
            Button {} label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                    Text("Agendar cita gratuita")
                }
                .nubiButton(color: Color(hex: "#5C9999")).frame(maxWidth: .infinity)
            }
        }
        .padding(18).background(Color.nubiGlaucous.opacity(0.07)).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.nubiGlaucous.opacity(0.22), lineWidth: 1.5))
    }

    // MARK: - Nubi Chat Entry Card
    var nubiChatCard: some View {
        Button { showNubiChat = true } label: {
            HStack(spacing: 16) {
                NubiAvatarView(color: .nubiGlaucous, size: 56, isAnimating: false)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left.and.bubble.right.fill").foregroundColor(.nubiGlaucous)
                        Text("Habla con Nubi").font(NubiFont.subheading).foregroundColor(.nubiDark)
                    }
                    Text("Cuéntame cómo te sientes. Te daré recomendaciones personalizadas para ti.")
                        .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.6))
                        .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "arrow.up.right.circle.fill").font(.system(size: 28)).foregroundColor(.nubiGlaucous)
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

    // MARK: - Filters
    private var filteredWorkGuides: [Guide] {
        workGuidesFor(position: vm.userPosition)
            .filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    private var filteredOtherGuides: [Guide] {
        let catOK: (Guide) -> Bool = { g in
            guard let cat = selectedCategory else { return true }
            // herramientas now lives as its own section; remove from list
            if cat == .herramientas { return false }
            return g.category == cat
        }
        return encyclopediaGuides.filter { catOK($0) && (searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText)) }
    }
}

// MARK: - Guide Detail (igual que antes)
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
                        VStack(spacing: 14) {
                            ZStack {
                                Circle().fill(guide.accentColor.opacity(0.15)).frame(width: 90, height: 90)
                                Image(systemName: guide.sfSymbol).font(.system(size: 40)).foregroundColor(guide.accentColor)
                            }
                            Text(guide.title).font(NubiFont.heading).foregroundColor(.nubiDark).multilineTextAlignment(.center)
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "tag.fill").font(.system(size: 11))
                                    Text(guide.category.rawValue).font(NubiFont.caption)
                                }
                                .foregroundColor(guide.accentColor)
                                HStack(spacing: 4) {
                                    Image(systemName: "clock").font(.system(size: 11))
                                    Text(guide.readTime).font(NubiFont.caption)
                                }
                                .foregroundColor(.nubiDark.opacity(0.45))
                            }
                        }
                        .padding(.vertical, 48).padding(.horizontal, 28)
                    }
                    Rectangle().fill(guide.accentColor).frame(height: 3).padding(.horizontal, 28)
                    Text(guide.content).font(NubiFont.body).foregroundColor(.nubiDark)
                        .lineSpacing(7).padding(28)
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

// MARK: - Guides Chatbot (sin cambios)
struct GuidesChatbotView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var history : [[String: Any]]                           = []
    @State private var messages: [(id: UUID, role: String, text: String)] = []
    @State private var input                                               = ""
    @State private var isLoading                                           = false
    @State private var showQuickTips                                       = true

    private let quickTips = [
        "Cómo manejo el estrés hoy?",
        "Dame un ejercicio de respiración",
        "Qué guía me recomiendas?",
        "Me siento agotado/a",
        "Tuve un cliente difícil",
    ]

    var body: some View {
        VStack(spacing: 0) {
            chatHeader; Divider()
            messageList
            if showQuickTips && messages.count <= 1 { quickTipsRow }
            Divider(); inputBar
            disclaimerText
        }
        .background(Color.nubiParchment.ignoresSafeArea())
        .onAppear { addWelcome() }
    }

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

    var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(messages, id: \.id) { m in bubble(m.text, isNubi: m.role == "assistant").id(m.id) }
                    if isLoading { typingDots }
                }
                .padding(.horizontal, 16).padding(.vertical, 14).id("btm")
            }
            .onChange(of: messages.count) { _ in withAnimation { proxy.scrollTo("btm", anchor: .bottom) } }
            .onChange(of: isLoading) { _ in withAnimation { proxy.scrollTo("btm", anchor: .bottom) } }
        }
    }

    var quickTipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(quickTips, id: \.self) { tip in
                    Button {
                        input = tip; sendMessage()
                        withAnimation { showQuickTips = false }
                    } label: {
                        Text(tip).font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.nubiGlaucous).padding(.horizontal, 14).padding(.vertical, 9)
                            .background(Color.nubiLightBlue.opacity(0.3)).cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.nubiGlaucous.opacity(0.3), lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
        }
        .background(Color.nubiParchment)
    }

    var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Escríbele a Nubi...", text: $input, axis: .vertical)
                .font(NubiFont.body).padding(12).background(Color.white.opacity(0.85)).cornerRadius(16).lineLimit(1...4)
            Button { sendMessage() } label: {
                Image(systemName: "paperplane.fill").font(.system(size: 18)).foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(input.trimmingCharacters(in: .whitespaces).isEmpty || isLoading
                                ? Color.nubiGlaucous.opacity(0.35) : Color.nubiGlaucous)
                    .cornerRadius(14)
            }
            .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
        }
        .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 6).background(Color.nubiParchment)
    }

    var disclaimerText: some View {
        Text("Nubi es un modelo de IA preentrenado. Si necesitas apoyo clínico o emocional, por favor acércate a un profesional.")
            .font(.system(size: 10, weight: .regular, design: .rounded))
            .foregroundColor(.nubiDark.opacity(0.45))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .background(Color.nubiParchment)
    }

    private func bubble(_ text: String, isNubi: Bool) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isNubi {
                Image(systemName: "cloud.fill").font(.system(size: 18)).foregroundColor(.nubiGlaucous)
            }
            if !isNubi { Spacer(minLength: 50) }
            Text(text).font(NubiFont.body)
                .foregroundColor(isNubi ? .nubiDark : .white)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(isNubi ? Color.nubiLightBlue.opacity(0.38) : Color.nubiGlaucous)
                .cornerRadius(20)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.72, alignment: isNubi ? .leading : .trailing)
            if isNubi { Spacer(minLength: 50) }
            if !isNubi {
                Image(systemName: "person.crop.circle.fill").font(.system(size: 18)).foregroundColor(.nubiGlaucous)
            }
        }
    }

    var typingDots: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Image(systemName: "cloud.fill").font(.system(size: 18)).foregroundColor(.nubiGlaucous)
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { _ in Circle().fill(Color.nubiGlaucous).frame(width: 8, height: 8).opacity(0.5) }
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(Color.nubiLightBlue.opacity(0.35)).cornerRadius(20)
            Spacer()
        }
    }

    private func addWelcome() {
        let name = vm.userName.isEmpty ? "" : " \(vm.userName)"
        let text = "Hola\(name). Soy Nubi, tu compañero de bienestar. Sé que trabajas en \(vm.userPosition.rawValue) y que no siempre es fácil. Estoy aquí para escucharte. ¿Cómo estuvo tu día?"
        messages.append((id: UUID(), role: "assistant", text: text))
    }

    private func sendMessage() {
        let text = input.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        input = ""; showQuickTips = false
        messages.append((id: UUID(), role: "user", text: text))
        history.append(["role": "user", "content": text])
        isLoading = true
        Task {
            do {
                let resp = try await vm.callGroqAPIWithHistory(messages: history, systemPrompt: buildPrompt())
                history.append(["role": "assistant", "content": resp])
                messages.append((id: UUID(), role: "assistant", text: resp))
            } catch {
                messages.append((id: UUID(), role: "assistant", text: "Lo siento, tuve un problema de conexión. ¿Lo intentamos de nuevo?"))
            }
            isLoading = false
        }
    }

    private func buildPrompt() -> String {
        let emotionCtx = vm.todayEmotion.map { "Emoción de hoy: \($0.primaryEmotion) -> \($0.subEmotion)." } ?? "No ha registrado emoción hoy."
        let stressors = vm.workStressors.isEmpty ? "No especificados" : vm.workStressors.map { $0.rawValue }.joined(separator: ", ")
        return """
        Eres Nubi, psicólogo de bienestar emocional para los colaboradores de Coppel.
        Tu rol en este chat es dar apoyo inmediato y consuelo para situaciones aisladas y puntuales que el usuario está viviendo en este momento.

        TONO Y ESTILO:
        - Empático, cálido, directo y profesional (que el usuario se sienta tranquilo y contenido).
        - Español mexicano, usando "tú" y llamando al usuario por su nombre.
        - Sin jerga clínica, respuestas conversacionales y naturales.
        - Sé breve (máximo 3-4 oraciones). No hagas listas largas.

        PERFIL DEL COLABORADOR:
        - Nombre: \(vm.userName.isEmpty ? "No especificado" : vm.userName)
        - Edad: \(vm.userAge.isEmpty ? "No especificada" : "\(vm.userAge) años")
        - Puesto en Coppel: \(vm.userPosition.rawValue)
        - Estresores laborales principales: \(stressors)
        - Rol familiar: \(vm.familyRole.rawValue)
        - \(emotionCtx)

        INSTRUCCIONES CLAVE PARA TUS RESPUESTAS:
        1. Valida su emoción primero. Hazle saber que es normal sentirse así.
        2. Dale consuelo profesional pero muy humano.
        3. Brinda 1 (máximo 2) tips o consejos súper prácticos y rápidos para manejar esa situación en este preciso momento.
        4. Si notas una crisis severa, sugiere con mucha calma usar el botón SOS de la app.
        5. Personaliza siempre la respuesta con su puesto y estresores. Termina con una acción concreta o pregunta de apoyo.
        """
    }
}
