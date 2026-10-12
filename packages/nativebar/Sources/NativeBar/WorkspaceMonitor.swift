import AppKit
import Foundation

private struct YabaiSpace: Decodable {
  let index: Int
}

private enum WorkspaceError: Error {
  case yabaiNotFound
  case queryFailed(Int32)
}

private struct YabaiWorkspaceProvider {
  let executableURL: URL

  init() throws {
    guard let path = Self.resolveYabaiPath() else {
      throw WorkspaceError.yabaiNotFound
    }
    executableURL = URL(fileURLWithPath: path)
  }

  func currentSpace() throws -> Int {
    let process = Process()
    let output = Pipe()
    process.executableURL = executableURL
    process.arguments = ["-m", "query", "--spaces", "--space"]
    process.standardOutput = output
    process.standardError = FileHandle.nullDevice

    try process.run()
    let data = output.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else {
      throw WorkspaceError.queryFailed(process.terminationStatus)
    }
    return try JSONDecoder().decode(YabaiSpace.self, from: data).index
  }

  private static func resolveYabaiPath() -> String? {
    let environment = ProcessInfo.processInfo.environment
    let candidates = [
      environment["NATIVEBAR_YABAI"],
      "/run/current-system/sw/bin/yabai",
      "/opt/homebrew/bin/yabai",
      "/usr/local/bin/yabai",
    ].compactMap { $0 }

    if let candidate = candidates.first(where: FileManager.default.isExecutableFile(atPath:)) {
      return candidate
    }

    return environment["PATH"]?
      .split(separator: ":")
      .map { String($0) + "/yabai" }
      .first(where: FileManager.default.isExecutableFile(atPath:))
  }
}

final class WorkspaceMonitor {
  private let model: BarModel
  private let provider: YabaiWorkspaceProvider?
  private let queryQueue = DispatchQueue(
    label: "com.joncarl.NativeBar.workspace", qos: .userInitiated)
  private var observer: NSObjectProtocol?

  init(model: BarModel) {
    self.model = model
    do {
      provider = try YabaiWorkspaceProvider()
    } catch {
      provider = nil
      NativeBarLog.spaces.error(
        "Unable to locate yabai; the active Space will not be highlighted"
      )
    }
  }

  func start() {
    observer = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.activeSpaceDidChangeNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.refresh()
    }
    refresh()
  }

  private func refresh() {
    guard let provider else {
      model.activeSpace = nil
      return
    }

    queryQueue.async { [weak self] in
      do {
        let space = try provider.currentSpace()
        DispatchQueue.main.async {
          self?.model.activeSpace = space
        }
      } catch {
        NativeBarLog.spaces.error(
          "Unable to query the active Space: \(String(describing: error), privacy: .public)"
        )
        DispatchQueue.main.async {
          self?.model.activeSpace = nil
        }
      }
    }
  }

  deinit {
    if let observer {
      NSWorkspace.shared.notificationCenter.removeObserver(observer)
    }
  }
}
