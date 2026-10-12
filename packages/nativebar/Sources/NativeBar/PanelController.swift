import AppKit
import SwiftUI

private final class BarPanel: NSPanel {
  override var canBecomeKey: Bool { false }
  override var canBecomeMain: Bool { false }

  override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
    frameRect
  }
}

private final class AdaptiveTintView: NSView {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    updateTint()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is unavailable")
  }

  override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    updateTint()
  }

  private func updateTint() {
    let isDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    layer?.backgroundColor =
      (isDark
      ? NSColor(calibratedWhite: 32 / 255, alpha: 0.72)
      : NSColor(calibratedWhite: 248 / 255, alpha: 0.72)).cgColor
  }
}

private final class BarWindow {
  private static let barHeight: CGFloat = 32
  private static let fadeHeight: CGFloat = 14

  let bar: NSPanel
  let fade: NSPanel

  init(screen: NSScreen, model: BarModel) {
    let barFrame = NSRect(
      x: screen.frame.minX,
      y: screen.frame.maxY - Self.barHeight,
      width: screen.frame.width,
      height: Self.barHeight
    )
    let fadeFrame = NSRect(
      x: screen.frame.minX,
      y: barFrame.minY - Self.fadeHeight,
      width: screen.frame.width,
      height: Self.fadeHeight
    )

    bar = Self.makePanel(frame: barFrame, screen: screen, ignoresMouseEvents: false)
    bar.acceptsMouseMovedEvents = true
    bar.contentView = Self.makeBarContent(frame: barFrame, model: model)

    fade = Self.makePanel(frame: fadeFrame, screen: screen, ignoresMouseEvents: true)
    fade.level = NSWindow.Level(rawValue: NSWindow.Level.statusBar.rawValue - 1)
    fade.contentView = NSHostingView(rootView: BarFadeView())
    bar.addChildWindow(fade, ordered: .below)
  }

  func show() {
    bar.orderFrontRegardless()
  }

  func close() {
    bar.removeChildWindow(fade)
    fade.close()
    bar.close()
  }

  private static func makePanel(
    frame: NSRect,
    screen: NSScreen,
    ignoresMouseEvents: Bool
  ) -> NSPanel {
    let panel = BarPanel(
      contentRect: frame,
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false,
      screen: screen
    )
    panel.setFrame(frame, display: false)
    panel.level = .statusBar
    panel.backgroundColor = .clear
    panel.isOpaque = false
    panel.hasShadow = false
    panel.hidesOnDeactivate = false
    panel.isFloatingPanel = true
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

    let background = makeBarBackground(frame: bounds)
    background.autoresizingMask = [.width, .height]
    container.addSubview(background)

    let content = NSHostingView(rootView: BarView(model: model))
    content.frame = bounds
    content.autoresizingMask = [.width, .height]
    container.addSubview(content)
    return container
  }

  private static func makeBarBackground(frame: NSRect) -> NSView {
    if #available(macOS 26.0, *),
      let glassType = NSClassFromString("NSGlassEffectView") as? NSView.Type
    {
      NativeBarLog.panels.debug("Using Liquid Glass background")
      let glass = glassType.init(frame: frame)
      glass.setValue(
        NSColor.windowBackgroundColor.withAlphaComponent(0.65),
        forKey: "tintColor"
      )
      glass.setValue(0, forKey: "cornerRadius")
      return glass
    }

    NativeBarLog.panels.notice("Liquid Glass unavailable; using material background")
    let fallback = NSVisualEffectView(frame: frame)
    fallback.blendingMode = .behindWindow
    fallback.material = .menu
    fallback.state = .active

    let tint = AdaptiveTintView(frame: frame)
    tint.autoresizingMask = [.width, .height]
    fallback.addSubview(tint)
    return fallback
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
