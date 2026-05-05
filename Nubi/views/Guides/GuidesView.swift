//
//  GuidesView.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 05/05/26.
//

import SwiftUI

struct GuidesView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedGuide: Guide? = nil
    @State private var searchText = ""
    @State private var selectedCategory = "Todos"
    @State private var showAppointment = false

    let categories = ["Todos", "Trabajo", "Salud Mental", "Herramientas", "Soft Skills", "Enciclopedia"]

    var filteredGuides: [Guide] {
        sampleGuides.filter { guide in
            (selectedCategory == "Todos" || guide.category == selectedCategory) &&
            (searchText.isEmpty || guide.title.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.nubiParchment.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.nubiGlaucous)
                        TextField("Buscar guías...", text: $searchText)
                            .font(NubiFont.body)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(16)
                    .shadow(color: .nubiGlaucous.opacity(0.1), radius: 4)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(categories, id: \.self) { cat in
                                Button {
                                    withAnimation(.spring()) { selectedCategory = cat }
                                } label: {
                                    Text(cat)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(selectedCategory == cat ? .white : .nubiGlaucous)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == cat ? Color.nubiGlaucous : Color.nubiLightBlue.opacity(0.3))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Para ti (recomendadas)
                            if selectedCategory == "Todos" && !vm.emotionHistory.isEmpty {
                                recommendedSection
                            }

                            // Todas las guías
                            ForEach(filteredGuides) { guide in
                                Button {
                                    selectedGuide = guide
                                } label: {
                                    guideCard(guide: guide)
                                }
                                .buttonStyle(BounceButtonStyle())
                            }

                            // Directorio de psicólogos
                            psychologistCard

                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
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

    // MARK: - Recommended
    var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.nubiGlaucous)
                Text("Para ti esta semana")
                    .font(NubiFont.subheading)
                    .foregroundColor(.nubiDark)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(sampleGuides.filter { $0.isRecommended }) { guide in
                        Button { selectedGuide = guide } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(guide.emoji)
                                    .font(.system(size: 32))
                                Text(guide.title)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.nubiDark)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                HStack {
                                    Text(guide.category)
                                        .font(NubiFont.caption)
                                        .foregroundColor(.nubiGlaucous)
                                    Spacer()
                                    Text(guide.readTime)
                                        .font(NubiFont.caption)
                                        .foregroundColor(.nubiDark.opacity(0.4))
                                }
                            }
                            .frame(width: 160)
                            .padding(16)
                            .background(Color.white.opacity(0.85))
                            .cornerRadius(18)
                            .shadow(color: .nubiGlaucous.opacity(0.12), radius: 6)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.nubiLightBlue.opacity(0.18))
        .cornerRadius(20)
    }

    // MARK: - Guide Card
    private func guideCard(guide: Guide) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.nubiGlaucous.opacity(0.12))
                    .frame(width: 54, height: 54)
                Text(guide.emoji)
                    .font(.system(size: 28))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(guide.title)
                    .font(NubiFont.body)
                    .foregroundColor(.nubiDark)
                    .multilineTextAlignment(.leading)
                HStack(spacing: 8) {
                    Text(guide.category)
                        .font(NubiFont.caption)
                        .foregroundColor(.nubiGlaucous)
                    Text("·")
                        .foregroundColor(.nubiDark.opacity(0.3))
                    Text(guide.readTime)
                        .font(NubiFont.caption)
                        .foregroundColor(.nubiDark.opacity(0.4))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundColor(.nubiGlaucous.opacity(0.5))
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(18)
        .shadow(color: .nubiGlaucous.opacity(0.08), radius: 6)
    }

    // MARK: - Psychologist Card
    var psychologistCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "person.badge.shield.checkmark.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.nubiGlaucous)
                VStack(alignment: .leading, spacing: 3) {
                    Text("¿Necesitas hablar con alguien?")
                        .font(NubiFont.subheading)
                        .foregroundColor(.nubiDark)
                    Text("Agenda con un psicólogo de Coppel")
                        .font(NubiFont.caption)
                        .foregroundColor(.nubiDark.opacity(0.6))
                }
                Spacer()
            }
            Button {
                showAppointment = true
            } label: {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text("Agendar cita gratuita")
                }
                .nubiButton(color: Color(hex: "#5C9999"))
                .frame(maxWidth: .infinity)
            }
        }
        .padding(18)
        .background(Color.nubiGlaucous.opacity(0.08))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.nubiGlaucous.opacity(0.25), lineWidth: 1.5))
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
                VStack(alignment: .leading, spacing: 20) {
                    // Hero
                    ZStack {
                        LinearGradient(colors: [Color.nubiLightBlue.opacity(0.4), Color.nubiParchment],
                                       startPoint: .top, endPoint: .bottom)
                        VStack(spacing: 10) {
                            Text(guide.emoji).font(.system(size: 64))
                            Text(guide.title)
                                .font(NubiFont.heading)
                                .foregroundColor(.nubiDark)
                                .multilineTextAlignment(.center)
                            HStack {
                                Label(guide.category, systemImage: "tag.fill")
                                    .font(NubiFont.caption)
                                    .foregroundColor(.nubiGlaucous)
                                Label(guide.readTime, systemImage: "clock")
                                    .font(NubiFont.caption)
                                    .foregroundColor(.nubiDark.opacity(0.5))
                            }
                        }
                        .padding(.vertical, 40)
                        .padding(.horizontal, 24)
                    }

                    Text(guide.content)
                        .font(NubiFont.body)
                        .foregroundColor(.nubiDark)
                        .lineSpacing(6)
                        .padding(.horizontal, 24)

                    Spacer(minLength: 80)
                }
            }

            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.nubiGlaucous.opacity(0.7))
                    .padding(20)
            }
        }
    }
}
