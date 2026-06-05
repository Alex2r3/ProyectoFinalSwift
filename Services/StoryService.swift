import Foundation

class StoryService {
    
    /// Carga todas las historias desde archivos JSON en el Bundle de la app.
    static func loadStoriesFromBundle() -> [Story] {
        var stories: [Story] = []
        
        // Buscar JSONs en distintas ubicaciones posibles del Bundle
        let searchSubdirectories: [String?] = [nil, "Resources/Stories", "Stories"]
        
        for subdirectory in searchSubdirectories {
            if let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: subdirectory) {
                for url in urls {
                    do {
                        let data = try Data(contentsOf: url)
                        let story = try JSONDecoder().decode(Story.self, from: data)
                        // Evitar duplicados
                        if !stories.contains(where: { $0.id == story.id }) {
                            stories.append(story)
                            print("StoryService: Cargada historia '\(story.title)' desde \(url.lastPathComponent)")
                        }
                    } catch {
                        print("StoryService [Error]: No se pudo decodificar \(url.lastPathComponent): \(error)")
                    }
                }
            }
        }
        
        if stories.isEmpty {
            print("StoryService [Aviso]: No se encontraron historias JSON en el Bundle. Se cargará la historia por defecto.")
        }
        
        return stories
    }
    
    /// Historia de ejemplo hardcodeada como fallback (actualizada a String IDs).
    static func getElUltimoFaro() -> Story {
        let inicioID = "faro_inicio"
        let playaID = "faro_playa"
        let bosqueID = "faro_bosque"
        let faroID = "faro_interior"
        let finalID = "faro_final"
        
        let c1 = Choice(text: "Explorar la playa", targetSceneID: playaID, bravery: 5, humanity: 2)
        let c2 = Choice(text: "Buscar sobrevivientes", targetSceneID: bosqueID, trust: 10, humanity: 5)
        let c3 = Choice(text: "Ir hacia el faro", targetSceneID: faroID, isCritical: true, timeLimit: 15.0, isWorstOption: true, bravery: 15)
        
        let inicio = GameScene(
            id: inicioID,
            characterName: "Alex",
            dialogue: "Despierto con el sabor de la sal en mi boca. La tormenta ha pasado, pero el silencio es peor. A lo lejos, un faro emite una luz roja intermitente. ¿Qué debo hacer?",
            backgroundImage: "beach_start",
            choices: [c1, c2, c3],
            bgMusic: "ambient_ocean"
        )
        
        let playa = GameScene(
            id: playaID,
            characterName: "Valeria",
            dialogue: "Veo a una mujer junto a unos restos de madera. Se presenta como Valeria. Dice que el faro no es lo que parece.",
            backgroundImage: "beach_mist",
            choices: [
                Choice(text: "Confiar en Valeria", targetSceneID: faroID, trust: 15, humanity: 5),
                Choice(text: "Sospechar de sus motivos", targetSceneID: bosqueID, isWorstOption: true, trust: -10, bravery: 5)
            ]
        )
        
        let bosque = GameScene(
            id: bosqueID,
            characterName: "Noah",
            dialogue: "¡No te acerques! Noah me apunta con un trozo de metal afilado. Cree que somos parte de un experimento.",
            backgroundImage: "dark_forest",
            choices: [
                Choice(text: "Cálmalo", targetSceneID: faroID, trust: 10, humanity: 15),
                Choice(text: "Desarmarlo", targetSceneID: faroID, isWorstOption: true, trust: -5, bravery: 20)
            ],
            bgMusic: "ambient_tension"
        )
        
        let faro = GameScene(
            id: faroID,
            characterName: "Elias",
            dialogue: "Elias está frente a una consola de bronce antigua. 'Alex, llegas justo a tiempo.'",
            backgroundImage: "lighthouse_interior",
            choices: [
                Choice(text: "Sacrificarse", targetSceneID: finalID, trust: 20, humanity: 30),
                Choice(text: "Usar la tecnología", targetSceneID: finalID, isWorstOption: true, bravery: 20, trust: -20)
            ],
            bgMusic: "ambient_climax"
        )
        
        let finalScene = GameScene(
            id: finalID,
            dialogue: "El destino está sellado.",
            backgroundImage: "lighthouse_top",
            isEnding: true
        )

        return Story(
            id: "el_ultimo_faro",
            title: "El Último Faro",
            description: "Una isla que devora recuerdos.",
            coverImage: "faro_cover",
            initialSceneID: inicioID,
            scenes: [inicio, playa, bosque, faro, finalScene],
            genre: "Misterio",
            duration: "30 min",
            defaultMusic: "ambient_ocean"
        )
    }
}
