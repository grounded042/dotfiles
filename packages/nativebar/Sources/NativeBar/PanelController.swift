import AppKit
import NativeBarCore
import SwiftUI

private final class BarPanel: NSPanel {
  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }

  override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
    frameRect
  }
}

private final class BarDecorationView: NSView {
  private let radius: CGFloat
  private let shadowDepth: CGFloat

  init(frame frameRect: NSRect, radius: CGFloat, shadowDepth: CGFloat) {
    self.radius = radius
    self.shadowDepth = shadowDepth
    super.init(frame: frameRect)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is unavailable")
  }

  override var isOpaque: Bool { false }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    let top = bounds.maxY
    let curveBottom = top - radius

    let boundary = NSBezierPath()
    boundary.move(to: NSPoint(x: bounds.minX, y: curveBottom))
    boundary.appendArc(
      withCenter: NSPoint(x: bounds.minX + radius, y: curveBottom),
      radius: radius,
      startAngle: 180,
      endAngle: 90,
      clockwise: true
    )
    boundary.line(to: NSPoint(x: bounds.maxX - radius, y: top))
    boundary.appendArc(
      withCenter: NSPoint(x: bounds.maxX - radius, y: curveBottom),
      radius: radius,
      startAngle: 90,
      endAngle: 0,
      clockwise: true
    )

    boundary.lineWidth = 1
    for step in stride(from: Int(shadowDepth), through: 0, by: -1) {
      let distance = CGFloat(step)
      NSGraphicsContext.saveGraphicsState()
      NSGraphicsContext.current?.cgContext.translateBy(x: 0, y: -distance)
      NSColor.black.withAlphaComponent(BarGeometry.shadowOpacity(at: distance)).setStroke()
      boundary.stroke()
      NSGraphicsContext.restoreGraphicsState()
    }

    let leftCorner = NSBezierPath()
    leftCorner.move(to: NSPoint(x: bounds.minX, y: top))
    leftCorner.line(to: NSPoint(x: bounds.minX + radius, y: top))
    leftCorner.appendArc(
      withCenter: NSPoint(x: bounds.minX + radius, y: curveBottom),
      radius: radius,
      startAngle: 90,
      endAngle: 180,
      clockwise: false
    )
    leftCorner.close()

    let rightCorner = NSBezierPath()
    rightCorner.move(to: NSPoint(x: bounds.maxX - radius, y: top))
    rightCorner.line(to: NSPoint(x: bounds.maxX, y: top))
    rightCorner.line(to: NSPoint(x: bounds.maxX, y: curveBottom))
    rightCorner.appendArc(
      withCenter: NSPoint(x: bounds.maxX - radius, y: curveBottom),
      radius: radius,
      startAngle: 0,
      endAngle: 90,
      clockwise: false
    )
    rightCorner.close()

    NSColor.black.setFill()
    leftCorner.fill()
    rightCorner.fill()
  }
}

private final class BarWindow {
  let bar: NSPanel
  let decoration: NSPanel

  init(screen: NSScreen, model: BarModel) {
    let barFrame = BarGeometry.frame(in: screen.frame)
    let decorationFrame = BarGeometry.decorationFrame(in: screen.frame)

    decoration = Self.makePanel(
      frame: decorationFrame,
      screen: screen,
      level: NSWindow.Level(rawValue: NSWindow.Level.statusBar.rawValue - 1),
      ignoresMouseEvents: true,
      isOpaque: false
    )
    decoration.contentView = BarDecorationView(
      frame: NSRect(origin: .zero, size: decorationFrame.size),
      radius: BarGeometry.cornerRadius,
      shadowDepth: BarGeometry.shadowDepth
    )

    bar = Self.makePanel(
      frame: barFrame,
      screen: screen,
      level: .statusBar,
      ignoresMouseEvents: false,
      isOpaque: true
    )
    bar.acceptsMouseMovedEvents = true
    bar.contentView = Self.makeBarContent(frame: barFrame, model: model)
  }

  func show() {
    decoration.orderFrontRegardless()
    bar.orderFrontRegardless()
  }

  func close() {
    decoration.close()
    bar.close()
  }

  private static func makePanel(
    frame: NSRect,
    screen: NSScreen,
    level: NSWindow.Level,
    ignoresMouseEvents: Bool,
    isOpaque: Bool
  ) -> NSPanel {
    let panel = BarPanel(
      contentRect: frame,
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false,
      screen: screen
    )
    panel.setFrame(frame, display: false)
    panel.backgroundColor = isOpaque ? .black : .clear
    panel.isOpaque = isOpaque
    panel.hasShadow = false
    panel.hidesOnDeactivate = false
    panel.isFloatingPanel = true
    panel.level = level
    panel.ignoresMouseEvents = ignoresMouseEvents
    panel.isMovable = false
    panel.collectionBehavior = [
      .canJoinAllSpaces,
      .stationary,
      .ignoresCycle,
    ]
    return panel
  }

  private static func makeBarContent(frame: NSRect, model: BarModel) -> NSView {
    let bounds = NSRect(origin: .zero, size: frame.size)
    let container = NSView(frame: bounds)
    container.autoresizingMask = [.width, .height]
    container.wantsLayer = true
    container.layer?.backgroundColor = NSColor.black.cgColor

    let content = NSHostingView(rootView: BarView(model: model))
    content.frame = bounds
    content.autoresizingMask = [.width, .height]
    container.addSubview(content)
    return container
  }
}

final class PanelController {
  private let model: BarModel
  private var panels: [BarWindow] = []
  private var screenObserver: NSObjectProtocol?

  init(model: BarModel) {
    self.model = model
  }

  func start() {
    rebuildPanels()
    screenObserver = NotificationCenter.default.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.rebuildPanels()
    }
  }

  private func rebuildPanels() {
    for panel in panels {
      panel.close()
    }
    panels = NSScreen.screens.map { BarWindow(screen: $0, model: model) }
    for panel in panels {
      panel.show()
    }
    NativeBarLog.panels.info("Displayed bars on \(self.panels.count, privacy: .public) screen(s)")
  }

  deinit {
    if let screenObserver {
      NotificationCenter.default.removeObserver(screenObserver)
    }
  }
}
