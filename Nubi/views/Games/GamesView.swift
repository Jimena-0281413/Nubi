//
//  GamesView.swift
//  Nubi
//
//  Created by Jimena Rodriguez on 05/05/26.
//


import SwiftUI

// MARK: - Games Hub
struct GamesView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedGame: GameType? = nil

    enum GameType: String, CaseIterable {
        case stroop    = "Orden en el Almacén"
        case balloon   = "Globos de Energía"
        case search    = "Búsqueda de Tesoros"
        case goNoGo    = "¡Cuidado con la Cafetera!"
        case balance   = "Equilibrio en la Cuerda"
        case memory    = "El Elevador Descompuesto"

        var sfSymbol: String {
            switch self {
            case .stroop:  return "shippingbox.fill"
            case .balloon: return "balloon.fill"
            case .search:  return "magnifyingglass.circle.fill"
            case .goNoGo:  return "cup.and.saucer.fill"
            case .balance: return "figure.stand"
            case .memory:  return "elevator"
            }
        }
        var description: String {
            switch self {
            case .stroop:  return "Mide tu fatiga mental"
            case .balloon: return "Mide tu nivel de ansiedad"
            case .search:  return "Mide tu atención sostenida"
            case .goNoGo:  return "Mide tu control de impulsos"
            case .balance: return "Mide tu estabilidad emocional"
            case .memory:  return "Mide tu memoria de trabajo"
            }
        }
        var color: Color {
            switch self {
            case .stroop:  return Color(hex: "#5C7B99")
            case .balloon: return Color(hex: "#EF476F")
            case .search:  return Color(hex: "#06D6A0")
            case .goNoGo:  return Color(hex: "#F4A261")
            case .balance: return Color(hex: "#9B59B6")
            case .memory:  return Color(hex: "#2196F3")
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.nubiParchment.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Info card
                        HStack(spacing: 12) {
                            NubiAvatarView(color: .nubiGlaucous, size: 50)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Zona de Descompresión")
                                    .font(NubiFont.subheading).foregroundColor(.nubiDark)
                                Text("Juega durante tu descanso. Los resultados enriquecen tu reporte de bienestar.")
                                    .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.6))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(16)
                        .nubiCard()
                        .padding(.horizontal, 20)

                        // Game Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            ForEach(GameType.allCases, id: \.self) { game in
                                Button { selectedGame = game } label: {
                                    gameCard(game: game)
                                }
                                .buttonStyle(BounceButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)

                        // Recent scores
                        if !vm.gameResults.isEmpty {
                            recentScores
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Juegos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "gamecontroller.fill")
                        .foregroundColor(.nubiGlaucous)
                }
            }
            .fullScreenCover(item: $selectedGame) { game in
                gameScreen(for: game)
                    .environmentObject(vm)
            }
        }
    }

    private func gameCard(game: GameType) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().fill(game.color.opacity(0.15)).frame(width: 60, height: 60)
                Image(systemName: game.sfSymbol)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(game.color)
            }
            Text(game.rawValue)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.nubiDark)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text(game.description)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.nubiDark.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 10)
        .background(Color.white.opacity(0.85))
        .cornerRadius(20)
        .shadow(color: game.color.opacity(0.15), radius: 8)
    }

    var recentScores: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tus últimos resultados")
                .font(NubiFont.subheading).foregroundColor(.nubiDark)
            ForEach(vm.gameResults.suffix(3).reversed()) { result in
                HStack {
                    Text(result.gameName).font(NubiFont.body).foregroundColor(.nubiDark)
                    Spacer()
                    Text("Puntos: \(result.score)").font(NubiFont.caption).foregroundColor(.nubiGlaucous)
                }
                .padding(12)
                .background(Color.nubiParchment)
                .cornerRadius(12)
            }
        }
        .padding(16)
        .nubiCard()
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func gameScreen(for game: GameType) -> some View {
        switch game {
        case .stroop:   StroopGameView()
        case .balloon:  BalloonGameView()
        case .search:   SearchGameView()
        case .goNoGo:   GoNoGoGameView()
        case .balance:  BalanceGameView()
        case .memory:   MemoryGameView()
        }
    }
}

extension GamesView.GameType: Identifiable { var id: String { rawValue } }

