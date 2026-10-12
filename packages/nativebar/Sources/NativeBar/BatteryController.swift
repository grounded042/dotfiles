import Foundation
import IOKit.ps
import NativeBarCore

final class BatteryController {
  private let model: BarModel
  private var notificationSource: CFRunLoopSource?

  init(model: BarModel) {
    self.model = model
  }

  func start() {
    refresh()

    let context = Unmanaged.passUnretained(self).toOpaque()
    guard
      let source = IOPSNotificationCreateRunLoopSource(
        { context in
          guard let context else { return }
          Unmanaged<BatteryController>
            .fromOpaque(context)
            .takeUnretainedValue()
            .refresh()
        },
        context
      )?.takeRetainedValue()
    else {
      NativeBarLog.battery.error("Unable to subscribe to power-source changes")
      return
    }

    notificationSource = source
    CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
  }

  private func refresh() {
    let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
    let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as [CFTypeRef]

    for source in sources {
      guard
        let description = IOPSGetPowerSourceDescription(snapshot, source)?
          .takeUnretainedValue() as? [String: Any],
        description[kIOPSTypeKey] as? String == kIOPSInternalBatteryType,
        let current = description[kIOPSCurrentCapacityKey] as? Int,
        let maximum = description[kIOPSMaxCapacityKey] as? Int,
        maximum > 0
      else {
        continue
      }

      let percentage = Int((Double(current) / Double(maximum) * 100).rounded())
      let state = description[kIOPSPowerSourceStateKey] as? String
      let isCharging = state == kIOPSACPowerValue
      model.batteryStatus = BatteryStatus(percentage: percentage, isCharging: isCharging)
      return
    }

    model.batteryStatus = nil
  }

  deinit {
    if let notificationSource {
      CFRunLoopRemoveSource(CFRunLoopGetMain(), notificationSource, .commonModes)
    }
  }
}
