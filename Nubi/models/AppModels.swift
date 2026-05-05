//
//  AppModels.swift
//  Nubi
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

    var sfSymbol: String {
        switch self {
        case .feliz:   return "face.smiling.inverse"
        case .triste:  return "drop.fill"
        case .enojado: return "flame.fill"
        case .ansioso: return "waveform.path.ecg"
        case .agotado: return "moon.zzz.fill"
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
            return [SubEmotion(label: "Con mucha energía",   sfSymbol: "bolt.fill"),
                    SubEmotion(label: "Tranquilo y bien",     sfSymbol: "leaf.fill"),
                    SubEmotion(label: "Orgulloso de algo",    sfSymbol: "trophy.fill"),
                    SubEmotion(label: "Agradecido hoy",       sfSymbol: "hands.and.sparkles.fill")]
        case .triste:
            return [SubEmotion(label: "Con ganas de llorar",  sfSymbol: "cloud.drizzle.fill"),
                    SubEmotion(label: "Triste y con coraje",  sfSymbol: "exclamationmark.bubble.fill"),
                    SubEmotion(label: "Me siento solo/a",     sfSymbol: "person.fill.questionmark"),
                    SubEmotion(label: "Nostálgico/a",         sfSymbol: "cloud.heavyrain.fill")]
        case .enojado:
            return [SubEmotion(label: "Frustrado con el trabajo", sfSymbol: "minus.circle.fill"),
                    SubEmotion(label: "Enojado con alguien",       sfSymbol: "flame"),
                    SubEmotion(label: "Me siento ignorado/a",      sfSymbol: "speaker.slash.fill"),
                    SubEmotion(label: "Injusticia que me afecta",  sfSymbol: "scale.3d")]
        case .ansioso:
            return [SubEmotion(label: "Nervioso/a sin razón",   sfSymbol: "tornado"),
                    SubEmotion(label: "Miedo a algo concreto",   sfSymbol: "exclamationmark.triangle.fill"),
                    SubEmotion(label: "Presión por metas",        sfSymbol: "chart.bar.fill"),
                    SubEmotion(label: "No puedo descansar",       sfSymbol: "moon.stars.fill")]
        case .agotado:
            return [SubEmotion(label: "Cansancio físico",    sfSymbol: "figure.walk"),
                    SubEmotion(label: "Cansancio mental",     sfSymbol: "brain.head.profile"),
                    SubEmotion(label: "Sin motivación",       sfSymbol: "battery.0percent"),
                    SubEmotion(label: "Quiero desconectarme", sfSymbol: "wifi.slash")]
        }
    }
}

struct SubEmotion: Identifiable {
    let id = UUID()
    let label: String
    let sfSymbol: String
}

// MARK: - Registro de emoción
struct EmotionEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let primaryEmotion: String
    let subEmotion: String
    let nubiColor: String

    init(primary: PrimaryEmotion, sub: SubEmotion) {
        self.id             = UUID()
        self.date           = Date()
        self.primaryEmotion = primary.rawValue
        self.subEmotion     = sub.label
        self.nubiColor      = primary.color.toHex() ?? "#B8D8D8"
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
    case callCenter = "Call Center"
    case cajas      = "Cajas"
    case pisoVenta  = "Piso de Venta"
    case almacen    = "Almacén"
    case supervisor = "Supervisor/a"
    case rh         = "Recursos Humanos"
    case otro       = "Otro"
}

// MARK: - Resultado de juego
struct GameResult: Identifiable, Codable {
    let id      : UUID
    let date    : Date
    let gameName: String
    let score   : Int
    let insight : String

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case gameName
        case score
        case insight
    }

    init(id: UUID = UUID(), date: Date, gameName: String, score: Int, insight: String) {
        self.id = id
        self.date = date
        self.gameName = gameName
        self.score = score
        self.insight = insight
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.date = try container.decode(Date.self, forKey: .date)
        self.gameName = try container.decode(String.self, forKey: .gameName)
        self.score = try container.decode(Int.self, forKey: .score)
        self.insight = try container.decode(String.self, forKey: .insight)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(gameName, forKey: .gameName)
        try container.encode(score, forKey: .score)
        try container.encode(insight, forKey: .insight)
    }
}

