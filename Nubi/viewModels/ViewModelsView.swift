//
//  ViewModelsView.swift
//  Nubi
//

import SwiftUI
import Combine

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
        case .padre:     return "figure.and.child.holdinghands"
        case .madre:     return "figure.2.and.child.holdinghands"
        case .hijo:      return "person.fill"
        case .esposo:    return "heart.fill"
        case .proveedor: return "briefcase.fill"
        case .cuidador:  return "hands.and.sparkles.fill"
        case .soltero:   return "house.fill"
        case .otro:      return "sparkles"
        }
    }
}

// MARK: - Estresores Laborales
enum WorkStressor: String, CaseIterable, Identifiable {
    case clientesDificiles  = "Clientes difíciles"
    case cargaTrabajo       = "Mucha carga de trabajo"
    case horarios           = "Horarios o turnos"
    case relacionCompaneros = "Relación con compañeros"
    case presionMetas       = "Presión por metas"
    case faltaReconocimiento = "Falta de reconocimiento"
    case comunicacion       = "Comunicación con jefes"
    case pagos              = "Pagos o salario"
    case ambiente           = "Ambiente de trabajo"

    var id: String { rawValue }

    var sfSymbol: String {
        switch self {
        case .clientesDificiles:   return "person.wave.2.fill"
        case .cargaTrabajo:        return "tray.full.fill"
        case .horarios:            return "clock.fill"
        case .relacionCompaneros:  return "person.2.fill"
        case .presionMetas:        return "target"
        case .faltaReconocimiento: return "medal.fill"
        case .comunicacion:        return "bubble.left.and.bubble.right.fill"
        case .pagos:               return "creditcard.fill"
        case .ambiente:            return "building.2.fill"
        }
    }
}

@MainActor
class AppViewModel: ObservableObject {

    // MARK: - Onboarding / Perfil completo
    @Published var isOnboardingComplete: Bool = false
    @Published var userName: String           = ""
    @Published var userAge: String            = ""
    @Published var userGender: String         = ""   // "hombre", "mujer", "otro"
    @Published var cycleSyncEnabled: Bool     = false
    @Published var userPosition: WorkPosition = .pisoVenta
    @Published var workStressors: Set<WorkStressor> = []
    @Published var familyRole: FamilyRole     = .hijo

    // MARK: - Emotion state
    @Published var todayEmotion: EmotionEntry?   = nil
    @Published var emotionHistory: [EmotionEntry] = []
    @Published var nubiColor: Color = Color.nubiLightBlue

    // MARK: - Report state
    @Published var weeklyReport: String      = ""
    @Published var isGeneratingReport: Bool  = false
    @Published var actionPlan: [String]      = []

    // MARK: - Games state
    @Published var gameResults: [GameResult] = []

    // MARK: - SOS
    @Published var showSOSAlert: Bool = false

    // MARK: - Groq API
    // ⚠️ Reemplaza con tu key real de https://console.groq.com
    private let groqAPIKey = ""
    private let groqModel  = "llama3-8b-8192"

    // MARK: - Persistence
    private let emotionHistoryKey = "emotionHistory"
    private let onboardingKey     = "onboardingComplete"
    private let profileKey        = "userProfile_v2"

    init() { loadData() }

    // MARK: - User Profile Builder
    // Este método construye el contexto completo del usuario para inyectarlo en cada prompt de IA
    var userProfileContext: String {
        var parts: [String] = []

        if !userName.isEmpty       { parts.append("Nombre: \(userName)") }
        if !userAge.isEmpty        { parts.append("Edad: \(userAge) años") }

        switch userGender {
        case "hombre": parts.append("Género: Hombre")
        case "mujer":
            parts.append("Género: Mujer")
            parts.append(cycleSyncEnabled
                ? "Seguimiento de ciclo menstrual: activo (considerar fase hormonal en recomendaciones)"
                : "Seguimiento de ciclo menstrual: no activo")
        default: parts.append("Género: Prefirió no especificar")
        }

        parts.append("Puesto en Coppel: \(userPosition.rawValue)")

        if !workStressors.isEmpty {
            let stressorsList = workStressors.map { $0.rawValue }.joined(separator: ", ")
            parts.append("Principales estresores laborales: \(stressorsList)")
        }

        parts.append("Rol familiar: \(familyRole.rawValue)")

        return parts.joined(separator: "\n")
    }

    // MARK: - Emotion Registration
    func registerEmotion(primary: PrimaryEmotion, sub: SubEmotion) {
        let entry = EmotionEntry(primary: primary, sub: sub)
        todayEmotion   = entry
        emotionHistory.append(entry)
        nubiColor      = primary.color
        saveData()
    }

