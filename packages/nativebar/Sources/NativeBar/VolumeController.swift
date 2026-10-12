import AudioToolbox
import CoreAudio
import Foundation
import NativeBarCore

final class VolumeController {
  private let model: BarModel
  private var outputDevice = AudioDeviceID(kAudioObjectUnknown)

  private lazy var defaultDeviceListener: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
    self?.defaultDeviceChanged()
  }

  private lazy var volumeListener: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
    self?.refresh()
  }

  init(model: BarModel) {
    self.model = model
  }

  func start() {
    var address = Self.defaultOutputAddress
    let status = AudioObjectAddPropertyListenerBlock(
      AudioObjectID(kAudioObjectSystemObject),
      &address,
      .main,
      defaultDeviceListener
    )
    logAudioError(status, operation: "subscribe to default output changes")
    defaultDeviceChanged()
  }

  private func defaultDeviceChanged() {
    removeDeviceListeners()
    outputDevice = Self.defaultOutputDevice()
    addDeviceListeners()
    refresh()
  }

  private func addDeviceListeners() {
    guard outputDevice != kAudioObjectUnknown else { return }

    for var address in [Self.volumeAddress, Self.muteAddress] {
      let status = AudioObjectAddPropertyListenerBlock(
        outputDevice, &address, .main, volumeListener)
      logAudioError(status, operation: "subscribe to output volume changes")
    }
  }

  private func removeDeviceListeners() {
    guard outputDevice != kAudioObjectUnknown else { return }

    for var address in [Self.volumeAddress, Self.muteAddress] {
      let status = AudioObjectRemovePropertyListenerBlock(
        outputDevice, &address, .main, volumeListener)
      logAudioError(status, operation: "remove output volume subscription")
    }
  }

  private func logAudioError(_ status: OSStatus, operation: String) {
    guard status != noErr else { return }
    NativeBarLog.audio.error(
      "Unable to \(operation, privacy: .public): OSStatus \(status, privacy: .public)"
    )
  }

  private func refresh() {
    guard
      outputDevice != kAudioObjectUnknown,
      let volume = Self.read(Self.volumeAddress, from: outputDevice, initialValue: Float32(0))
    else {
      model.volumeStatus = nil
      return
    }

    let muted = Self.read(Self.muteAddress, from: outputDevice, initialValue: UInt32(0)) ?? 0
    model.volumeStatus = VolumeStatus(
      percentage: Int((volume * 100).rounded()),
      isMuted: muted != 0
    )
  }

  private static func defaultOutputDevice() -> AudioDeviceID {
    read(
      defaultOutputAddress,
      from: AudioObjectID(kAudioObjectSystemObject),
      initialValue: AudioDeviceID(kAudioObjectUnknown)
    )
      ?? AudioDeviceID(kAudioObjectUnknown)
  }

  private static func read<Value>(
    _ address: AudioObjectPropertyAddress,
    from object: AudioObjectID,
    initialValue: Value
  ) -> Value? {
    var address = address
    guard AudioObjectHasProperty(object, &address) else { return nil }

    var value = initialValue
    var size = UInt32(MemoryLayout<Value>.size)
    let status = withUnsafeMutablePointer(to: &value) { pointer in
      AudioObjectGetPropertyData(object, &address, 0, nil, &size, pointer)
    }
    return status == noErr ? value : nil
  }

  private static let defaultOutputAddress = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyDefaultOutputDevice,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )

  private static let volumeAddress = AudioObjectPropertyAddress(
    mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
    mScope: kAudioDevicePropertyScopeOutput,
    mElement: kAudioObjectPropertyElementMain
  )

  private static let muteAddress = AudioObjectPropertyAddress(
    mSelector: kAudioDevicePropertyMute,
    mScope: kAudioDevicePropertyScopeOutput,
    mElement: kAudioObjectPropertyElementMain
  )

  deinit {
    removeDeviceListeners()
    var address = Self.defaultOutputAddress
    let status = AudioObjectRemovePropertyListenerBlock(
      AudioObjectID(kAudioObjectSystemObject),
      &address,
      .main,
      defaultDeviceListener
    )
    logAudioError(status, operation: "remove default output subscription")
  }
}
