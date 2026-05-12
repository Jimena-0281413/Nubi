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
        case .feliz:   return "face.smiling.fill"
        case .triste:  return "cloud.rain.fill"
        case .enojado: return "flame.fill"
        case .ansioso: return "waveform.path.ecg"
        case .agotado: return "moon.zzz.fill"
        }
    }

    var color: Color {
        switch self {
        case .feliz:   return Color(hex: "#FFB703")
        case .triste:  return Color(hex: "#5C7B99")
        case .enojado: return Color(hex: "#EF476F")
        case .ansioso: return Color(hex: "#9B59B6")
        case .agotado: return Color(hex: "#95A5A6")
        }
    }

    /// Tipo de expresión que adopta Nubi para esta emoción
    var nubiExpression: NubiExpression {
        switch self {
        case .feliz:   return .happy
        case .triste:  return .sad
        case .enojado: return .angry
        case .ansioso: return .anxious
        case .agotado: return .tired
        }
    }

    var subEmotions: [SubEmotion] {
        switch self {
        case .feliz:
            return [SubEmotion(label: "Con mucha energía",  sfSymbol: "bolt.fill"),
                    SubEmotion(label: "Tranquilo y bien",   sfSymbol: "leaf.fill"),
                    SubEmotion(label: "Orgulloso de algo",  sfSymbol: "star.fill"),
                    SubEmotion(label: "Agradecido hoy",     sfSymbol: "heart.fill")]
        case .triste:
            return [SubEmotion(label: "Con ganas de llorar", sfSymbol: "drop.fill"),
                    SubEmotion(label: "Triste y con coraje", sfSymbol: "wind"),
                    SubEmotion(label: "Me siento solo/a",    sfSymbol: "person.2.fill"),
                    SubEmotion(label: "Nostálgico/a",        sfSymbol: "cloud.rain.fill")]
        case .enojado:
            return [SubEmotion(label: "Frustrado con el trabajo", sfSymbol: "exclamationmark.triangle.fill"),
                    SubEmotion(label: "Enojado con alguien",      sfSymbol: "flame.fill"),
                    SubEmotion(label: "Me siento ignorado/a",     sfSymbol: "minus.circle.fill"),
                    SubEmotion(label: "Injusticia que me afecta", sfSymbol: "hand.raised.fill")]
        case .ansioso:
            return [SubEmotion(label: "Nervioso/a sin razón",   sfSymbol: "waveform.path.ecg"),
                    SubEmotion(label: "Miedo a algo concreto",  sfSymbol: "exclamationmark.circle.fill"),
                    SubEmotion(label: "Presión por metas",      sfSymbol: "chart.bar.fill"),
                    SubEmotion(label: "No puedo descansar",     sfSymbol: "moon.fill")]
        case .agotado:
            return [SubEmotion(label: "Cansancio físico",      sfSymbol: "figure.walk"),
                    SubEmotion(label: "Cansancio mental",      sfSymbol: "brain.head.profile"),
                    SubEmotion(label: "Sin motivación",        sfSymbol: "battery.25"),
                    SubEmotion(label: "Quiero desconectarme",  sfSymbol: "xmark.circle.fill")]
        }
    }
}

// MARK: - Expresión de Nubi (boca dinámica)
enum NubiExpression {
    case neutral, happy, sad, angry, anxious, tired
}

struct SubEmotion: Identifiable {
    let id       = UUID()
    let label    : String
    let sfSymbol : String
}

// MARK: - EmotionEntry
struct EmotionEntry: Identifiable, Codable {
    let id            : UUID
    let date          : Date
    let primaryEmotion: String
    let subEmotion    : String
    let nubiColor     : String