    // MARK: - Weekly Report via Groq
    func generateWeeklyReport() async {
        isGeneratingReport = true

        // Resumen emocional enriquecido
        let last14 = emotionHistory.suffix(14)
        let emotionSummary: String
        if last14.isEmpty {
            emotionSummary = "Sin registros emocionales esta semana"
        } else {
            emotionSummary = last14
                .map { "[\($0.primaryEmotion) → \($0.subEmotion)]" }
                .joined(separator: ", ")
        }

        // Resumen de juegos
        let gameSummary = gameResults.suffix(6)
            .map { "• \($0.gameName): \($0.insight)" }
            .joined(separator: "\n")

        let prompt = """
        Eres Nubi, el psicólogo de bienestar emocional de los colaboradores de Coppel. \
        Hablas en español mexicano, con calidez y cercanía. Sin jerga clínica. \
        Siempre usas "tú" y el nombre del usuario cuando sea relevante.

        ═══════════════════════════════════
        PERFIL COMPLETO DEL COLABORADOR:
        ═══════════════════════════════════
        \(userProfileContext)

        ═══════════════════════════════════
        DATOS EMOCIONALES DE LA SEMANA:
        ═══════════════════════════════════
        \(emotionSummary)

        \(gameSummary.isEmpty ? "" : "═══════════════════════════════════\nRESULTADOS DE JUEGOS DE BIENESTAR:\n═══════════════════════════════════\n\(gameSummary)")

        ═══════════════════════════════════
        GENERA EL REPORTE CON ESTA ESTRUCTURA EXACTA:
        ═══════════════════════════════════

        🌤️ **Cómo estuvo tu semana**
        [2-3 oraciones empáticas. Usa el nombre del usuario. Conecta las emociones con su puesto \
        y sus estresores específicos (\(workStressors.map{$0.rawValue}.joined(separator: ", "))). \
        Si es mujer con ciclo activo, considera el impacto hormonal si aplica.]

        💡 **Lo que detecté en ti**
        • [Patrón emocional más relevante de los registros]
        • [Algo relacionado con sus estresores laborales o rol familiar (\(familyRole.rawValue))]
        • [Un punto positivo o fortaleza que se vislumbra]

        🌱 **Tu plan para este fin de semana**
        1. [Micro-tarea específica, máximo 12 palabras, adaptada a su perfil]
        2. [Micro-tarea específica, máximo 12 palabras]
        3. [Micro-tarea específica, máximo 12 palabras]

        Reglas: Máximo 220 palabras. Sin texto antes del primer emoji. Sin texto después de la tarea 3.
        """

        do {
            let result = try await callGroqAPI(
                systemPrompt: nubiSystemPrompt,
                userPrompt: prompt
            )
            self.weeklyReport = result
            self.actionPlan   = extractActionPlan(from: result)
        } catch {
            self.weeklyReport = fallbackReport
            self.actionPlan   = fallbackActionPlan
        }
        isGeneratingReport = false
    }

