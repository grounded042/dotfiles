import Foundation

public enum ExtensionPosition: String, Codable, Sendable {
  case left
  case right
}

public struct ExtensionManifest: Codable, Hashable, Sendable {
  public let id: String
  public let protocolVersion: Int
  public let position: ExtensionPosition
  public let order: Int
  public let executable: String
  public let arguments: [String]

  public init(
    id: String,
    protocolVersion: Int = 1,
    position: ExtensionPosition = .right,
    order: Int = 0,
    executable: String,
    arguments: [String] = []
  ) {
    self.id = id
    self.protocolVersion = protocolVersion
    self.position = position
    self.order = order
    self.executable = executable
    self.arguments = arguments
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case protocolVersion = "protocol"
    case position
    case order
    case executable
    case arguments
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    protocolVersion = try container.decodeIfPresent(Int.self, forKey: .protocolVersion) ?? 1
    position = try container.decodeIfPresent(ExtensionPosition.self, forKey: .position) ?? .right
    order = try container.decodeIfPresent(Int.self, forKey: .order) ?? 0
    executable = try container.decode(String.self, forKey: .executable)
    arguments = try container.decodeIfPresent([String].self, forKey: .arguments) ?? []
  }
}

public struct ExtensionUpdate: Codable, Equatable, Sendable {
  public let symbol: String?
  public let label: String?
  public let color: String?

  public init(symbol: String? = nil, label: String? = nil, color: String? = nil) {
    self.symbol = symbol
    self.label = label
    self.color = color
  }
}

public struct LineBuffer: Sendable {
  private var storage = Data()
  private let maximumSize: Int

  public init(maximumSize: Int = 65_536) {
    self.maximumSize = maximumSize
  }

  public mutating func append(_ data: Data) -> [Data] {
    storage.append(data)
    guard storage.count <= maximumSize else {
      storage.removeAll(keepingCapacity: true)
      return []
    }

    var lines: [Data] = []
    while let newline = storage.firstIndex(of: 0x0a) {
      let line = storage[..<newline]
      if !line.isEmpty {
        lines.append(Data(line))
      }
      storage.removeSubrange(...newline)
    }
    return lines
  }
}