    init(primary: PrimaryEmotion, sub: SubEmotion) {
        self.id             = UUID()
        self.date           = Date()
        self.primaryEmotion = primary.rawValue
        self.subEmotion     = sub.label
        self.nubiColor      = primary.color.toHex() ?? "#5C7B99"
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

// MARK: - Puestos
enum WorkPosition: String, CaseIterable {
    case callCenter = "Call Center"
    case cajas      = "Cajas"
    case pisoVenta  = "Piso de Venta"
    case almacen    = "Almacén"
    case supervisor = "Supervisor/a"
    case rh         = "Recursos Humanos"
    case otro       = "Otro"
}

// MARK: - Rol Familiar
enum FamilyRole: String, CaseIterable {
    case padre      = "Papá"
    case madre      = "Mamá"
    case hijo       = "Hijo/a"
    case esposo     = "Esposo/a"
    case proveedor  = "Proveedor/a principal"
    case cuidador   = "Cuidador/a"
    case soltero    = "Vivo solo/a"
    case otro       = "Otro"

    var sfSymbol: String {
        switch self {
        case .padre:     return "figure.2.and.child.holdinghands"
        case .madre:     return "figure.and.child.holdinghands"
        case .hijo:      return "person.fill"
        case .esposo:    return "heart.fill"
        case .proveedor: return "briefcase.fill"
        case .cuidador:  return "hands.sparkles.fill"
        case .soltero:   return "house.fill"
        case .otro:      return "sparkles"
        }
    }
}

// MARK: - Tipo de transporte (NUEVO)
enum TransportType: String, CaseIterable {
    case caminando      = "Caminando"
    case bicicleta      = "Bicicleta"
    case publico        = "Transporte público"
    case auto           = "Auto propio"
    case motocicleta    = "Motocicleta"
    case compartido     = "Aventón / compartido"
    case otro           = "Otro"

    var sfSymbol: String {
        switch self {
        case .caminando:   return "figure.walk"
        case .bicicleta:   return "bicycle"
        case .publico:     return "bus.fill"
        case .auto:        return "car.fill"
        case .motocicleta: return "bolt.car.fill"
        case .compartido:  return "person.2.fill"
        case .otro:        return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Estresores
enum WorkStressor: String, CaseIterable, Identifiable {
    case clientesDificiles   = "Clientes difíciles"
    case cargaTrabajo        = "Mucha carga de trabajo"
    case horarios            = "Horarios o turnos"
    case relacionCompaneros  = "Relación con compañeros"
    case presionMetas        = "Presión por metas"
    case faltaReconocimiento = "Falta de reconocimiento"
    case comunicacion        = "Comunicación con jefes"
    case pagos               = "Pagos o salario"
    case ambiente            = "Ambiente de trabajo"

    var id: String { rawValue }

    var sfSymbol: String {
        switch self {
        case .clientesDificiles:   return "person.crop.circle.badge.exclamationmark.fill"
        case .cargaTrabajo:        return "tray.full.fill"
        case .horarios:            return "clock.fill"
        case .relacionCompaneros:  return "person.2.fill"
        case .presionMetas:        return "scope"
        case .faltaReconocimiento: return "medal.fill"
        case .comunicacion:        return "bubble.left.fill"
        case .pagos:               return "dollarsign.circle.fill"
        case .ambiente:            return "building.2.fill"
        }
    }
}

// MARK: - Resultado de juego
struct GameResult: Identifiable, Codable {
    let id       = UUID()
    let date     : Date
    let gameName : String
    let score    : Int
    let insight  : String
}

// MARK: - Categorías de guías
enum GuideCategory: String, CaseIterable {
    case softSkill     = "Soft Skills"
    case workSituation = "Mi trabajo"
    case saludMental   = "Salud Mental"
    case herramientas  = "Herramientas"
    case enciclopedia  = "Enciclopedia"
    case energiaVital  = "Energía Vital"  // NUEVA — para mamás / sincronización con ciclo
}

// MARK: - Modelo de guía
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
         accentColor: Color = Color.coppelButton,
         forPositions: [WorkPosition] = []) {
        self.title          = title
        self.sfSymbol       = sfSymbol
        self.category       = category
        self.readTime       = readTime
        self.content        = content
        self.isRecommended  = isRecommended
        self.accentColor    = accentColor
        self.forPositions   = forPositions
    }
}

// MARK: - Soft Skills (cards rápidas)
let softSkillsGuides: [Guide] = [
    Guide(title: "Comunicación\nasertiva",
          sfSymbol: "bubble.left.and.bubble.right.fill", category: .softSkill, readTime: "3 min",
          content: "Hablar claro no es ser grosero. La comunicación asertiva es decir lo que piensas y sientes sin atacar al otro. La clave está en usar 'yo' en lugar de 'tú'.\n\nFórmula: SITUACIÓN + EFECTO EN TI + LO QUE NECESITAS.",
          isRecommended: true, accentColor: Color(hex: "#5C7B99")),
    Guide(title: "Límites\nsaludables",
          sfSymbol: "shield.fill", category: .softSkill, readTime: "3 min",
          content: "Un límite no es un muro: es una señal de respeto hacia ti y hacia el otro. Decir no no es egoísmo.",
          accentColor: Color(hex: "#7FA8C9")),
    Guide(title: "Escucha\nactiva",
          sfSymbol: "waveform", category: .softSkill, readTime: "2 min",
          content: "Escuchar no es esperar tu turno para hablar.",
          accentColor: Color(hex: "#9B8EC4")),
    Guide(title: "Manejo del\ntiempo",
          sfSymbol: "timer", category: .softSkill, readTime: "4 min",
          content: "Matriz de Eisenhower: clasifica cada tarea en URGENTE/IMPORTANTE.",
          accentColor: Color(hex: "#06D6A0")),
]

// MARK: - "Mi trabajo" — guías AMPLIADAS con texto más extenso
let workSituationGuides: [Guide] = [
    Guide(title: "Con un cliente\nque grita",
          sfSymbol: "exclamationmark.bubble.fill", category: .workSituation, readTime: "3 min",
          content: """
          Cuando un cliente alza la voz, tu voz baja. Esa es la regla de oro de servicio al cliente. El volumen bajo obliga al otro a bajar el suyo para escucharte.

          PROTOCOLO DE 3 PASOS:

          1) Valida sin ceder. "Entiendo perfectamente su molestia, tiene razón en estar frustrado."

          2) Redirige. "Déjeme ver qué puedo hacer por usted ahora mismo."

          3) Actúa. Propón una solución concreta, en pasos claros.

          QUÉ NO HACER:
          • No discutir si el cliente tiene razón o no.
          • No tomarte los insultos personalmente: están dirigidos al sistema, no a ti.
          • No prometer algo que no puedes cumplir.

          DESPUÉS DE LA INTERACCIÓN:
          Date 2 minutos para recuperarte. Respira hondo, toma agua, mueve los hombros. No eres el banco de emociones del cliente.

          Recuerda: tu calma es tu herramienta más poderosa. Quien mantiene la cabeza fría siempre tiene la razón al final.
          """,
          isRecommended: true, accentColor: Color(hex: "#EF476F"),
          forPositions: [.callCenter, .cajas, .pisoVenta, .otro]),

    Guide(title: "Cuando el\nsistema falla",
          sfSymbol: "wifi.exclamationmark", category: .workSituation, readTime: "3 min",
          content: """
          El sistema cayó. El cliente espera. La fila crece. La ansiedad sube. Aquí el plan:

          PRIMERO — Comunica rápido y con calma:
          "Estamos teniendo un problema técnico. Le pido 2 minutos de paciencia." La mayoría entiende cuando se avisa de inmediato. Lo que no perdonan es el silencio.

          SEGUNDO — Usa el tiempo productivamente:
          • Anota el folio o número de operación.
          • Busca la solución manual si existe.
          • Llama al supervisor si el protocolo lo requiere.
          • Mantén ocupada la mente del cliente preguntándole datos relevantes.

          TERCERO — Cuida tu cuerpo:
          La frustración acumulada del sistema afecta tus hombros, tu mandíbula, tu estómago. Cada 10 minutos suelta los hombros conscientemente.

          Recuerda: tu trabajo NO es arreglar el sistema. Tu trabajo es manejar la espera con dignidad.
          """,
          accentColor: Color(hex: "#2196F3"),
          forPositions: [.callCenter, .cajas, .pisoVenta, .rh]),

    Guide(title: "En hora\npico",
          sfSymbol: "chart.line.uptrend.xyaxis", category: .workSituation, readTime: "3 min",
          content: """
          La hora pico es predecible, y aun así nos sorprende. La diferencia entre quien la sobrevive y quien la domina está en los 5 minutos antes.

          PREPARACIÓN MENTAL (5 min antes):
          • Respira: 3 ciclos de inhala 4 / exhala 6.
          • Organiza tu espacio físico.
          • Activa el modo flujo: una interacción a la vez.

          DURANTE EL PICO:
          • Baja tu velocidad de habla un 20%. Hablar más despacio transmite control y reduce malentendidos.
          • Mantén contacto visual breve pero genuino con cada cliente.
          • No anticipes lo siguiente, atiende lo que tienes enfrente.

          DESPUÉS DEL PICO:
          • 2 minutos de silencio. Sin pantallas. Sin redes. Solo respira.
          • Anota mentalmente qué funcionó y qué no.
          • Hidrátate.

          La hora pico bien manejada es satisfacción pura. Mal manejada, es burnout acumulado.
          """,
          accentColor: Color(hex: "#9B59B6"),
          forPositions: [.cajas, .pisoVenta, .almacen]),

    Guide(title: "Cuando cometo\nun error",
          sfSymbol: "arrow.uturn.backward.circle.fill", category: .workSituation, readTime: "3 min",
          content: """
          Cometiste un error en el trabajo. El cliente lo notó. Tu primer instinto es disculparte mil veces, pero eso a veces amplifica el problema.

          LOS 3 PASOS DEL ERROR BIEN MANEJADO:

          1) Reconoce rápido y claro: "Me equivoqué, tiene razón."

          2) Propón solución inmediata y concreta. No prometas; ejecuta.

          3) Cierra con aprendizaje (después): pregúntate qué proceso cambiarías para que no vuelva a pasar.

          LO QUE NO DEBES HACER:
          • Echar la culpa al sistema, al jefe o a un compañero.
          • Disculparte 5 veces seguidas (eso transmite inseguridad).
          • Llevarte la culpa a casa. Errar es parte del trabajo de alta carga.

          DATO IMPORTANTE:
          El indicador de tu profesionalismo no es si te equivocas, sino cómo lo resuelves. Los empleados promedio temen los errores. Los profesionales los usan para crecer.
          """,
          accentColor: Color(hex: "#F4A261"), forPositions: []),

    Guide(title: "Con metas\nque abruman",
          sfSymbol: "scope", category: .workSituation, readTime: "4 min",
          content: """
          Las metas del mes se ven imposibles desde el día 1. El truco es nunca verlas completas, solo fraccionadas.

          DIVIDE Y CONQUISTA:
          Divide la meta mensual entre los días hábiles que te quedan. Eso te da la meta diaria real. Después divídela en bloques de 2 horas.

          EJEMPLO PRÁCTICO:
          Meta mensual: vender 60 servicios. Días hábiles: 24. Meta diaria: 2.5 (redondea a 3 algunos días, 2 otros). En bloques de 2h durante un turno de 8h: menos de 1 servicio por bloque. Suena más manejable, ¿verdad?

          CUANDO EL ESTRÉS SUBE:
          • Pausa 60 segundos. Respira.
          • Pregúntate: ¿qué puedo hacer en los próximos 10 minutos?
          • Olvida la meta total. Concéntrate en la siguiente acción.

          PARADOJA IMPORTANTE:
          Cuando el estrés por metas sube, tu rendimiento baja. Relajarte estratégicamente te acerca más a la meta que el pánico constante. Los mejores vendedores no son los más estresados; son los más enfocados.
          """,
          isRecommended: true, accentColor: Color(hex: "#06D6A0"),
          forPositions: [.callCenter, .pisoVenta, .supervisor]),

    Guide(title: "Al final de\nun turno largo",
          sfSymbol: "moon.zzz.fill", category: .workSituation, readTime: "3 min",
          content: """
          Llevas 8 horas de pie, de pantalla, o de llamadas. El cuerpo dice basta. ¿Cómo terminas el turno sin llevarte el trabajo a casa?

          EL RITUAL DE CIERRE (3 minutos):
          Antes de salir, escribe en tu mente las 3 cosas que resolviste hoy. No lo que faltó: lo que lograste. Esto activa el sistema de recompensa cerebral y cierra el bucle cognitivo del turno.

          EN EL CAMINO A CASA:
          • 10 minutos sin redes sociales. Solo música o silencio.
          • Si vas en transporte, observa el paisaje. Si caminas, siente tus pies.
          • No revises mensajes laborales fuera de tu horario.

          AL LLEGAR:
          • Cámbiate de ropa. Es un ritual simbólico que separa el "yo trabajador" del "yo personal".
          • Antes de hablar con alguien, dedícate 5 minutos a ti.
          • Cena algo nutritivo aunque sea algo rápido.

          Recuperarse del turno no es opcional, es parte del trabajo bien hecho.
          """,
          isRecommended: true, accentColor: Color(hex: "#5C7B99"), forPositions: []),

    // RENOMBRADO — antes "Con un compañero que te saca"
    Guide(title: "Compañeros\ndifíciles",
          sfSymbol: "person.2.fill", category: .workSituation, readTime: "4 min",
          content: """
          Hay compañeros que drenan energía sin darse cuenta. La clave es no dejar que su caos se vuelva el tuyo.

          TIPOS COMUNES Y CÓMO MANEJARLOS:

          EL INTERRUPTOR:
          Te corta cada 10 minutos. Respuesta: "Ahora estoy en algo, en 10 minutos te atiendo." Repítelo con calma cada vez. Eventualmente respeta el límite.

          EL QUEJUMBROSO:
          Habla mal de todos y todo. Respuesta: "¿Qué vas a hacer tú al respecto?" Devuelve la agencia. Si solo se queja, no aporta soluciones, no inviertas energía.

          EL VAMPIRO EMOCIONAL:
          Te cuenta sus problemas todo el día y nunca pregunta por ti. Respuesta: limita el tiempo. "Tengo solo 5 minutos, cuéntame lo más importante."

          EL COMPETITIVO:
          Quiere ganarte en todo. Respuesta: no compitas. Sé honestamente bueno en tu trabajo y no pelees con el ego ajeno.

          EL CHISMOSO:
          Lleva información de un lado a otro. Respuesta: no le des material. "Prefiero hablar de cosas que sumen."

          REGLA DE ORO:
          No puedes cambiar a la persona, pero sí puedes cambiar cómo te relacionas con ella. Tu energía es tuya: decide a quién se la regalas.
          """,
          accentColor: Color(hex: "#7FA8C9"), forPositions: []),

    Guide(title: "Cuando no\nquieres ir",
          sfSymbol: "cloud.rain.fill", category: .workSituation, readTime: "3 min",
          content: """
          Hay días que levantarse para el turno se siente imposible. No es flojera, es una señal de agotamiento real.

          PARA EL DÍA DE HOY — EL TRUCO DE LOS 2 MINUTOS:
          Sólo comprométete con 2 minutos de la primera tarea del día (vestirte, lavarte la cara, salir de la cama). El inicio es la parte más difícil. Una vez que estás en movimiento, el resto sigue.

          PARA ESTA SEMANA:
          • Identifica tu energía vital: ¿qué te da gasolina para ir? Música, café, una llamada con alguien que quieres, una rutina.
          • Premia los días difíciles. No lo veas como capricho: es supervivencia emocional.

          A MEDIANO PLAZO:
          Si este sentimiento dura más de 2 semanas seguidas, agenda una cita con uno de los psicólogos disponibles en la app. El desinterés crónico es la señal más clara de burnout temprano y NO se cura solo.

          IMPORTANTE:
          Pedir ayuda no es debilidad. Es la respuesta inteligente a un cuerpo que te está avisando que necesita apoyo profesional.
          """,
          accentColor: Color(hex: "#95A5A6"), forPositions: []),
]

// MARK: - Salud Mental — guías AMPLIADAS con texto más extenso
let encyclopediaGuides: [Guide] = [
    Guide(title: "¿Qué es el burnout\ny cómo lo identifico?",
          sfSymbol: "flame.fill", category: .saludMental, readTime: "5 min",
          content: """
          El burnout no es solo cansancio. Es agotamiento emocional profundo combinado con cinismo hacia el trabajo. La OMS lo reconoce como síndrome laboral oficial desde 2019.

          LAS 3 SEÑALES PRINCIPALES:

          1) AGOTAMIENTO FÍSICO Y EMOCIONAL
          Sin que el descanso lo repare. Duermes 8 horas y aún así amaneces sin energía. El fin de semana no te recupera. Las vacaciones se sienten cortas.

          2) DESPERSONALIZACIÓN (CINISMO)
          Te vuelves distante. Hablas con sarcasmo del trabajo, de los clientes, de los compañeros. Lo que antes te importaba ahora te da igual.

          3) REDUCCIÓN DEL LOGRO PERSONAL
          Sientes que nada de lo que haces importa. Los logros pasados se sienten ajenos. Crees que estás fracasando aunque otros te digan lo contrario.

          SEÑALES FÍSICAS QUE NO DEBES IGNORAR:
          • Dolores de cabeza frecuentes.
          • Tensión en hombros y mandíbula constante.
          • Cambios de apetito (mucho o nada).
          • Insomnio o dormir demasiado.
          • Sistema inmune débil (te enfermas seguido).

          QUÉ HACER:
          Si llevas más de 2 semanas con varias de estas señales, no las normalices. Habla con los psicólogos de Coppel desde la app. El burnout NO se cura descansando un fin de semana. Requiere acompañamiento profesional.

          DATO IMPORTANTE:
          El burnout no es debilidad. Le pasa a la gente más comprometida con su trabajo. Reconocerlo a tiempo evita que se convierta en algo más grave.
          """,
          isRecommended: true, accentColor: Color(hex: "#EF476F")),

    Guide(title: "Depresión: señales\nque no debes ignorar",
          sfSymbol: "heart.fill", category: .saludMental, readTime: "5 min",
          content: """
          La depresión no siempre se parece a la tristeza extrema. A veces se manifiesta como irritabilidad, como dormir demasiado o muy poco, como pérdida de interés en cosas que antes amabas.

          LA DEPRESIÓN ES UNA CONDICIÓN MÉDICA, NO UNA DEBILIDAD DE CARÁCTER. Como la diabetes o la hipertensión, requiere atención profesional y a veces tratamiento. Salir adelante "por fuerza de voluntad" rara vez funciona porque hay un desbalance químico real.

          SÍNTOMAS COMUNES (4 o más por más de 2 semanas):
          • Tristeza persistente o sensación de vacío.
          • Pérdida de energía aunque duermas mucho.
          • Cambios significativos en apetito (subir o bajar mucho de peso sin razón).
          • Dificultad de concentración: leer la misma frase 3 veces sin entenderla.
          • Culpa excesiva o sensación de inutilidad.
          • Pensamientos de que sería mejor no estar.
          • Pérdida de interés en cosas que antes te alegraban.

          QUIÉNES SON MÁS VULNERABLES:
          Personas que cuidan a otros (mamás, cuidadores, trabajadores de servicio), personas con cargas económicas grandes, personas con historia familiar de depresión.

          QUÉ HACER AHORA:
          Si reconoces estos síntomas en ti, busca apoyo profesional cuanto antes. El botón SOS de la app conecta con un psicólogo en el momento. No esperes a estar peor para pedir ayuda.

          NO ESTÁS SOLO/A. Aproximadamente 1 de cada 5 adultos en México vive con síntomas de depresión en algún momento de su vida. Lo importante es buscar apoyo.
          """,
          accentColor: Color(hex: "#5C7B99")),

    // NUEVA — Baja autoestima
    Guide(title: "Baja autoestima\ny desconfianza",
          sfSymbol: "person.crop.circle.badge.questionmark.fill", category: .saludMental, readTime: "5 min",
          content: """
          La baja autoestima no se ve, pero se siente todos los días. Es esa voz interna que te dice "no soy suficiente", "no merezco esto", "todos lo hacen mejor que yo". Cuando suena fuerte, contamina cómo trabajas, cómo te relacionas, cómo te tratas.

          CÓMO SE MANIFIESTA EN EL TRABAJO:
          • Te cuesta pedir un aumento aunque sepas que lo mereces.
          • No defiendes tus ideas en juntas.
          • Aceptas tareas extra para "ganarte" tu lugar.
          • Te disculpas por todo, incluso cuando no es tu culpa.
          • Comparas tu desempeño con el de otros constantemente.

          DE DÓNDE VIENE:
          La autoestima se forma muy temprano (infancia, adolescencia) por las palabras y trato que recibimos. No es tu culpa tenerla baja, pero SÍ es tu responsabilidad reconstruirla.

          LA DESCONFIANZA HACIA OTROS:
          Cuando uno no se confía en sí, también desconfía de los demás. Crees que los elogios son falsos, que los amigos te traicionarán, que la pareja te va a dejar. Esto desgasta relaciones que en realidad son sanas.

          5 EJERCICIOS QUE SÍ FUNCIONAN:

          1) DIARIO DE LOGROS:
          Cada noche escribe 3 cosas que hiciste bien hoy, por pequeñas que sean. Revisa la lista cada semana.

          2) CAMBIA EL DIÁLOGO INTERNO:
          Cuando te digas "soy un fracaso", pregúntate: "¿le diría esto a un amigo?" Si la respuesta es no, no te lo digas a ti.

          3) ACEPTA CUMPLIDOS:
          Cuando alguien te elogie, di "gracias" y no agregues "pero...". Practica recibir.

          4) IDENTIFICA TUS LOGROS REALES:
          Haz una lista de 10 cosas que has logrado en tu vida. Léela cuando la voz crítica se active.

          5) CUERPO PRIMERO:
          La autoestima también es física. Camina derecho, hombros atrás. La postura cambia la química cerebral.

          CUÁNDO BUSCAR AYUDA PROFESIONAL:
          Si la baja autoestima te lleva a aislarte, a sentir que no mereces vivir, o si interfiere con tu trabajo y relaciones por más de un mes, agenda con un psicólogo. La terapia cognitivo-conductual tiene un éxito comprobado para reconstruir la autoestima en pocas sesiones.

          MENSAJE CLAVE:
          Eres mucho más capaz de lo que tu voz crítica te dice. Tu valor no se mide en productividad ni en aprobación de otros. Existe simplemente porque eres tú.
          """,
          isRecommended: true, accentColor: Color(hex: "#9B8EC4")),

    Guide(title: "Técnica 4-7-8\npara ansiedad inmediata",
          sfSymbol: "wind", category: .herramientas, readTime: "2 min",
          content: """
          Inhala 4 segundos. Retén 7. Exhala 8. Esta técnica activa el nervio vago y reduce el cortisol en menos de 2 minutos.

          La encuentras como herramienta guiada en esta misma sección, con temporizador y animación.
          """,
          accentColor: Color(hex: "#B8D8D8")),
]

// MARK: - Energía Vital (NUEVA categoría — para mamás trabajadoras / sincronización con ciclo)
let energiaVitalGuides: [Guide] = [
    Guide(title: "Productividad en Flujo:\nGestiona el estrés según tu ciclo",
          sfSymbol: "moon.stars.fill", category: .energiaVital, readTime: "6 min",
          content: """
          Tu energía no es la misma todos los días, y eso es tu superpoder, no un obstáculo. En esta guía aprenderás a leer las señales de tu cuerpo para adaptar tu carga laboral y de crianza a cada fase hormonal.

          ¿POR QUÉ IMPORTA?
          Las hormonas femeninas oscilan a lo largo del mes en 4 fases. Cada fase activa diferentes neurotransmisores que afectan tu energía, tu enfoque, tu creatividad y tu paciencia. Trabajar en sintonía con esto reduce el estrés un 40%.

          LAS 4 FASES Y CÓMO USARLAS:

          FASE MENSTRUAL (días 1-5):
          Tu cuerpo descansa. Bajan los estrógenos. Es momento de tareas de bajo esfuerzo: organizar, archivar, planear. Si puedes, evita confrontaciones difíciles. Si tienes hijos, simplifica las cenas y rutinas.

          FASE FOLICULAR (días 6-14):
          Energía y creatividad al máximo. Estrógenos en alza. Es el momento ideal para LIDERAR juntas importantes, hacer presentaciones, conocer gente nueva, hablar con tu jefe sobre proyectos. También es buena fase para empezar nuevos hábitos.

          FASE OVULATORIA (días 14-16):
          Pico de energía social. Comunicación brillante. Si tienes que negociar algo difícil con la pareja, hablar con maestros de la escuela o resolver un conflicto familiar, este es el momento.

          FASE LÚTEA (días 17-28):
          Bajan los estrógenos, sube la progesterona. Mejor concentración para trabajo individual y de detalle. Pero también: más sensibilidad emocional. Prioriza trabajo de enfoque profundo en solitario, evita decisiones grandes los últimos 3 días.

          CÓMO REGISTRARLO:
          Usa el seguimiento del ciclo en tu perfil de Nubi. La IA on-device (que NO sube tus datos a internet, todo se procesa en tu teléfono para máxima privacidad) ajustará tus recomendaciones diarias según tu fase actual.

          MITO QUE HAY QUE ROMPER:
          "Estar en tu periodo es debilidad". Falso. Cada fase tiene fortalezas únicas. Las mejores ejecutivas del mundo trabajan CON su biología, no contra ella.

          MENSAJE CLAVE:
          Si eres mamá trabajadora, esto es vital. No estás fallando porque algunos días no rindes igual. Tu cuerpo está diseñado para fluir entre potencias diferentes. Aprende a leerlo y serás imparable.
          """,
          isRecommended: true, accentColor: Color(hex: "#EF476F")),

    Guide(title: "Nutrición rápida\npara mamás en su periodo",
          sfSymbol: "leaf.fill", category: .energiaVital, readTime: "5 min",
          content: """
          El cansancio físico durante el periodo no es flojera: es química. Tu cuerpo pierde hierro y necesita reponer minerales específicos. Aquí te decimos cómo, sin que pierdas tiempo en la cocina.

          ALIMENTOS CLAVE QUE AYUDAN MUCHO:

          RICOS EN HIERRO (combaten cansancio extremo):
          • Espinacas (puedes incluirlas en licuados rápidos).
          • Carne roja magra 2-3 veces por semana.
          • Frijoles y lentejas (cómpralos ya cocidos en lata para ahorrar tiempo).
          • Huevos (especialmente la yema).

          RICOS EN MAGNESIO (reducen cólicos y cambios de humor):
          • Plátano (snack perfecto para llevar).
          • Almendras y semillas de calabaza.
          • Chocolate amargo 70% (sí, está aprobado y científicamente recomendado).
          • Aguacate.

          OMEGA-3 (ayudan a estabilizar el ánimo):
          • Sardinas en lata (rápido, barato, efectivo).
          • Nueces.
          • Salmón si el presupuesto lo permite.

          LO QUE DEBES EVITAR:
          • Cafeína en exceso (empeora la ansiedad y los cólicos).
          • Azúcar refinada (te da picos y bajones bruscos).
          • Alcohol (deshidrata e intensifica los síntomas).

          IDEAS DE SNACKS PARA LLEVAR EN LA BOLSA:
          • Mezcla de almendras + arándanos + cuadritos de chocolate amargo.
          • Plátano + crema de cacahuate (en envase pequeño).
          • Yogurt griego con miel (se conserva 2-3 horas en bolsa térmica).
          • Huevos cocidos del día anterior (proteína rápida en piso de venta).

          MICROMEDITACIONES DE 2 MINUTOS:
          Cuando los síntomas físicos coinciden con juntas importantes o tareas escolares de los hijos:

          • Cierra los ojos.
          • Pon ambas manos sobre tu vientre bajo (el calor de las manos relaja).
          • Respira: inhala 4 segundos, exhala 6.
          • Repite 8 veces.

          Esto baja el cortisol y reduce los cólicos en menos de 2 minutos. Lo puedes hacer en el baño del trabajo, en el coche antes de bajar, en el estacionamiento de la escuela.

          MENSAJE FINAL:
          No se trata de cocinar perfecto en una semana difícil. Se trata de elegir mejor entre lo que ya tienes a la mano. Pequeños cambios, gran diferencia.
          """,
          isRecommended: true, accentColor: Color(hex: "#06D6A0")),
]

// MARK: - All / Helpers
let allGuides: [Guide]    = softSkillsGuides + workSituationGuides + encyclopediaGuides + energiaVitalGuides
let sampleGuides: [Guide] = allGuides

func workGuidesFor(position: WorkPosition) -> [Guide] {
    workSituationGuides.filter { $0.forPositions.isEmpty || $0.forPositions.contains(position) }
}
