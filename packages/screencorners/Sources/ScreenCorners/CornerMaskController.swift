import AppKit
import OSLog
import ScreenCornersCore

private let logger = Logger(subsystem: "com.joncarl.ScreenCorners", category: "overlays")

private final class CornerPanel: NSPanel {
  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }

  override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
    frameRect
  }
}

private final class CornerMaskView: NSView {
  private let corner: ScreenCorner
  private let radius: CGFloat

  init(corner: ScreenCorner, radius: CGFloat) {
    self.corner = corner
    self.radius = radius
    super.init(frame: CGRect(x: 0, y: 0, width: radius, height: radius))
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is unavailable")
  }

  override var isOpaque: Bool { false }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    let mask = NSBezierPath(rect: bounds)
    mask.appendOval(in: CornerGeometry.circleFrame(for: corner, radius: radius))
    mask.windingRule = .evenOdd
    NSColor.black.setFill()
    mask.fill()
  }
}

private final class EdgeShadowView: NSView {
  private let edge: ScreenEdge
  private let opacity: CGFloat

  init(edge: ScreenEdge, frame: NSRect, opacity: CGFloat) {
    self.edge = edge
    self.opacity = opacity
    super.init(frame: frame)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is unavailable")
  }

  override var isOpaque: Bool { false }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    let clear = NSColor.clear
    let shadow = NSColor.black.withAlphaComponent(opacity)
    let gradient: NSGradient?
    let start: NSPoint
    let end: NSPoint

    switch edge {
    case .top:
      gradient = NSGradient(colors: [clear, shadow])
      start = NSPoint(x: bounds.midX, y: bounds.minY)
      end = NSPoint(x: bounds.midX, y: bounds.maxY)
    case .bottom:
      gradient = NSGradient(colors: [shadow, clear])
      start = NSPoint(x: bounds.midX, y: bounds.minY)
      end = NSPoint(x: bounds.midX, y: bounds.maxY)
    case .left:
      gradient = NSGradient(colors: [shadow, clear])
      start = NSPoint(x: bounds.minX, y: bounds.midY)
      end = NSPoint(x: bounds.maxX, y: bounds.midY)
    case .right:
      gradient = NSGradient(colors: [clear, shadow])
      start = NSPoint(x: bounds.minX, y: bounds.midY)
      end = NSPoint(x: bounds.maxX, y: bounds.midY)
    }

    gradient?.draw(from: start, to: end, options: [])
  }
}

private func makeOverlayPanel(
  frame: NSRect,
  screen: NSScreen,
  level: NSWindow.Level,
  contentView: NSView
) -> NSPanel {
  let panel = CornerPanel(
    contentRect: frame,
    styleMask: [.borderless, .nonactivatingPanel],
    backing: .buffered,
    defer: false,
    screen: screen
  )
  panel.setFrame(frame, display: false)
  panel.backgroundColor = .clear
  panel.isOpaque = false
  panel.hasShadow = false
  panel.hidesOnDeactivate = false
  panel.isFloatingPanel = true
  panel.level = level
  panel.ignoresMouseEvents = true
  panel.isMovable = false
  panel.collectionBehavior = [
    .canJoinAllSpaces,
    .stationary,
    .fullScreenAuxiliary,
    .ignoresCycle,
  ]
  panel.contentView = contentView
  return panel
}

private final class CornerOverlay {
  let panel: NSPanel

  init(screen: NSScreen, corner: ScreenCorner, radius: CGFloat) {
    let frame = CornerGeometry.frame(for: corner, in: screen.frame, radius: radius)
    panel = makeOverlayPanel(
      frame: frame,
      screen: screen,
      level: .screenSaver,
      contentView: CornerMaskView(corner: corner, radius: radius)
    )
  }

  func show() {
    panel.orderFrontRegardless()
  }

  func close() {
    panel.close()
  }
}

private final class EdgeShadowOverlay {
  let panel: NSPanel

  init(screen: NSScreen, edge: ScreenEdge, depth: CGFloat, opacity: CGFloat) {
    let frame = EdgeShadowGeometry.frame(for: edge, in: screen.frame, depth: depth)
    let contentFrame = NSRect(origin: .zero, size: frame.size)
    panel = makeOverlayPanel(
      frame: frame,
      screen: screen,
      level: NSWindow.Level(rawValue: NSWindow.Level.statusBar.rawValue - 1),
      contentView: EdgeShadowView(edge: edge, frame: contentFrame, opacity: opacity)
    )
  }

  func show() {
    panel.orderFrontRegardless()
  }

  func close() {
    panel.close()
  }
}

final class CornerMaskController {
  private static let shadowDepth: CGFloat = 16
  private static let shadowOpacity: CGFloat = 0.22

  private let radius: CGFloat
  private var cornerOverlays: [CornerOverlay] = []
  private var edgeOverlays: [EdgeShadowOverlay] = []
  private var observers: [NSObjectProtocol] = []

  init(radius: CGFloat) {
    self.radius = radius
  }

  func start() {
    rebuild()

    observers.append(
      NotificationCenter.default.addObserver(
        forName: NSApplication.didChangeScreenParametersNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        self?.rebuild()
      })

    for name in [NSWorkspace.didWakeNotification, NSWorkspace.activeSpaceDidChangeNotification] {
      observers.append(
        NSWorkspace.shared.notificationCenter.addObserver(
          forName: name,
          object: nil,
          queue: .main
        ) { [weak self] _ in
          self?.showAll()
        })
    }
  }

  private func rebuild() {
    for overlay in cornerOverlays {
      overlay.close()
    }
    for overlay in edgeOverlays {
      overlay.close()
    }
    edgeOverlays = NSScreen.screens.flatMap { screen in
      ScreenEdge.allCases.map { edge in
        EdgeShadowOverlay(
          screen: screen,
          edge: edge,
          depth: Self.shadowDepth,
          opacity: Self.shadowOpacity
        )
      }
    }
    cornerOverlays = NSScreen.screens.flatMap { screen in
      ScreenCorner.allCases.map { corner in
        CornerOverlay(screen: screen, corner: corner, radius: radius)
      }
    }
    showAll()
    logger.info(
      "Displayed \(self.cornerOverlays.count, privacy: .public) corner masks and \(self.edgeOverlays.count, privacy: .public) edge shadows on \(NSScreen.screens.count, privacy: .public) display(s) at radius \(self.radius, privacy: .public)"
    )
  }

  private func showAll() {
    for overlay in edgeOverlays {
      overlay.show()
    }
    for overlay in cornerOverlays {
      overlay.show()
    }
  }

  deinit {
    for observer in observers {
      NotificationCenter.default.removeObserver(observer)
      NSWorkspace.shared.notificationCenter.removeObserver(observer)
    }
  }
}
