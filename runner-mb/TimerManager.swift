//MIT License
//
//Copyright (c) 2020 Matthias Brodalka
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import Foundation
import RxSwift
import RxCocoa

class TimerManager: ObservableObject {

    static let shared = TimerManager()

    var timer = Timer()
    let timerInterval = 1.0
    var timeElapsed: TimeInterval = 0
    var timeElapsedBinding = BehaviorRelay<TimeInterval>(value: 0)
    var pauseInSeconds = 0

    var timerAction:((_ elapsedTime: TimeInterval) -> Void)?

    var startDate:Date?

    // MARK: Basic
    func start(_ date:Date? = nil, _ pauseInSeconds: Int = 0) {

        self.pauseInSeconds += pauseInSeconds

        if let date = date {
            reset()
            self.startDate = date
        }
        if timer.isValid { timer.invalidate() }
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(timerAction(timer:)), userInfo: nil, repeats: true)
    }

    func pause() {
        timer.invalidate()
    }

    func resume() {
        if startDate != nil {
            start()
        }
    }

    func stop() {
        timer.invalidate()
        self.reset()
    }

    func reset() {
        self.timeElapsed = 0
        self.timeElapsedBinding.accept(self.timeElapsed)
        self.startDate = nil
        self.pauseInSeconds = 0
    }

    // MARK: Timer Update
    @objc func timerAction(timer: Timer) {
        self.timeElapsed += 1
        self.timerAction?(timeElapsed)

        if let startDate = startDate {
            self.timeElapsedBinding.accept(Date().timeIntervalSince(startDate)-Double(self.pauseInSeconds))
        }
        print("update \(timeElapsed)")
    }

    func timePassed(_ startDate: Date) -> String {
        return "\(startDate.timeIntervalSinceNow)"
    }
}
