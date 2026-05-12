//
//  CertificationView.swift
//  Nubi
//
//  Vista de micro-certificación con módulos, lectura y quiz
//

import SwiftUI

// MARK: ────────────────────────────────────────────────────
// 1. CERTIFICATION OVERVIEW (lista de módulos)
// ────────────────────────────────────────────────────────
struct CertificationOverviewView: View {
    let certification: Certification
    @Environment(\.dismiss) var dismiss
    @State private var selectedModule: CertModule? = nil

    // Progreso por módulo (en memoria por ahora)
    @State private var completedModuleIDs: Set<UUID> = []

    private var progress: Double {
        guard !certification.modules.isEmpty else { return 0 }
        return Double(completedModuleIDs.count) / Double(certification.modules.count)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.nubiParchment.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // ── HERO ──────────────────────────────
                    heroSection

                    // ── PROGRESS BAR ──────────────────────
                    progressSection

                    // ── MODULES LIST ──────────────────────
                    modulesList

                    // ── COMPLETION CARD ───────────────────
                    if completedModuleIDs.count == certification.modules.count {
                        completionCard
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 60)
            }

            // Close button
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(certification.accentColor.opacity(0.7))
                    .padding(20)
            }
        }
        .sheet(item: $selectedModule) { module in
            CertModuleView(
                module: module,
                accentColor: certification.accentColor,
                isCompleted: completedModuleIDs.contains(module.id),
                onComplete: { completedModuleIDs.insert(module.id) }
            )
        }
    }

    // MARK: - Hero
    var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(certification.accentColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                Image(systemName: certification.sfSymbol)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(certification.accentColor)
            }

            // Badge "Certificación"
            HStack(spacing: 5) {
                Image(systemName: "rosette")
                    .font(.system(size: 11))
                Text("MICRO-CERTIFICACIÓN")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(1.2)
            }
            .foregroundColor(certification.accentColor)
            .padding(.horizontal, 12).padding(.vertical, 5)
            .background(certification.accentColor.opacity(0.12))
            .cornerRadius(20)

            Text(certification.title)
                .font(NubiFont.title)
                .foregroundColor(.nubiDark)
                .multilineTextAlignment(.center)

            Text(certification.subtitle)
                .font(NubiFont.body)
                .foregroundColor(.nubiDark.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            HStack(spacing: 14) {
                Label(certification.estimatedTime, systemImage: "clock.fill")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiDark.opacity(0.5))
                Label("\(certification.modules.count) módulos", systemImage: "square.stack.3d.up.fill")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiDark.opacity(0.5))
            }
        }
    }

    // MARK: - Progress
    var progressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Tu progreso")
                    .font(NubiFont.subheading)
                    .foregroundColor(.nubiDark)
                Spacer()
                Text("\(completedModuleIDs.count)/\(certification.modules.count)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(certification.accentColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.nubiLightBlue.opacity(0.3))
                        .frame(height: 10)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [certification.accentColor, certification.accentColor.opacity(0.7)],
                            startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(0, geo.size.width * progress), height: 10)
                        .animation(.spring(response: 0.5), value: progress)
                }
            }
            .frame(height: 10)
        }
        .padding(18)
        .background(Color.white.opacity(0.85))
        .cornerRadius(18)
        .shadow(color: certification.accentColor.opacity(0.1), radius: 6)
        .padding(.horizontal, 20)
    }

    // MARK: - Modules List
    var modulesList: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Módulos")
                    .font(NubiFont.heading)
                    .foregroundColor(.nubiDark)
                Spacer()
            }
            .padding(.horizontal, 20)

            ForEach(certification.modules) { module in
                Button { selectedModule = module } label: {
                    moduleRow(module)
                }
                .buttonStyle(BounceButtonStyle())
                .padding(.horizontal, 20)
            }
        }
    }

    private func moduleRow(_ module: CertModule) -> some View {
        let isCompleted = completedModuleIDs.contains(module.id)
        return HStack(spacing: 14) {
            // Number circle / check
            ZStack {
                Circle()
                    .fill(isCompleted ? certification.accentColor : certification.accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(module.number)")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(certification.accentColor)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: module.sfSymbol)
                        .font(.system(size: 12))
                        .foregroundColor(certification.accentColor)
                    Text(module.title)
                        .font(NubiFont.body)
                        .foregroundColor(.nubiDark)
                        .multilineTextAlignment(.leading)
                }
                Text(module.summary)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.nubiDark.opacity(0.55))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    Label(module.readTime, systemImage: "clock")
                        .font(.system(size: 11))
                        .foregroundColor(.nubiDark.opacity(0.4))
                    Label("Quiz incluido", systemImage: "checkmark.bubble")
                        .font(.system(size: 11))
                        .foregroundColor(certification.accentColor.opacity(0.7))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.nubiGlaucous.opacity(0.5))
        }
        .padding(16)
        .background(Color.white.opacity(0.85))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isCompleted ? certification.accentColor.opacity(0.4) : Color.clear, lineWidth: 1.5)
        )
        .shadow(color: certification.accentColor.opacity(0.08), radius: 5)
    }

    // MARK: - Completion Card
    var completionCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "rosette")
                .font(.system(size: 50))
                .foregroundColor(certification.accentColor)
            Text("¡Certificación completa!")
                .font(NubiFont.heading)
                .foregroundColor(.nubiDark)
            Text("Has completado todos los módulos. Tu IE acaba de subir un nivel.")
                .font(NubiFont.caption)
                .foregroundColor(.nubiDark.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [
                certification.accentColor.opacity(0.2),
                certification.accentColor.opacity(0.08)
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(certification.accentColor, lineWidth: 1.5)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: ────────────────────────────────────────────────────
// 2. MODULE VIEW (contenido + quiz inline)
// ────────────────────────────────────────────────────────
struct CertModuleView: View {
    let module      : CertModule
    let accentColor : Color
    let isCompleted : Bool
    let onComplete  : () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var phase: Phase = .reading
    @State private var selectedAnswer: Int? = nil
    @State private var showResult: Bool = false

    enum Phase { case reading, quiz, finished }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.nubiParchment.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    moduleHeader

                    Group {
                        switch phase {
                        case .reading:  readingPhase
                        case .quiz:     quizPhase
                        case .finished: finishedPhase
                        }
                    }
                    .transition(.opacity)
                }
                .padding(.bottom, 80)
            }

            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(accentColor.opacity(0.7))
                    .padding(20)
            }
        }
    }

    // MARK: - Module Header
    var moduleHeader: some View {
        ZStack {
            LinearGradient(
                colors: [accentColor.opacity(0.3), Color.nubiParchment],
                startPoint: .top, endPoint: .bottom
            )

            VStack(spacing: 10) {
                Text("MÓDULO \(module.number)")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(accentColor)
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.18))
                        .frame(width: 80, height: 80)
                    Image(systemName: module.sfSymbol)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(accentColor)
                }
                Text(module.title)
                    .font(NubiFont.heading)
                    .foregroundColor(.nubiDark)
                    .multilineTextAlignment(.center)
                Label(module.readTime, systemImage: "clock")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiDark.opacity(0.5))
            }
            .padding(.top, 60)
            .padding(.bottom, 28)
            .padding(.horizontal, 28)
        }
    }

    // MARK: - Reading Phase
    var readingPhase: some View {
        VStack(spacing: 24) {
            Rectangle().fill(accentColor).frame(height: 3).padding(.horizontal, 28)

            Text(module.content)
                .font(NubiFont.body)
                .foregroundColor(.nubiDark)
                .lineSpacing(7)
                .padding(.horizontal, 28)
                .padding(.top, 4)

            // Key takeaway card
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(accentColor)
                    Text("PARA RECORDAR")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(1)
                        .foregroundColor(accentColor)
                }
                Text(module.keyTakeaway)
                    .font(NubiFont.body)
                    .italic()
                    .foregroundColor(.nubiDark)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(accentColor.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(accentColor.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 28)

            // Continue button
            Button {
                withAnimation(.spring()) { phase = .quiz }
            } label: {
                HStack(spacing: 8) {
                    Text("Hacer el quiz")
                    Image(systemName: "arrow.right.circle.fill")
                }
                .nubiButton(color: accentColor)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Quiz Phase
    var quizPhase: some View {
        VStack(spacing: 20) {
            // Banner quiz
            HStack(spacing: 8) {
                Image(systemName: "questionmark.bubble.fill")
                    .foregroundColor(accentColor)
                Text("MINI TEST")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(1.2)
                    .foregroundColor(accentColor)
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 20)

            Text(module.quiz.question)
                .font(NubiFont.subheading)
                .foregroundColor(.nubiDark)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)

            // Options
            VStack(spacing: 10) {
                ForEach(Array(module.quiz.options.enumerated()), id: \.offset) { index, option in
                    Button {
                        if !showResult {
                            withAnimation(.spring()) {
                                selectedAnswer = index
                                showResult = true
                            }
                        }
                    } label: {
                        quizOption(index: index, text: option)
                    }
                    .disabled(showResult)
                }
            }
            .padding(.horizontal, 28)

            if showResult {
                resultCard.padding(.horizontal, 28)

                Button {
                    onComplete()
                    withAnimation(.spring()) { phase = .finished }
                } label: {
                    HStack(spacing: 8) {
                        Text("Continuar")
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .nubiButton(color: accentColor)
                }
                .padding(.top, 4)
            }
        }
    }

    private func quizOption(index: Int, text: String) -> some View {
        let isCorrect   = index == module.quiz.correctIndex
        let isSelected  = selectedAnswer == index
        let bgColor: Color = {
            guard showResult else {
                return Color.white.opacity(0.85)
            }
            if isCorrect      { return Color(hex: "#06D6A0").opacity(0.18) }
            if isSelected     { return Color(hex: "#EF476F").opacity(0.18) }
            return Color.white.opacity(0.6)
        }()
        let borderColor: Color = {
            guard showResult else {
                return isSelected ? accentColor : Color.nubiLightBlue.opacity(0.5)
            }
            if isCorrect      { return Color(hex: "#06D6A0") }
            if isSelected     { return Color(hex: "#EF476F") }
            return Color.clear
        }()

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(borderColor.opacity(0.6), lineWidth: 1.5)
                    .frame(width: 28, height: 28)
                if showResult && isCorrect {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "#06D6A0"))
                } else if showResult && isSelected && !isCorrect {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "#EF476F"))
                } else {
                    Text(["A","B","C","D"][min(index, 3)])
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.nubiDark.opacity(0.5))
                }
            }
            Text(text)
                .font(NubiFont.body)
                .foregroundColor(.nubiDark)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bgColor)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderColor, lineWidth: 1.5)
        )
    }

    var resultCard: some View {
        let isCorrect = selectedAnswer == module.quiz.correctIndex
        let resultColor: Color = isCorrect ? Color(hex: "#06D6A0") : Color(hex: "#F4A261")

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: isCorrect ? "checkmark.seal.fill" : "lightbulb.fill")
                    .foregroundColor(resultColor)
                Text(isCorrect ? "¡Correcto!" : "Buen intento. Esto es lo que dice la teoría:")
                    .font(NubiFont.subheading)
                    .foregroundColor(.nubiDark)
            }
            Text(module.quiz.explanation)
                .font(NubiFont.body)
                .foregroundColor(.nubiDark.opacity(0.75))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(resultColor.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(resultColor.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: - Finished
    var finishedPhase: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundColor(accentColor)
            Text("Módulo \(module.number) completado")
                .font(NubiFont.heading)
                .foregroundColor(.nubiDark)
            Text("Sigue con el siguiente módulo para avanzar en tu certificación.")
                .font(NubiFont.body)
                .foregroundColor(.nubiDark.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button { dismiss() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Volver a la certificación")
                }
                .nubiButton(color: accentColor)
            }
            .padding(.top, 8)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
    }
}
