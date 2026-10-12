import CoreGraphics
import Foundation

public enum ScreenCorner: CaseIterable {
  case topLeft
  case topRight
  case bottomLeft
  case bottomRight
}

public enum ScreenEdge: CaseIterable {
  case top
  case bottom
  case left
  case right
}

public enum EdgeShadowGeometry {
  public static func frame(
    for edge: ScreenEdge,
    in screen: CGRect,
    depth: CGFloat
  ) -> CGRect {
    switch edge {
    case .top:
      return CGRect(x: screen.minX, y: screen.maxY - depth, width: screen.width, height: depth)
    case .bottom:
      return CGRect(x: screen.minX, y: screen.minY, width: screen.width, height: depth)
    case .left:
      return CGRect(x: screen.minX, y: screen.minY, width: depth, height: screen.height)
    case .right:
      return CGRect(x: screen.maxX - depth, y: screen.minY, width: depth, height: screen.height)
    }
  }
}

public enum CornerGeometry {
  public static let macBookRadius: CGFloat = 19

  public static func radius(environment: [String: String]) -> CGFloat {
    guard
      let value = environment["SCREEN_CORNERS_RADIUS"],
      let parsed = Double(value),
      parsed.isFinite
    else {
      return macBookRadius
    }
    return min(max(CGFloat(parsed), 4), 40)
  }

  public static func frame(
    for corner: ScreenCorner,
    in screen: CGRect,
    radius: CGFloat
  ) -> CGRect {
    let x: CGFloat
    let y: CGFloat

    switch corner {
    case .topLeft:
      x = screen.minX
      y = screen.maxY - radius
    case .topRight:
      x = screen.maxX - radius
      y = screen.maxY - radius
    case .bottomLeft:
      x = screen.minX
      y = screen.minY
    case .bottomRight:
      x = screen.maxX - radius
      y = screen.minY
    }

    return CGRect(x: x, y: y, width: radius, height: radius)
  }

  public static func circleFrame(for corner: ScreenCorner, radius: CGFloat) -> CGRect {
    let origin: CGPoint
    switch corner {
    case .topLeft:
      origin = CGPoint(x: 0, y: -radius)
    case .topRight:
      origin = CGPoint(x: -radius, y: -radius)
    case .bottomLeft:
      origin = .zero
    case .bottomRight:
      origin = CGPoint(x: -radius, y: 0)
    }

    return CGRect(
      origin: origin,
      size: CGSize(width: radius * 2, height: radius * 2)
    )
  }
}
