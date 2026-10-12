import NativeBarCore
import SwiftUI

private let spaceLabels = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

struct BarView: View {
  @ObservedObject var model: BarModel

  var body: some View {
    HStack(spacing: 0) {
      HStack(spacing: 12) {
        ForEach(Array(spaceLabels.enumerated()), id: \.offset) { index, label in
          Text(label)
            .foregroundStyle(model.activeSpace == index + 1 ? selectedColor : Color.primary)
        }
      }
      .font(.system(size: 15, weight: .semibold))
      .padding(.leading, 14)

      ExtensionItems(model: model, position: .left)
        .padding(.leading, 18)

      Spacer(minLength: 20)

      ExtensionItems(model: model, position: .right)

      SystemStatusItems(model: model)

      ClockItem(model: model)
        .padding(.leading, 14)
        .padding(.trailing, 14)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var selectedColor: Color {
    Color(red: 230 / 255, green: 0, blue: 0)
  }

}

private struct ClockItem: View {
  @ObservedObject var model: BarModel
  @State private var showsUTC = false

  var body: some View {
    ZStack(alignment: .leading) {
      BarItem(symbol: "clock", label: model.clockText, monospacedDigits: true)
        .hidden()
      BarItem(
        symbol: "clock",
        label: showsUTC ? model.clockUTCText : model.clockText,
        monospacedDigits: true
      )
    }
    .contentShape(Rectangle())
    .onHover { showsUTC = $0 }
  }
}

private struct BarItem: View {
  let symbol: String?
  let label: String?
  var color: Color = .primary
  var monospacedDigits = false

  var body: some View {
    HStack(spacing: 5) {
      if let symbol, !symbol.isEmpty {
        Image(systemName: symbol)
          .font(.system(size: 16, weight: .regular))
          .frame(width: 18, height: 18)
      }
      if let label, !label.isEmpty {
        if monospacedDigits {
          Text(label)
            .font(.system(size: 14, weight: .regular))
            .monospacedDigit()
        } else {
          Text(label)
            .font(.system(size: 14, weight: .regular))
        }
      }
    }
    .foregroundStyle(color)
    .lineLimit(1)
  }
}

private struct SystemStatusItems: View {
  @ObservedObject var model: BarModel

  var body: some View {
    HStack(spacing: 16) {
      if let wifiStatus = model.wifiStatus {
        BarItem(symbol: wifiStatus.symbolName, label: model.wifiSSID)
          .truncationMode(.tail)
          .layoutPriority(-1)
          .accessibilityLabel(model.wifiSSID ?? "Wi-Fi")
      }

      if let volumeStatus = model.volumeStatus {
        BarItem(symbol: volumeStatus.symbolName, label: volumeStatus.label)
          .accessibilityLabel("Volume \(volumeStatus.label)")
      }

      if let batteryStatus = model.batteryStatus {
        BarItem(symbol: batteryStatus.symbolName, label: batteryStatus.label)
          .accessibilityLabel("Battery \(batteryStatus.label)")
      }
    }
    .padding(.leading, 14)
  }
}

private struct ExtensionItems: View {
  @ObservedObject var model: BarModel
  let position: ExtensionPosition

  var body: some View {
    HStack(spacing: 16) {
      ForEach(model.extensionItems.filter { $0.position == position }) { item in
        BarItem(
          symbol: item.update.symbol,
          label: item.update.label,
          color: color(for: item.update.color)
        )
      }
    }
  }

  private func color(for value: String?) -> Color {
    guard
      let value,
      value.hasPrefix("#"),
      value.count == 7,
      let rgb = UInt64(value.dropFirst(), radix: 16)
    else {
      return .primary
    }

    return Color(
      red: Double((rgb >> 16) & 0xff) / 255,
      green: Double((rgb >> 8) & 0xff) / 255,
      blue: Double(rgb & 0xff) / 255
    )
  }
}

struct BarFadeView: View {
  var body: some View {
    LinearGradient(
      colors: [Color.black.opacity(0.28), .clear],
      startPoint: .top,
      endPoint: .bottom
    )
  }
}
