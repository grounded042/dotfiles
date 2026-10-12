import Foundation

public struct BatteryStatus: Equatable, Sendable {
  public let percentage: Int
  public let isCharging: Bool

  public init(percentage: Int, isCharging: Bool) {
    self.percentage = min(max(percentage, 0), 100)
    self.isCharging = isCharging
  }

  public var symbolName: String {
    if isCharging {
      return "battery.100percent.bolt"
    }

    switch percentage {
    case 88...100:
      return "battery.100percent"
    case 63..<88:
      return "battery.75percent"
    case 38..<63:
      return "battery.50percent"
    case 13..<38:
      return "battery.25percent"
    default:
      return "battery.0percent"
    }
  }

  public var label: String {
    "\(percentage)%"
  }
}

public struct VolumeStatus: Equatable, Sendable {
  public let percentage: Int
  public let isMuted: Bool

  public init(percentage: Int, isMuted: Bool) {
    self.percentage = min(max(percentage, 0), 100)
    self.isMuted = isMuted
  }

  public var symbolName: String {
    if isMuted {
      return "speaker.slash.fill"
    }

    switch percentage {
    case 67...100:
      return "speaker.wave.3.fill"
    case 34..<67:
      return "speaker.wave.2.fill"
    case 1..<34:
      return "speaker.wave.1.fill"
    default:
      return "speaker.fill"
    }
  }

  public var label: String {
    "\(percentage)%"
  }
}

public enum WiFiStatus: Equatable, Sendable {
  case connected
  case disconnected

  public var symbolName: String {
    switch self {
    case .connected:
      return "wifi"
    case .disconnected:
      return "wifi.slash"
    }
  }
}
