//
//  GuidesView.swift
//  Nubi
//
import SwiftUI

struct GuidesView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedGuide: Guide?         = nil
    @State private var selectedCert : Certification? = nil
    @State private var selectedTool : WellnessTool?  = nil
    @State private var searchText                    = ""
    @State private var selectedCategory: GuideCategory = .softSkill
    @State private var showNubiChat                  = false

    /// Categorías visibles (sin "Todos"). "Energía Vital" solo si la usuaria la habilitó.
    private var availableCategories: [GuideCategory] {
        var cats: [GuideCategory] = [.softSkill, .workSituation, .saludMental, .herramientas]
        if vm.userGender == "mujer" && vm.cycleSyncEnabled {
            cats.append(.energiaVital)
        }
        return cats
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.coppelBackground, Color.coppelYellow.opacity(0.5)],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        searchBar.padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 14)
                        categoryPills.padding(.bottom, 22)

                        // Contenido filtrado por categoría seleccionada
                        switch selectedCategory {
                        case .softSkill:     softSkillsCertificationsSection.padding(.bottom, 26)
                        case .workSituation: workSituationsSection.padding(.bottom, 26)
                        case .saludMental:   saludMentalSection.padding(.bottom, 26)
                        case .herramientas:  toolsSection.padding(.bottom, 26)
                        case .energiaVital:  energiaVitalSection.padding(.bottom, 26)
                        case .enciclopedia:  EmptyView()
                        }

                        nubiChatCard.padding(.horizontal, 20).padding(.bottom, 110)
                    }
                }
            }
            .navigationTitle("Guías de Bienestar")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedGuide) { GuideDetailView(guide: $0) }
        .fullScreenCover(item: $selectedCert) { CertificationOverviewView(certification: $0) }
        .fullScreenCover(item: $selectedTool) { ToolView(tool: $0) }
        .fullScreenCover(isPresented: $showNubiChat) {
            GuidesChatbotView().environmentObject(vm)
        }
    }

    // MARK: - Search
    var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundColor(.coppelButton)
            TextField("Buscar guías...", text: $searchText).font(NubiFont.body)
        }
        .padding(14).background(Color.coppelYellow).cornerRadius(16)
        .shadow(color: .coppelDeepBlue.opacity(0.08), radius: 4)
    }

    // MARK: - Category Pills (sin "Todos")
    var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(availableCategories, id: \.self) { cat in
                    pillBtn(label: cat.rawValue, icon: pillIcon(cat), cat: cat)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func pillIcon(_ cat: GuideCategory) -> String {
        switch cat {
        case .softSkill:     return "brain.head.profile"
        case .workSituation: return "briefcase.fill"
        case .saludMental:   return "heart.fill"
        case .herramientas:  return "wrench.and.screwdriver.fill"
        case .energiaVital:  return "moon.stars.fill"
        case .enciclopedia:  return "book.fill"
        }
    }

    private func pillBtn(label: String, icon: String, cat: GuideCategory) -> some View {
        let active = selectedCategory == cat
        return Button {
            withAnimation(.spring(response: 0.3)) { selectedCategory = cat }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 11))
                Text(label).font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .foregroundColor(active ? .white : .coppelButton)
            .padding(.horizontal, 13).padding(.vertical, 9)
            .background(active ? Color.coppelButton : Color.coppelYellow)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20)
                .stroke(active ? Color.clear : Color.coppelButton.opacity(0.3), lineWidth: 1))
        }
    }

    // MARK: - Soft Skills (Certificaciones)
    var softSkillsCertificationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Soft Skills",
                          subtitle: "Cursos cortos con módulos y mini-tests",
                          icon: "graduationcap.fill",
                          showBadge: true)

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
            ZStack(alignment: .topTrailing) {
                LinearGradient(colors: [cert.accentColor, cert.accentColor.opacity(0.7)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .frame(height: 110)
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "rosette").font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.9)).padding(10)
                    }
                    Spacer()
                    HStack {
                        Image(systemName: cert.sfSymbol)
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.leading, 14).padding(.bottom, 12)
                        Spacer()
                    }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(cert.title).font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.coppelDeepBlue).multilineTextAlignment(.leading).lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 10) {
                    Label("\(cert.modules.count) módulos", systemImage: "square.stack.3d.up.fill")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(cert.accentColor)
                    Label(cert.estimatedTime, systemImage: "clock")
                        .font(.system(size: 10)).foregroundColor(.coppelDeepBlue.opacity(0.45))
                }
                HStack(spacing: 4) {
                    Text("Comenzar curso")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(cert.accentColor)
                    Image(systemName: "arrow.right").font(.system(size: 9, weight: .bold)).foregroundColor(cert.accentColor)
                }
            }
            .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 200)
        .background(Color.coppelYellow)
        .cornerRadius(20)
        .shadow(color: cert.accentColor.opacity(0.25), radius: 10, x: 0, y: 4)
        .clipped()
    }

    // MARK: - Work situations (todas visibles + texto más grande en detalle)
    var workSituationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Cómo me manejo en...")
                    .font(NubiFont.heading).foregroundColor(.coppelDeepBlue)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").font(.system(size: 10)).foregroundColor(.coppelButton)
                    Text("Para tu día a día en \(vm.userPosition.rawValue)")
                        .font(NubiFont.caption).foregroundColor(.coppelButton)
                }
            }
            .padding(.horizontal, 20)

            VStack(spacing: 12) {
                ForEach(filteredWorkGuides) { g in
                    Button { selectedGuide = g } label: { workSituationFullCard(g) }
                        .buttonStyle(BounceButtonStyle())
                        .padding(.horizontal, 20)
                }
            }
        }
    }

    /// Card más amplia con texto más legible para "Mi trabajo"
    private func workSituationFullCard(_ g: Guide) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(colors: [g.accentColor, g.accentColor.opacity(0.55)],
                               startPoint: .topLeading, endPoint: .bottomTrailing).frame(height: 76)
                HStack {
                    Image(systemName: g.sfSymbol).font(.system(size: 26, weight: .semibold)).foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "clock").font(.system(size: 10)).foregroundColor(.white.opacity(0.85))
                        Text(g.readTime).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(14)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(g.title.replacingOccurrences(of: "\n", with: " "))
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.coppelDeepBlue)
                    .multilineTextAlignment(.leading)
                Text(previewSnippet(g.content))
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.coppelDeepBlue.opacity(0.65))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 4) {
                    Text("Ver cómo manejarlo")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(g.accentColor)
                    Image(systemName: "arrow.right").font(.system(size: 10)).foregroundColor(g.accentColor)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.coppelYellow).cornerRadius(20)
        .shadow(color: g.accentColor.opacity(0.18), radius: 8, x: 0, y: 4).clipped()
    }

    private func previewSnippet(_ text: String) -> String {
        let firstLine = text.split(separator: "\n").first.map(String.init) ?? text
        return firstLine
    }

    // MARK: - Salud Mental (lista vertical con texto grande)
    var saludMentalSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Salud Mental",
                          subtitle: "Información cuidada y validada",
                          icon: "heart.fill",
                          showBadge: false)

            VStack(spacing: 12) {
                ForEach(filteredSaludMental) { g in
                    Button { selectedGuide = g } label: { saludMentalCard(g) }
                        .buttonStyle(BounceButtonStyle())
                        .padding(.horizontal, 20)
                }
            }
        }
    }

    private func saludMentalCard(_ g: Guide) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(g.accentColor.opacity(0.15))
                        .frame(width: 60, height: 60)
                    Image(systemName: g.sfSymbol)
                        .font(.system(size: 26))
                        .foregroundColor(g.accentColor)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(g.title.replacingOccurrences(of: "\n", with: " "))
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.coppelDeepBlue)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 8) {
                        Text(g.category.rawValue).font(.system(size: 12, weight: .medium, design: .rounded)).foregroundColor(g.accentColor)
                        Text("·").foregroundColor(.coppelDeepBlue.opacity(0.3))
                        Text(g.readTime).font(.system(size: 12, design: .rounded)).foregroundColor(.coppelDeepBlue.opacity(0.4))
                    }
                }
                Spacer()
            }
            Text(previewSnippet(g.content))
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.coppelDeepBlue.opacity(0.7))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Text("Leer guía completa").font(.system(size: 12, weight: .semibold, design: .rounded))
                    Image(systemName: "arrow.right").font(.system(size: 10))
                }
                .foregroundColor(g.accentColor)
            }
        }
        .padding(16)
        .background(Color.coppelYellow)
        .cornerRadius(20)
        .shadow(color: g.accentColor.opacity(0.12), radius: 6)
    }

    // MARK: - Herramientas
    var toolsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Herramientas",
                          subtitle: "Ejercicios guiados con temporizador",
                          icon: "wrench.and.screwdriver.fill",
                          showBadge: false)

            VStack(spacing: 12) {
                ForEach(allTools) { tool in
                    Button { selectedTool = tool } label: { toolFullCard(tool) }
                        .buttonStyle(BounceButtonStyle())
                        .padding(.horizontal, 20)
                }
            }
        }
    }

    private func toolFullCard(_ tool: WellnessTool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(tool.accentColor.opacity(0.2)).frame(width: 56, height: 56)
                Image(systemName: tool.sfSymbol).font(.system(size: 24, weight: .semibold)).foregroundColor(tool.accentColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(tool.title).font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundColor(.coppelDeepBlue)
                Text(tool.subtitle).font(.system(size: 13, design: .rounded)).foregroundColor(.coppelDeepBlue.opacity(0.6))
                    .lineLimit(2).fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            VStack {
                Image(systemName: "play.circle.fill").font(.system(size: 28)).foregroundColor(tool.accentColor)
                Text(tool.estimatedTime).font(.system(size: 10, weight: .medium, design: .rounded)).foregroundColor(tool.accentColor)
            }
        }
        .padding(16)
        .background(Color.coppelYellow).cornerRadius(20)
        .shadow(color: tool.accentColor.opacity(0.18), radius: 8, x: 0, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(tool.accentColor.opacity(0.25), lineWidth: 1))
    }

    // MARK: - Energía Vital
    var energiaVitalSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Energía Vital").font(NubiFont.heading).foregroundColor(.coppelDeepBlue)
                    HStack(spacing: 3) {
                        Image(systemName: "moon.stars.fill").font(.system(size: 9))
                        Text("PARA TI").font(.system(size: 9, weight: .heavy, design: .rounded)).tracking(0.8)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color(hex: "#EF476F"))
                    .cornerRadius(10)
                }
                Text("Trabaja con tu cuerpo, no en contra")
                    .font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.55))
            }
            .padding(.horizontal, 20)

            VStack(spacing: 12) {
                ForEach(energiaVitalGuides) { g in
                    Button { selectedGuide = g } label: { energiaVitalCard(g) }
                        .buttonStyle(BounceButtonStyle())
                        .padding(.horizontal, 20)
                }
            }
        }
    }

    private func energiaVitalCard(_ g: Guide) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(colors: [g.accentColor, g.accentColor.opacity(0.6)],
                               startPoint: .topLeading, endPoint: .bottomTrailing).frame(height: 90)
                HStack {
                    Image(systemName: g.sfSymbol).font(.system(size: 30, weight: .semibold)).foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "clock").font(.system(size: 10)).foregroundColor(.white.opacity(0.85))
                        Text(g.readTime).font(.system(size: 11, weight: .medium, design: .rounded)).foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(16)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(g.title.replacingOccurrences(of: "\n", with: " "))
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.coppelDeepBlue)
                Text(previewSnippet(g.content))
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.coppelDeepBlue.opacity(0.65))
                    .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 4) {
                    Text("Leer guía").font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundColor(g.accentColor)
                    Image(systemName: "arrow.right").font(.system(size: 10)).foregroundColor(g.accentColor)
                }
            }
            .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.coppelYellow).cornerRadius(20)
        .shadow(color: g.accentColor.opacity(0.2), radius: 8, x: 0, y: 4).clipped()
    }

    // MARK: - Section header
    private func sectionHeader(title: String, subtitle: String, icon: String, showBadge: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(title).font(NubiFont.heading).foregroundColor(.coppelDeepBlue)
                    if showBadge {
                        HStack(spacing: 3) {
                            Image(systemName: "rosette").font(.system(size: 9))
                            Text("CERTIFICACIONES").font(.system(size: 9, weight: .heavy, design: .rounded)).tracking(0.8)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.coppelButton)
                        .cornerRadius(10)
                    }
                }
                Text(subtitle).font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.55))
            }
            Spacer()
            Image(systemName: icon).font(.system(size: 22)).foregroundColor(.coppelButton)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Nubi Chat
    var nubiChatCard: some View {
        Button { showNubiChat = true } label: {
            HStack(spacing: 16) {
                NubiAvatarView(color: .coppelButton, size: 56, isAnimating: false)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left.and.bubble.right.fill").foregroundColor(.coppelButton)
                        Text("Habla con Nubi").font(NubiFont.subheading).foregroundColor(.coppelDeepBlue)
                    }
                    Text("Cuéntame cómo te sientes. Te daré recomendaciones personalizadas para ti.")
                        .font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.6))
                        .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "arrow.up.right.circle.fill").font(.system(size: 28)).foregroundColor(.coppelButton)
            }
            .padding(18)
            .background(LinearGradient(colors: [Color.coppelYellow, Color.coppelBackground],
                                       startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(22)
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.coppelButton.opacity(0.3), lineWidth: 1.5))
            .shadow(color: .coppelDeepBlue.opacity(0.10), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(BounceButtonStyle())
    }

    // MARK: - Filters
    private var filteredWorkGuides: [Guide] {
        workGuidesFor(position: vm.userPosition)
            .filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    private var filteredSaludMental: [Guide] {
        encyclopediaGuides
            .filter { $0.category == .saludMental }
            .filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
    }
}