// MARK: - Base Game Container
struct GameContainer<Content: View>: View {
    let title: String
    let emoji: String
    let color: Color
    let insight: String
    @ViewBuilder let content: Content
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(colors: [color.opacity(0.15), Color.nubiParchment],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(color.opacity(0.7))
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: emoji)
                            .font(NubiFont.subheading)
                            .foregroundColor(color)
                        Text(title)
                            .font(NubiFont.subheading).foregroundColor(.nubiDark)
                    }
                    Spacer()
                    Color.clear.frame(width: 28, height: 28)
                }
                .padding(16)

                content
            }
        }
    }
}

// MARK: - GAME 1: Stroop Test
struct StroopGameView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    let colorWords = [("ROJO", Color.red), ("AZUL", Color.blue), ("VERDE", Color.green), ("AMARILLO", Color.yellow)]
    @State private var wordText = "AZUL"
    @State private var inkColor: Color = .red
    @State private var score = 0
    @State private var timeLeft = 30
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var showNubiMessage = false
    @State private var nubiMessage = ""
    @State private var timer: Timer? = nil

    var body: some View {
        GameContainer(title: "Orden en el Almacén", emoji: "shippingbox.fill", color: .nubiGlaucous, insight: "") {
            VStack(spacing: 24) {
                if !gameStarted {
                    startScreen
                } else if gameOver {
                    resultScreen
                } else {
                    gameScreen
                }
            }
            .padding(20)
        }
    }

    var startScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 72))
                .foregroundColor(.nubiGlaucous)
            Text("Toca el COLOR de la caja, ¡no leas la palabra!")
                .font(NubiFont.subheading).foregroundColor(.nubiDark).multilineTextAlignment(.center)
            Text("Ejemplo: si ves la palabra 'AZUL' en color ROJO → toca ROJO")
                .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.6)).multilineTextAlignment(.center)
            Button { startGame() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                    Text("¡Empezar!")
                }
                .nubiButton()
            }
        }
    }

    var gameScreen: some View {
        VStack(spacing: 28) {
            HStack {
                Label("\(score)", systemImage: "star.fill").foregroundColor(.nubiGlaucous).font(NubiFont.heading)
                Spacer()
                Label("\(timeLeft)s", systemImage: "timer").foregroundColor(timeLeft < 10 ? .red : .nubiDark).font(NubiFont.subheading)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .frame(height: 130)
                    .shadow(color: inkColor.opacity(0.3), radius: 12)
                Text(wordText)
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundColor(inkColor)
            }

            Text("¿De qué COLOR es el texto?").font(NubiFont.body).foregroundColor(.nubiDark)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(colorWords, id: \.0) { pair in
                    Button {
                        checkAnswer(tapped: pair.1)
                    } label: {
                        Text(pair.0)
                            .font(NubiFont.subheading)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(pair.1)
                            .cornerRadius(16)
                    }
                    .buttonStyle(BounceButtonStyle())
                }
            }

            if showNubiMessage {
                Text(nubiMessage).font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
        }
    }

    var resultScreen: some View {
        VStack(spacing: 20) {
            let insight = score >= 10 ? "¡Excelente agilidad cognitiva hoy! Tu mente está muy clara." :
                          score >= 5  ? "Buen trabajo. Tu mente tuvo algunos cruces de cables, ¡normal!" :
                                        "Hoy los cables se cruzan un poco. Nubi sugiere un respiro de 1 minuto."
            NubiAvatarView(color: score >= 10 ? Color(hex: "#FFD166") : .nubiGlaucous, size: 80)
            Text("¡Tiempo!")
                .font(NubiFont.heading).foregroundColor(.nubiDark)
            Text("Puntuación: \(score)")
                .font(.system(size: 48, weight: .black, design: .rounded)).foregroundColor(.nubiGlaucous)
            Text(insight)
                .font(NubiFont.body).foregroundColor(.nubiDark).multilineTextAlignment(.center)
            Button {
                vm.saveGameResult(name: "Orden en el Almacén", score: score, insight: insight)
                dismiss()
            } label: { Text("Guardar y salir").nubiButton() }
        }
    }

    private func startGame() {
        gameStarted = true
        timeLeft = 30
        score = 0
        nextRound()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if timeLeft > 0 { timeLeft -= 1 } else { endGame() }
            }
        }
    }

    private func nextRound() {
        wordText = colorWords.randomElement()!.0
        inkColor = colorWords.randomElement()!.1
    }

    private func checkAnswer(tapped: Color) {
        if tapped == inkColor {
            score += 1
            nubiMessage = ["¡Perfecto!", "¡Así!", "¡Excelente!"].randomElement()!
        } else {
            nubiMessage = ["Casi...", "¡Ojo con el color!", "¡No te dejes engañar!"].randomElement()!
        }
        withAnimation { showNubiMessage = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { withAnimation { showNubiMessage = false } }
        nextRound()
    }

    private func endGame() {
        timer?.invalidate()
        gameOver = true
    }
}

