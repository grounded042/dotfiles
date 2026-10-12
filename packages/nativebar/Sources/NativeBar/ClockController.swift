import Foundation
import NativeBarCore

final class ClockController {
  private let model: BarModel
  private var timer: Timer?

  init(model: BarModel) {
    self.model = model
  }

  func start() {
    model.updateClock()

    let timer = Timer(
      fire: ClockSchedule.nextMinuteBoundary(after: Date()),
      interval: 60,
      repeats: true
    ) { [weak self] _ in
      self?.model.updateClock()
    }
    RunLoop.main.add(timer, forMode: .common)
    self.timer = timer
  }

  deinit {
    timer?.invalidate()
  }
}