// MARK: - Guide Category
enum GuideCategory: String, CaseIterable {
    case softSkill     = "Soft Skills"
    case workSituation = "Mi trabajo"
    case saludMental   = "Salud Mental"
    case herramientas  = "Herramientas"
    case enciclopedia  = "Enciclopedia"
}

// MARK: - Guide Model
struct Guide: Identifiable {
    let id           = UUID()
    let title        : String
    let sfSymbol     : String
    let category     : GuideCategory
    let readTime     : String
    let content      : String
    let isRecommended: Bool
    let accentColor  : Color
    let forPositions : [WorkPosition]

    init(title: String, sfSymbol: String, category: GuideCategory,
         readTime: String, content: String, isRecommended: Bool = false,
         accentColor: Color = Color(hex: "#5C7B99"),
         forPositions: [WorkPosition] = []) {
        self.title         = title
        self.sfSymbol      = sfSymbol
        self.category      = category
        self.readTime      = readTime
        self.content       = content
        self.isRecommended = isRecommended
        self.accentColor   = accentColor
        self.forPositions  = forPositions
    }
}

// MARK: - Soft Skills Guides
let softSkillsGuides: [Guide] = [
    Guide(title: "Comunicación\nasertiva",
          sfSymbol: "bubble.left.and.bubble.right.fill", category: .softSkill, readTime: "3 min",
          content: "Hablar claro no es ser grosero. La comunicación asertiva es decir lo que piensas y sientes sin atacar al otro. La clave está en usar 'yo' en lugar de 'tú': en vez de 'tú siempre llegas tarde', prueba 'yo me siento afectado cuando empezamos tarde'. Esto desactiva la defensiva del otro y abre el diálogo real.\n\nEn el trabajo, aplícalo con esta fórmula: SITUACIÓN + EFECTO EN TI + LO QUE NECESITAS. Ejemplo: 'Cuando me cambian el turno sin avisarme, me estresa no poder organizarme, necesito al menos un día de anticipación.'\n\nPractica esto primero en conversaciones de bajo riesgo —con compañeros de confianza— antes de usarlo en situaciones tensas.",
          isRecommended: true, accentColor: Color(hex: "#5C7B99")),

    Guide(title: "Límites\nsaludables",
          sfSymbol: "shield.fill", category: .softSkill, readTime: "3 min",
          content: "Un límite no es un muro: es una señal de respeto hacia ti y hacia el otro. Muchas personas en trabajo de servicio sienten que 'no pueden decir no', pero eso lleva directo al agotamiento.\n\nUn límite saludable suena así: 'Entiendo que necesitas ayuda, ahora mismo estoy atendiendo a este cliente, en 5 minutos soy todo tuyo.' Es específico, amable y firme.\n\nLos límites tienen tres elementos: claridad (qué no puedes hacer), alternativa (qué sí ofreces) y consistencia (mantenerlo sin sentirte culpable). El primer límite cuesta mucho. El décimo sale solo.",
          isRecommended: false, accentColor: Color(hex: "#7FA8C9")),

    Guide(title: "Escucha\nactiva",
          sfSymbol: "ear.fill", category: .softSkill, readTime: "2 min",
          content: "Escuchar no es esperar tu turno para hablar. La escucha activa hace que el otro sienta que realmente lo estás recibiendo.\n\nLas 3 técnicas más poderosas: (1) Espejeo —repite la última frase del otro como pregunta para que se sientan escuchados. (2) Asentir con el cuerpo —contacto visual, cabeza inclinada. (3) Valida antes de resolver: 'Entiendo lo frustrante que eso debe ser' antes de buscar la solución.\n\nEn atención al cliente, quien se siente escuchado rara vez escala la situación.",
          isRecommended: true, accentColor: Color(hex: "#9B8EC4")),

    Guide(title: "Manejo del\ntiempo",
          sfSymbol: "timer", category: .softSkill, readTime: "4 min",
          content: "En el turno de trabajo, el tiempo es la moneda más escasa. La técnica que mejor funciona en trabajo operativo es la Matriz de Eisenhower simplificada: clasifica cada tarea en URGENTE/IMPORTANTE.\n\nTodo lo que es urgente e importante: hazlo ahora. Importante pero no urgente: agéndalo. Urgente pero no importante: delégalo si puedes. Ni urgente ni importante: ignóralo.\n\nEl error más común es tratar todo como urgente. Cuando todo es urgente, nada lo es. Aprende a distinguir 'el cliente que grita más' de 'el problema que tiene mayor impacto real'.",
          isRecommended: false, accentColor: Color(hex: "#06D6A0")),

    Guide(title: "Trabajo bajo\npresión",
          sfSymbol: "bolt.heart.fill", category: .softSkill, readTime: "3 min",
          content: "La presión no desaparece —pero puedes cambiar tu relación con ella. El primer paso es separar lo que puedes controlar de lo que no: la actitud del cliente no es tuya, tu respuesta sí lo es.\n\nCuando sientas que la presión sube: respira (4 segundos dentro, 6 afuera), enfócate en la siguiente acción más pequeña posible, y recuerda que el 90% de las situaciones que sentimos como catástrofes en el momento, en una hora serán manejables.\n\nLos equipos de alto rendimiento no trabajan sin presión —trabajan con ella sin dejar que los paralice.",
          isRecommended: false, accentColor: Color(hex: "#F4A261")),

    Guide(title: "Inteligencia\nemocional",
          sfSymbol: "brain.head.profile", category: .softSkill, readTime: "4 min",
          content: "La inteligencia emocional no es controlar tus emociones —es entenderlas antes de que ellas te controlen a ti. Tiene 4 pilares: autoconciencia, autogestión, empatía y habilidades sociales.\n\nEl ejercicio más práctico: la pausa de 6 segundos. Cuando sientas un impulso fuerte (enojo, ansiedad, frustración), cuenta hasta 6 antes de responder. En ese tiempo, tu córtex prefrontal recupera el control.\n\nLas personas con alta IE no son las que nunca se enojan. Son las que usan el enojo como información, no como combustible.",
          isRecommended: true, accentColor: Color(hex: "#5C7B99")),
]

