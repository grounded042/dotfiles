import NativeBarCore
import XCTest

final class SystemStatusTests: XCTestCase {
  func testBatteryUsesQuarterSymbolsAtMidpoints() {
    XCTAssertEqual(
      BatteryStatus(percentage: 100, isCharging: false).symbolName,
      "battery.100percent"
    )
    XCTAssertEqual(BatteryStatus(percentage: 75, isCharging: false).symbolName, "battery.75percent")
    XCTAssertEqual(BatteryStatus(percentage: 50, isCharging: false).symbolName, "battery.50percent")
    XCTAssertEqual(BatteryStatus(percentage: 25, isCharging: false).symbolName, "battery.25percent")
    XCTAssertEqual(BatteryStatus(percentage: 0, isCharging: false).symbolName, "battery.0percent")
  }

  func testChargingBatteryUsesBoltAndClampsPercentage() {
    let status = BatteryStatus(percentage: 120, isCharging: true)

    XCTAssertEqual(status.percentage, 100)
    XCTAssertEqual(status.label, "100%")
    XCTAssertEqual(status.symbolName, "battery.100percent.bolt")
  }

  func testVolumeUsesMutedAndLevelSymbols() {
    XCTAssertEqual(VolumeStatus(percentage: 80, isMuted: false).symbolName, "speaker.wave.3.fill")
    XCTAssertEqual(VolumeStatus(percentage: 50, isMuted: false).symbolName, "speaker.wave.2.fill")
    XCTAssertEqual(VolumeStatus(percentage: 20, isMuted: false).symbolName, "speaker.wave.1.fill")
    XCTAssertEqual(VolumeStatus(percentage: 0, isMuted: false).symbolName, "speaker.fill")
    XCTAssertEqual(VolumeStatus(percentage: 80, isMuted: true).symbolName, "speaker.slash.fill")
  }

  func testWifiUsesConnectionStateSymbols() {
    XCTAssertEqual(WiFiStatus.connected.symbolName, "wifi")
    XCTAssertEqual(WiFiStatus.disconnected.symbolName, "wifi.slash")
  }
}