// MARK: - GAME 2: Balloon
struct BalloonGameView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    @State private var balloonSize: CGFloat = 60
    @State private var maxSize: CGFloat = CGFloat.random(in: 140...200)
    @State private var score = 0
    @State private var round = 1
    @State private var popped = false
    @State private var saved = false
    @State private var gameOver = false
    @State private var pressing = false

    let maxRounds = 5

    var body: some View {
        GameContainer(title: "Globos de Energía", emoji: "balloon.fill", color: Color(hex: "#EF476F"), insight: "") {
            VStack(spacing: 20) {
                if gameOver {
                    resultScreen
                } else {
                    gameScreen
                }
            }
            .padding(20)
        }
    }

    var gameScreen: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Ronda \(round)/\(maxRounds)").font(NubiFont.subheading).foregroundColor(.nubiDark)
                Spacer()
                Text("Puntos: \(score)").font(NubiFont.subheading).foregroundColor(Color(hex: "#EF476F"))
            }

            Spacer()

            ZStack {
                // Nubi holding string
                VStack(spacing: 0) {
                    ZStack {
                        if popped {
                            Image(systemName: "wind")
                                .font(.system(size: 50))
                                .foregroundColor(.nubiGlaucous)
                        } else {
                            Circle()
                                .fill(LinearGradient(colors: [Color(hex: "#EF476F"), Color(hex: "#FF8BA7")],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: balloonSize, height: balloonSize)
                                .shadow(color: Color(hex: "#EF476F").opacity(0.4), radius: 10)
                            Image(systemName: "balloon.fill")
                                .font(.system(size: balloonSize * 0.4))
                                .foregroundColor(.white)
                        }
                    }
                    Rectangle()
                        .fill(Color.nubiGlaucous.opacity(0.5))
                        .frame(width: 2, height: 60)
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.nubiGlaucous.opacity(0.7))
                }
            }
            .frame(height: 240)

            // Progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8).fill(Color.nubiLightBlue.opacity(0.3)).frame(height: 14)
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [Color(hex: "#EF476F"), Color(hex: "#FFD166")],
                                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(0, (balloonSize - 60) / (maxSize - 60) * (UIScreen.main.bounds.width - 60)), height: 14)
            }
            .animation(.linear(duration: 0.1), value: balloonSize)
            .padding(.horizontal)

            if !popped && !saved {
                VStack(spacing: 12) {
                    Text("Mantén presionado para inflar").font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.6))
                    HStack(spacing: 16) {
                        Button {
                            savePoints()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("Guardar puntos (\(Int((balloonSize - 60) * 1.5)))")
                            }
                            .nubiButton(color: .nubiGlaucous)
                        }
                    }

                    // Inflate button
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "wind")
                            Text("Inflar")
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 120, height: 120)
                        .background(Circle().fill(Color(hex: "#EF476F")))
                        .shadow(color: Color(hex: "#EF476F").opacity(0.4), radius: 12)
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in inflateBalloon() }
                            .onEnded { _ in pressing = false }
                    )
                }
            } else if saved {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.nubiGlaucous)
                    Text("¡Guardaste \(Int((balloonSize-60)*1.5)) puntos!")
                }
                .font(NubiFont.subheading).foregroundColor(.nubiGlaucous)
                Button { nextRound() } label: { Text("Siguiente globo →").nubiButton() }
            } else if popped {
                VStack(spacing: 8) {
                    Text("¡POP! El globo explotó").font(NubiFont.subheading).foregroundColor(.red)
                    Text("Nubi salió volando... ¡pero volvió con paracaídas!")
                        .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.6)).multilineTextAlignment(.center)
                    Button { nextRound() } label: { Text("Siguiente →").nubiButton(color: Color(hex: "#EF476F")) }
                }
            }

            Spacer()
        }
    }

    var resultScreen: some View {
        let insight = score >= 300 ? "Tomaste riesgos calculados. Tu gestión del riesgo es excelente." :
                      score >= 150 ? "Balance saludable entre riesgo y precaución. ¡Bien hecho!" :
                                     "Tendiste a ser muy precavido o muy impulsivo. Nubi sugiere equilibrio."
        return VStack(spacing: 20) {
            NubiAvatarView(color: score >= 200 ? Color(hex: "#FFD166") : .nubiGlaucous, size: 80)
            Text("¡Resultado final!")
                .font(NubiFont.heading).foregroundColor(.nubiDark)
            Text("\(score) puntos")
                .font(.system(size: 48, weight: .black, design: .rounded)).foregroundColor(Color(hex: "#EF476F"))
            Text(insight)
                .font(NubiFont.body).foregroundColor(.nubiDark).multilineTextAlignment(.center)
            Button {
                vm.saveGameResult(name: "Globos de Energía", score: score, insight: insight)
                dismiss()
            } label: { Text("Guardar y salir").nubiButton() }
        }
    }

    private func inflateBalloon() {
        guard !popped && !saved else { return }
        balloonSize += 2
        if balloonSize >= maxSize {
            withAnimation(.spring()) { popped = true }
        }
    }

    private func savePoints() {
        let pts = Int((balloonSize - 60) * 1.5)
        score += pts
        saved = true
    }

    private func nextRound() {
        if round >= maxRounds { gameOver = true; return }
        round += 1
        balloonSize = 60
        maxSize = CGFloat.random(in: 120...220)
        popped = false
        saved = false
    }
}

