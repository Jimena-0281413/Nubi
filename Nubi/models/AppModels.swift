//
//  AppModels.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 05/05/26.
//
import SwiftUI

// MARK: - Emociones primarias
enum PrimaryEmotion: String, CaseIterable, Identifiable {
    case feliz    = "Feliz"
    case triste   = "Triste"
    case enojado  = "Enojado"
    case ansioso  = "Ansioso"
    case agotado  = "Agotado"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .feliz:   return "😊"
        case .triste:  return "😢"
        case .enojado: return "😠"
        case .ansioso: return "😰"
        case .agotado: return "😴"
        }
    }

    var color: Color {
        switch self {
        case .feliz:   return Color(hex: "#FFD166")
        case .triste:  return Color(hex: "#5C7B99")
        case .enojado: return Color(hex: "#EF476F")
        case .ansioso: return Color(hex: "#9B59B6")
        case .agotado: return Color(hex: "#95A5A6")
        }
    }

    var subEmotions: [SubEmotion] {
        switch self {
        case .feliz:
            return [SubEmotion(label: "Con mucha energía", emoji: "⚡"),
                    SubEmotion(label: "Tranquilo y bien", emoji: "🌿"),
                    SubEmotion(label: "Orgulloso de algo", emoji: "🏆"),
                    SubEmotion(label: "Agradecido hoy", emoji: "🙏")]
        case .triste:
            return [SubEmotion(label: "Con ganas de llorar", emoji: "😭"),
                    SubEmotion(label: "Triste y con coraje", emoji: "😤"),
                    SubEmotion(label: "Me siento solo/a", emoji: "🫂"),
                    SubEmotion(label: "Nostálgico/a", emoji: "🌧️")]
        case .enojado:
            return [SubEmotion(label: "Frustrado con el trabajo", emoji: "💢"),
                    SubEmotion(label: "Enojado con alguien", emoji: "🔥"),
                    SubEmotion(label: "Me siento ignorado/a", emoji: "😶"),
                    SubEmotion(label: "Injusticia que me afecta", emoji: "⚖️")]
        case .ansioso:
            return [SubEmotion(label: "Nervioso/a sin razón", emoji: "🌀"),
                    SubEmotion(label: "Miedo a algo concreto", emoji: "😨"),
                    SubEmotion(label: "Presión por metas", emoji: "📊"),
                    SubEmotion(label: "No puedo descansar", emoji: "🌙")]
        case .agotado:
            return [SubEmotion(label: "Cansancio físico", emoji: "💪"),
                    SubEmotion(label: "Cansancio mental", emoji: "🧠"),
                    SubEmotion(label: "Sin motivación", emoji: "🪫"),
                    SubEmotion(label: "Quiero desconectarme", emoji: "🔌")]
        }
    }
}

struct SubEmotion: Identifiable {
    let id = UUID()
    let label: String
    let emoji: String
}

// MARK: - Registro de emoción del día
struct EmotionEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let primaryEmotion: String
    let subEmotion: String
    let nubiColor: String // hex color saved

    init(primary: PrimaryEmotion, sub: SubEmotion) {
        self.id = UUID()
        self.date = Date()
        self.primaryEmotion = primary.rawValue
        self.subEmotion = sub.label
        self.nubiColor = primary.color.toHex() ?? "#B8D8D8"
    }
}

extension Color {
    func toHex() -> String? {
        let uic = UIColor(self)
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        guard uic.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return String(format: "#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
    }
}

// MARK: - Puestos de trabajo
enum WorkPosition: String, CaseIterable {
    case callCenter  = "Call Center"
    case cajas       = "Cajas"
    case pisoVenta   = "Piso de Venta"
    case almacen     = "Almacén"
    case supervisor  = "Supervisor/a"
    case rh          = "Recursos Humanos"
    case otro        = "Otro"
}

// MARK: - Resultado de juego (para enriquecer reporte)
struct GameResult: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let gameName: String
    let score: Int
    let insight: String // Lo que reveló el juego
}

// MARK: - Guía de contenido
struct Guide: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let category: String
    let readTime: String
    let content: String
    let isRecommended: Bool
}

let sampleGuides: [Guide] = [
    Guide(title: "Cómo manejar clientes agresivos",
          emoji: "🛡️", category: "Trabajo",
          readTime: "3 min",
          content: "Cuando un cliente pierde la calma, tu calma es tu superpoder. Respira hondo, usa voz suave y repite lo que escuchaste para que se sientan validados...",
          isRecommended: true),
    Guide(title: "¿Qué es el burnout y cómo lo identifico?",
          emoji: "🔥", category: "Salud Mental",
          readTime: "4 min",
          content: "El burnout no es solo cansancio. Es agotamiento emocional profundo combinado con cinismo hacia el trabajo. Las señales incluyen: irritabilidad constante, dificultad de concentración...",
          isRecommended: true),
    Guide(title: "Técnica 4-7-8 para ansiedad inmediata",
          emoji: "🌬️", category: "Herramientas",
          readTime: "2 min",
          content: "Inhala 4 segundos. Retén 7. Exhala 8. Esta técnica activa el nervio vago y baja el cortisol en menos de 2 minutos. Ideal para el descanso en turno...",
          isRecommended: false),
    Guide(title: "Inteligencia emocional en el trabajo",
          emoji: "🧠", category: "Soft Skills",
          readTime: "5 min",
          content: "Reconocer tus emociones antes de reaccionar es la base de la IE. Practica el 'pausa de 6 segundos': cuando sientas un impulso fuerte, cuenta hasta 6 antes de responder...",
          isRecommended: false),
    Guide(title: "Depresión: señales que no debes ignorar",
          emoji: "💙", category: "Enciclopedia",
          readTime: "4 min",
          content: "La depresión no siempre se parece a la tristeza extrema. A veces se manifiesta como irritabilidad, dormir demasiado o muy poco, pérdida de interés en actividades que antes amabas...",
          isRecommended: false),
    Guide(title: "Límites saludables con compañeros",
          emoji: "🤝", category: "Soft Skills",
          readTime: "3 min",
          content: "Decir 'no' no es egoísmo. Es respeto propio y respeto al otro. Un límite claro y amable suena así: 'Entiendo que necesitas ayuda, ahora mismo no puedo, pero a las 3 pm sí'...",
          isRecommended: true),
]