// MARK: - Work Situation Guides
let workSituationGuides: [Guide] = [
    Guide(title: "Con un cliente\nque grita",
          sfSymbol: "person.wave.2.fill", category: .workSituation, readTime: "2 min",
          content: "Cuando un cliente alza la voz, tu voz baja —esa es la regla de oro. El volumen bajo obliga al otro a bajar el suyo para escucharte.\n\nProtocolo de 3 pasos: (1) Valida sin ceder: 'Entiendo perfectamente su molestia, tiene razón en estar frustrado.' (2) Redirige: 'Déjeme ver exactamente qué puedo hacer por usted ahora mismo.' (3) Actúa: propón una solución concreta aunque sea pequeña.\n\nDespués de la interacción, date 2 minutos para recuperarte. No eres el banco de emociones del cliente.",
          isRecommended: true, accentColor: Color(hex: "#EF476F"),
          forPositions: [.callCenter, .cajas, .pisoVenta, .otro]),

    Guide(title: "Cuando el\nsistema falla",
          sfSymbol: "desktopcomputer.trianglebadge.exclamationmark", category: .workSituation, readTime: "2 min",
          content: "El sistema cayó. El cliente espera. La fila crece. La ansiedad sube. Esto es lo que funciona:\n\nPrimero, comunica rápido y con calma: 'Estamos teniendo un problema técnico, le pido 2 minutos de paciencia.' La mayoría entiende cuando se avisa de inmediato. Lo que no perdonan es el silencio.\n\nSegundo, usa el tiempo productivamente: anota el folio del cliente, busca solución manual, llama al supervisor si el protocolo lo requiere. El cliente que te ve activo rara vez escala la situación.",
          isRecommended: false, accentColor: Color(hex: "#2196F3"),
          forPositions: [.callCenter, .cajas, .pisoVenta, .rh]),

    Guide(title: "En hora\npico",
          sfSymbol: "chart.line.uptrend.xyaxis", category: .workSituation, readTime: "2 min",
          content: "La hora pico es predecible —y aún así nos sorprende. La diferencia entre quien la sobrevive y quien la domina está en la preparación mental de los 5 minutos antes.\n\nAntes de que llegue la ola: respira, organiza tu espacio físico y activa el modo 'flujo': decide que vas a enfocarte en una interacción a la vez, sin importar cuántas estén esperando.\n\nDurante el pico, baja tu velocidad de habla un 20%. Paradójicamente, hablar más despacio transmite control y acelera la resolución porque reduces malentendidos.",
          isRecommended: false, accentColor: Color(hex: "#9B59B6"),
          forPositions: [.cajas, .pisoVenta, .almacen]),

    Guide(title: "Cuando cometo\nun error",
          sfSymbol: "exclamationmark.arrow.triangle.2.circlepath", category: .workSituation, readTime: "2 min",
          content: "Cometiste un error en el trabajo. El cliente lo notó. Tu primer instinto es disculparte exageradamente —pero eso a veces amplifica el problema.\n\nLos 3 pasos del error bien manejado: (1) Reconoce rápido y sin excusas: 'Me equivoqué, tiene razón.' (2) Propón solución inmediata: 'Esto es lo que puedo hacer ahora mismo.' (3) Cierra con aprendizaje: después pregúntate qué proceso cambiarías.\n\nErrar es parte del trabajo de alta carga. El indicador de tu profesionalismo no es si te equivocas —sino cómo lo resuelves.",
          isRecommended: false, accentColor: Color(hex: "#F4A261"), forPositions: []),

    Guide(title: "Con metas\nque abruman",
          sfSymbol: "target", category: .workSituation, readTime: "3 min",
          content: "Las metas del mes se ven imposibles desde el día 1. El truco es nunca verlas completas —solo verlas fraccionadas.\n\nDivide la meta mensual entre los días hábiles que te quedan. Eso te da la meta diaria real. Después divide esa meta diaria en bloques de 2 horas. De repente, lo imposible se vuelve manejable.\n\nCuando el estrés por metas sube, tu rendimiento baja. La paradoja es que relajarte estratégicamente te acerca más a la meta que el pánico constante. Toma tus descansos —no son un lujo, son mantenimiento.",
          isRecommended: true, accentColor: Color(hex: "#06D6A0"),
          forPositions: [.callCenter, .pisoVenta, .supervisor]),

    Guide(title: "Al final de\nun turno largo",
          sfSymbol: "moon.zzz.fill", category: .workSituation, readTime: "2 min",
          content: "Llevas 8 horas de pie, de pantalla, o de llamadas. El cuerpo dice basta. ¿Cómo terminas el turno sin llevarte el trabajo a casa?\n\nEl ritual de cierre: antes de salir, escribe las 3 cosas que resolviste hoy. No lo que faltó: lo que lograste. Esto activa el sistema de recompensa y cierra el bucle cognitivo del trabajo.\n\nEn el camino a casa: 10 minutos sin redes sociales, sin hablar de trabajo. Solo música o silencio. Este buffer entre el trabajo y tu vida personal es lo que te permite recuperarte de verdad.",
          isRecommended: true, accentColor: Color(hex: "#5C7B99"), forPositions: []),

    Guide(title: "Con un compañero\nque te saca",
          sfSymbol: "person.2.fill", category: .workSituation, readTime: "3 min",
          content: "Hay compañeros que drenan energía sin darse cuenta. La clave es no dejar que su caos se vuelva el tuyo.\n\nPrimero, identifica el patrón: ¿te interrumpe? ¿te carga de trabajo extra? Cada patrón tiene una respuesta. Para interrupciones: 'Ahora estoy en algo, en 10 minutos te atiendo.' Para quejas constantes: '¿Qué vas a hacer tú al respecto?'\n\nRecuerda: no puedes cambiar a la persona, pero sí puedes cambiar cómo te relacionas con ella. A veces la respuesta más saludable es mantener una relación profesional y cortés, sin más.",
          isRecommended: false, accentColor: Color(hex: "#7FA8C9"), forPositions: []),

    Guide(title: "Cuando no\nquieres ir",
          sfSymbol: "cloud.heavyrain.fill", category: .workSituation, readTime: "2 min",
          content: "Hay días que levantarse para el turno se siente imposible. No es flojera —es una señal de agotamiento real.\n\nPara el día de hoy: el truco de los 2 minutos. Solo comprométete con 2 minutos de la primera tarea. El inicio es la parte más difícil; el cuerpo y la mente suelen entrar en ritmo una vez que arrancan.\n\nA mediano plazo: si este sentimiento dura más de 2 semanas seguidas, habla con Nubi o agenda una cita. El desinterés crónico es la señal más clara de burnout temprano —y es tratable cuando se detecta a tiempo.",
          isRecommended: false, accentColor: Color(hex: "#95A5A6"), forPositions: []),
]