// MARK: - Detail con texto más grande
struct GuideDetailView: View {
    let guide: Guide
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.coppelBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        LinearGradient(colors: [guide.accentColor.opacity(0.3), Color.coppelBackground],
                                       startPoint: .top, endPoint: .bottom)
                        VStack(spacing: 14) {
                            ZStack {
                                Circle().fill(guide.accentColor.opacity(0.15)).frame(width: 90, height: 90)
                                Image(systemName: guide.sfSymbol).font(.system(size: 40)).foregroundColor(guide.accentColor)
                            }
                            Text(guide.title).font(NubiFont.heading).foregroundColor(.coppelDeepBlue).multilineTextAlignment(.center)
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
                                .foregroundColor(.coppelDeepBlue.opacity(0.45))
                            }
                        }
                        .padding(.vertical, 48).padding(.horizontal, 28)
                    }
                    Rectangle().fill(guide.accentColor).frame(height: 3).padding(.horizontal, 28)
                    Text(guide.content)
                        .font(NubiFont.guideBody)        // ← más grande
                        .foregroundColor(.coppelDeepBlue)
                        .lineSpacing(8)
                        .padding(28)
                    Spacer(minLength: 80)
                }
            }
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill").font(.system(size: 30))
                    .foregroundColor(.coppelButton.opacity(0.8)).padding(20)
            }
        }
    }
}

