// IncrementableLabel.swift
//
// Copyright (c) 2016 Recisio (http://www.recisio.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public enum IncrementableLabelOptions {
    case Linear, EaseIn, EaseOut, EaseInOut
}

public typealias StringFormatter = (Float) -> String
public typealias AttributedTextFormatter = (Float) -> NSAttributedString
public typealias IncrementableLabelCompletion = () -> Void

public class IncrementableLabel: UILabel {

    // MARK: Properties
    
    /// An options indicating how you want to perform the incrementation:
    public var option: IncrementableLabelOptions = .Linear
    
    /// A callback closure which permits a greater control on how the text (attributed or not) is formatted between each incrementation.
    public var stringFormatter: StringFormatter?
    public var attributedTextFormatter: AttributedTextFormatter?
    
    /// A callback closure that will be called once the incrementation is finished
    public var incrementationCompletion: IncrementableLabelCompletion?

    /// The rate used when an option is used.
    public var easingRate: Float = 3.0
    
    /// The format is used to set the text in the label. You can set the format to %f in order to display decimals.
    public var format: String = "%d" {
        didSet {
            updateText()
        }
    }
    
    // MARK: Public methods
    
    /** The label's value during the incrementation */
    public func currentValue() -> Float {
        if progress >= duration {
            return toValue
        }
        let percent: Float = Float(progress / duration)
        return fromValue + (nextValueForCurrentOption(percent) * (toValue - fromValue))
    }
    
    /** Starts the incrementation fromValue to toValue */
    public func incrementFromValue(fromValue: Float, toValue: Float, duration: Float = 0.3) {
        startIncrementationFromValue(fromValue, toValue: toValue, duration: duration)
    }

    /** Starts the incrementation from the current value to toValue */
    public func incrementFromCurrentValueToValue(toValue: Float, duration: Float = 0.3) {
        startIncrementationFromValue(currentValue(), toValue: toValue, duration: duration)
    }

    /** Starts the incrementation from zero to toValue */
    public func incrementFromZero(toValue: Float, duration: Float = 0.3) {
        startIncrementationFromValue(0.0, toValue: toValue, duration: duration)
    }
    
    // MARK: Private properties
    
    private var timer: NSTimer?
    private var fromValue: Float = 0.0
    private var toValue: Float = 0.0
    
    private var duration: NSTimeInterval = 0.3
    private var progress: NSTimeInterval = 0.0
    private var lastUpdate: NSTimeInterval = 0.0

    // MARK: Private methods

    private func startIncrementationFromValue(fromValue: Float, toValue: Float, duration: Float) {
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = Double(duration)
        progress = 0
        lastUpdate = NSDate.timeIntervalSinceReferenceDate()
        
        self.timer?.invalidate()
        self.timer = nil
        
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(1.0/30.0, target: self, selector: "incrementValue:", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: UITrackingRunLoopMode)
        self.timer = timer
    }

    @objc private func incrementValue(sender: NSTimer) {
        let now = NSDate.timeIntervalSinceReferenceDate()
        progress += now - lastUpdate
        lastUpdate = now
        if progress >= duration {
            timer?.invalidate()
            timer = nil
            progress = duration
        }
        
        updateText()
        if progress == duration,
             let nonNilCompletion = incrementationCompletion {
                nonNilCompletion()
        }
    }
    
    private func updateText() {
        if let formatStringClosure = stringFormatter {
            text = formatStringClosure(currentValue())
        } else if let attributedTextClosure = attributedTextFormatter {
            attributedText = attributedTextClosure(currentValue())
        } else {
            let formatRange = Range<String.Index>(start: format.startIndex, end: format.endIndex)
            if format.rangeOfString("%(.*)(d|i)", options: .RegularExpressionSearch, range: formatRange) ==  formatRange {
                text = String(format: format, Int(currentValue()))
            } else {
                text = String(format: format, currentValue())
            }
        }
    }
    
}

private extension IncrementableLabel {
    
    // MARK: NextValue
    
    func nextValueForCurrentOption(value: Float) -> Float {
        switch option {
        case .Linear: return nextValueForLinearOption(value)
        case .EaseIn: return nextValueForEaseInOption(value)
        case .EaseOut: return nextValueForEaseInOutOption(value)
        case .EaseInOut: return nextValueForEaseInOutOption(value)
        }
    }
    
    func nextValueForLinearOption(value: Float) -> Float {
        return value
    }
    
    func nextValueForEaseInOption(value: Float) -> Float {
        return powf(value, easingRate)
    }
    
    func nextValueForEaseOutOption(value: Float) -> Float {
        return 1.0 - powf(1.0 - value, easingRate)
    }
    
    func nextValueForEaseInOutOption(var value: Float) -> Float {
        let sign: Float = easingRate % 2 == 0 ?  -1 : 1
        value *= 2
        if value < 1 {
            return 0.5 * powf(value, easingRate)
        }
        return sign * 0.5 * (powf(value - 2, easingRate) + sign * 2)
    }
}
