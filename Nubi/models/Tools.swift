//
//  WellnessTool.swift
//  Nubi
//
//  Created by Max Lozano on 5/5/26.
//


//
//  ToolsModels.swift
//  Nubi
//
//  Herramientas guiadas con temporizador (4-7-8, Enfoque Visual, etc.)
//

import SwiftUI

// MARK: - Modelo de Herramienta
struct WellnessTool: Identifiable {
    let id              = UUID()
    let title           : String
    let subtitle        : String        // descripción corta
    let sfSymbol        : String
    let accentColor     : Color
    let estimatedTime   : String        // "2 min"
    let intro           : String        // explicación de por qué funciona
    let steps           : [ToolStep]
    let totalSeconds    : Int           // duración del temporizador
    let timerMode       : TimerMode

    enum TimerMode {
        case simple        // un solo temporizador hasta totalSeconds
        case breathing     // ciclos de inhala/retén/exhala
    }
}

// MARK: - Paso de herramienta
struct ToolStep: Identifiable {
    let id          = UUID()
    let number      : Int
    let title       : String
    let description : String
    let sfSymbol    : String
}

// MARK: - Fase de respiración (para ciclos)
enum BreathPhase {
    case inhale, hold, exhale, pause
    var label: String {
        switch self {
        case .inhale: return "Inhala"
        case .hold:   return "Retén"
        case .exhale: return "Exhala"
        case .pause:  return "Pausa"
        }
    }
    var sfSymbol: String {
        switch self {
        case .inhale: return "arrow.down.circle.fill"
        case .hold:   return "pause.circle.fill"
        case .exhale: return "arrow.up.circle.fill"
        case .pause:  return "circle.fill"
        }
    }
}

// MARK: ════════════════════════════════════════════
// HERRAMIENTAS DISPONIBLES
// ════════════════════════════════════════════════

let tool478: WellnessTool = WellnessTool(
    title: "Respiración 4-7-8",
    subtitle: "Calma la ansiedad en 2 minutos",
    sfSymbol: "wind",
    accentColor: Color(hex: "#B8D8D8"),
    estimatedTime: "2 min",
    intro: "Esta técnica activa tu nervio vago y baja el cortisol en menos de 2 minutos. Es la herramienta de emergencia que usan los Navy SEALs y funciona igual de bien en la sala de descanso del turno.",
    steps: [
        ToolStep(number: 1, title: "Inhala",
                 description: "Por la nariz durante 4 segundos",
                 sfSymbol: "arrow.down.circle.fill"),
        ToolStep(number: 2, title: "Retén",
                 description: "El aire en tus pulmones por 7 segundos",
                 sfSymbol: "pause.circle.fill"),
        ToolStep(number: 3, title: "Exhala",
                 description: "Por la boca lentamente durante 8 segundos",
                 sfSymbol: "arrow.up.circle.fill"),
        ToolStep(number: 4, title: "Repite",
                 description: "El ciclo completo 4 veces más",
                 sfSymbol: "arrow.clockwise.circle.fill"),
    ],
    totalSeconds: 95,    // 4 ciclos de 19s + 19s primero + buffer
    timerMode: .breathing
)

let toolEnfoqueVisual: WellnessTool = WellnessTool(
    title: "Enfoque Visual",
    subtitle: "Recupera tu concentración en segundos",
    sfSymbol: "eye.fill",
    accentColor: Color(hex: "#9B8EC4"),
    estimatedTime: "1-3 min",
    intro: "El enfoque visual precede al enfoque cognitivo. Al entrenar tus ojos para mantener un punto fijo, activas la liberación de dopamina y acetilcolina, esenciales para encender la concentración y reducir el ruido mental.",
    steps: [
        ToolStep(number: 1, title: "Elige un punto",
                 description: "Un objeto o marca a una distancia cómoda",
                 sfSymbol: "scope"),
        ToolStep(number: 2, title: "Mira fijo",
                 description: "Sin desviar la vista hacia los lados",
                 sfSymbol: "eye.fill"),
        ToolStep(number: 3, title: "Sostén el enfoque",
                 description: "Si parpadeas, regresa la vista al punto",
                 sfSymbol: "checkmark.circle.fill"),
        ToolStep(number: 4, title: "Redirige",
                 description: "Si tu mente divaga, vuelve al objetivo",
                 sfSymbol: "arrow.uturn.left.circle.fill"),
    ],
    totalSeconds: 60,
    timerMode: .simple
)

let toolGrounding: WellnessTool = WellnessTool(
    title: "Anclaje 5-4-3-2-1",
    subtitle: "Sal del modo ansiedad usando tus 5 sentidos",
    sfSymbol: "hand.point.up.braillepattern",
    accentColor: Color(hex: "#06D6A0"),
    estimatedTime: "2 min",
    intro: "Cuando la ansiedad te lleva al pasado o al futuro, esta técnica te trae de vuelta al presente usando tus 5 sentidos. Es la herramienta # 1 que usan los terapeutas para ataques de pánico.",
    steps: [
        ToolStep(number: 1, title: "Mira 5 cosas",
                 description: "Que puedas ver a tu alrededor",
                 sfSymbol: "eye.fill"),
        ToolStep(number: 2, title: "Toca 4 cosas",
                 description: "Siente la textura de cada una",
                 sfSymbol: "hand.tap.fill"),
        ToolStep(number: 3, title: "Escucha 3 sonidos",
                 description: "Identifícalos uno por uno",
                 sfSymbol: "ear.fill"),
        ToolStep(number: 4, title: "Huele 2 cosas",
                 description: "Detecta los aromas del lugar",
                 sfSymbol: "nose.fill"),
        ToolStep(number: 5, title: "Saborea 1",
                 description: "Lo que sea que tengas en la boca",
                 sfSymbol: "mouth.fill"),
    ],
    totalSeconds: 120,
    timerMode: .simple
)

let allTools: [WellnessTool] = [tool478, toolEnfoqueVisual, toolGrounding]