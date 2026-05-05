//
//  NubiAvatarView.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 05/05/26.
//
import SwiftUI

struct NubiAvatarView: View {
    var color: Color
    var size: CGFloat = 120
    var isAnimating: Bool = true

    @State private var floatOffset: CGFloat = 0
    @State private var eyeBlink: Bool = false
    @State private var twinkle: Bool = false

    var body: some View {
        ZStack {
            // Sombra del suelo
            Ellipse()
                .fill(color.opacity(0.2))
                .frame(width: size * 0.75, height: size * 0.12)
                .offset(y: size * 0.52 + floatOffset * 0.3)
                .blur(radius: 4)

            // Cuerpo de la nube (Nubi)
            ZStack {
                // Base nube
                cloudShape(size: size, color: color)

                // Ojos
                HStack(spacing: size * 0.18) {
                    eyeView(size: size * 0.11, blink: eyeBlink)
                    eyeView(size: size * 0.11, blink: eyeBlink)
                }
                .offset(y: size * 0.04)

                // Boca sonriente
                mouthView(size: size)
                    .offset(y: size * 0.19)

                // Destellos
                if twinkle {
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
                startFloating()
                startBlinking()
                startTwinkling()
            }
        }
        .animation(.spring(response: 0.5), value: color)
    }

    // MARK: - Cloud Shape
    private func cloudShape(size: CGFloat, color: Color) -> some View {
        ZStack {
            // Bumps de la nube
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
            // Base
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(cloudGradient(color: color))
                .frame(width: size * 0.88, height: size * 0.52)
                .offset(y: size * 0.08)
        }
    }

    private func cloudGradient(color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color.opacity(0.95), color.opacity(0.7)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    // MARK: - Eye
    private func eyeView(size: CGFloat, blink: Bool) -> some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: size, height: blink ? size * 0.1 : size)
            if !blink {
                Circle()
                    .fill(Color(hex: "#2C4A6E"))
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

    // MARK: - Mouth
    private func mouthView(size: CGFloat) -> some View {
        Path { path in
            path.move(to: CGPoint(x: -size * 0.12, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: size * 0.12, y: 0),
                control: CGPoint(x: 0, y: size * 0.1)
            )
        }
        .stroke(Color(hex: "#2C4A6E"), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        .frame(width: size * 0.25, height: size * 0.12)
    }

    // MARK: - Animations
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

// MARK: - Preview
struct NubiAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.nubiParchment.ignoresSafeArea()
            NubiAvatarView(color: .nubiGlaucous)
        }
    }
}