// MARK: - Chatbot
struct GuidesChatbotView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var history : [[String: Any]]                          = []
    @State private var messages: [(id: UUID, role: String, text: String)] = []
    @State private var input                                              = ""
    @State private var isLoading                                          = false
    @State private var showQuickTips                                      = true

    private let quickTips = [
        "¿Cómo manejo el estrés hoy?",
        "Dame un ejercicio de respiración",
        "¿Qué guía me recomiendas?",
        "Me siento agotado/a",
        "Tuve un cliente difícil",
    ]

    var body: some View {
        VStack(spacing: 0) {
            chatHeader; Divider()
            messageList
            if showQuickTips && messages.count <= 1 { quickTipsRow }
            Divider(); inputBar
        }
        .background(Color.coppelBackground.ignoresSafeArea())
        .onAppear { addWelcome() }
    }

    var chatHeader: some View {
        ZStack {
            LinearGradient(colors: [Color.coppelYellow, Color.coppelBackground],
                           startPoint: .top, endPoint: .bottom)
            HStack(spacing: 12) {
                NubiAvatarView(color: .coppelButton, size: 44, isAnimating: false)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Nubi").font(NubiFont.subheading).foregroundColor(.coppelDeepBlue)
                    HStack(spacing: 5) {
                        Circle().fill(Color.green).frame(width: 7, height: 7)
                        Text("Respuestas personalizadas para ti").font(NubiFont.caption).foregroundColor(.coppelDeepBlue.opacity(0.55))
                    }
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 26)).foregroundColor(.coppelButton.opacity(0.7))
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
                        input = tip; sendMessage(); withAnimation { showQuickTips = false }
                    } label: {
                        Text(tip).font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.coppelButton)
                            .padding(.horizontal, 14).padding(.vertical, 9)
                            .background(Color.coppelYellow).cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.coppelButton.opacity(0.4), lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
        }
    }

    var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Escríbele a Nubi...", text: $input, axis: .vertical)
                .font(NubiFont.body).padding(12).background(Color.white.opacity(0.9)).cornerRadius(16).lineLimit(1...4)
            Button { vm.toggleRecording { text in input = text } } label: {
                Image(systemName: vm.isRecording ? "mic.fill.badge.xmark" : "mic.fill")
                    .font(.system(size: 20))
                    .foregroundColor(vm.isRecording ? .red : .coppelButton)
                    .scaleEffect(vm.isRecording ? 1.1 : 1.0)
            }
            Button { sendMessage() } label: {
                Image(systemName: "paperplane.fill").font(.system(size: 18)).foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(input.trimmingCharacters(in: .whitespaces).isEmpty || isLoading
                                ? Color.coppelButton.opacity(0.4) : Color.coppelButton)
                    .cornerRadius(14)
            }
            .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
        }
        .padding(.horizontal, 16).padding(.vertical, 12).background(Color.coppelBackground)
    }

    private func bubble(_ text: String, isNubi: Bool) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isNubi {
                Image(systemName: "cloud.fill").font(.system(size: 18)).foregroundColor(.coppelButton)
            }
            if !isNubi { Spacer(minLength: 50) }
            VStack(alignment: isNubi ? .leading : .trailing, spacing: 4) {
                Text((try? AttributedString(markdown: text)) ?? AttributedString(text)).font(NubiFont.body)
                    .foregroundColor(isNubi ? .coppelDeepBlue : .white)
                if isNubi {
                    Button { vm.speak(text: text) } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("Escuchar")
                        }
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.coppelButton.opacity(0.8))
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(isNubi ? Color.coppelYellow : Color.coppelButton)
            .cornerRadius(20)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.72, alignment: isNubi ? .leading : .trailing)
            if isNubi { Spacer(minLength: 50) }
            if !isNubi {
                Image(systemName: "person.crop.circle.fill").font(.system(size: 18)).foregroundColor(.coppelButton)
            }
        }
    }

    var typingDots: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Image(systemName: "cloud.fill").font(.system(size: 18)).foregroundColor(.coppelButton)
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { _ in Circle().fill(Color.coppelButton).frame(width: 8, height: 8).opacity(0.5) }
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(Color.coppelYellow).cornerRadius(20)
            Spacer()
        }
    }

    private func addWelcome() {
        let name = vm.userName.isEmpty ? "" : ", \(vm.userName)"
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
                let err = "Lo siento, tuve un problema de conexión. ¿Lo intentamos de nuevo?"
                messages.append((id: UUID(), role: "assistant", text: err))
            }
            isLoading = false
        }
    }

    private func buildPrompt() -> String {
        let emotionCtx = vm.todayEmotion.map { "Emoción de hoy: \($0.primaryEmotion) — \($0.subEmotion)." } ?? "No registró emoción hoy."
        return """
        Eres Nubi, el compañero de bienestar de los colaboradores de Coppel. Empático, cálido, directo. Español mexicano. Usa "tú". Sin jerga clínica. Máximo 4 oraciones. Termina con acción concreta o pregunta de apoyo.
        PERFIL: \(vm.userProfileContext) | \(emotionCtx)
        Considera contexto especial si es mamá o ciclo sincronizado: ofrece consideración por carga emocional y física. Si detectas crisis severa, recomienda usar el botón SOS.
        """
    }
}
