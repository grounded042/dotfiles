import OSLog

enum NativeBarLog {
  static let subsystem = "com.joncarl.NativeBar"

  static let lifecycle = Logger(subsystem: subsystem, category: "lifecycle")
  static let extensions = Logger(subsystem: subsystem, category: "extensions")
  static let spaces = Logger(subsystem: subsystem, category: "spaces")
  static let wifi = Logger(subsystem: subsystem, category: "wifi")
  static let audio = Logger(subsystem: subsystem, category: "audio")
  static let battery = Logger(subsystem: subsystem, category: "battery")
  static let panels = Logger(subsystem: subsystem, category: "panels")
}
