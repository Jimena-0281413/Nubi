//
//  ToolView.swift
//  Nubi
//
//  Created by Max Lozano on 5/5/26.
//


//
//  ToolView.swift
//  Nubi
//
//  Vista guiada de herramienta: VStack con nombre, HStack con pasos,
//  botón comenzar que activa temporizador.
//

import SwiftUI

// MARK: ════════════════════════════════════════════
// MAIN TOOL VIEW (entry point - shows steps + start)
// ════════════════════════════════════════════════
struct ToolView: View {
    let tool: WellnessTool
    @Environment(\.dismiss) var dismiss
    @State private var isRunning: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.nubiParchment.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroHeader

                    // ── VSTACK CON NOMBRE Y CONTENIDO ──
                    VStack(spacing: 28) {
                        // Section 1: Intro
                        introCard
                            .padding(.horizontal, 20)
                            .padding(.top, 24)

                        // Section 2: Pasos en HStack
                        stepsSection
                            .padding(.horizontal, 20)

                        // Section 3: Botón Comenzar
                        startButton
                            .padding(.top, 8)
                            .padding(.bottom, 60)
                    }
                }
            }

            // Close button
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(tool.accentColor.opacity(0.7))
                    .padding(20)
            }
        }
        .fullScreenCover(isPresented: $isRunning) {
            ToolRunnerView(tool: tool)
        }
    }

    // MARK: - Hero
    var heroHeader: some View {
        ZStack {
            LinearGradient(
                colors: [tool.accentColor.opacity(0.4), Color.nubiParchment],
                startPoint: .top, endPoint: .bottom
            )
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(tool.accentColor.opacity(0.25))
                        .frame(width: 110, height: 110)
                    Image(systemName: tool.sfSymbol)
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundColor(tool.accentColor.opacity(0.95))
                }

                HStack(spacing: 5) {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 11))
                    Text("HERRAMIENTA GUIADA")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(1.2)
                }
                .foregroundColor(tool.accentColor)
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(Color.white.opacity(0.7))
                .cornerRadius(20)

                // 1. NOMBRE DE LA SECCIÓN
                Text(tool.title)
                    .font(NubiFont.title)
                    .foregroundColor(.nubiDark)
                    .multilineTextAlignment(.center)

                Text(tool.subtitle)
                    .font(NubiFont.body)
                    .foregroundColor(.nubiDark.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Label(tool.estimatedTime, systemImage: "clock.fill")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiDark.opacity(0.5))
            }
            .padding(.top, 60)
            .padding(.bottom, 32)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Intro
    var introCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 18))
                .foregroundColor(tool.accentColor)
                .padding(.top, 2)
            Text(tool.intro)
                .font(NubiFont.body)
                .foregroundColor(.nubiDark.opacity(0.8))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tool.accentColor.opacity(0.12))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(tool.accentColor.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - 2. PASOS EN HSTACK
    var stepsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "list.number")
                    .foregroundColor(tool.accentColor)
                Text("Cómo hacerlo")
                    .font(NubiFont.heading)
                    .foregroundColor(.nubiDark)
            }

            // ── HSTACK SCROLL HORIZONTAL CON LOS PASOS ──
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(tool.steps) { step in
                        stepCard(step)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func stepCard(_ step: ToolStep) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Number badge
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(tool.accentColor)
                        .frame(width: 26, height: 26)
                    Text("\(step.number)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Image(systemName: step.sfSymbol)
                    .font(.system(size: 18))
                    .foregroundColor(tool.accentColor)
                Spacer()
            }

            Text(step.title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.nubiDark)

            Text(step.description)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.nubiDark.opacity(0.65))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(width: 160, height: 160, alignment: .topLeading)
        .padding(14)
        .background(Color.white.opacity(0.92))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(tool.accentColor.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: tool.accentColor.opacity(0.1), radius: 6, x: 0, y: 3)
    }

    // MARK: - 3. BOTÓN COMENZAR
    var startButton: some View {
        Button {
            isRunning = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 22))
                Text("Comenzar")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [tool.accentColor, tool.accentColor.opacity(0.75)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(20)
            .shadow(color: tool.accentColor.opacity(0.45), radius: 12, x: 0, y: 6)
        }
    }
}

