import CoreGraphics

public enum BarGeometry {
  public static let height: CGFloat = 38
  public static let cornerRadius: CGFloat = 19
  public static let shadowDepth: CGFloat = 12

  public static func frame(in screen: CGRect) -> CGRect {
    CGRect(
      x: screen.minX,
      y: screen.maxY - height,
      width: screen.width,
      height: height
    )
  }

  public static func decorationFrame(in screen: CGRect) -> CGRect {
    CGRect(
      x: screen.minX,
      y: screen.maxY - height - cornerRadius - shadowDepth,
      width: screen.width,
      height: cornerRadius + shadowDepth
    )
  }

  public static func shadowOpacity(at distance: CGFloat) -> CGFloat {
    let progress = max(0, min(1, 1 - (distance / shadowDepth)))
    return 0.30 * progress * progress
  }
}