// MARK: - GAME 3: Visual Search
struct SearchGameView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    let allIcons = ["🧴", "🌳", "👔", "☕", "📱", "🎈", "🔑", "💼", "🎯", "🧢", "👟", "🎁", "📦", "🌮", "💡", "🎵"]
    @State private var targets: [String] = []
    @State private var gridIcons: [String] = []
    @State private var found: [String] = []
    @State private var score = 0
    @State private var round = 1
    @State private var timeLeft = 15
    @State private var gameOver = false
    @State private var timer: Timer? = nil
    @State private var gameStarted = false

    var body: some View {
        GameContainer(title: "Búsqueda de Tesoros", emoji: "magnifyingglass.circle.fill", color: Color(hex: "#06D6A0"), insight: "") {
            VStack(spacing: 16) {
                if !gameStarted { startScreen }
                else if gameOver { resultScreen }
                else { gameScreen }
            }
            .padding(20)
        }
    }

    var startScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(Color(hex: "#06D6A0"))
            Text("Encuentra los 3 objetos objetivo en menos de 15 segundos")
                .font(NubiFont.subheading).foregroundColor(.nubiDark).multilineTextAlignment(.center)
            Button { setupRound(); gameStarted = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                    Text("¡Buscar!")
                }
                .nubiButton(color: Color(hex: "#06D6A0"))
            }
        }
    }

    var gameScreen: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Ronda \(round)/5").font(NubiFont.subheading).foregroundColor(.nubiDark)
                Spacer()
                Label("\(timeLeft)s", systemImage: "timer")
                    .font(NubiFont.subheading)
                    .foregroundColor(timeLeft <= 5 ? .red : Color(hex: "#06D6A0"))
            }

            // Targets
            VStack(spacing: 8) {
                Text("Encuentra:").font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.6))
                HStack(spacing: 20) {
                    ForEach(targets, id: \.self) { t in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(found.contains(t) ? Color(hex: "#06D6A0").opacity(0.3) : Color.white)
                                .frame(width: 54, height: 54)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(found.contains(t) ? Color(hex: "#06D6A0") : Color.nubiGlaucous.opacity(0.3), lineWidth: 2))
                            Text(t).font(.system(size: 28))
                            if found.contains(t) {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(Color(hex: "#06D6A0")).font(.system(size: 20)).offset(x: 18, y: -18)
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(Color.nubiLightBlue.opacity(0.2))
            .cornerRadius(16)

            // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                ForEach(Array(gridIcons.enumerated()), id: \.offset) { idx, icon in
                    Button {
                        tapIcon(icon)
                    } label: {
                        Text(icon)
                            .font(.system(size: 28))
                            .frame(width: 50, height: 50)
                            .background(found.contains(icon) && targets.contains(icon) ? Color(hex: "#06D6A0").opacity(0.25) : Color.white.opacity(0.7))
                            .cornerRadius(10)
                    }
                    .buttonStyle(BounceButtonStyle())
                }
            }
        }
    }

    var resultScreen: some View {
        let insight = score >= 4 ? "¡Atención visual muy aguda! Tu mente está enfocada." :
                      score >= 2 ? "Buena atención. Algunos objetos se escaparon." :
                                   "Tu atención visual puede estar fatigada. Un descanso de pantallas te ayudaría."
        return VStack(spacing: 20) {
            NubiAvatarView(color: score >= 4 ? Color(hex: "#FFD166") : .nubiGlaucous, size: 80)
            Text("Resultado")
                .font(NubiFont.heading).foregroundColor(.nubiDark)
            Text("\(score)/5 rondas completadas")
                .font(.system(size: 40, weight: .black, design: .rounded)).foregroundColor(Color(hex: "#06D6A0"))
            Text(insight).font(NubiFont.body).foregroundColor(.nubiDark).multilineTextAlignment(.center)
            Button {
                vm.saveGameResult(name: "Búsqueda de Tesoros", score: score, insight: insight)
                dismiss()
            } label: { Text("Guardar y salir").nubiButton() }
        }
    }

    private func setupRound() {
        found = []
        targets = Array(allIcons.shuffled().prefix(3))
        var grid = allIcons.shuffled()
        gridIcons = Array(grid.prefix(20))
        // Make sure targets appear
        for t in targets {
            if !gridIcons.contains(t) {
                gridIcons[Int.random(in: 0..<gridIcons.count)] = t
            }
        }
        gridIcons.shuffle()
        timeLeft = 15
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if timeLeft > 0 { timeLeft -= 1 }
                else { nextRound() }
            }
        }
    }

    private func tapIcon(_ icon: String) {
        if targets.contains(icon) && !found.contains(icon) {
            withAnimation(.spring()) { found.append(icon) }
            if found.count == targets.count {
                score += 1
                nextRound()
            }
        }
    }

    private func nextRound() {
        timer?.invalidate()
        if round >= 5 { gameOver = true; return }
        round += 1
        setupRound()
    }
}

