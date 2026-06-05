import Foundation

struct Choice: Identifiable, Codable {
    let id: String
    let text: String
    let targetSceneID: String
    let isCritical: Bool
    let timeLimit: Double?
    let isWorstOption: Bool?
    
    // Impacto en las estadísticas
    let trustImpact: Int
    let braveryImpact: Int
    let humanityImpact: Int
    
    init(id: String = UUID().uuidString, text: String, targetSceneID: String, isCritical: Bool = false, timeLimit: Double? = nil, isWorstOption: Bool? = false, trust: Int = 0, bravery: Int = 0, humanity: Int = 0) {
        self.id = id
        self.text = text
        self.targetSceneID = targetSceneID
        self.isCritical = isCritical
        self.timeLimit = timeLimit
        self.isWorstOption = isWorstOption
        self.trustImpact = trust
        self.braveryImpact = bravery
        self.humanityImpact = humanity
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case targetSceneID
        case isCritical
        case timeLimit
        case isWorstOption
        case trustImpact
        case braveryImpact
        case humanityImpact
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.text = try container.decode(String.self, forKey: .text)
        self.targetSceneID = try container.decode(String.self, forKey: .targetSceneID)
        self.isCritical = try container.decodeIfPresent(Bool.self, forKey: .isCritical) ?? false
        self.timeLimit = try container.decodeIfPresent(Double.self, forKey: .timeLimit)
        self.isWorstOption = try container.decodeIfPresent(Bool.self, forKey: .isWorstOption) ?? false
        self.trustImpact = try container.decodeIfPresent(Int.self, forKey: .trustImpact) ?? 0
        self.braveryImpact = try container.decodeIfPresent(Int.self, forKey: .braveryImpact) ?? 0
        self.humanityImpact = try container.decodeIfPresent(Int.self, forKey: .humanityImpact) ?? 0
    }
}
