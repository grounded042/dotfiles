import Darwin
import Foundation
import NativeBarCore

private final class ExtensionRunner {
  let manifest: ExtensionManifest

  private let onUpdate: (ExtensionUpdate) -> Void
  private var process: Process?
  private var stopped = false
  private var restartAttempt = 0
  private var startedAt: Date?

  init(manifest: ExtensionManifest, onUpdate: @escaping (ExtensionUpdate) -> Void) {
    self.manifest = manifest
    self.onUpdate = onUpdate
  }

  func start() {
    guard !stopped else { return }

    let process = Process()
    let output = Pipe()
    let errorOutput = Pipe()
    process.executableURL = URL(fileURLWithPath: manifest.executable)
    process.arguments = manifest.arguments
    process.standardOutput = output
    process.standardError = errorOutput
    self.process = process
    startedAt = Date()

    readUpdates(from: output.fileHandleForReading)
    readErrors(from: errorOutput.fileHandleForReading)
    process.terminationHandler = { [weak self] process in
      DispatchQueue.main.async {
        self?.processTerminated(status: process.terminationStatus)
      }
    }

    do {
      NativeBarLog.extensions.info(
        "Starting extension \(self.manifest.id, privacy: .public)"
      )
      try process.run()
    } catch {
      try? output.fileHandleForWriting.close()
      try? errorOutput.fileHandleForWriting.close()
      self.process = nil
      NativeBarLog.extensions.error(
        "Unable to start extension \(self.manifest.id, privacy: .public): \(error.localizedDescription, privacy: .public)"
      )
      processTerminated(status: nil)
    }
  }

  func stop() {
    stopped = true
    process?.terminationHandler = nil
    if process?.isRunning == true {
      process?.terminate()
    }
    process = nil
  }

  private func readUpdates(from handle: FileHandle) {
    DispatchQueue.global(qos: .utility).async { [weak self] in
      var buffer = LineBuffer()
      while true {
        let data: Data
        do {
          guard let chunk = try handle.read(upToCount: 4096), !chunk.isEmpty else {
            break
          }
          data = chunk
        } catch {
          NativeBarLog.extensions.error(
            "Unable to read output from extension \(self?.manifest.id ?? "unknown", privacy: .public): \(error.localizedDescription, privacy: .public)"
          )
          break
        }

        for line in buffer.append(data) {
          guard let update = try? JSONDecoder().decode(ExtensionUpdate.self, from: line) else {
            NativeBarLog.extensions.error(
              "Extension \(self?.manifest.id ?? "unknown", privacy: .public) emitted invalid JSON"
            )
            continue
          }
          DispatchQueue.main.async {
            guard self?.stopped == false else { return }
            self?.onUpdate(update)
          }
        }
      }
    }
  }

  private func readErrors(from handle: FileHandle) {
    handle.readabilityHandler = { [weak self] handle in
      let data = handle.availableData
      guard !data.isEmpty else {
        handle.readabilityHandler = nil
        return
      }
      guard
        let message = String(data: data, encoding: .utf8)?
          .trimmingCharacters(in: .whitespacesAndNewlines),
        !message.isEmpty
      else {
        return
      }
      NativeBarLog.extensions.error(
        "Extension \(self?.manifest.id ?? "unknown", privacy: .public) stderr: \(message, privacy: .private)"
      )
    }
  }

  private func processTerminated(status: Int32?) {
    guard !stopped else { return }
    process = nil
    if let startedAt, Date().timeIntervalSince(startedAt) >= 30 {
      restartAttempt = 0
    } else {
      restartAttempt = min(restartAttempt + 1, 6)
    }
    let delay = pow(2.0, Double(restartAttempt))
    if let status {
      NativeBarLog.extensions.error(
        "Extension \(self.manifest.id, privacy: .public) exited with status \(status, privacy: .public); restarting in \(delay, privacy: .public) seconds"
      )
    } else {
      NativeBarLog.extensions.info(
        "Retrying extension \(self.manifest.id, privacy: .public) in \(delay, privacy: .public) seconds"
      )
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
      self?.start()
    }
  }
}

private final class DirectoryWatcher {
  private let source: DispatchSourceFileSystemObject

  init?(url: URL, onChange: @escaping () -> Void) {
    let descriptor = open(url.path, O_EVTONLY)
    guard descriptor >= 0 else { return nil }

    source = DispatchSource.makeFileSystemObjectSource(
      fileDescriptor: descriptor,
      eventMask: [.write, .delete, .rename, .attrib, .extend, .link],
      queue: .main
    )
    source.setEventHandler(handler: onChange)
    source.setCancelHandler {
      close(descriptor)
    }
    source.resume()
  }