// MARK: - GAME 4: Go/No-Go
struct GoNoGoGameView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    let goItems  = ["☕", "🍎", "🍊", "🫖", "🍇"]
    let noItems  = ["⚙️", "⏰", "📧", "🔨", "💢"]
    @State private var currentItem = "☕"
    @State private var isGo = true
    @State private var score = 0
    @State private var misses = 0
    @State private var round = 0
    @State private var gameOver = false
    @State private var nubiState: NubiState = .normal
    @State private var showItem = false

    enum NubiState { case normal, happy, shocked, burnt }

    var body: some View {
        GameContainer(title: "¡Cuidado con la Cafetera!", emoji: "cup.and.saucer.fill", color: Color(hex: "#F4A261"), insight: "") {
            VStack(spacing: 20) {
                if round == 0 && !gameOver { startScreen }
                else if gameOver { resultScreen }
                else { gameScreen }
            }
            .padding(20)
        }
    }

    var startScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 72))
                .foregroundColor(Color(hex: "#F4A261"))
            Text("Toca si pasa una cafetera o fruta\n¡NO toques si pasa una herramienta o un email!")
                .font(NubiFont.subheading).foregroundColor(.nubiDark).multilineTextAlignment(.center)
            Button { nextItem() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                    Text("¡Empezar!")
                }
                .nubiButton(color: Color(hex: "#F4A261"))
            }
        }
    }

    var gameScreen: some View {
        VStack(spacing: 24) {
            HStack {
                Label("\(score)", systemImage: "star.fill").foregroundColor(Color(hex: "#F4A261")).font(NubiFont.heading)
                Spacer()
                Label("\(misses) errores", systemImage: "xmark.circle").foregroundColor(.red).font(NubiFont.body)
                Spacer()
                Text("\(round)/15").font(NubiFont.body).foregroundColor(.nubiDark)
            }

            // Conveyor belt
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.nubiLightBlue.opacity(0.3))
                    .frame(height: 100)
                if showItem {
                    Text(currentItem).font(.system(size: 56)).transition(.move(edge: .leading))
                }
            }

            Text(isGo ? "¡TOCA!" : "¡NO toques!")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(isGo ? Color(hex: "#06D6A0") : .red)

            // Nubi
            ZStack {
                switch nubiState {
                case .normal:  NubiAvatarView(color: .nubiGlaucous, size: 80)
                case .happy:   NubiAvatarView(color: Color(hex: "#FFD166"), size: 80)
                case .shocked: NubiAvatarView(color: Color(hex: "#9B59B6"), size: 80)
                case .burnt:   NubiAvatarView(color: Color(hex: "#EF476F"), size: 80)
                }
            }
            .animation(.spring(), value: nubiState)

            // Tap zone
            Button { handleTap() } label: {
                Text("ATRAPAR")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color(hex: "#F4A261"))
                    .cornerRadius(20)
                    .shadow(color: Color(hex: "#F4A261").opacity(0.4), radius: 10)
            }
            .buttonStyle(BounceButtonStyle())
        }
    }

    var resultScreen: some View {
        let insight = misses <= 2 ? "¡Excelente control de impulsos! Tu atención selectiva es muy buena." :
                      misses <= 5 ? "Buen intento. Algunos distractores te engañaron." :
                                    "El estrés elevado activa respuestas impulsivas. Nubi te recomienda un respiro."
        return VStack(spacing: 20) {
            NubiAvatarView(color: misses <= 2 ? Color(hex: "#FFD166") : .nubiGlaucous, size: 80)
            Text("¡Fin del turno!")
                .font(NubiFont.heading).foregroundColor(.nubiDark)
            Text("Puntos: \(score) · Errores: \(misses)")
                .font(.system(size: 32, weight: .black, design: .rounded)).foregroundColor(Color(hex: "#F4A261"))
            Text(insight).font(NubiFont.body).foregroundColor(.nubiDark).multilineTextAlignment(.center)
            Button {
                vm.saveGameResult(name: "Cuidado con la Cafetera", score: score, insight: insight)
                dismiss()
            } label: { Text("Guardar y salir").nubiButton() }
        }
    }

    private func nextItem() {
        if round >= 15 { gameOver = true; return }
        round += 1
        isGo = Bool.random() || Bool.random() // 75% go
        currentItem = isGo ? goItems.randomElement()! : noItems.randomElement()!
        withAnimation(.spring()) { showItem = true }
        nubiState = .normal
        // Auto-miss if not tapped (for Go items)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if showItem && isGo { // missed
                misses += 1
                withAnimation { nubiState = .shocked }
            }
            withAnimation { showItem = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { nextItem() }
        }
    }

    private func handleTap() {
        guard showItem else { return }
        showItem = false
        if isGo {
            score += 1
            withAnimation { nubiState = .happy }
        } else {
            misses += 1
            withAnimation { nubiState = .burnt }
        }
    }
}

