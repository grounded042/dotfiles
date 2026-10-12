import AppKit

private final class AppDelegate: NSObject, NSApplicationDelegate {
  private let requestLocation = CommandLine.arguments.contains("--request-location")
  private let model = BarModel()
  private var batteryController: BatteryController?
  private var clockController: ClockController?
  private var extensionHost: ExtensionHost?
  private var panelController: PanelController?
  private var volumeController: VolumeController?
  private var wifiController: WiFiController?
  private var workspaceMonitor: WorkspaceMonitor?

  func applicationDidFinishLaunching(_ notification: Notification) {
    NativeBarLog.lifecycle.notice("NativeBar starting")

    let batteryController = BatteryController(model: model)
    let clockController = ClockController(model: model)
    let extensionHost = ExtensionHost(model: model)
    let panelController = PanelController(model: model)
    let volumeController = VolumeController(model: model)
    let wifiController = WiFiController(model: model)
    let workspaceMonitor = WorkspaceMonitor(model: model)

    self.batteryController = batteryController
    self.clockController = clockController
    self.extensionHost = extensionHost
    self.panelController = panelController
    self.volumeController = volumeController
    self.wifiController = wifiController
    self.workspaceMonitor = workspaceMonitor

    batteryController.start()
    clockController.start()
    extensionHost.start()
    volumeController.start()
    wifiController.start(requestLocation: requestLocation)
    workspaceMonitor.start()
    panelController.start()

    NativeBarLog.lifecycle.notice("NativeBar started")
  }

  func applicationWillTerminate(_ notification: Notification) {
    NativeBarLog.lifecycle.notice("NativeBar stopping")
  }
}

@main
private enum NativeBarApplication {
  static func main() {
    let application = NSApplication.shared
    let delegate = AppDelegate()
    application.delegate = delegate
    application.setActivationPolicy(.accessory)
    withExtendedLifetime(delegate) {
      application.run()
    }
  }
}
