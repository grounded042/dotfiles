import Foundation
import XCTest

@testable import NativeBarCore

final class ExtensionProtocolTests: XCTestCase {
  func testManifestDefaultsToRightSideWithNoArguments() throws {
    let manifest = try JSONDecoder().decode(
      ExtensionManifest.self,
      from: Data(#"{"id":"example-vpn","executable":"/opt/example/bin/vpn-status"}"#.utf8)
    )

    XCTAssertEqual(manifest.id, "example-vpn")
    XCTAssertEqual(manifest.protocolVersion, 1)
    XCTAssertEqual(manifest.position, .right)
    XCTAssertEqual(manifest.order, 0)
    XCTAssertEqual(manifest.arguments, [])
  }

  func testLineBufferPreservesFragmentedMessages() {
    var buffer = LineBuffer()

    XCTAssertEqual(buffer.append(Data(#"{"label":"First"}"#.utf8)), [])

    let messages = buffer.append(Data("\n{\"label\":\"VPN\"}\npartial".utf8))
    XCTAssertEqual(
      messages.map { String(decoding: $0, as: UTF8.self) },
      [
        #"{"label":"First"}"#,
        #"{"label":"VPN"}"#,
      ])

    let finalMessages = buffer.append(Data(" message\n".utf8))
    XCTAssertEqual(finalMessages.map { String(decoding: $0, as: UTF8.self) }, ["partial message"])
  }

  func testExtensionUpdateDecodesSFsymbolAndHexColor() throws {
    let update = try JSONDecoder().decode(
      ExtensionUpdate.self,
      from: Data(##"{"symbol":"lock.shield.fill","label":"Example VPN","color":"#73daca"}"##.utf8)
    )

    XCTAssertEqual(update.symbol, "lock.shield.fill")
    XCTAssertEqual(update.label, "Example VPN")
    XCTAssertEqual(update.color, "#73daca")
  }

  func testLineBufferDropsOversizedUnterminatedMessage() {
    var buffer = LineBuffer(maximumSize: 8)

    XCTAssertEqual(buffer.append(Data("123456789".utf8)), [])
    XCTAssertEqual(
      buffer.append(Data("valid\n".utf8)).map { String(decoding: $0, as: UTF8.self) },
      [
        "valid"
      ])
  }
}
