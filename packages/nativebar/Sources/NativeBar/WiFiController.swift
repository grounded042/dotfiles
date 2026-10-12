import AppKit
import CoreLocation
import CoreWLAN
import Foundation
import NativeBarCore
import Network

final class WiFiController: NSObject, CLLocationManagerDelegate, CWEventDelegate {
  private let model: BarModel
  private let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
  private let monitorQueue = DispatchQueue(label: "com.joncarl.NativeBar.wifi")
  private let wifiClient = CWWiFiClient.shared()
  private var locationManager: CLLocationManager?

  init(model: BarModel) {
    self.model = model
  }

  func start(requestLocation: Bool) {
    wifiClient.delegate = self
    startMonitoring(.ssidDidChange)
    startMonitoring(.powerDidChange)

    monitor.pathUpdateHandler = { [weak self] path in
      DispatchQueue.main.async {
        self?.update(for: path)
      }
    }
    monitor.start(queue: monitorQueue)

    guard requestLocation else { return }
    let manager = CLLocationManager()
    manager.delegate = self
    locationManager = manager

    guard manager.authorizationStatus == .notDetermined else {
      refreshSSID()
      return
    }

    NativeBarLog.wifi.notice("Requesting Location Services access for SSID display")
    DispatchQueue.main.async {
      NSApplication.shared.activate(ignoringOtherApps: true)
      manager.requestWhenInUseAuthorization()
    }
  }

  private func startMonitoring(_ event: CWEventType) {
    do {
      try wifiClient.startMonitoringEvent(with: event)
    } catch {
      NativeBarLog.wifi.error(
        "Unable to monitor Wi-Fi event \(event.rawValue, privacy: .public): \(error.localizedDescription, privacy: .public)"
      )
    }
  }

  private func update(for path: NWPath) {
    let connected = path.status == .satisfied
    model.wifiStatus = connected ? .connected : .disconnected
    model.wifiSSID = connected ? wifiClient.interface()?.ssid() : nil
  }

  private func refreshSSID() {
    guard model.wifiStatus == .connected else {
      model.wifiSSID = nil
      return
    }
    model.wifiSSID = wifiClient.interface()?.ssid()
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    NativeBarLog.wifi.info(
      "Location authorization changed to \(manager.authorizationStatus.rawValue, privacy: .public)"
    )
    refreshSSID()
  }

  func ssidDidChangeForWiFiInterface(withName interfaceName: String) {
    DispatchQueue.main.async { [weak self] in
      self?.refreshSSID()
    }
  }

  func powerStateDidChangeForWiFiInterface(withName interfaceName: String) {
    DispatchQueue.main.async { [weak self] in
      self?.refreshSSID()
    }
  }

  deinit {
    monitor.cancel()
    do {
      try wifiClient.stopMonitoringAllEvents()
    } catch {
      NativeBarLog.wifi.error(
        "Unable to stop Wi-Fi event monitoring: \(error.localizedDescription, privacy: .public)"
      )
    }
  }
}
