import CoreGraphics
import XCTest

@testable import ScreenCornersCore

final class CornerGeometryTests: XCTestCase {
  func testCornerFramesFollowEveryScreenEdge() {
    let screen = CGRect(x: -100, y: 20, width: 800, height: 600)
    let radius: CGFloat = 12

    XCTAssertEqual(
      CornerGeometry.frame(for: .topLeft, in: screen, radius: radius),
      CGRect(x: -100, y: 608, width: 12, height: 12)
    )
    XCTAssertEqual(
      CornerGeometry.frame(for: .topRight, in: screen, radius: radius),
      CGRect(x: 688, y: 608, width: 12, height: 12)
    )
    XCTAssertEqual(
      CornerGeometry.frame(for: .bottomLeft, in: screen, radius: radius),
      CGRect(x: -100, y: 20, width: 12, height: 12)
    )
    XCTAssertEqual(
      CornerGeometry.frame(for: .bottomRight, in: screen, radius: radius),
      CGRect(x: 688, y: 20, width: 12, height: 12)
    )
  }

  func testCircleFramesExposeTheCorrectOuterQuadrant() {
    let radius: CGFloat = 12

    XCTAssertEqual(
      CornerGeometry.circleFrame(for: .topLeft, radius: radius),
      CGRect(x: 0, y: -12, width: 24, height: 24)
    )
    XCTAssertEqual(
      CornerGeometry.circleFrame(for: .topRight, radius: radius),
      CGRect(x: -12, y: -12, width: 24, height: 24)
    )
    XCTAssertEqual(
      CornerGeometry.circleFrame(for: .bottomLeft, radius: radius),
      CGRect(x: 0, y: 0, width: 24, height: 24)
    )
    XCTAssertEqual(
      CornerGeometry.circleFrame(for: .bottomRight, radius: radius),
      CGRect(x: -12, y: 0, width: 24, height: 24)
    )
  }

  func testEdgeFramesFollowEveryScreenEdge() {
    let screen = CGRect(x: -100, y: 20, width: 800, height: 600)
    let depth: CGFloat = 16

    XCTAssertEqual(
      EdgeShadowGeometry.frame(for: .top, in: screen, depth: depth),
      CGRect(x: -100, y: 604, width: 800, height: 16)
    )
    XCTAssertEqual(
      EdgeShadowGeometry.frame(for: .bottom, in: screen, depth: depth),
      CGRect(x: -100, y: 20, width: 800, height: 16)
    )
    XCTAssertEqual(
      EdgeShadowGeometry.frame(for: .left, in: screen, depth: depth),
      CGRect(x: -100, y: 20, width: 16, height: 600)
    )
    XCTAssertEqual(
      EdgeShadowGeometry.frame(for: .right, in: screen, depth: depth),
      CGRect(x: 684, y: 20, width: 16, height: 600)
    )
  }

  func testRadiusUsesMacBookDefaultAndAcceptsBoundedOverride() {
    XCTAssertEqual(CornerGeometry.radius(environment: [:]), 19)
    XCTAssertEqual(CornerGeometry.radius(environment: ["SCREEN_CORNERS_RADIUS": "18.5"]), 18.5)
    XCTAssertEqual(CornerGeometry.radius(environment: ["SCREEN_CORNERS_RADIUS": "1"]), 4)
    XCTAssertEqual(CornerGeometry.radius(environment: ["SCREEN_CORNERS_RADIUS": "100"]), 40)
    XCTAssertEqual(CornerGeometry.radius(environment: ["SCREEN_CORNERS_RADIUS": "nope"]), 19)
  }
}
