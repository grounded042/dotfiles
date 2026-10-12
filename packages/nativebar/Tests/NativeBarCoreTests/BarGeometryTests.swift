import CoreGraphics
import Testing

@testable import NativeBarCore

@Test func barFrameIsFlushWithTheTopAndSides() {
  let screen = CGRect(x: -1440, y: 0, width: 1440, height: 900)

  #expect(BarGeometry.height == 38)
  #expect(BarGeometry.cornerRadius == 19)
  #expect(
    BarGeometry.frame(in: screen)
      == CGRect(x: -1440, y: 862, width: 1440, height: 38)
  )
}

@Test func decorationFrameContinuesBelowTheBar() {
  let screen = CGRect(x: -1440, y: 0, width: 1440, height: 900)

  #expect(BarGeometry.shadowDepth == 12)
  #expect(
    BarGeometry.decorationFrame(in: screen)
      == CGRect(x: -1440, y: 831, width: 1440, height: 31)
  )
}

@Test func shadowFalloffFadesToTransparent() {
  #expect(BarGeometry.shadowOpacity(at: 0) == 0.30)
  #expect(abs(BarGeometry.shadowOpacity(at: 6) - 0.075) < 0.0001)
  #expect(BarGeometry.shadowOpacity(at: 12) == 0)
  #expect(BarGeometry.shadowOpacity(at: 20) == 0)
}