// MARK: - GAME 5: Balance (Simplified without gyroscope for simulator)
struct BalanceGameView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    @State private var balance: Double = 0 // -1 to 1
    @State private var timeLeft = 20
    @State private var score = 0
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var timer: Timer? = nil
    @State private var distractors: [String] = []
    @State private var showDistractor = false

    var body: some View {
        GameContainer(title: "Equilibrio en la Cuerda", emoji: "figure.stand", color: Color(hex: "#9B59B6"), insight: "") {
            VStack(spacing: 20) {
                if !gameStarted { startScreen }
                else if gameOver { resultScreen }
                else { gameScreen }
            }
            .padding(20)
        }
    }

    var startScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.stand")
                .font(.system(size: 72))
                .foregroundColor(Color(hex: "#9B59B6"))
            Text("Mantén a Nubi equilibrado en la cuerda.\nUsa los botones ← → para balancearte.")
                .font(NubiFont.subheading).foregroundColor(.nubiDark).multilineTextAlignment(.center)
            Button { startGame() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                    Text("¡Equilibrar!")
                }
                .nubiButton(color: Color(hex: "#9B59B6"))
            }
        }
    }

    var gameScreen: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Equilibrio").font(NubiFont.subheading).foregroundColor(.nubiDark)
                Spacer()
                Label("\(timeLeft)s", systemImage: "timer")
                    .font(NubiFont.subheading).foregroundColor(timeLeft <= 5 ? .red : Color(hex: "#9B59B6"))
                Spacer()
                Label("\(score)", systemImage: "sparkles")
                    .font(NubiFont.subheading).foregroundColor(Color(hex: "#9B59B6"))
            }

            // Balance indicator
            ZStack(alignment: .leading) {
                Capsule().fill(Color.nubiLightBlue.opacity(0.4)).frame(height: 20)
                Capsule().fill(abs(balance) < 0.3 ? Color(hex: "#06D6A0") : Color(hex: "#EF476F"))
                    .frame(width: 20, height: 20)
                    .offset(x: (balance + 1) / 2 * (UIScreen.main.bounds.width - 80))
                    .animation(.spring(response: 0.3), value: balance)
            }
            .padding(.horizontal)

            // Rope + Nubi
            ZStack {
                Rectangle().fill(Color.nubiGlaucous.opacity(0.4)).frame(maxWidth: .infinity).frame(height: 4)
                VStack(spacing: 0) {
                    NubiAvatarView(color: abs(balance) < 0.3 ? Color(hex: "#9B59B6") : Color(hex: "#EF476F"), size: 80)
                        .rotationEffect(.degrees(balance * 20))
                        .offset(x: balance * 30)
                    HStack(spacing: 4) {
                        Image(systemName: "shippingbox.fill")
                        Image(systemName: "shippingbox.fill")
                        Image(systemName: "shippingbox.fill")
                    }
                    .font(.system(size: 20))
                    .foregroundColor(.nubiGlaucous.opacity(0.6))
                }
            }
            .frame(height: 160)

            if showDistractor {
                HStack(spacing: 8) {
                    ForEach(["star.fill", "bolt.fill", "sparkles"].shuffled().prefix(2), id: \.self) { sym in
                        Image(systemName: sym)
                            .font(.system(size: 32))
                            .foregroundColor(.nubiGlaucous.opacity(0.7))
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }

            Text(abs(balance) < 0.2 ? "¡Perfecto!" : abs(balance) < 0.5 ? "¡Casi!" : "¡Cuidado!")
                .font(NubiFont.subheading).foregroundColor(.nubiDark)

            HStack(spacing: 40) {
                Button { adjustBalance(-0.15) } label: {
                    Text("← Izquierda")
                        .nubiButton(color: Color(hex: "#9B59B6"))
                }
                Button { adjustBalance(0.15) } label: {
                    Text("Derecha →")
                        .nubiButton(color: Color(hex: "#9B59B6"))
                }
            }
        }
    }

    var resultScreen: some View {
        let insight = score >= 15 ? "¡Excelente estabilidad! Tu sistema nervioso está muy equilibrado." :
                      score >= 8  ? "Buen equilibrio con algunas oscilaciones. Normal en días de trabajo." :
                                    "Tu equilibrio muestra signos de fatiga en el sistema nervioso. Nubi sugiere un descanso activo."
        return VStack(spacing: 20) {
            NubiAvatarView(color: score >= 15 ? Color(hex: "#9B59B6") : .nubiGlaucous, size: 80)
            Text("¡Ejercicio completado!")
                .font(NubiFont.heading).foregroundColor(.nubiDark)
            Text("\(score) segundos en equilibrio")
                .font(.system(size: 40, weight: .black, design: .rounded)).foregroundColor(Color(hex: "#9B59B6"))
            Text(insight).font(NubiFont.body).foregroundColor(.nubiDark).multilineTextAlignment(.center)
            Button {
                vm.saveGameResult(name: "Equilibrio en la Cuerda", score: score, insight: insight)
                dismiss()
            } label: { Text("Guardar y salir").nubiButton() }
        }
    }

    private func startGame() {
        gameStarted = true
        balance = 0
        score = 0
        timeLeft = 20
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if timeLeft > 0 {
                    timeLeft -= 1
                    if abs(balance) < 0.4 { score += 1 }
                    // Random distractor
                    if Int.random(in: 0...4) == 0 {
                        withAnimation { showDistractor = true }
                        balance += Double.random(in: -0.2...0.2)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { withAnimation { showDistractor = false } }
                    }
                } else {
                    timer?.invalidate()
                    gameOver = true
                }
            }
        }
    }

    private func adjustBalance(_ delta: Double) {
        balance = max(-1, min(1, balance + delta))
    }
}

