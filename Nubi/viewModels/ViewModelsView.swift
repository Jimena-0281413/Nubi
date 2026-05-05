//
//  ViewModelsView.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 05/05/26.
//
import SwiftUI
import Combine

@MainActor
class AppViewModel: ObservableObject {

    // MARK: - Onboarding state
    @Published var isOnboardingComplete: Bool = false
    @Published var userName: String = ""
    @Published var userAge: String = ""
    @Published var userPosition: WorkPosition = .pisoVenta
    @Published var userGender: String = "" // "hombre", "mujer", "otro"
    @Published var cycleSyncEnabled: Bool = false

    // MARK: - Emotion state
    @Published var todayEmotion: EmotionEntry? = nil
    @Published var emotionHistory: [EmotionEntry] = []
    @Published var nubiColor: Color = Color.nubiLightBlue

    // MARK: - Report state
    @Published var weeklyReport: String = ""
    @Published var isGeneratingReport: Bool = false
    @Published var actionPlan: [String] = []

    // MARK: - Games state
    @Published var gameResults: [GameResult] = []

    // MARK: - SOS
    @Published var showSOSAlert: Bool = false

    // MARK: - Groq API Key
    // ⚠️ IMPORTANTE: Reemplaza con tu key real de https://console.groq.com
    private let groqAPIKey = "YOUR_GROQ_API_KEY_HERE"
    private let groqModel  = "llama3-8b-8192"

    // MARK: - Persistence keys
    private let emotionHistoryKey = "emotionHistory"
    private let onboardingKey     = "onboardingComplete"

    init() {
        loadData()
    }

    // MARK: - Emotion Registration
    func registerEmotion(primary: PrimaryEmotion, sub: SubEmotion) {
        let entry = EmotionEntry(primary: primary, sub: sub)
        todayEmotion = entry
        emotionHistory.append(entry)
        nubiColor = primary.color
        saveData()
    }

    // MARK: - Weekly Report via Groq
    func generateWeeklyReport() async {
        isGeneratingReport = true
        let last7 = emotionHistory.suffix(14)
        let emotionSummary = last7.map { "\($0.primaryEmotion) - \($0.subEmotion)" }.joined(separator: ", ")
        let gameSummary = gameResults.suffix(5).map { "\($0.gameName): \($0.insight)" }.joined(separator: ". ")

        let prompt = """
        Eres un psicólogo empático especializado en bienestar laboral. Analiza los siguientes datos emocionales de un colaborador de Coppel y genera un reporte semanal cálido, empático y accionable en español.

        Datos emocionales de la semana: \(emotionSummary.isEmpty ? "Sin registros esta semana" : emotionSummary)
        Puesto: \(userPosition.rawValue)
        \(gameSummary.isEmpty ? "" : "Resultados de juegos de bienestar: \(gameSummary)")

        El reporte debe tener:
        1. Un párrafo de resumen empático de cómo fue la semana (2-3 oraciones, usa "tu" no "el usuario")
        2. Una sección "💡 Lo que detecté" con 2-3 observaciones clave
        3. Una sección "🌱 Tu plan de fin de semana" con exactamente 3 micro-tareas específicas y alcanzables

        Tono: cálido, sin jerga clínica, como si fuera un amigo psicólogo. Máximo 200 palabras.
        """

        do {
            let result = try await callGroqAPI(prompt: prompt)
            self.weeklyReport = result
            self.actionPlan = extractActionPlan(from: result)
        } catch {
            self.weeklyReport = "Esta semana tu avatar Nubi estuvo contigo en cada momento. Para ver tu reporte completo, asegúrate de tener conexión a internet. 💙"
        }
        isGeneratingReport = false
    }

    // MARK: - Groq API Call
    func callGroqAPI(prompt: String) async throws -> String {
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(groqAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": groqModel,
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 500,
            "temperature": 0.7
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        throw URLError(.cannotParseResponse)
    }

    private func extractActionPlan(from text: String) -> [String] {
        // Simple extraction of lines that look like tasks
        let lines = text.components(separatedBy: "\n")
        var tasks: [String] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("• ") || trimmed.hasPrefix("1.") || trimmed.hasPrefix("2.") || trimmed.hasPrefix("3.") {
                let clean = trimmed.dropFirst(2).trimmingCharacters(in: .whitespaces)
                if !clean.isEmpty { tasks.append(String(clean)) }
            }
        }
        return tasks.isEmpty ? ["Camina 10 minutos sin celular 🚶", "Escucha música que te alegre 🎵", "Duerme 8 horas esta noche 🌙"] : Array(tasks.prefix(3))
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
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(emotionHistory) {
            UserDefaults.standard.set(encoded, forKey: emotionHistoryKey)
        }
    }

    private func loadData() {
        isOnboardingComplete = UserDefaults.standard.bool(forKey: onboardingKey)
        if let data = UserDefaults.standard.data(forKey: emotionHistoryKey),
           let decoded = try? JSONDecoder().decode([EmotionEntry].self, from: data) {
            emotionHistory = decoded
            todayEmotion = decoded.last(where: { Calendar.current.isDateInToday($0.date) })
            if let last = todayEmotion {
                nubiColor = Color(hex: last.nubiColor)
            }
        }
    }
}
