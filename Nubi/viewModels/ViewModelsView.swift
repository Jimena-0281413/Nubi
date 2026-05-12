//
//  ViewModelsView.swift
//  Nubi
//
import SwiftUI
import Combine
import AVFoundation
import Speech

@MainActor
class AppViewModel: ObservableObject {
    // MARK: - Voice Synthesizer
    private let speechSynthesizer = AVSpeechSynthesizer()

    func speak(text: String) {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX")
        utterance.rate = 0.52
        utterance.pitchMultiplier = 0.95
        speechSynthesizer.speak(utterance)
    }

    // MARK: - Speech to Text
    @Published var isRecording: Bool = false
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-MX"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func toggleRecording(onTextChanged: @escaping (String) -> Void) {
        if audioEngine.isRunning {
            stopRecording()
            return
        }
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.startRecording(onTextChanged: onTextChanged)
                }
            }
        }
    }

    private func startRecording(onTextChanged: @escaping (String) -> Void) {
        isRecording = true
        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else { return }
        request.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                onTextChanged(result.bestTranscription.formattedString)
            }
            if error != nil || result?.isFinal == true {
                self.stopRecording()
            }
        }
    }

    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
        }
        isRecording = false
    }

    // MARK: - Onboarding
    @Published var isOnboardingComplete: Bool = false

    // Coppel info (NUEVO)
    @Published var workerNumber: String = ""
    @Published var cediOrStore : String = ""
    @Published var transportType: TransportType = .publico

    // Profile
    @Published var userName: String = ""
    @Published var userAge: String = ""
    @Published var userPosition: WorkPosition = .pisoVenta
    @Published var userGender: String = ""
    @Published var cycleSyncEnabled: Bool = false
    @Published var workStressors: Set<WorkStressor> = []
    @Published var familyRole: FamilyRole = .otro

    // MARK: - Emotion state
    @Published var todayEmotion: EmotionEntry? = nil
    @Published var emotionHistory: [EmotionEntry] = []
    @Published var nubiColor: Color = Color.coppelButton

    // MARK: - Report
    @Published var weeklyReport: String = ""
    @Published var isGeneratingReport: Bool = false
    @Published var actionPlan: [String] = []

    // MARK: - Games (con sistema de puntos / ranking)
    @Published var gameResults: [GameResult] = []
    @Published var gamePoints: Int = 0
    @Published var userRanking: Int = 47   // Ranking inicial dummy (mejorará al jugar)

    // MARK: - SOS
    @Published var showSOSAlert: Bool = false

    // MARK: - Groq API Key
    private let groqAPIKey = ""
    private let groqModel  = "llama-3.1-8b-instant"

    // MARK: - Persistence keys
    private let emotionHistoryKey = "emotionHistory"
    private let onboardingKey     = "onboardingComplete_v3"
    private let profileKey        = "userProfile_v3"
    private let gameKey           = "gameProgress"

    init() {
        loadData()
    }

    // MARK: - User context for AI prompts
    var userProfileContext: String {
        let stressors = workStressors.isEmpty ? "no especificados" : workStressors.map { $0.rawValue }.joined(separator: ", ")
        let cycleInfo = (userGender == "mujer" && cycleSyncEnabled) ? " — sincronización con ciclo activada" : ""
        return """
        Nombre: \(userName.isEmpty ? "no proporcionado" : userName) | Edad: \(userAge.isEmpty ? "n/d" : userAge) | Género: \(userGender.isEmpty ? "no especificado" : userGender)\(cycleInfo) | Puesto: \(userPosition.rawValue) | CEDI/Tienda: \(cediOrStore.isEmpty ? "n/d" : cediOrStore) | Estresores principales: \(stressors) | Rol familiar: \(familyRole.rawValue) | Transporte: \(transportType.rawValue)
        """
    }

    // MARK: - Emotion
    func registerEmotion(primary: PrimaryEmotion, sub: SubEmotion) {
        let entry = EmotionEntry(primary: primary, sub: sub)
        todayEmotion = entry
        emotionHistory.append(entry)
        nubiColor = primary.color
        saveData()
    }

    // MARK: - Game points
    func saveGameResult(name: String, score: Int, insight: String) {
        let result = GameResult(date: Date(), gameName: name, score: score, insight: insight)
        gameResults.append(result)
        gamePoints += score
        // Bajar el ranking conforme suben los puntos (mejor posición)
        let newRank = max(1, 50 - gamePoints / 25)
        userRanking = newRank
        saveData()
    }

    // MARK: - Weekly Report
    func generateWeeklyReport() async {
        isGeneratingReport = true
        let last7 = emotionHistory.suffix(14)
        let emotionSummary = last7.map { "\($0.primaryEmotion) (\($0.subEmotion))" }.joined(separator: ", ")
        let gameSummary = gameResults.suffix(5).map { "\($0.gameName): \($0.insight)" }.joined(separator: ". ")

        let systemPrompt = """
        Eres Nubi, psicólogo empático especializado en bienestar laboral en Coppel. Hablas en español mexicano, con tono cálido, sin jerga clínica. Usas "tú". Si la persona es mamá o tiene el ciclo sincronizado, considera carga emocional adicional. Máximo 220 palabras.
        """

        let userPrompt = """
        PERFIL DEL COLABORADOR:
        \(userProfileContext)

        DATOS EMOCIONALES DE LA SEMANA:
        \(emotionSummary.isEmpty ? "Sin registros esta semana" : emotionSummary)

        \(gameSummary.isEmpty ? "" : "JUEGOS DE BIENESTAR: \(gameSummary)")

        Genera un reporte semanal con:
        1) Un párrafo de resumen empático de la semana (2-3 oraciones).
        2) Sección "Lo que detecté:" con 2-3 observaciones clave.
        3) Sección "Tu plan de fin de semana:" con exactamente 3 micro-tareas concretas.
        """

        do {
            let result = try await callGroqAPI(systemPrompt: systemPrompt, userPrompt: userPrompt)
            self.weeklyReport = result
            self.actionPlan = extractActionPlan(from: result)
        } catch {
            self.weeklyReport = "Esta semana Nubi estuvo contigo en cada momento. Para ver tu reporte completo, asegúrate de tener conexión a internet."
            self.actionPlan = ["Camina 10 minutos sin celular", "Escucha música que te alegre", "Duerme 8 horas esta noche"]
        }
        isGeneratingReport = false
    }

    // MARK: - Groq API (single-turn con system + user)
    func callGroqAPI(systemPrompt: String, userPrompt: String) async throws -> String {
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(groqAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": groqModel,
            "messages": [
                ["role": "system",  "content": systemPrompt],
                ["role": "user",    "content": userPrompt]
            ],
            "max_tokens": 600,
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

    /// Backward-compat single-prompt
    func callGroqAPI(prompt: String) async throws -> String {
        try await callGroqAPI(systemPrompt: "Eres Nubi, un asistente de bienestar empático.", userPrompt: prompt)
    }

    /// Multi-turn with full conversation history
    func callGroqAPIWithHistory(messages: [[String: Any]], systemPrompt: String) async throws -> String {
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(groqAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var fullMessages: [[String: Any]] = [["role": "system", "content": systemPrompt]]
        fullMessages.append(contentsOf: messages)

        let body: [String: Any] = [
            "model": groqModel,
            "messages": fullMessages,
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
        let lines = text.components(separatedBy: "\n")
        var tasks: [String] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("- ") || trimmed.hasPrefix("• ") || trimmed.hasPrefix("1.") || trimmed.hasPrefix("2.") || trimmed.hasPrefix("3.") {
                let clean = trimmed.dropFirst(2).trimmingCharacters(in: .whitespaces)
                if !clean.isEmpty { tasks.append(String(clean)) }
            }
        }
        return tasks.isEmpty ? ["Camina 10 minutos sin celular", "Escucha música que te alegre", "Duerme 8 horas esta noche"] : Array(tasks.prefix(3))
    }

    // MARK: - Persistence
    func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
        saveData()
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(emotionHistory) {
            UserDefaults.standard.set(encoded, forKey: emotionHistoryKey)
        }

        let profile: [String: Any] = [
            "workerNumber": workerNumber,
            "cediOrStore": cediOrStore,
            "transportType": transportType.rawValue,
            "userName": userName,
            "userAge": userAge,
            "userPosition": userPosition.rawValue,
            "userGender": userGender,
            "cycleSyncEnabled": cycleSyncEnabled,
            "workStressors": Array(workStressors).map { $0.rawValue },
            "familyRole": familyRole.rawValue,
            "gamePoints": gamePoints,
            "userRanking": userRanking
        ]
        UserDefaults.standard.set(profile, forKey: profileKey)
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

        if let profile = UserDefaults.standard.dictionary(forKey: profileKey) {
            workerNumber = profile["workerNumber"] as? String ?? ""
            cediOrStore  = profile["cediOrStore"]  as? String ?? ""
            if let tRaw  = profile["transportType"] as? String,
               let t     = TransportType(rawValue: tRaw) { transportType = t }
            userName     = profile["userName"] as? String ?? ""
            userAge      = profile["userAge"]  as? String ?? ""
            if let pRaw  = profile["userPosition"] as? String,
               let p     = WorkPosition(rawValue: pRaw)  { userPosition = p }
            userGender   = profile["userGender"] as? String ?? ""
            cycleSyncEnabled = profile["cycleSyncEnabled"] as? Bool ?? false
            if let arr   = profile["workStressors"] as? [String] {
                workStressors = Set(arr.compactMap { WorkStressor(rawValue: $0) })
            }
            if let fRaw  = profile["familyRole"] as? String,
               let f     = FamilyRole(rawValue: fRaw)    { familyRole = f }
            gamePoints   = profile["gamePoints"] as? Int ?? 0
            userRanking  = profile["userRanking"] as? Int ?? 47
        }
    }
}
