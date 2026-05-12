//
//  theme.swift
//  Nubi
//

import SwiftUI

// MARK: - Paleta de colores
extension Color {
    // Coppel
    static let coppelYellow      = Color(hex: "#F2EDED") // Islas / cards
    static let coppelBackground  = Color(hex: "#F5FEFF") // Fondo
    static let coppelButton      = Color(hex: "#234DB0") // Botones primarios
    static let coppelDeepBlue    = Color(hex: "#191942") // Azul profundo (textos destacados)

    // Nubi (mantenemos para acentos y emociones)
    static let nubiGlaucous   = Color(hex: "#5C7B99")
    static let nubiLightBlue  = Color(hex: "#B8D8D8")
    static let nubiParchment  = coppelBackground // alias del fondo Coppel
    static let nubiCardBg     = coppelYellow // alias amarillo de tarjetas
    static let nubiAccent     = Color(hex: "#7FA8C9")
    static let nubiSoft       = Color(hex: "#D6EAF8")
    static let nubiDark       = Color(hex: "#191942") // ahora apunta al azul profundo Coppel
    static let nubiPrimary    = Color(hex: "#234DB0") // botones
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
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Fuentes
struct NubiFont {
    static let title       = Font.system(size: 28, weight: .bold,     design: .rounded)
    static let heading     = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let subheading  = Font.system(size: 17, weight: .medium,   design: .rounded)
    static let body        = Font.system(size: 15, weight: .regular,  design: .rounded)
    static let caption     = Font.system(size: 13, weight: .light,    design: .rounded)
    // Nuevas fuentes para guías más legibles
    static let guideBody   = Font.system(size: 16, weight: .regular,  design: .rounded)
    static let guideTitle  = Font.system(size: 17, weight: .semibold, design: .rounded)
}

// MARK: - Modificadores reutilizables
struct NubiCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.coppelYellow)
            .cornerRadius(20)
            .shadow(color: Color.coppelDeepBlue.opacity(0.10), radius: 10, x: 0, y: 4)
    }
}

struct NubiButton: ViewModifier {
    var color: Color = .coppelButton
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(NubiFont.subheading)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(LinearGradient(colors: [color, color.opacity(0.8)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(Capsule())
            .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func nubiCard() -> some View { modifier(NubiCard()) }
    func nubiButton(color: Color = .coppelButton) -> some View { modifier(NubiButton(color: color)) }
    
    // Función global para desaparecer el teclado
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
