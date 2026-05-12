//
//  NubiAvatarView.swift
//  Nubi
//
import SwiftUI

struct NubiAvatarView: View {
    var color: Color
    var size: CGFloat = 120
    var isAnimating: Bool = true
    /// La boca de Nubi cambia con su estado emocional
    var expression: NubiExpression = .neutral

    @State private var floatOffset: CGFloat = 0
    @State private var eyeBlink: Bool = false
    @State private var twinkle: Bool = false

    var body: some View {
        ZStack {
            Ellipse()
                .fill(color.opacity(0.2))
                .frame(width: size * 0.75, height: size * 0.12)
                .offset(y: size * 0.52 + floatOffset * 0.3)
                .blur(radius: 4)

            ZStack {
                cloudShape(size: size, color: color)

                HStack(spacing: size * 0.18) {
                    eyeView(size: size * 0.11, blink: eyeBlink)
                    eyeView(size: size * 0.11, blink: eyeBlink)
                }
                .offset(y: size * 0.04)

                mouthView(size: size, expression: expression)
                    .offset(y: size * 0.19)

                if twinkle && expression == .happy {
                    ForEach(0..<3) { i in
                        Image(systemName: "sparkle")
                            .font(.system(size: size * 0.12))
                            .foregroundColor(.white.opacity(0.8))
                            .offset(x: CGFloat([-1, 1, 0][i]) * size * 0.42,
                                    y: CGFloat([-1, -0.5, -1.2][i]) * size * 0.28)
                    }
                }
            }
            .offset(y: floatOffset)
        }
        .frame(width: size * 1.2, height: size * 1.3)
        .onAppear {
            if isAnimating {
                startFloating(); startBlinking(); startTwinkling()
            }
        }
        .animation(.spring(response: 0.5), value: color)
        .animation(.spring(response: 0.4), value: expression)
    }

    // Cloud shape
    private func cloudShape(size: CGFloat, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(cloudGradient(color: color))
                .frame(width: size * 0.55, height: size * 0.55)
                .offset(x: -size * 0.22, y: -size * 0.1)
            Circle()
                .fill(cloudGradient(color: color))
                .frame(width: size * 0.45, height: size * 0.45)
                .offset(x: size * 0.22, y: -size * 0.12)
            Circle()
                .fill(cloudGradient(color: color))
                .frame(width: size * 0.38, height: size * 0.38)
                .offset(x: 0, y: -size * 0.2)
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(cloudGradient(color: color))
                .frame(width: size * 0.88, height: size * 0.52)
                .offset(y: size * 0.08)
        }
    }

    private func cloudGradient(color: Color) -> LinearGradient {
        LinearGradient(colors: [color.opacity(0.95), color.opacity(0.7)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // Eye
    private func eyeView(size: CGFloat, blink: Bool) -> some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: size, height: blink ? size * 0.1 : size)
            if !blink {
                Circle()
                    .fill(Color(hex: "#191942"))
                    .frame(width: size * 0.6, height: size * 0.6)
                    .offset(x: 1, y: 1)
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: size * 0.25, height: size * 0.25)
                    .offset(x: -2, y: -2)
            }
        }
        .animation(.easeInOut(duration: 0.08), value: blink)
    }

    // Mouth — dinámica según expresión
    @ViewBuilder
    private func mouthView(size: CGFloat, expression: NubiExpression) -> some View {
        let strokeColor = Color(hex: "#191942")
        let strokeStyle = StrokeStyle(lineWidth: 2.5, lineCap: .round)

        switch expression {
        case .neutral, .happy:
            // Sonrisa
            Path { p in
                p.move(to: CGPoint(x: -size * 0.12, y: 0))
                p.addQuadCurve(to: CGPoint(x: size * 0.12, y: 0),
                               control: CGPoint(x: 0, y: size * 0.10))
            }
            .stroke(strokeColor, style: strokeStyle)
            .frame(width: size * 0.25, height: size * 0.12)

        case .sad:
            // Boca hacia abajo
            Path { p in
                p.move(to: CGPoint(x: -size * 0.12, y: size * 0.05))
                p.addQuadCurve(to: CGPoint(x: size * 0.12, y: size * 0.05),
                               control: CGPoint(x: 0, y: -size * 0.05))
            }
            .stroke(strokeColor, style: strokeStyle)
            .frame(width: size * 0.25, height: size * 0.12)

        case .angry:
            // Línea recta (tensa)
            Path { p in
                p.move(to: CGPoint(x: -size * 0.12, y: 0))
                p.addLine(to: CGPoint(x: size * 0.12, y: 0))
            }
            .stroke(strokeColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .frame(width: size * 0.25, height: size * 0.04)

        case .anxious:
            // Línea ondulada
            Path { p in
                p.move(to: CGPoint(x: -size * 0.13, y: 0))
                p.addCurve(to: CGPoint(x: size * 0.13, y: 0),
                           control1: CGPoint(x: -size * 0.05, y: -size * 0.05),
                           control2: CGPoint(x: size * 0.05, y: size * 0.05))
            }
            .stroke(strokeColor, style: strokeStyle)
            .frame(width: size * 0.27, height: size * 0.10)

        case .tired:
            // Boca pequeña abierta (cansada)
            Path { p in
                p.addEllipse(in: CGRect(x: -size * 0.04, y: 0, width: size * 0.08, height: size * 0.06))
            }
            .stroke(strokeColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .frame(width: size * 0.10, height: size * 0.08)
        }
    }

    private func startFloating() {
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            floatOffset = -12
        }
    }

    private func startBlinking() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { eyeBlink = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation { eyeBlink = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2...5)) {
                    startBlinking()
                }
            }
        }
    }

    private func startTwinkling() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            twinkle = true
        }
    }
}

struct NubiAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.coppelBackground.ignoresSafeArea()
            VStack(spacing: 20) {
                NubiAvatarView(color: .nubiGlaucous, expression: .happy)
                NubiAvatarView(color: Color(hex: "#EF476F"), expression: .angry)
            }
        }
    }
}
