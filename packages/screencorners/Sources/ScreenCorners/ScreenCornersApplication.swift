import AppKit
import OSLog
import ScreenCornersCore

private let logger = Logger(subsystem: "com.joncarl.ScreenCorners", category: "lifecycle")

private final class AppDelegate: NSObject, NSApplicationDelegate {
  private var controller: CornerMaskController?

  func applicationDidFinishLaunching(_ notification: Notification) {
    let radius = CornerGeometry.radius(environment: ProcessInfo.processInfo.environment)
    logger.notice("ScreenCorners starting with radius \(radius, privacy: .public)")

    let controller = CornerMaskController(radius: radius)
    self.controller = controller
    controller.start()
  }

  func applicationWillTerminate(_ notification: Notification) {
    logger.notice("ScreenCorners stopping")
  }
}

@main
private enum ScreenCornersApplication {
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
