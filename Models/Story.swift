import Foundation

struct Story: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let coverImage: String
    let initialSceneID: String
    let scenes: [GameScene]
    let genre: String
    let duration: String
    let defaultMusic: String?
    
    init(id: String = UUID().uuidString, title: String, description: String, coverImage: String, initialSceneID: String, scenes: [GameScene], genre: String, duration: String, defaultMusic: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.coverImage = coverImage
        self.initialSceneID = initialSceneID
        self.scenes = scenes
        self.genre = genre
        self.duration = duration
        self.defaultMusic = defaultMusic
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case coverImage
        case initialSceneID
        case scenes
        case genre
        case duration
        case defaultMusic
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.coverImage = try container.decode(String.self, forKey: .coverImage)
        self.initialSceneID = try container.decode(String.self, forKey: .initialSceneID)
        self.scenes = try container.decode([GameScene].self, forKey: .scenes)
        self.genre = try container.decode(String.self, forKey: .genre)
        self.duration = try container.decode(String.self, forKey: .duration)
        self.defaultMusic = try container.decodeIfPresent(String.self, forKey: .defaultMusic)
    }
}