  deinit {
    source.cancel()
  }
}

final class ExtensionHost {
  private let model: BarModel
  private let directories: [URL]
  private var runners: [String: ExtensionRunner] = [:]
  private var watchers: [DirectoryWatcher] = []
  private var pendingReload: DispatchWorkItem?

  init(model: BarModel) {
    self.model = model
    directories = Self.extensionDirectories()
  }

  func start() {
    for directory in directories {
      do {
        try FileManager.default.createDirectory(
          at: directory,
          withIntermediateDirectories: true
        )
      } catch {
        NativeBarLog.extensions.error(
          "Unable to create extension directory \(directory.path, privacy: .private): \(error.localizedDescription, privacy: .public)"
        )
      }
    }
    reload()
    watchers = directories.compactMap { directory in
      guard
        let watcher = DirectoryWatcher(
          url: directory,
          onChange: { [weak self] in
            self?.scheduleReload()
          })
      else {
        NativeBarLog.extensions.error(
          "Unable to watch extension directory \(directory.path, privacy: .private)"
        )
        return nil
      }
      return watcher
    }
  }

  private func scheduleReload() {
    pendingReload?.cancel()
    let reloadTask = DispatchWorkItem { [weak self] in
      self?.reload()
    }
    pendingReload = reloadTask
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: reloadTask)
  }

  private func reload() {
    let manifests = loadManifests()
    NativeBarLog.extensions.info(
      "Loaded \(manifests.count, privacy: .public) extension manifest(s)"
    )
    let desired = Dictionary(manifests.map { ($0.id, $0) }, uniquingKeysWith: { _, last in last })

    let obsoleteIDs = runners.compactMap { id, runner in
      desired[id] != runner.manifest ? id : nil
    }
    for id in obsoleteIDs {
      runners.removeValue(forKey: id)?.stop()
      model.removeExtension(id: id)
    }

    let desiredManifests = desired.values.sorted { ($0.order, $0.id) < ($1.order, $1.id) }
    for manifest in desiredManifests where runners[manifest.id] == nil {
      let runner = ExtensionRunner(manifest: manifest) { [weak model] update in
        model?.updateExtension(manifest, with: update)
      }
      runners[manifest.id] = runner
      runner.start()
    }
  }

  private func loadManifests() -> [ExtensionManifest] {
    directories.flatMap { directory -> [ExtensionManifest] in
      let urls: [URL]
      do {
        urls = try FileManager.default.contentsOfDirectory(
          at: directory,
          includingPropertiesForKeys: nil,
          options: [.skipsHiddenFiles]
        )
      } catch {
        NativeBarLog.extensions.error(
          "Unable to read extension directory \(directory.path, privacy: .private): \(error.localizedDescription, privacy: .public)"
        )
        return []
      }

      return
        urls
        .filter { $0.pathExtension == "json" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
        .compactMap { url -> ExtensionManifest? in
          let manifest: ExtensionManifest
          do {
            let data = try Data(contentsOf: url)
            manifest = try JSONDecoder().decode(ExtensionManifest.self, from: data)
          } catch {
            NativeBarLog.extensions.error(
              "Unable to load manifest \(url.lastPathComponent, privacy: .public): \(error.localizedDescription, privacy: .public)"
            )
            return nil
          }

          guard manifest.protocolVersion == 1 else {
            NativeBarLog.extensions.error(
              "Manifest \(url.lastPathComponent, privacy: .public) uses unsupported protocol \(manifest.protocolVersion, privacy: .public)"
            )
            return nil
          }
          guard manifest.executable.hasPrefix("/") else {
            NativeBarLog.extensions.error(
              "Manifest \(url.lastPathComponent, privacy: .public) has a relative executable path"
            )
            return nil
          }
          guard FileManager.default.isExecutableFile(atPath: manifest.executable) else {
            NativeBarLog.extensions.error(
              "Manifest \(url.lastPathComponent, privacy: .public) executable is missing or not executable"
            )
            return nil
          }
          return manifest
        }
    }
  }

  private static func extensionDirectories() -> [URL] {
    if let configured = ProcessInfo.processInfo.environment["NATIVEBAR_EXTENSION_DIRS"] {
      return
        configured
        .split(separator: ":")
        .map { URL(fileURLWithPath: String($0), isDirectory: true) }
    }

    return [
      FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/nativebar/extensions.d", isDirectory: true)
    ]
  }

  deinit {
    for runner in runners.values {
      runner.stop()
    }
  }
}
