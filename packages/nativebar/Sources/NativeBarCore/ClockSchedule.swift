import Foundation

public enum ClockSchedule {
  public static func nextMinuteBoundary(after date: Date) -> Date {
    let seconds = date.timeIntervalSince1970
    return Date(timeIntervalSince1970: (floor(seconds / 60) + 1) * 60)
  }
}

public struct ClockDisplay: Equatable, Sendable {
  public let local: String
  public let utc: String

  public init(local: String, utc: String) {
    self.local = local
    self.utc = utc
  }
}

public final class ClockTextFormatter {
  private let localFormatter: DateFormatter
  private let utcFormatter: DateFormatter

  public init(localTimeZone: TimeZone = .autoupdatingCurrent) {
    localFormatter = DateFormatter()
    localFormatter.locale = Locale(identifier: "en_US_POSIX")
    localFormatter.timeZone = localTimeZone
    localFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"

    utcFormatter = DateFormatter()
    utcFormatter.locale = Locale(identifier: "en_US_POSIX")
    utcFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    utcFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
  }

  public func display(at date: Date) -> ClockDisplay {
    ClockDisplay(
      local: localFormatter.string(from: date),
      utc: utcFormatter.string(from: date)
    )
  }
}
