import Foundation

struct GameScene: Identifiable, Codable {
    let id: String
    let characterName: String?
    let dialogue: String
    let backgroundImage: String
    let choices: [Choice]
    let isEnding: Bool
    let bgMusic: String?
    
    init(id: String = UUID().uuidString, characterName: String? = nil, dialogue: String, backgroundImage: String, choices: [Choice] = [], isEnding: Bool = false, bgMusic: String? = nil) {
        self.id = id
        self.characterName = characterName
        self.dialogue = dialogue
        self.backgroundImage = backgroundImage
        self.choices = choices
        self.isEnding = isEnding
        self.bgMusic = bgMusic
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case characterName
        case dialogue
        case backgroundImage
        case choices
        case isEnding
        case bgMusic
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.characterName = try container.decodeIfPresent(String.self, forKey: .characterName)
        self.dialogue = try container.decode(String.self, forKey: .dialogue)
        self.backgroundImage = try container.decode(String.self, forKey: .backgroundImage)
        self.choices = try container.decodeIfPresent([Choice].self, forKey: .choices) ?? []
        self.isEnding = try container.decodeIfPresent(Bool.self, forKey: .isEnding) ?? false
        self.bgMusic = try container.decodeIfPresent(String.self, forKey: .bgMusic)
    }
}