// MARK: - GAME 6: Memory (Elevator)
struct MemoryGameView: View {
    @EnvironmentObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss

    @State private var sequence: [Int] = []
    @State private var userSequence: [Int] = []
    @State private var highlighting: Int? = nil
    @State private var phase: Phase = .showing
    @State private var score = 0
    @State private var gameOver = false
    @State private var level = 1
    @State private var nubiFlying = false

    enum Phase { case showing, input, correct, wrong }

    var body: some View {
        GameContainer(title: "El Elevador Descompuesto", emoji: "elevator", color: Color(hex: "#2196F3"), insight: "") {
            VStack(spacing: 20) {
                if gameOver { resultScreen }
                else { gameScreen }
            }
            .padding(20)
            .onAppear { newRound() }
        }
    }

    var gameScreen: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Nivel \(level)").font(NubiFont.subheading).foregroundColor(.nubiDark)
                Spacer()
                Label("\(score)", systemImage: "sparkles")
                    .font(NubiFont.subheading).foregroundColor(Color(hex: "#2196F3"))
            }

            // Nubi in elevator
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.nubiLightBlue.opacity(0.2))
                    .frame(height: 120)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#2196F3"), lineWidth: 2))
                if nubiFlying {
                    VStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "#2196F3"))
                        NubiAvatarView(color: Color(hex: "#2196F3"), size: 50, isAnimating: false)
                            .offset(y: nubiFlying ? -20 : 0)
                    }
                } else {
                    HStack(spacing: 4) {
                        NubiAvatarView(color: phase == .correct ? Color(hex: "#FFD166") : phase == .wrong ? Color(hex: "#EF476F") : Color(hex: "#2196F3"), size: 60, isAnimating: false)
                        VStack(alignment: .leading) {
                             Text(phase == .showing ? "Observa la secuencia..." :
                                 phase == .input ? "Tu turno, ¡repite!" :
                                 phase == .correct ? "¡Correcto!" : "¡Equivocado!")
                                .font(NubiFont.caption).foregroundColor(.nubiDark)
                        }
                    }
                }
            }
            .animation(.spring(), value: nubiFlying)

            // Floor buttons
            Text("Pisos iluminados: \(sequence.map(String.init).joined(separator: " → "))")
                .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.5))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(1...8, id: \.self) { floor in
                    Button {
                        if phase == .input { tapFloor(floor) }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(highlighting == floor ? Color(hex: "#2196F3") :
                                      userSequence.last == floor && phase == .input ? Color(hex: "#06D6A0") :
                                      Color.nubiLightBlue.opacity(0.3))
                                .frame(height: 56)
                                .animation(.easeInOut(duration: 0.2), value: highlighting)
                            Text("\(floor)")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(highlighting == floor ? .white : .nubiDark)
                        }
                    }
                    .disabled(phase != .input)
                    .buttonStyle(BounceButtonStyle())
                }
            }

            Text(phase == .input ? "Repite la secuencia tocando los pisos" : "Memoriza la secuencia...")
                .font(NubiFont.caption).foregroundColor(.nubiDark.opacity(0.6))
        }
    }

    var resultScreen: some View {
        let insight = score >= 5 ? "¡Memoria de trabajo excelente! Tu carga cognitiva es baja." :
                      score >= 3 ? "Buena memoria. Algunos pisos se escaparon." :
                                   "Tu memoria de corto plazo puede estar saturada. Anotar pendientes puede ayudar."
        return VStack(spacing: 20) {
            NubiAvatarView(color: score >= 5 ? Color(hex: "#2196F3") : .nubiGlaucous, size: 80)
            Text("¡Fin del viaje!")
                .font(NubiFont.heading).foregroundColor(.nubiDark)
            Text("Llegaste al nivel \(score + 1)")
                .font(.system(size: 40, weight: .black, design: .rounded)).foregroundColor(Color(hex: "#2196F3"))
            Text(insight).font(NubiFont.body).foregroundColor(.nubiDark).multilineTextAlignment(.center)
            Button {
                vm.saveGameResult(name: "El Elevador Descompuesto", score: score, insight: insight)
                dismiss()
            } label: { Text("Guardar y salir").nubiButton() }
        }
    }

    private func newRound() {
        userSequence = []
        sequence = (0..<(level + 2)).map { _ in Int.random(in: 1...8) }
        phase = .showing
        showSequence()
    }

    private func showSequence() {
        var delay = 0.5
        for floor in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation { highlighting = floor }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
                highlighting = nil
            }
            delay += 0.8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            phase = .input
        }
    }

    private func tapFloor(_ floor: Int) {
        userSequence.append(floor)
        let idx = userSequence.count - 1
        if floor == sequence[idx] {
            if userSequence.count == sequence.count {
                // Level complete
                phase = .correct
                score += 1
                level += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { newRound() }
            }
        } else {
            phase = .wrong
            withAnimation(.spring()) { nubiFlying = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                nubiFlying = false
                gameOver = true
            }
        }
    }
}
