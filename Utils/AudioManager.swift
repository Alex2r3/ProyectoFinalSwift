import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var musicPlayer: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?
    
    @Published var currentMusicName: String? = nil
    
    private init() {
        // Configurar la sesión de audio para reproducción en modo silencioso (opcional pero recomendado)
        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
        } catch {
            print("AudioManager: No se pudo configurar AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    /// Reproduce música de fondo en bucle.
    /// - Parameter filename: Nombre del archivo de música (ej. "dark_ambient.mp3" o "dark_ambient").
    func playMusic(_ filename: String) {
        let cleanName = (filename as NSString).deletingPathExtension
        let fileExtension = (filename as NSString).pathExtension.isEmpty ? "mp3" : (filename as NSString).pathExtension
        
        // Evitar reiniciar si ya se está reproduciendo la misma canción
        if currentMusicName == cleanName && musicPlayer?.isPlaying == true {
            return
        }
        
        // Buscar en el Bundle principal (también en subcarpetas del Bundle si se agregaron como folder references)
        guard let url = findAudioURL(name: cleanName, ext: fileExtension) else {
            print("AudioManager [Aviso]: No se encontró el archivo de música '\(filename)'. Agrega el archivo a la carpeta Resources/Music en Xcode.")
            stopMusic()
            currentMusicName = nil
            return
        }
        
        do {
            musicPlayer?.stop()
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1 // Bucle infinito
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
            currentMusicName = cleanName
            print("AudioManager: Reproduciendo música de fondo: \(cleanName).\(fileExtension)")
        } catch {
            print("AudioManager [Error]: No se pudo reproducir la música '\(cleanName)': \(error.localizedDescription)")
        }
    }
    
    /// Detiene la música de fondo actual con un pequeño desvanecimiento.
    func stopMusic() {
        musicPlayer?.stop()
        currentMusicName = nil
    }
    
    /// Reproduce un efecto de sonido una sola vez.
    /// - Parameter filename: Nombre del archivo de sonido (ej. "click.wav" o "time_out.mp3").
    func playSFX(_ filename: String) {
        let cleanName = (filename as NSString).deletingPathExtension
        let fileExtension = (filename as NSString).pathExtension.isEmpty ? "wav" : (filename as NSString).pathExtension
        
        guard let url = findAudioURL(name: cleanName, ext: fileExtension) else {
            print("AudioManager [Aviso]: No se encontró el efecto de sonido '\(filename)'.")
            return
        }
        
        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.prepareToPlay()
            sfxPlayer?.play()
            print("AudioManager: Reproduciendo SFX: \(cleanName).\(fileExtension)")
        } catch {
            print("AudioManager [Error]: No se pudo reproducir SFX '\(cleanName)': \(error.localizedDescription)")
        }
    }
    
    /// Helper para buscar la URL de audio en distintas ubicaciones del bundle de la app.
    private func findAudioURL(name: String, ext: String) -> URL? {
        // Buscar directamente en el Bundle principal
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            return url
        }
        // Buscar en la carpeta Resources/Music
        if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Resources/Music") {
            return url
        }
        // Buscar en subdirectorio Music
        if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Music") {
            return url
        }
        return nil
    }
}