// MARK: ════════════════════════════════════════════
// TOOL RUNNER (timer guía la actividad)
// ════════════════════════════════════════════════
struct ToolRunnerView: View {
    let tool: WellnessTool
    @Environment(\.dismiss) var dismiss

    @State private var elapsed: Int          = 0
    @State private var isPaused              = false
    @State private var isFinished            = false
    @State private var timer: Timer?         = nil
    @State private var animateBreath: Bool   = false

    // Breathing 4-7-8 cycle phases
    @State private var breathPhase: BreathPhase = .inhale
    @State private var breathSecondsLeft: Int   = 4
    @State private var cycleNumber: Int         = 1

    private let cycleSeconds   = (inhale: 4, hold: 7, exhale: 8)
    private let totalCycles    = 4

    var remainingSeconds: Int {
        max(0, tool.totalSeconds - elapsed)
    }

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        stopTimer()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(tool.accentColor.opacity(0.7))
                    }
                    Spacer()
                    Text(tool.title)
                        .font(NubiFont.subheading)
                        .foregroundColor(.nubiDark)
                    Spacer()
                    Color.clear.frame(width: 28, height: 28)
                }
                .padding(20)

                Spacer()

                if isFinished {
                    finishedView
                } else if tool.timerMode == .breathing {
                    breathingRunner
                } else {
                    simpleRunner
                }

                Spacer()

                if !isFinished {
                    controlButtons.padding(.bottom, 40)
                }
            }
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    var backgroundGradient: some View {
        LinearGradient(
            colors: [tool.accentColor.opacity(0.5), Color.nubiParchment],
            startPoint: .top, endPoint: .bottom
        )
    }

    // MARK: - Simple Runner (single timer)
    var simpleRunner: some View {
        VStack(spacing: 32) {
            // Big circular timer
            ZStack {
                Circle()
                    .stroke(tool.accentColor.opacity(0.2), lineWidth: 14)
                    .frame(width: 240, height: 240)
                Circle()
                    .trim(from: 0, to: CGFloat(elapsed) / CGFloat(tool.totalSeconds))
                    .stroke(
                        LinearGradient(colors: [tool.accentColor, tool.accentColor.opacity(0.6)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: elapsed)

                VStack(spacing: 4) {
                    Text(formatTime(remainingSeconds))
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundColor(.nubiDark)
                    Text("restantes")
                        .font(NubiFont.caption)
                        .foregroundColor(.nubiDark.opacity(0.5))
                }
            }

            // Current step indicator
            VStack(spacing: 6) {
                Text("Mantén el enfoque")
                    .font(NubiFont.caption)
                    .foregroundColor(.nubiDark.opacity(0.5))
                Text("Sigue los pasos a tu ritmo")
                    .font(NubiFont.body)
                    .foregroundColor(.nubiDark.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
        }
    }

    // MARK: - Breathing Runner (cyclical phases)
    var breathingRunner: some View {
        VStack(spacing: 28) {
            Text("Ciclo \(cycleNumber) de \(totalCycles)")
                .font(NubiFont.subheading)
                .foregroundColor(.nubiDark.opacity(0.6))

            // Breathing animation circle
            ZStack {
                Circle()
                    .fill(tool.accentColor.opacity(0.18))
                    .frame(width: 280, height: 280)
                Circle()
                    .fill(LinearGradient(
                        colors: [tool.accentColor.opacity(0.7), tool.accentColor.opacity(0.4)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: animateBreath ? 240 : 120,
                           height: animateBreath ? 240 : 120)
                    .animation(.easeInOut(duration: animationDuration), value: animateBreath)

                VStack(spacing: 6) {
                    Image(systemName: breathPhase.sfSymbol)
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                    Text(breathPhase.label)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("\(breathSecondsLeft)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
            }

            Text(breathInstruction)
                .font(NubiFont.body)
                .foregroundColor(.nubiDark.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .frame(height: 50)
        }
    }

    private var animationDuration: Double {
        switch breathPhase {
        case .inhale: return Double(cycleSeconds.inhale)
        case .hold:   return 0.3
        case .exhale: return Double(cycleSeconds.exhale)
        case .pause:  return 0.3
        }
    }

    private var breathInstruction: String {
        switch breathPhase {
        case .inhale: return "Inhala lentamente por la nariz"
        case .hold:   return "Retén el aire en tus pulmones"
        case .exhale: return "Exhala despacio por la boca"
        case .pause:  return "Listo para el siguiente ciclo"
        }
    }

    // MARK: - Finished
    var finishedView: some View {
        VStack(spacing: 22) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(tool.accentColor)
            Text("¡Bien hecho!")
                .font(NubiFont.title)
                .foregroundColor(.nubiDark)
            Text("Acabas de regalarte un momento de calma. Tu cuerpo lo agradece.")
                .font(NubiFont.body)
                .foregroundColor(.nubiDark.opacity(0.65))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button { dismiss() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Volver")
                }
                .nubiButton(color: tool.accentColor)
            }
            .padding(.top, 10)
        }
    }

    // MARK: - Controls
    var controlButtons: some View {
        HStack(spacing: 16) {
            Button {
                isPaused.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                    Text(isPaused ? "Continuar" : "Pausar")
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(tool.accentColor)
                .padding(.horizontal, 24).padding(.vertical, 12)
                .background(Color.white.opacity(0.85))
                .cornerRadius(16)
                .shadow(color: tool.accentColor.opacity(0.2), radius: 6)
            }

            Button {
                stopTimer()
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "stop.circle.fill")
                    Text("Terminar")
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.nubiDark.opacity(0.6))
                .padding(.horizontal, 24).padding(.vertical, 12)
                .background(Color.white.opacity(0.6))
                .cornerRadius(16)
            }
        }
    }

    // MARK: - Timer logic
    private func startTimer() {
        if tool.timerMode == .breathing {
            startBreathingPhase(.inhale)
        } else {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animateBreath.toggle()
            }
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard !isPaused else { return }
            Task { @MainActor in
                elapsed += 1
                if tool.timerMode == .breathing { tickBreathing() }
                if elapsed >= tool.totalSeconds {
                    stopTimer()
                    withAnimation(.spring()) { isFinished = true }
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func startBreathingPhase(_ phase: BreathPhase) {
        breathPhase = phase
        switch phase {
        case .inhale:
            breathSecondsLeft = cycleSeconds.inhale
            withAnimation(.easeInOut(duration: Double(cycleSeconds.inhale))) {
                animateBreath = true
            }
        case .hold:
            breathSecondsLeft = cycleSeconds.hold
        case .exhale:
            breathSecondsLeft = cycleSeconds.exhale
            withAnimation(.easeInOut(duration: Double(cycleSeconds.exhale))) {
                animateBreath = false
            }
        case .pause:
            breathSecondsLeft = 0
        }
    }

    private func tickBreathing() {
        if breathSecondsLeft > 0 { breathSecondsLeft -= 1 }
        if breathSecondsLeft == 0 {
            switch breathPhase {
            case .inhale: startBreathingPhase(.hold)
            case .hold:   startBreathingPhase(.exhale)
            case .exhale:
                if cycleNumber >= totalCycles {
                    stopTimer()
                    withAnimation(.spring()) { isFinished = true }
                } else {
                    cycleNumber += 1
                    startBreathingPhase(.inhale)
                }
            case .pause: startBreathingPhase(.inhale)
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}