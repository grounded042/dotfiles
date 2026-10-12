import Combine
import Foundation
import NativeBarCore

struct ExtensionItem: Identifiable, Equatable {
  let id: String
  let position: ExtensionPosition
  let order: Int
  let update: ExtensionUpdate
}

final class BarModel: ObservableObject {
  @Published var activeSpace: Int?
  @Published var batteryStatus: BatteryStatus?
  @Published private(set) var clockText = ""
  @Published private(set) var clockUTCText = ""
  @Published private(set) var extensionItems: [ExtensionItem] = []
  @Published var volumeStatus: VolumeStatus?
  @Published var wifiStatus: WiFiStatus?
  @Published var wifiSSID: String?

  private let clockFormatter = ClockTextFormatter()

  func updateClock(at date: Date = Date()) {
    let display = clockFormatter.display(at: date)
    clockText = display.local
    clockUTCText = display.utc
  }

  func updateExtension(_ manifest: ExtensionManifest, with update: ExtensionUpdate) {
    let item = ExtensionItem(
      id: manifest.id,
      position: manifest.position,
      order: manifest.order,
      update: update
    )
    extensionItems.removeAll { $0.id == manifest.id }
    extensionItems.append(item)
    extensionItems.sort {
      if $0.position == $1.position {
        return ($0.order, $0.id) < ($1.order, $1.id)
      }
      return $0.position.rawValue < $1.position.rawValue
    }
  }

  func removeExtension(id: String) {
    extensionItems.removeAll { $0.id == id }
  }
}
