import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var currentStory: Story?
    @Published var currentScene: GameScene?
    
    @Published var trust: Int = 50
    @Published var bravery: Int = 50
    @Published var humanity: Int = 50
    
    @Published var gameCompleted: Bool = false
    @Published var activeEndingTitle: String = ""
    @Published var activeEndingDescription: String = ""
    
    @Published var timerValue: Double = 0
    @Published var maxTimerValue: Double = 1.0
    @Published var isTimerActive: Bool = false
    @Published var timeOutTriggered: Bool = false
    
    private var timerCancellable: AnyCancellable?

    func startStory(_ story: Story) {
        self.currentStory = story
        self.currentScene = story.scenes.first(where: { $0.id == story.initialSceneID })
        self.trust = 50
        self.bravery = 50
        self.humanity = 50
        self.gameCompleted = false
        self.timeOutTriggered = false
        
        // Iniciar música si la historia define una por defecto
        if let music = story.defaultMusic {
            AudioManager.shared.playMusic(music)
        }
        
        // Iniciar timer si la primera escena tiene opciones con límite de tiempo
        if let scene = currentScene, let time = getSceneTimeLimit(scene) {
            startTimer(seconds: time)
        }
    }
    
    func makeChoice(_ choice: Choice) {
        stopTimer()
        timeOutTriggered = false
        
        withAnimation(.spring()) {
            trust = max(0, min(100, trust + choice.trustImpact))
            bravery = max(0, min(100, bravery + choice.braveryImpact))
            humanity = max(0, min(100, humanity + choice.humanityImpact))
        }
        
        if let nextScene = currentStory?.scenes.first(where: { $0.id == choice.targetSceneID }) {
            transitionToScene(nextScene)
        }
    }
    
    private func transitionToScene(_ scene: GameScene) {
        withAnimation(.easeInOut(duration: 0.8)) {
            self.currentScene = scene
        }
        
        // Cambiar música si la escena define una diferente
        if let music = scene.bgMusic {
            AudioManager.shared.playMusic(music)
        }
        
        if scene.isEnding {
            determineEnding()
        } else if let time = getSceneTimeLimit(scene) {
            startTimer(seconds: time)
        }
    }
    
    /// Obtiene el límite de tiempo de la escena (del primer Choice que lo tenga)
    private func getSceneTimeLimit(_ scene: GameScene) -> Double? {
        return scene.choices.first(where: { $0.timeLimit != nil })?.timeLimit
    }
    
    private func determineEnding() {
        self.gameCompleted = true
        AudioManager.shared.stopMusic()
        
        if humanity >= 80 && trust >= 70 {
            activeEndingTitle = "SACRIFICIO"
            activeEndingDescription = "Alex activa el faro para salvar a los demás, pero queda atrapado para siempre en sus engranajes de luz."
        } else if bravery >= 80 && humanity >= 60 {
            activeEndingTitle = "ESCAPE"
            activeEndingDescription = "Lograste reparar el barco. El horizonte ya no es un sueño, sino tu destino."
        } else if trust <= 30 && humanity <= 40 {
            activeEndingTitle = "SOLEDAD"
            activeEndingDescription = "Tus aliados se han ido. El faro se apaga y la oscuridad de la isla te consume."
        } else if bravery >= 70 && trust >= 40 {
            activeEndingTitle = "EL SECRETO DEL FARO"
            activeEndingDescription = "Has descubierto la tecnología de manipulación mental. El mundo nunca volverá a ser el mismo."
        } else {
            activeEndingTitle = "LA VERDAD"
            activeEndingDescription = "Las paredes de la realidad se desmoronan. Todo era una simulación de laboratorio."
        }
    }
    
    func startTimer(seconds: Double) {
        timerValue = seconds
        maxTimerValue = seconds
        isTimerActive = true
        timeOutTriggered = false
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timerValue > 0 {
                    self.timerValue -= 0.1
                } else {
                    self.timerValue = 0
                    self.handleTimeOut()
                }
            }
    }
    
    func stopTimer() {
        isTimerActive = false
        timerCancellable?.cancel()
    }
    
    /// Progreso del timer de 0.0 (tiempo lleno) a 1.0 (se acabó el tiempo)
    var timerProgress: Double {
        guard maxTimerValue > 0 else { return 0 }
        return 1.0 - (timerValue / maxTimerValue)
    }
    
    private func handleTimeOut() {
        stopTimer()
        timeOutTriggered = true
        
        // Reproducir efecto de sonido de timeout
        AudioManager.shared.playSFX("time_out")
        
        // Buscar la peor opción (marcada como isWorstOption, o con peores impactos)
        guard let scene = currentScene else { return }
        let worstChoice = findWorstChoice(in: scene)
        
        // Esperar 1.5 segundos mostrando el mensaje y luego autoseleccionar
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            if let choice = worstChoice {
                self.makeChoice(choice)
            }
        }
    }
    
    /// Encuentra la peor opción en una escena: primero busca la marcada con isWorstOption,
    /// si no hay, elige la que tenga el impacto total más negativo.
    private func findWorstChoice(in scene: GameScene) -> Choice? {
        // Primero buscar opción marcada explícitamente como la peor
        if let worst = scene.choices.first(where: { $0.isWorstOption == true }) {
            return worst
        }
        
        // Si no, buscar la que tenga el peor impacto total
        return scene.choices.min(by: { totalImpact($0) < totalImpact($1) })
    }
    
    private func totalImpact(_ choice: Choice) -> Int {
        return choice.trustImpact + choice.braveryImpact + choice.humanityImpact
    }
}