// MARK: - Encyclopedia / Health Guides
let encyclopediaGuides: [Guide] = [
    Guide(title: "¿Qué es el burnout\ny cómo lo identifico?",
          sfSymbol: "flame.fill", category: .saludMental, readTime: "4 min",
          content: "El burnout no es solo cansancio. Es agotamiento emocional profundo combinado con cinismo hacia el trabajo y sensación de ineficacia. La OMS lo reconoce como síndrome laboral oficial.\n\nLas 3 señales principales: (1) Agotamiento —físico y emocional, sin que el descanso lo repare. (2) Despersonalización —te vuelves cínico, distante. (3) Reducción del logro personal —sientes que nada de lo que haces importa.\n\nSi llevas más de 2 semanas con estas señales, habla con los psicólogos de Coppel. El burnout no se cura descansando un fin de semana: requiere intervención real.",
          isRecommended: true, accentColor: Color(hex: "#EF476F")),

    Guide(title: "Depresión: señales\nque no debes ignorar",
          sfSymbol: "heart.fill", category: .saludMental, readTime: "4 min",
          content: "La depresión no siempre se parece a la tristeza extrema. A veces se manifiesta como irritabilidad, dormir demasiado o muy poco, pérdida de interés en actividades que antes amabas.\n\nLa depresión es una condición médica —no una debilidad de carácter. Decirle a alguien que 'se anime' no funciona así.\n\nSi reconoces 4 o más síntomas por más de 2 semanas: tristeza persistente, pérdida de energía, cambios en apetito, dificultad de concentración, culpa excesiva —por favor busca apoyo. El botón SOS de Nubi conecta con alguien ahora mismo.",
          isRecommended: false, accentColor: Color(hex: "#5C7B99")),

    Guide(title: "Técnica 4-7-8\npara ansiedad inmediata",
          sfSymbol: "wind", category: .herramientas, readTime: "2 min",
          content: "Inhala 4 segundos. Retén 7. Exhala 8. Esta técnica activa el nervio vago y reduce el cortisol en menos de 2 minutos.\n\nPor qué funciona: la exhalación prolongada activa el sistema nervioso parasimpático, contrarrestando la respuesta de pelea-huida del estrés. No necesitas creerlo para que funcione —solo hazlo.\n\nÚsala en: el baño del turno, el camino al trabajo, antes de una conversación difícil, o cuando sientas que la ansiedad sube sin razón aparente.",
          isRecommended: false, accentColor: Color(hex: "#B8D8D8")),
]

// MARK: - All guides combined
let allGuides: [Guide] = softSkillsGuides + workSituationGuides + encyclopediaGuides

// Legacy compatibility (usado en otras partes de la app)
let sampleGuides: [Guide] = allGuides

// Helper: filter work guides for a specific position
func workGuidesFor(position: WorkPosition) -> [Guide] {
    workSituationGuides.filter { guide in
        guide.forPositions.isEmpty || guide.forPositions.contains(position)
    }
}

