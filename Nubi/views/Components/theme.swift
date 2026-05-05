//
//  theme.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 05/05/26.
//

import SwiftUI

// MARK: - Paleta de colores oficial Nubi
extension Color {
    static let nubiGlaucous   = Color(hex: "#5C7B99") // Azul principal
    static let nubiLightBlue  = Color(hex: "#B8D8D8") // Azul claro
    static let nubiParchment  = Color(hex: "#F4F1EA") // Fondo cálido
    static let nubiAccent     = Color(hex: "#7FA8C9") // Intermedio
    static let nubiSoft       = Color(hex: "#D6EAF8") // Muy suave
    static let nubiDark       = Color(hex: "#2C4A6E") // Oscuro
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Fuentes y estilos
struct NubiFont {
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let heading = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let subheading = Font.system(size: 17, weight: .medium, design: .rounded)
    static let body = Font.system(size: 15, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 13, weight: .light, design: .rounded)
}

// MARK: - Modificadores reutilizables
struct NubiCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.nubiParchment)
            .cornerRadius(20)
            .shadow(color: Color.nubiGlaucous.opacity(0.15), radius: 10, x: 0, y: 4)
    }
}

struct NubiButton: ViewModifier {
    var color: Color = .nubiGlaucous
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(NubiFont.subheading)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                LinearGradient(colors: [color, color.opacity(0.75)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(16)
            .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func nubiCard() -> some View { modifier(NubiCard()) }
    func nubiButton(color: Color = .nubiGlaucous) -> some View { modifier(NubiButton(color: color)) }
}