    // MARK: - Groq API Call (con system prompt separado)
    func callGroqAPI(systemPrompt: String = "", userPrompt: String) async throws -> String {
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(groqAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var messages: [[String: Any]] = []
        if !systemPrompt.isEmpty {
            messages.append(["role": "system", "content": systemPrompt])
        }
        messages.append(["role": "user", "content": userPrompt])

        let body: [String: Any] = [
            "model":       groqModel,
            "messages":    messages,
            "max_tokens":  600,
            "temperature": 0.75
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let errText = String(data: data, encoding: .utf8) ?? "Error"
            throw NubiAPIError.httpError(http.statusCode, errText)
        }

        guard
            let json    = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else { throw URLError(.cannotParseResponse) }

        return content
    }

    // Overload para compatibilidad con el chatbot (firma original de un solo argumento)
    func callGroqAPI(prompt: String) async throws -> String {
        try await callGroqAPI(systemPrompt: nubiSystemPrompt, userPrompt: prompt)
    }

    // MARK: - Groq Multi-turn (para el chatbot de reporte)
    func callGroqAPIWithHistory(
        messages: [[String: Any]],
        systemPrompt: String? = nil
    ) async throws -> String {
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(groqAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var allMessages: [[String: Any]] = []
        let system = systemPrompt ?? chatSystemPrompt
        allMessages.append(["role": "system", "content": system])
        allMessages.append(contentsOf: messages)

        let body: [String: Any] = [
            "model":       groqModel,
            "messages":    allMessages,
            "max_tokens":  400,
            "temperature": 0.75
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let errText = String(data: data, encoding: .utf8) ?? "Error"
            throw NubiAPIError.httpError(http.statusCode, errText)
        }

        guard
            let json    = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else { throw URLError(.cannotParseResponse) }

        return content
    }

    // MARK: - System Prompts
    private var nubiSystemPrompt: String {
        """
        Eres Nubi, el compañero de bienestar emocional de los colaboradores de Coppel. \
        Eres empático, cálido y cercano. Hablas en español mexicano. \
        Usas "tú" siempre, nunca "el usuario". Sin jerga clínica. \
        Perfil del colaborador con quien hablas:\n\(userProfileContext)
        """
    }

    private var chatSystemPrompt: String {
        """
        Eres Nubi, psicólogo de bienestar de Coppel. Empático, cálido, español mexicano. \
        Respuestas de 2-4 oraciones. Termina siempre con una pregunta de apoyo o micro-acción. \
        Nunca minimices lo que siente el usuario. \
        Si detectas señales de crisis severa, pídele que use el botón SOS de la app. \
        Perfil del colaborador:\n\(userProfileContext)
        """
    }

    // MARK: - Action Plan Extractor
    private func extractActionPlan(from text: String) -> [String] {
        let lines = text.components(separatedBy: "\n")
        var tasks: [String] = []
        for line in lines {
            let t = line.trimmingCharacters(in: .whitespaces)
            for prefix in ["1. ", "2. ", "3. "] {
                if t.hasPrefix(prefix) {
                    let clean = String(t.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
                    if !clean.isEmpty { tasks.append(clean) }
                }
            }
            // También detecta "- " y "• "
            if (t.hasPrefix("- ") || t.hasPrefix("• ")) && tasks.count < 3 {
                let clean = String(t.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                if !clean.isEmpty { tasks.append(clean) }
            }
        }
        return tasks.isEmpty ? fallbackActionPlan : Array(tasks.prefix(3))
    }

    // MARK: - Fallbacks
    private var fallbackReport: String {
        """
        🌤️ **Cómo estuvo tu semana**
        Nubi estuvo contigo en cada momento, aunque hoy tiene problemas de conexión. \
        Tus registros están guardados de forma segura y te esperan para la próxima vez.

        💡 **Lo que detecté en ti**
        • Tu constancia al registrar emociones es autoconocimiento valioso.
        • Esta semana hiciste algo importante: te detuviste a observar cómo te sientes.
        • Eso ya es un gran paso hacia el bienestar.

        🌱 **Tu plan para este fin de semana**
        1. Camina 10 minutos sin celular, solo escucha el ambiente
        2. Escribe una cosa buena que ocurrió esta semana
        3. Duerme a la misma hora dos noches seguidas
        """
    }

    private var fallbackActionPlan: [String] {
        [
            "Camina 10 minutos sin celular",
            "Escribe una cosa buena de la semana",
            "Duerme a la misma hora dos noches"
        ]
    }

    // MARK: - Game result saving
    func saveGameResult(name: String, score: Int, insight: String) {
        let result = GameResult(date: Date(), gameName: name, score: score, insight: insight)
        gameResults.append(result)
    }

    // MARK: - Persistence
    func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
        saveProfile()
    }

    private func saveProfile() {
        let profile: [String: Any] = [
            "userName":     userName,
            "userAge":      userAge,
            "userGender":   userGender,
            "cycleSync":    cycleSyncEnabled,
            "position":     userPosition.rawValue,
            "stressors":    workStressors.map { $0.rawValue },
            "familyRole":   familyRole.rawValue
        ]
        if let data = try? JSONSerialization.data(withJSONObject: profile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(emotionHistory) {
            UserDefaults.standard.set(encoded, forKey: emotionHistoryKey)
        }
    }

    private func loadData() {
        isOnboardingComplete = UserDefaults.standard.bool(forKey: onboardingKey)

        // Load profile
        if let data    = UserDefaults.standard.data(forKey: profileKey),
           let profile = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            userName    = profile["userName"]   as? String ?? ""
            userAge     = profile["userAge"]    as? String ?? ""
            userGender  = profile["userGender"] as? String ?? ""
            cycleSyncEnabled = profile["cycleSync"] as? Bool ?? false
            if let pos  = profile["position"]   as? String,
               let wp   = WorkPosition(rawValue: pos) { userPosition = wp }
            if let strs = profile["stressors"]  as? [String] {
                workStressors = Set(strs.compactMap { WorkStressor(rawValue: $0) })
            }
            if let fr   = profile["familyRole"] as? String,
               let role = FamilyRole(rawValue: fr) { familyRole = role }
        }

        // Load emotion history
        if let data    = UserDefaults.standard.data(forKey: emotionHistoryKey),
           let decoded = try? JSONDecoder().decode([EmotionEntry].self, from: data) {
            emotionHistory = decoded
            todayEmotion   = decoded.last(where: { Calendar.current.isDateInToday($0.date) })
            if let last    = todayEmotion { nubiColor = Color(hex: last.nubiColor) }
        }
    }
}

// MARK: - Custom Error
enum NubiAPIError: LocalizedError {
    case httpError(Int, String)
    var errorDescription: String? {
        if case .httpError(let code, let msg) = self { return "Error \(code): \(msg)" }
        return nil
    }
}
