import Foundation
import XCTest

@testable import NativeBarCore

final class ClockScheduleTests: XCTestCase {
  func testNextMinuteBoundaryRoundsUp() {
    let now = Date(timeIntervalSince1970: 12 * 60 + 34.25)

    XCTAssertEqual(
      ClockSchedule.nextMinuteBoundary(after: now),
      Date(timeIntervalSince1970: 13 * 60)
    )
  }

  func testExactBoundaryAdvancesOneMinute() {
    let now = Date(timeIntervalSince1970: 12 * 60)

    XCTAssertEqual(
      ClockSchedule.nextMinuteBoundary(after: now),
      Date(timeIntervalSince1970: 13 * 60)
    )
  }

  func testClockDisplayKeepsLocalOffsetAndProvidesUTC() throws {
    let formatter = ClockTextFormatter(
      localTimeZone: try XCTUnwrap(TimeZone(secondsFromGMT: -6 * 60 * 60))
    )
    let date = Date(timeIntervalSince1970: 0)

    XCTAssertEqual(
      formatter.display(at: date),
      ClockDisplay(
        local: "1969-12-31T18:00-0600",
        utc: "1970-01-01T00:00Z"
      )
    )
  }
}
